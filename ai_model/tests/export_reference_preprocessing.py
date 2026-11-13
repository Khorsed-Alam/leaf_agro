"""
AgriCare AI — Export Reference Preprocessed Tensors for Flutter Parity Verification.
Phase 43: Python vs Flutter Image Preprocessing Parity Test.

Selects an approved validation leaf image from the dataset, runs the official Phase 34
preprocessing pipeline (load, decode, RGB convert, bilinear resize to 224x224),
runs inference with plant_disease_model.tflite, and exports reference data for
direct numerical comparison in Dart.
"""

import json
import os
import shutil
import sys
from pathlib import Path

# Redirect environment caches inside the workspace
project_root = Path(__file__).resolve().parents[2]
os.environ["KERAS_HOME"] = str(project_root / "ai_model" / ".keras")
os.environ["MPLCONFIGDIR"] = str(project_root / "ai_model" / ".mplconfig")
os.environ["TF_CPP_MIN_LOG_LEVEL"] = "2"
sys.path.insert(0, str(project_root))

import numpy as np
import tensorflow as tf

from ai_model.src.config import (
    PROJECT_ROOT,
    MODELS_DIR,
    LABELS_PATH,
)
from ai_model.src.preprocessing import (
    prepare_single_image,
    load_image,
    convert_to_rgb,
    resize_image,
)
from ai_model.src.export_tflite import TFLITE_FLOAT32_PATH


def export_reference_sample():
    # 1. Target reference image from split_manifest
    ref_src = (
        PROJECT_ROOT
        / "ai_model"
        / "dataset"
        / "processed"
        / "validation"
        / "Potato___Early_blight"
        / "009c8c31-f22d-4ffd-8f16-189c6f06c577___RS_Early.B 7885.JPG"
    )

    if not ref_src.exists():
        # Fallback to any valid jpg in processed dataset
        candidates = list((PROJECT_ROOT / "ai_model" / "dataset" / "processed").rglob("*.JPG")) + \
                     list((PROJECT_ROOT / "ai_model" / "dataset" / "processed").rglob("*.jpg"))
        if not candidates:
            raise FileNotFoundError("No dataset sample images found.")
        ref_src = candidates[0]

    fixtures_dir = PROJECT_ROOT / "test" / "fixtures"
    fixtures_dir.mkdir(parents=True, exist_ok=True)

    dest_image_path = fixtures_dir / "reference_leaf.jpg"
    shutil.copyfile(ref_src, dest_image_path)
    print(f"Copied reference image to: {dest_image_path}")

    # 2. Phase 34 Preprocessing (for_model_input=True keeps [0.0, 255.0] Float32 range)
    # Shape: (1, 224, 224, 3)
    py_tensor = prepare_single_image(str(ref_src), target_size=(224, 224), for_model_input=True)
    flat_tensor = py_tensor[0].flatten().astype(np.float32)

    # 3. Execute reference TFLite inference
    interpreter = tf.lite.Interpreter(model_path=str(TFLITE_FLOAT32_PATH))
    interpreter.allocate_tensors()

    input_details = interpreter.get_input_details()[0]
    output_details = interpreter.get_output_details()[0]

    interpreter.set_tensor(input_details["index"], py_tensor)
    interpreter.invoke()
    py_probabilities = interpreter.get_tensor(output_details["index"])[0].tolist()

    top_class_idx = int(np.argmax(py_probabilities))
    top_confidence = float(py_probabilities[top_class_idx])

    # 4. Read class labels
    with open(LABELS_PATH, "r", encoding="utf-8") as f:
        labels_data = json.load(f)
    top_class_name = labels_data["class_names"][top_class_idx]

    # 5. Export preprocessed tensor as binary float32 file for fast, exact comparison
    tensor_bin_path = fixtures_dir / "python_tensor_150528_f32.bin"
    flat_tensor.tofile(tensor_bin_path)

    # 6. Export metadata and probabilities as JSON
    meta_path = fixtures_dir / "reference_preprocessing_manifest.json"
    manifest = {
        "source_image": str(ref_src.name),
        "target_size": [224, 224, 3],
        "tensor_dtype": "float32",
        "tensor_shape": [1, 224, 224, 3],
        "tensor_length": int(flat_tensor.size),
        "tensor_min": float(flat_tensor.min()),
        "tensor_max": float(flat_tensor.max()),
        "tensor_mean": float(flat_tensor.mean()),
        "tensor_sample_indices": [0, 1, 2, 1000, 50000, 100000, 150527],
        "tensor_sample_values": [float(flat_tensor[i]) for i in [0, 1, 2, 1000, 50000, 100000, 150527]],
        "top_class_index": top_class_idx,
        "top_class_name": top_class_name,
        "top_confidence": top_confidence,
        "probabilities": py_probabilities,
    }

    with open(meta_path, "w", encoding="utf-8") as f:
        json.dump(manifest, f, indent=2)

    print(f"Saved reference tensor binary: {tensor_bin_path}")
    print(f"Saved reference manifest: {meta_path}")
    print(f"Top prediction: #{top_class_idx} {top_class_name} ({top_confidence * 100:.2f}%)")


if __name__ == "__main__":
    export_reference_sample()
