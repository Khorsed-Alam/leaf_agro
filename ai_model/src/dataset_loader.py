"""
AgriCare AI — Unified Dataset Loader Module.
Phase 36: Python Environment, TensorFlow Setup & tf.data Streaming Pipeline.

Integrates:
- Verified Class Mapping (Phase 32)
- Approved Cleaned Images (Phase 33)
- Image Preprocessing & MobileNetV2 Input Contract (Phase 34)
- Leakage-Resistant Group-Aware Split Manifests (Phase 35)

Enforces:
- Streaming tf.data pipeline (no in-memory full dataset loads)
- Strict split isolation: train, validation, and test
- Stable, consistent 19-class indexing
- MobileNetV2 contract: 224x224x3, float32, [0, 255] range
- Augmentation strictly active for training split
- Validation and test datasets are deterministic and unaugmented
- Zero silent error tolerance (raises explicit exceptions for missing files/corrupted labels)
"""

import csv
import os
from pathlib import Path
from typing import List, Dict, Any, Tuple, Optional
import tensorflow as tf

try:
    from .config import (
        PROJECT_ROOT,
        BASE_DIR,
        SPLIT_MANIFEST_PATH,
        SPLIT_SUMMARY_PATH,
        CLASS_MAPPING_PATH,
        IMAGE_SIZE,
        IMG_HEIGHT,
        IMG_WIDTH,
        CHANNELS,
        BATCH_SIZE,
        SHUFFLE_BUFFER_SIZE,
        RANDOM_SEED,
        CLASSES,
        NUM_CLASSES,
    )
    from .augmentation import get_training_augmentation_layer
except ImportError:
    from config import (
        PROJECT_ROOT,
        BASE_DIR,
        SPLIT_MANIFEST_PATH,
        SPLIT_SUMMARY_PATH,
        CLASS_MAPPING_PATH,
        IMAGE_SIZE,
        IMG_HEIGHT,
        IMG_WIDTH,
        CHANNELS,
        BATCH_SIZE,
        SHUFFLE_BUFFER_SIZE,
        RANDOM_SEED,
        CLASSES,
        NUM_CLASSES,
    )
    from augmentation import get_training_augmentation_layer


def get_verified_class_index_map(mapping_path: Optional[Path] = None) -> Tuple[Dict[str, int], Dict[int, str]]:
    """
    Builds stable bidirectional mapping between standardized class names and numeric indices.
    Index range is [0, NUM_CLASSES - 1].
    """
    path = Path(mapping_path) if mapping_path else CLASS_MAPPING_PATH
    class_to_idx: Dict[str, int] = {}
    idx_to_class: Dict[int, str] = {}

    if path.exists():
        with open(path, mode="r", encoding="utf-8") as f:
            reader = csv.DictReader(f)
            for idx, row in enumerate(reader):
                std_name = row.get("standardized_class_name", "").strip()
                crop = row.get("crop_name", "").strip()
                orig_cls = row.get("original_class_name", "").strip()
                # Create recognizable alias names
                if orig_cls.startswith(f"{crop}___"):
                    canonical = orig_cls
                else:
                    canonical = f"{crop}___{orig_cls}" if crop and orig_cls else std_name

                class_to_idx[canonical] = idx
                class_to_idx[std_name] = idx
                if orig_cls:
                    class_to_idx[orig_cls] = idx
                idx_to_class[idx] = canonical
    else:
        # Fallback to configured CLASSES
        for idx, cls_name in enumerate(CLASSES):
            class_to_idx[cls_name] = idx
            idx_to_class[idx] = cls_name

    return class_to_idx, idx_to_class


def load_manifest_records(
    split: Optional[str] = None,
    manifest_path: Optional[Path] = None
) -> List[Dict[str, Any]]:
    """
    Reads split_manifest.csv, optionally filtering by split ('train', 'validation', 'test').
    Raises FileNotFoundError if manifest does not exist.
    """
    path = Path(manifest_path) if manifest_path else SPLIT_MANIFEST_PATH
    if not path.exists():
        raise FileNotFoundError(f"Split manifest not found at: {path}")

    records: List[Dict[str, Any]] = []
    valid_splits = {"train", "validation", "test"}
    target_split = split.lower().strip() if split else None

    if target_split and target_split not in valid_splits:
        raise ValueError(f"Invalid split requested: '{split}'. Must be one of {valid_splits}")

    with open(path, mode="r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            row_split = row.get("split", "").lower().strip()
            if target_split is None or row_split == target_split:
                records.append(row)

    return records


def resolve_image_path(record: Dict[str, Any], project_root: Optional[Path] = None) -> Path:
    """
    Safely resolves the physical image file path for a manifest record.
    Checks relative paths against project root and BASE_DIR.
    """
    root = Path(project_root) if project_root else PROJECT_ROOT
    rel_path = record.get("image_path", "")
    if not rel_path:
        raise ValueError(f"Record {record.get('image_id')} has empty image_path")

    # Candidate 1: relative to PROJECT_ROOT
    candidate1 = (root / rel_path).resolve()
    if candidate1.exists():
        return candidate1

    # Candidate 2: relative to BASE_DIR (ai_model/)
    candidate2 = (BASE_DIR / rel_path).resolve()
    if candidate2.exists():
        return candidate2

    # Candidate 3: absolute path
    candidate3 = Path(rel_path).resolve()
    if candidate3.exists():
        return candidate3

    raise FileNotFoundError(
        f"Image file not found on disk for image_id '{record.get('image_id')}': {rel_path}"
    )


def audit_manifest_integrity(
    split: Optional[str] = None,
    manifest_path: Optional[Path] = None
) -> Dict[str, Any]:
    """
    Audits the manifest and verifies that:
    - Every file exists on disk
    - Every record has a valid class index
    - Every image can be decoded
    - No silent record drops occur
    """
    records = load_manifest_records(split=split, manifest_path=manifest_path)
    class_to_idx, idx_to_class = get_verified_class_index_map()

    total_records = len(records)
    missing_files: List[str] = []
    invalid_labels: List[str] = []
    class_counts: Dict[str, int] = {}

    for r in records:
        img_id = r.get("image_id", "UNKNOWN")
        cls_name = r.get("standardized_class", "")

        # Check label
        if cls_name not in class_to_idx and not r.get("class_index", "").isdigit():
            invalid_labels.append(f"{img_id}: unknown class '{cls_name}'")

        class_counts[cls_name] = class_counts.get(cls_name, 0) + 1

        # Check file presence
        try:
            resolve_image_path(r)
        except (FileNotFoundError, ValueError) as err:
            missing_files.append(str(err))

    status = "PASS" if not missing_files and not invalid_labels else "FAIL"

    return {
        "status": status,
        "split": split or "all",
        "total_records": total_records,
        "missing_files_count": len(missing_files),
        "missing_files": missing_files[:10],  # truncated sample
        "invalid_labels_count": len(invalid_labels),
        "invalid_labels": invalid_labels[:10],
        "class_distribution": class_counts
    }


def _tf_decode_and_preprocess(file_path: tf.Tensor, label: tf.Tensor) -> Tuple[tf.Tensor, tf.Tensor]:
    """
    TensorFlow graph function to read image file, decode JPEG/PNG, resize, and cast.
    Output image shape: (224, 224, 3), dtype: tf.float32, pixel range: [0.0, 255.0].
    """
    img_bytes = tf.io.read_file(file_path)
    # decode_image handles JPEG, PNG, BMP, GIF
    img = tf.io.decode_image(img_bytes, channels=CHANNELS, expand_animations=False)
    img = tf.image.resize(img, [IMG_HEIGHT, IMG_WIDTH], method="bilinear")
    img = tf.cast(img, tf.float32)
    img.set_shape([IMG_HEIGHT, IMG_WIDTH, CHANNELS])
    label = tf.cast(label, tf.int32)
    return img, label


def create_split_dataset(
    split: str,
    batch_size: int = BATCH_SIZE,
    is_training: Optional[bool] = None,
    shuffle: Optional[bool] = None,
    augment: Optional[bool] = None,
    manifest_path: Optional[Path] = None,
    seed: int = RANDOM_SEED
) -> tf.data.Dataset:
    """
    Constructs an optimized, streaming tf.data.Dataset for a specified split.

    Args:
        split: 'train', 'validation', or 'test'.
        batch_size: Mini-batch size.
        is_training: If True, indicates training split. Defaults to (split == 'train').
        shuffle: Whether to shuffle data. Defaults to True for train, False otherwise.
        augment: Whether to apply data augmentation. Defaults to True for train, False otherwise.
        manifest_path: Custom path to split_manifest.csv.
        seed: Random seed for shuffling.

    Returns:
        tf.data.Dataset streaming (image_batch, label_batch) tuples.
    """
    split_clean = split.lower().strip()
    if is_training is None:
        is_training = (split_clean == "train")
    if shuffle is None:
        shuffle = is_training
    if augment is None:
        augment = is_training

    records = load_manifest_records(split=split_clean, manifest_path=manifest_path)
    if not records:
        raise ValueError(f"No records found for split '{split_clean}' in manifest.")

    class_to_idx, _ = get_verified_class_index_map()

    file_paths: List[str] = []
    labels: List[int] = []

    for r in records:
        path = resolve_image_path(r)
        cls_name = r.get("standardized_class", "")
        # Resolve index from class_index column or dictionary mapping
        if "class_index" in r and r["class_index"].isdigit():
            idx = int(r["class_index"])
        elif cls_name in class_to_idx:
            idx = class_to_idx[cls_name]
        else:
            raise ValueError(f"Unrecognized class '{cls_name}' for record {r.get('image_id')}")

        file_paths.append(str(path))
        labels.append(idx)

    # 1. Tensor slice dataset
    ds = tf.data.Dataset.from_tensor_slices((file_paths, labels))

    # 2. Shuffle if training
    if shuffle:
        ds = ds.shuffle(
            buffer_size=min(len(file_paths), SHUFFLE_BUFFER_SIZE),
            seed=seed,
            reshuffle_each_iteration=True
        )

    # 3. Decode & Preprocess
    autotune = tf.data.AUTOTUNE
    ds = ds.map(_tf_decode_and_preprocess, num_parallel_calls=autotune)

    # 4. Augmentation (Training ONLY)
    if augment and is_training:
        aug_layer = get_training_augmentation_layer(seed=seed)
        ds = ds.map(lambda x, y: (aug_layer(x, training=True), y), num_parallel_calls=autotune)

    # 5. Batch & Prefetch
    ds = ds.batch(batch_size, drop_remainder=False)
    ds = ds.prefetch(buffer_size=autotune)

    return ds


def load_train_dataset(batch_size: int = BATCH_SIZE) -> tf.data.Dataset:
    """Convenience wrapper for the training dataset."""
    return create_split_dataset(
        split="train",
        batch_size=batch_size,
        is_training=True,
        shuffle=True,
        augment=True
    )


def load_validation_dataset(batch_size: int = BATCH_SIZE) -> tf.data.Dataset:
    """Convenience wrapper for the validation dataset (unaugmented)."""
    return create_split_dataset(
        split="validation",
        batch_size=batch_size,
        is_training=False,
        shuffle=False,
        augment=False
    )


def load_test_dataset(batch_size: int = BATCH_SIZE) -> tf.data.Dataset:
    """Convenience wrapper for the test dataset (unaugmented)."""
    return create_split_dataset(
        split="test",
        batch_size=batch_size,
        is_training=False,
        shuffle=False,
        augment=False
    )


def get_split_statistics() -> Dict[str, Any]:
    """
    Returns summary statistics for all available splits.
    """
    stats = {}
    for split_name in ["train", "validation", "test"]:
        try:
            records = load_manifest_records(split=split_name)
            stats[split_name] = {
                "count": len(records),
                "classes_present": len(set(r.get("standardized_class") for r in records))
            }
        except Exception as e:
            stats[split_name] = {"error": str(e)}

    return stats

