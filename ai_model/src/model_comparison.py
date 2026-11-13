"""
AgriCare AI — Keras vs TensorFlow Lite Prediction Comparison Module.
Phase 40: TensorFlow Lite Model Export & Optimization.

Performs side-by-side numerical and prediction agreement auditing:
- Feeds identical input tensors to Keras and TFLite models
- Computes maximum and mean absolute probability discrepancies across all 19 classes
- Verifies Top-1 class agreement across representative validation samples
- Generates ai_model/reports/prediction_comparison.csv
"""

import json
import os
from pathlib import Path
from typing import Dict, Any, List, Tuple, Optional
import numpy as np
import pandas as pd
import tensorflow as tf

try:
    from .config import (
        MODELS_DIR,
        REPORTS_DIR,
        BEST_MODEL_PATH,
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
        BEST_MODEL_PATH,
        NUM_CLASSES,
        RANDOM_SEED,
        set_reproducibility,
    )
    from dataset_loader import (
        load_manifest_records,
        load_validation_dataset,
        get_verified_class_index_map,
    )


def run_tflite_inference_single(
    interpreter: tf.lite.Interpreter,
    img_tensor: np.ndarray,
    input_index: int,
    output_index: int
) -> np.ndarray:
    """
    Executes a single-image forward pass through a prepared TFLite interpreter.
    """
    interpreter.set_tensor(input_index, img_tensor)
    interpreter.invoke()
    return interpreter.get_tensor(output_index)[0]


def compare_keras_vs_tflite(
    keras_model_path: Path = BEST_MODEL_PATH,
    tflite_paths: Optional[List[Path]] = None,
    output_csv_path: Optional[Path] = None
) -> Dict[str, Any]:
    """
    Conducts comparative analysis between Keras source model and TFLite models.
    """
    set_reproducibility(RANDOM_SEED)

    if tflite_paths is None:
        tflite_paths = [
            MODELS_DIR / "plant_disease_model.tflite",
            MODELS_DIR / "plant_disease_model_fp16.tflite",
            MODELS_DIR / "plant_disease_model_int8.tflite"
        ]

    # Load Keras Model
    keras_model = tf.keras.models.load_model(str(keras_model_path))

    # Load Validation Dataset
    val_records = load_manifest_records(split="validation")
    val_ds = load_validation_dataset(batch_size=len(val_records))
    val_images, val_labels = next(iter(val_ds))
    val_labels_np = val_labels.numpy()
    num_samples = len(val_images)

    # Class mappings
    class_to_idx, idx_to_class = get_verified_class_index_map()

    # Pre-compute Keras outputs
    keras_probs = keras_model(val_images, training=False).numpy()
    keras_preds = np.argmax(keras_probs, axis=1)

    all_comparisons = {}
    detailed_rows = []

    for tflite_path in tflite_paths:
        if not tflite_path.exists():
            continue

        model_name = tflite_path.name
        interpreter = tf.lite.Interpreter(model_path=str(tflite_path))
        interpreter.allocate_tensors()
        inp_idx = interpreter.get_input_details()[0]["index"]
        out_idx = interpreter.get_output_details()[0]["index"]

        max_diffs = []
        mean_diffs = []
        agreements = []

        for i in range(num_samples):
            rec = val_records[i]
            img_tensor = tf.expand_dims(val_images[i], axis=0).numpy().astype(np.float32)

            tflite_prob = run_tflite_inference_single(interpreter, img_tensor, inp_idx, out_idx)
            tflite_pred = int(np.argmax(tflite_prob))
            k_prob = keras_probs[i]
            k_pred = int(keras_preds[i])

            abs_diff = np.abs(k_prob - tflite_prob)
            max_d = float(np.max(abs_diff))
            mean_d = float(np.mean(abs_diff))
            agrees = bool(k_pred == tflite_pred)

            max_diffs.append(max_d)
            mean_diffs.append(mean_d)
            agreements.append(agrees)

            detailed_rows.append({
                "sample_id": rec.get("image_id", f"VAL_SAMPLE_{i:04d}"),
                "model_format": model_name,
                "actual_class_index": int(val_labels_np[i]),
                "actual_class_name": idx_to_class.get(int(val_labels_np[i]), ""),
                "keras_predicted_index": k_pred,
                "keras_predicted_name": idx_to_class.get(k_pred, ""),
                "keras_confidence": round(float(k_prob[k_pred]), 4),
                "tflite_predicted_index": tflite_pred,
                "tflite_predicted_name": idx_to_class.get(tflite_pred, ""),
                "tflite_confidence": round(float(tflite_prob[tflite_pred]), 4),
                "max_absolute_diff": round(max_d, 6),
                "mean_absolute_diff": round(mean_d, 6),
                "top1_agreement": agrees
            })

        agreement_pct = round(float(np.mean(agreements)) * 100.0, 2)
        overall_max_diff = round(float(np.max(max_diffs)), 6)
        overall_mean_diff = round(float(np.mean(mean_diffs)), 6)

        all_comparisons[model_name] = {
            "samples_compared": num_samples,
            "top1_agreement_percentage": agreement_pct,
            "top1_agreement_count": f"{sum(agreements)}/{num_samples}",
            "max_absolute_difference": overall_max_diff,
            "mean_absolute_difference": overall_mean_diff,
            "fidelity_assessment": (
                "PERFECT_EQUIVALENCE" if agreement_pct == 100.0 and overall_max_diff < 1e-4 else
                "HIGH_FIDELITY" if agreement_pct == 100.0 and overall_max_diff < 0.05 else
                "ACCEPTABLE_QUANTIZATION" if agreement_pct >= 90.0 else
                "SUBSTANTIAL_DIVERGENCE"
            )
        }

    # Save detailed CSV
    df = pd.DataFrame(detailed_rows)
    csv_target = output_csv_path or (REPORTS_DIR / "prediction_comparison.csv")
    os.makedirs(csv_target.parent, exist_ok=True)
    df.to_csv(csv_target, index=False)

    return {
        "summary": all_comparisons,
        "csv_path": str(csv_target.as_posix()),
        "rows_recorded": len(df)
    }


if __name__ == "__main__":
    res = compare_keras_vs_tflite()
    print("\nKeras vs TFLite Comparison Summary:")
    print(json.dumps(res["summary"], indent=2))
    print(f"\nSaved CSV: {res['csv_path']}")
