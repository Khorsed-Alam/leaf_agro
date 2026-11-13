"""
AgriCare AI — TensorFlow Lite Model Validation Module.
Phase 40: TensorFlow Lite Model Export & Optimization.

Performs rigorous tensor validation and inference verification across all exported TFLite models:
- Interpreter initialization and tensor allocation
- Input/output shape and dtype verification (1, 224, 224, 3) -> (1, 19)
- Numerical sanity: finite values, bounds in [0.0, 1.0], softmax sum ~ 1.0
- Validation split inference verification across representative validation samples
- Identification of quantization parameters and tensor metadata
"""

import json
from pathlib import Path
from typing import Dict, Any, List, Tuple
import numpy as np
import tensorflow as tf

try:
    from .config import (
        MODELS_DIR,
        REPORTS_DIR,
        NUM_CLASSES,
        RANDOM_SEED,
        set_reproducibility,
    )
    from .dataset_loader import (
        load_manifest_records,
        load_validation_dataset,
        get_verified_class_index_map,
    )
except ImportError:
    from config import (
        MODELS_DIR,
        REPORTS_DIR,
        NUM_CLASSES,
        RANDOM_SEED,
        set_reproducibility,
    )
    from dataset_loader import (
        load_manifest_records,
        load_validation_dataset,
        get_verified_class_index_map,
    )


def validate_single_tflite_model(
    tflite_path: Path,
    val_images: tf.Tensor,
    val_labels: np.ndarray,
    expected_num_classes: int = NUM_CLASSES
) -> Dict[str, Any]:
    """
    Validates an individual TFLite model file against standard mobile deployment contracts.
    """
    path = Path(tflite_path)
    if not path.exists():
        return {
            "model_file": path.name,
            "status": "FAIL",
            "error": f"File does not exist: {path}"
        }

    # 1. Interpreter Initialization
    try:
        interpreter = tf.lite.Interpreter(model_path=str(path))
        interpreter.allocate_tensors()
    except Exception as e:
        return {
            "model_file": path.name,
            "status": "FAIL",
            "error": f"Interpreter initialization failure: {str(e)}"
        }

    input_details = interpreter.get_input_details()[0]
    output_details = interpreter.get_output_details()[0]

    input_shape = input_details["shape"].tolist()
    output_shape = output_details["shape"].tolist()
    input_dtype = str(np.dtype(input_details["dtype"]))
    output_dtype = str(np.dtype(output_details["dtype"]))

    # 2. Contract Verification
    checks = {
        "input_channels_is_3": input_shape[-1] == 3,
        "input_spatial_224x224": input_shape[1:3] == [224, 224],
        "output_classes_matches": output_shape[-1] == expected_num_classes,
        "input_is_float32": "float32" in input_dtype,
        "output_is_float32": "float32" in output_dtype
    }

    # 3. Validation Inference Loop across Validation Set Images
    num_samples = len(val_images)
    finite_check = True
    bounds_check = True
    sum_one_check = True
    index_valid_check = True

    predictions = []
    confidences = []

    for i in range(num_samples):
        # Prepare single image batch (1, 224, 224, 3)
        img_tensor = tf.expand_dims(val_images[i], axis=0).numpy().astype(np.float32)

        interpreter.set_tensor(input_details["index"], img_tensor)
        interpreter.invoke()
        output_data = interpreter.get_tensor(output_details["index"])[0]

        # Check finite
        if not np.all(np.isfinite(output_data)):
            finite_check = False
        # Check bounds
        if np.any(output_data < -1e-5) or np.any(output_data > 1.0 + 1e-5):
            bounds_check = False
        # Check softmax sum
        prob_sum = float(np.sum(output_data))
        if abs(prob_sum - 1.0) > 0.05:  # Tolerate small quantization deviations
            sum_one_check = False

        pred_idx = int(np.argmax(output_data))
        if pred_idx < 0 or pred_idx >= expected_num_classes:
            index_valid_check = False

        predictions.append(pred_idx)
        confidences.append(float(output_data[pred_idx]))

    # Accuracy on validation set
    accuracy = float(np.mean(np.array(predictions) == val_labels))

    all_passed = (
        all(checks.values()) and
        finite_check and bounds_check and
        sum_one_check and index_valid_check
    )

    return {
        "model_file": path.name,
        "file_size_bytes": path.stat().st_size,
        "file_size_mb": round(path.stat().st_size / (1024 * 1024), 2),
        "status": "PASS" if all_passed else "FAIL",
        "input_details": {
            "name": input_details["name"],
            "shape": input_shape,
            "dtype": input_dtype,
            "quantization": input_details.get("quantization", (0.0, 0))
        },
        "output_details": {
            "name": output_details["name"],
            "shape": output_shape,
            "dtype": output_dtype,
            "quantization": output_details.get("quantization", (0.0, 0))
        },
        "assertions": {
            **checks,
            "outputs_finite": finite_check,
            "outputs_bounded_zero_to_one": bounds_check,
            "softmax_sums_to_one": sum_one_check,
            "predicted_indices_within_range": index_valid_check
        },
        "validation_samples_tested": num_samples,
        "validation_empirical_accuracy": round(accuracy, 4),
        "mean_confidence": round(float(np.mean(confidences)), 4)
    }


def run_all_tflite_validations(
    models_dir: Path = MODELS_DIR
) -> Dict[str, Any]:
    """
    Validates all candidate TFLite models in the models directory.
    """
    set_reproducibility(RANDOM_SEED)

    # Load validation dataset (14 unaugmented images)
    val_records = load_manifest_records(split="validation")
    val_ds = load_validation_dataset(batch_size=len(val_records))
    val_images, val_labels = next(iter(val_ds))
    val_labels_np = val_labels.numpy()

    candidate_files = [
        models_dir / "plant_disease_model.tflite",
        models_dir / "plant_disease_model_fp16.tflite",
        models_dir / "plant_disease_model_int8.tflite"
    ]

    results = {}
    for path in candidate_files:
        if path.exists():
            print(f"Validating TFLite Model: {path.name}...")
            res = validate_single_tflite_model(
                tflite_path=path,
                val_images=val_images,
                val_labels=val_labels_np
            )
            results[path.name] = res
            status_str = "[PASS]" if res["status"] == "PASS" else "[FAIL]"
            print(f"  {status_str} {path.name}: Size {res['file_size_mb']} MB | Val Acc: {res['validation_empirical_accuracy']*100:.1f}%")

    return results


if __name__ == "__main__":
    results = run_all_tflite_validations()
    print("\nValidation Summary:")
    print(json.dumps(results, indent=2))
