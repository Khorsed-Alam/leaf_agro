"""
AgriCare AI — Machine Learning Pipeline Configuration.
Phase 36: Python Environment, TensorFlow Setup & Reproducible Configuration.

Provides centralized, cross-platform configuration using pathlib:
- Directory paths and file locations
- Image dimensions and MobileNetV2 preprocessing constants
- Dynamic verified class mapping resolution
- Seed-controlled reproducibility configuration
"""

import csv
import os
import random
from pathlib import Path
from typing import List, Dict, Any, Tuple

# Base Directory Paths (Resolved relative to this file)
SRC_DIR = Path(__file__).resolve().parent
BASE_DIR = SRC_DIR.parent
PROJECT_ROOT = BASE_DIR.parent

# Dataset Directories
DATASET_DIR = BASE_DIR / "dataset"
DATASET_ROOT = DATASET_DIR
RAW_DATASET_DIR = DATASET_DIR / "raw"
PROCESSED_DATASET_DIR = DATASET_DIR / "processed"

APPROVED_IMAGES_DIR = PROCESSED_DATASET_DIR / "approved" / "images"
QUARANTINE_IMAGES_DIR = PROCESSED_DATASET_DIR / "quarantine" / "images"
REJECTED_IMAGES_DIR = PROCESSED_DATASET_DIR / "rejected" / "images"

# Metadata Directories
METADATA_DIR = DATASET_DIR / "metadata"
DATASET_METADATA_DIR = METADATA_DIR
PROCESSED_METADATA_DIR = PROCESSED_DATASET_DIR / "metadata"

# Dataset Splits & Manifest Paths (Phase 35 Artifacts)
TRAIN_DIR = PROCESSED_DATASET_DIR / "train"
VAL_DIR = PROCESSED_DATASET_DIR / "validation"
VALIDATION_DIR = VAL_DIR
TEST_DIR = PROCESSED_DATASET_DIR / "test"

SPLIT_MANIFEST_PATH = PROCESSED_METADATA_DIR / "split_manifest.csv"
SPLIT_SUMMARY_PATH = PROCESSED_METADATA_DIR / "split_summary.csv"
SPLIT_CONFIG_PATH = PROCESSED_METADATA_DIR / "split_config.json"
CLASS_MAPPING_PATH = METADATA_DIR / "verified_class_mapping.csv"

# Project Artifact Directories
MODELS_DIR = BASE_DIR / "models"
MODEL_OUTPUT_DIR = MODELS_DIR
REPORTS_DIR = BASE_DIR / "reports"
REPORT_OUTPUT_DIR = REPORTS_DIR
VISUALIZATIONS_DIR = BASE_DIR / "visualizations"
TESTS_DIR = BASE_DIR / "tests"
DOCUMENTATION_DIR = BASE_DIR / "documentation"
NOTEBOOKS_DIR = BASE_DIR / "notebooks"

# Image Preprocessing & MobileNetV2 Dimensions
IMG_HEIGHT = 224
IMG_WIDTH = 224
IMAGE_SIZE: Tuple[int, int] = (IMG_HEIGHT, IMG_WIDTH)
IMG_SIZE = IMAGE_SIZE
IMAGE_CHANNELS = 3
CHANNELS = IMAGE_CHANNELS
IMAGE_DTYPE = "float32"
INTERPOLATION_METHOD = "bilinear"

# Input Contract
EXTERNAL_PIXEL_MIN = 0.0
EXTERNAL_PIXEL_MAX = 255.0
NORMALIZED_PIXEL_MIN = -1.0
NORMALIZED_PIXEL_MAX = 1.0
MOBILENETV2_RESCALING_SCALE = 1.0 / 127.5
MOBILENETV2_RESCALING_OFFSET = -1.0

# Batch & Execution Configuration
# Default 16 for memory-safe execution on Windows CPU / 16GB RAM setups; configurable via env
DEFAULT_BATCH_SIZE = int(os.environ.get("AGRICARE_BATCH_SIZE", 16))
BATCH_SIZE = DEFAULT_BATCH_SIZE
SHUFFLE_BUFFER_SIZE = 1000
RANDOM_SEED = 42
MOBILENETV2_ALPHA = 1.0
PREFETCH_BUFFER = "AUTOTUNE"
CACHE_DATASET = False
AUGMENTATION_ENABLED = True

# Training-Only Augmentation Parameters (Agricultural Focus)
AUG_HORIZONTAL_FLIP = True
AUG_ROTATION_FACTOR = 0.03       # ~10 degrees
AUG_ZOOM_LOWER = -0.10          # 0.90x zoom
AUG_ZOOM_UPPER = 0.10           # 1.10x zoom
AUG_TRANSLATION_HEIGHT = 0.05   # +/- 5% vertical shift
AUG_TRANSLATION_WIDTH = 0.05    # +/- 5% horizontal shift
AUG_BRIGHTNESS_FACTOR = 0.10    # +/- 10% brightness variation
AUG_CONTRAST_FACTOR = 0.10      # +/- 10% contrast variation

# Model Hyperparameters (for training phases)
INITIAL_EPOCHS = 20
FINE_TUNE_EPOCHS = 15
TOTAL_EPOCHS = INITIAL_EPOCHS + FINE_TUNE_EPOCHS
INITIAL_LEARNING_RATE = 1e-3
FINE_TUNE_LEARNING_RATE = 1e-5

# Model File Names
KERAS_MODEL_NAME = "best_model.keras"
TFLITE_MODEL_NAME = "plant_disease_model.tflite"
LABELS_FILE_NAME = "labels.json"
METADATA_FILE_NAME = "model_metadata.json"

# Verified Default Class List (Fallback baseline matching Phase 32 standardization)
DEFAULT_CLASSES: List[str] = [
    # Rice (BRRI)
    "Rice___Bacterial_leaf_blight",
    "Rice___Brown_spot",
    "Rice___Leaf_smut",
    "Rice___healthy",
    # Potato (BARI)
    "Potato___Early_blight",
    "Potato___Late_blight",
    "Potato___healthy",
    # Tomato (BARI)
    "Tomato___Bacterial_spot",
    "Tomato___Early_blight",
    "Tomato___Late_blight",
    "Tomato___Leaf_Mold",
    "Tomato___Septoria_leaf_spot",
    "Tomato___healthy",
    # Mango
    "Mango___Anthracnose",
    "Mango___Bacterial_canker",
    "Mango___healthy",
    # Jute (BJRI)
    "Jute___Stem_rot",
    "Jute___Anthracnose",
    "Jute___healthy"
]


def load_verified_classes(mapping_path: Path = CLASS_MAPPING_PATH) -> List[str]:
    """
    Dynamically loads verified classes from verified_class_mapping.csv.
    Falls back to DEFAULT_CLASSES if the file does not exist.
    """
    if not mapping_path.exists():
        return list(DEFAULT_CLASSES)

    try:
        loaded = []
        with open(mapping_path, mode="r", encoding="utf-8") as f:
            reader = csv.DictReader(f)
            for row in reader:
                crop = row.get("crop_name", "").strip()
                orig_cls = row.get("original_class_name", "").strip()
                # Format standard name as Crop___Disease
                if crop and orig_cls:
                    if orig_cls.startswith(f"{crop}___"):
                        loaded.append(orig_cls)
                    else:
                        loaded.append(f"{crop}___{orig_cls}")
                elif row.get("standardized_class_name"):
                    loaded.append(row["standardized_class_name"].strip())

        return loaded if loaded else list(DEFAULT_CLASSES)
    except Exception:
        return list(DEFAULT_CLASSES)


# Dynamic Classes Definition derived from verified metadata
CLASSES: List[str] = load_verified_classes()
NUM_CLASSES: int = len(CLASSES)


def validate_directories() -> Dict[str, bool]:
    """
    Validates existence of core project directories.
    Returns status map for system health reporting.
    """
    targets = {
        "PROJECT_ROOT": PROJECT_ROOT,
        "BASE_DIR": BASE_DIR,
        "DATASET_DIR": DATASET_DIR,
        "METADATA_DIR": METADATA_DIR,
        "PROCESSED_METADATA_DIR": PROCESSED_METADATA_DIR,
        "MODELS_DIR": MODELS_DIR,
        "REPORTS_DIR": REPORTS_DIR,
        "TRAIN_DIR": TRAIN_DIR,
        "VAL_DIR": VAL_DIR,
        "TEST_DIR": TEST_DIR,
    }
    return {k: p.exists() for k, p in targets.items()}


def set_reproducibility(seed: int = RANDOM_SEED) -> Dict[str, Any]:
    """
    Configures deterministic random seeds across Python, NumPy, and TensorFlow.
    Documents limitations: hardware architecture, GPU non-determinism, and parallel I/O.
    """
    status = {
        "seed": seed,
        "python_random_set": False,
        "numpy_seed_set": False,
        "tensorflow_seed_set": False,
        "op_determinism_enabled": False,
        "notes": []
    }

    # 1. Python random
    random.seed(seed)
    status["python_random_set"] = True

    # 2. NumPy
    try:
        import numpy as np
        np.random.seed(seed)
        status["numpy_seed_set"] = True
    except ImportError:
        status["notes"].append("NumPy not imported")

    # 3. TensorFlow
    try:
        import tensorflow as tf
        tf.random.set_seed(seed)
        status["tensorflow_seed_set"] = True
        try:
            tf.config.experimental.enable_op_determinism()
            status["op_determinism_enabled"] = True
        except Exception as e:
            status["notes"].append(f"enable_op_determinism notice: {str(e)}")
    except ImportError:
        status["notes"].append("TensorFlow not imported")

    return status
