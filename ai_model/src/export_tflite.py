import json
import shutil
import tensorflow as tf
from pathlib import Path

try:
    from .config import (
        MODELS_DIR, KERAS_MODEL_NAME, TFLITE_MODEL_NAME,
        LABELS_FILE_NAME, METADATA_FILE_NAME
    )
except ImportError:
    from config import (
        MODELS_DIR, KERAS_MODEL_NAME, TFLITE_MODEL_NAME,
        LABELS_FILE_NAME, METADATA_FILE_NAME
    )


def export_to_tflite():
    keras_path = MODELS_DIR / KERAS_MODEL_NAME
    tflite_path = MODELS_DIR / TFLITE_MODEL_NAME

    if not keras_path.exists():
        print(f"Error: {keras_path} does not exist.")
        return

    print(f"Loading Keras model from {keras_path}...")
    model = tf.keras.models.load_model(keras_path)

    print("Converting to TensorFlow Lite format (with Default optimizations)...")
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    tflite_model = converter.convert()

    with open(tflite_path, "wb") as f:
        f.write(tflite_model)
    print(f"Successfully exported TFLite model to: {tflite_path}")
    print(f"Model size: {len(tflite_model) / (1024 * 1024):.2f} MB")

    # Generate metadata file
    metadata = {
        "model_name": "AgriCare AI Leaf Disease Detector",
        "model_version": "1.0.0",
        "architecture": "MobileNetV2",
        "input_width": 224,
        "input_height": 224,
        "input_channels": 3,
        "color_order": "RGB",
        "input_normalization": "mobilenet_v2_minus1_to_plus1",
        "output_activation": "softmax",
        "labels_file": "labels.json",
        "exported_at": "2026-11-12T00:00:00Z"
    }

    meta_path = MODELS_DIR / METADATA_FILE_NAME
    with open(meta_path, "w", encoding="utf-8") as f:
        json.dump(metadata, f, indent=2)
    print(f"Saved metadata to: {meta_path}")

    # Copy to flutter assets
    flutter_assets_models = Path(__file__).resolve().parent.parent.parent / "assets" / "models"
    flutter_assets_models.mkdir(parents=True, exist_ok=True)
    shutil.copy(tflite_path, flutter_assets_models / TFLITE_MODEL_NAME)
    shutil.copy(MODELS_DIR / LABELS_FILE_NAME, flutter_assets_models / LABELS_FILE_NAME)
    shutil.copy(meta_path, flutter_assets_models / METADATA_FILE_NAME)
    print(f"Copied TFLite artifacts to Flutter app: {flutter_assets_models}")


if __name__ == "__main__":
    export_to_tflite()

