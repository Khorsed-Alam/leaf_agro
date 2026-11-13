"""
AgriCare AI — Machine Learning Pipeline Configuration.
Phase 34: Image Preprocessing, Normalization & Data Augmentation.
"""

import os
from pathlib import Path

# Base Directory Paths
SRC_DIR = Path(__file__).resolve().parent
BASE_DIR = SRC_DIR.parent
PROJECT_ROOT = BASE_DIR.parent

DATASET_DIR = BASE_DIR / "dataset"
RAW_DATASET_DIR = DATASET_DIR / "raw"
PROCESSED_DATASET_DIR = DATASET_DIR / "processed"

APPROVED_IMAGES_DIR = PROCESSED_DATASET_DIR / "approved" / "images"
QUARANTINE_IMAGES_DIR = PROCESSED_DATASET_DIR / "quarantine" / "images"
REJECTED_IMAGES_DIR = PROCESSED_DATASET_DIR / "rejected" / "images"
METADATA_DIR = DATASET_DIR / "metadata"

MODELS_DIR = BASE_DIR / "models"
REPORTS_DIR = BASE_DIR / "reports"
VISUALIZATIONS_DIR = BASE_DIR / "visualizations"
TESTS_DIR = BASE_DIR / "tests"

# Backward compatibility paths for future train/val/test splits (Phase 35)
TRAIN_DIR = PROCESSED_DATASET_DIR / "train"
VAL_DIR = PROCESSED_DATASET_DIR / "validation"
TEST_DIR = PROCESSED_DATASET_DIR / "test"

# Image Preprocessing & MobileNetV2 Dimensions
IMG_HEIGHT = 224
IMG_WIDTH = 224
IMAGE_SIZE = (IMG_HEIGHT, IMG_WIDTH)
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

# Batch & tf.data Configuration
BATCH_SIZE = 32
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

# Supported target classes for Bangladesh + PlantVillage crops (19 classes)
CLASSES = [
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

NUM_CLASSES = len(CLASSES)
