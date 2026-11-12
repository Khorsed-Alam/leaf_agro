import os
from pathlib import Path

# Base Paths
BASE_DIR = Path(__file__).resolve().parent.parent
DATASET_DIR = BASE_DIR / "dataset"
RAW_DATASET_DIR = DATASET_DIR / "raw"
PROCESSED_DATASET_DIR = DATASET_DIR / "processed"

TRAIN_DIR = PROCESSED_DATASET_DIR / "train"
VAL_DIR = PROCESSED_DATASET_DIR / "validation"
TEST_DIR = PROCESSED_DATASET_DIR / "test"

MODELS_DIR = BASE_DIR / "models"
REPORTS_DIR = BASE_DIR / "reports"

# Model Hyperparameters
IMG_HEIGHT = 224
IMG_WIDTH = 224
IMG_SIZE = (IMG_HEIGHT, IMG_WIDTH)
CHANNELS = 3
BATCH_SIZE = 32
INITIAL_EPOCHS = 20
FINE_TUNE_EPOCHS = 15
TOTAL_EPOCHS = INITIAL_EPOCHS + FINE_TUNE_EPOCHS

INITIAL_LEARNING_RATE = 1e-3
FINE_TUNE_LEARNING_RATE = 1e-5

# Model Export Names
KERAS_MODEL_NAME = "best_model.keras"
TFLITE_MODEL_NAME = "plant_disease_model.tflite"
LABELS_FILE_NAME = "labels.json"
METADATA_FILE_NAME = "model_metadata.json"

# Supported target classes for Bangladesh + PlantVillage crops
CLASSES = [
    # Rice
    "Rice___Bacterial_leaf_blight",
    "Rice___Brown_spot",
    "Rice___Leaf_smut",
    "Rice___healthy",
    # Potato
    "Potato___Early_blight",
    "Potato___Late_blight",
    "Potato___healthy",
    # Tomato
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
    # Jute
    "Jute___Stem_rot",
    "Jute___Anthracnose",
    "Jute___healthy"
]

NUM_CLASSES = len(CLASSES)

