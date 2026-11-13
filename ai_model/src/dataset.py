"""
AgriCare AI — Reusable tf.data Dataset Pipeline.
Phase 34: Image Preprocessing, Normalization & Data Augmentation.

Reads approved images directly from Phase 33 cleaning manifest:
  - Generates stable, deterministic label index mappings from verified class definitions
  - Decodes images to RGB, resizes to 224 x 224
  - Keeps pixel values in [0, 255] float32 range for model graph Rescaling
  - Supports training-only dynamic augmentation
  - Implements batching, prefetching, and memory-safe tf.data streams
"""

import csv
import json
from pathlib import Path
import tensorflow as tf

try:
    from .config import (
        BASE_DIR,
        APPROVED_IMAGES_DIR,
        METADATA_DIR,
        IMAGE_SIZE,
        BATCH_SIZE,
        SHUFFLE_BUFFER_SIZE,
        RANDOM_SEED,
        PREFETCH_BUFFER,
        CACHE_DATASET,
        CLASSES,
    )
    from .augmentation import get_training_augmentation_layer
except ImportError:
    from config import (
        BASE_DIR,
        APPROVED_IMAGES_DIR,
        METADATA_DIR,
        IMAGE_SIZE,
        BATCH_SIZE,
        SHUFFLE_BUFFER_SIZE,
        RANDOM_SEED,
        PREFETCH_BUFFER,
        CACHE_DATASET,
        CLASSES,
    )
    from augmentation import get_training_augmentation_layer


def load_cleaning_manifest(manifest_path=None):
    """
    Loads all records from cleaning_manifest.csv.
    """
    path = Path(manifest_path) if manifest_path else (METADATA_DIR / "cleaning_manifest.csv")
    if not path.exists():
        raise FileNotFoundError(f"Cleaning manifest not found at: {path}")

    records = []
    with open(path, mode="r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            records.append(row)
    return records


def load_verified_class_mapping(mapping_path=None):
    """
    Loads class metadata from verified_class_mapping.csv.
    """
    path = Path(mapping_path) if mapping_path else (METADATA_DIR / "verified_class_mapping.csv")
    if not path.exists():
        raise FileNotFoundError(f"Verified class mapping not found at: {path}")

    classes = []
    with open(path, mode="r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            classes.append(row)
    return classes


def discover_approved_images(manifest_path=None):
    """
    Filters cleaning_manifest.csv for APPROVED records where the processed image exists on disk.
    Returns a list of verified dictionaries.
    """
    all_records = load_cleaning_manifest(manifest_path)
    approved = []
    for r in all_records:
        if r.get("cleaning_status") == "APPROVED":
            # Check file on disk
            proc_rel = r.get("processed_file_path", "")
            # Project root is BASE_DIR.parent
            full_path = BASE_DIR.parent / proc_rel
            if full_path.exists():
                r["full_file_path"] = str(full_path)
                approved.append(r)
    return approved


def encode_labels(classes_list=None):
    """
    Generates a deterministic 1:1 mapping from class identifiers to integer indices.
    Sorts alphabetically by standardized class identifier to ensure complete stability.
    """
    if classes_list is None:
        classes_list = CLASSES

    class_names = sorted(list(set(classes_list)))
    class_to_idx = {name: idx for idx, name in enumerate(class_names)}
    idx_to_class = {idx: name for idx, name in enumerate(class_names)}
    return class_to_idx, idx_to_class


def decode_label(class_index, idx_to_class_map):
    """
    Decodes an integer class index back to its class name.
    """
    return idx_to_class_map.get(int(class_index), "UNKNOWN_CLASS")


def _parse_and_preprocess_image(file_path, label, target_size=IMAGE_SIZE):
    """
    Pure TensorFlow mapping function for tf.data pipelines.
    Reads file bytes, decodes to 3-channel RGB, resizes to target_size using bilinear interpolation,
    and casts to float32 in [0, 255] range.
    """
    img_bytes = tf.io.read_file(file_path)
    # Decode JPEG / PNG to RGB with 3 channels
    img = tf.io.decode_image(img_bytes, channels=3, expand_animations=False)
    img = tf.image.resize(img, target_size, method="bilinear")
    img = tf.cast(img, tf.float32)
    return img, label


def create_image_dataset(
    records,
    class_to_idx_map=None,
    is_training=False,
    batch_size=BATCH_SIZE,
    shuffle=False,
    seed=RANDOM_SEED,
):
    """
    Builds a high-performance, memory-safe tf.data.Dataset from approved image records.
    
    Invariants:
      - Outputs (image_tensor, one_hot_label)
      - image_tensor is float32 with values in [0.0, 255.0]
      - Augmentation is applied dynamically only when is_training is True
      - Deterministic evaluation when is_training is False
    """
    if not records:
        raise ValueError("Cannot create dataset from empty record list.")

    if class_to_idx_map is None:
        class_to_idx_map, _ = encode_labels()

    num_classes = len(class_to_idx_map)

    file_paths = []
    labels = []

    for r in records:
        file_paths.append(r["full_file_path"])
        # Match class name from record: either standardized or original PlantVillage class
        cname = r.get("original_class_name", "")
        if cname not in class_to_idx_map:
            # Check crop___class composite
            cname = f"{r.get('crop_name', '')}___{cname}"
        
        idx = class_to_idx_map.get(cname, 0)
        labels.append(idx)

    # One-hot encode labels
    labels_one_hot = tf.keras.utils.to_categorical(labels, num_classes=num_classes)

    ds = tf.data.Dataset.from_tensor_slices((file_paths, labels_one_hot))

    if shuffle or is_training:
        ds = ds.shuffle(buffer_size=min(len(file_paths), SHUFFLE_BUFFER_SIZE), seed=seed)

    # Parallel image decoding and 224x224 resizing
    ds = ds.map(
        lambda path, lbl: _parse_and_preprocess_image(path, lbl, target_size=IMAGE_SIZE),
        num_parallel_calls=tf.data.AUTOTUNE,
    )

    # Optional training-only dynamic augmentation
    if is_training:
        aug_layer = get_training_augmentation_layer(seed=seed)
        ds = ds.map(
            lambda x, y: (aug_layer(x, training=True), y),
            num_parallel_calls=tf.data.AUTOTUNE,
        )

    # Batching
    ds = ds.batch(batch_size)

    # Caching (disabled by default for memory safety)
    if CACHE_DATASET:
        ds = ds.cache()

    # Prefetch for GPU/CPU pipeline overlap
    ds = ds.prefetch(buffer_size=tf.data.AUTOTUNE)

    return ds


def create_inference_dataset(image_paths, batch_size=BATCH_SIZE):
    """
    Creates an inference-only tf.data.Dataset for unlabelled image paths.
    Outputs batches of shape (B, 224, 224, 3) in [0, 255] float32 range.
    """
    ds = tf.data.Dataset.from_tensor_slices(list(image_paths))
    ds = ds.map(
        lambda path: tf.image.resize(
            tf.cast(tf.io.decode_image(tf.io.read_file(path), channels=3, expand_animations=False), tf.float32),
            IMAGE_SIZE,
            method="bilinear"
        ),
        num_parallel_calls=tf.data.AUTOTUNE,
    )
    return ds.batch(batch_size).prefetch(buffer_size=tf.data.AUTOTUNE)


# ---------------------------------------------------------------------------
# Backward Compatibility Wrappers
# ---------------------------------------------------------------------------
def load_datasets(train_dir, val_dir, test_dir=None, batch_size=BATCH_SIZE, img_size=IMAGE_SIZE):
    """
    Backward-compatible directory-based dataset loader.
    """
    train_ds = tf.keras.utils.image_dataset_from_directory(
        train_dir, labels="categorical", image_size=img_size, batch_size=batch_size, shuffle=True, seed=42
    )
    val_ds = tf.keras.utils.image_dataset_from_directory(
        val_dir, labels="categorical", image_size=img_size, batch_size=batch_size, shuffle=False
    )
    test_ds = None
    if test_dir and Path(test_dir).exists():
        test_ds = tf.keras.utils.image_dataset_from_directory(
            test_dir, labels="categorical", image_size=img_size, batch_size=batch_size, shuffle=False
        )
    return train_ds, val_ds, test_ds, train_ds.class_names
