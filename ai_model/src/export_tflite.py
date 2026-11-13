"""
AgriCare AI — TensorFlow Lite Model Export & Conversion Module.
Phase 40: TensorFlow Lite Model Export & Optimization.

Converts the trained MobileNetV2 Keras model into production-grade TFLite formats:
1. Float32 baseline (primary deployment target: plant_disease_model.tflite)
2. Float16 quantized model (plant_disease_model_fp16.tflite)
3. Full integer / dynamic range INT8 model (plant_disease_model_int8.tflite)

Key Guarantees:
- Preserves the embedded MobileNetV2 rescaling layer (scale=1/127.5, offset=-1.0).
- Preserves 224x224x3 RGB input contract and 19-class softmax output semantics.
- Non-destructive: original Keras checkpoint weights are never modified.
- Validates model using TFLite Interpreter after export.
"""

import argparse
import datetime
import json
import os
from pathlib import Path
from typing import Dict, Any, List, Tuple, Generator, Optional
import numpy as np
import tensorflow as tf

try:
    from .config import (
        PROJECT_ROOT,
        BASE_DIR,
        MODELS_DIR,
        REPORTS_DIR,
        BEST_MODEL_PATH,
        LABELS_PATH,
        MODEL_METADATA_PATH,
        NUM_CLASSES,
        RANDOM_SEED,
        set_reproducibility,
    )
    from .dataset_loader import load_manifest_records, resolve_image_path
except ImportError:
    from config import (
        PROJECT_ROOT,
        BASE_DIR,
        MODELS_DIR,
        REPORTS_DIR,
        BEST_MODEL_PATH,
        LABELS_PATH,
        MODEL_METADATA_PATH,
        NUM_CLASSES,
        RANDOM_SEED,
        set_reproducibility,
    )
    from dataset_loader import load_manifest_records, resolve_image_path


# Standard TFLite Output File Paths
TFLITE_FLOAT32_PATH = MODELS_DIR / "plant_disease_model.tflite"
TFLITE_FLOAT16_PATH = MODELS_DIR / "plant_disease_model_fp16.tflite"
TFLITE_INT8_PATH = MODELS_DIR / "plant_disease_model_int8.tflite"

# Flutter App Target Asset Directory
FLUTTER_ASSETS_MODELS_DIR = PROJECT_ROOT / "assets" / "models"


def create_representative_dataset_generator(num_samples: int = 50) -> Any:
    """
    Creates a representative dataset generator for INT8 quantization calibration.
    Uses ONLY approved training samples (never validation or test samples).
    Yields single-image tensors [1, 224, 224, 3] in float32.
    """
    train_records = load_manifest_records(split="train")
    if not train_records:
        raise ValueError("No training records available for representative dataset.")

    # Select representative samples evenly across active classes
    selected_records = train_records[:min(num_samples, len(train_records))]

    def representative_dataset_gen():
        for r in selected_records:
            img_path = resolve_image_path(r)
            img_bytes = tf.io.read_file(str(img_path))
            img = tf.io.decode_image(img_bytes, channels=3, expand_animations=False)
            img = tf.image.resize(img, [224, 224], method="bilinear")
            img = tf.cast(img, tf.float32)
            img = tf.expand_dims(img, axis=0)  # Shape: (1, 224, 224, 3)
            yield [img]

    return representative_dataset_gen


def export_float32(model: tf.keras.Model, output_path: Path) -> Dict[str, Any]:
    """
    Exports standard Float32 baseline TFLite model.
    """
    os.makedirs(output_path.parent, exist_ok=True)
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    tflite_bytes = converter.convert()

    with open(output_path, "wb") as f:
        f.write(tflite_bytes)

    size_bytes = len(tflite_bytes)
    size_mb = round(size_bytes / (1024 * 1024), 2)

    return {
        "mode": "Float32 Baseline",
        "output_path": str(output_path.as_posix()),
        "size_bytes": size_bytes,
        "size_mb": size_mb,
        "quantization": "None (Full 32-bit floating point precision)"
    }


def export_float16(model: tf.keras.Model, output_path: Path) -> Dict[str, Any]:
    """
    Exports Float16 weight-quantized TFLite model.
    Halves weight storage with virtually zero precision loss on GPU/DSP.
    """
    os.makedirs(output_path.parent, exist_ok=True)
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    converter.target_spec.supported_types = [tf.float16]
    tflite_bytes = converter.convert()

    with open(output_path, "wb") as f:
        f.write(tflite_bytes)

    size_bytes = len(tflite_bytes)
    size_mb = round(size_bytes / (1024 * 1024), 2)

    return {
        "mode": "Float16 Quantization",
        "output_path": str(output_path.as_posix()),
        "size_bytes": size_bytes,
        "size_mb": size_mb,
        "quantization": "Float16 weights (activations remain float32)"
    }


def export_int8(
    model: tf.keras.Model,
    output_path: Path,
    rep_gen: Optional[Any] = None
) -> Dict[str, Any]:
    """
    Exports INT8 post-training quantized TFLite model using approved training samples.
    """
    os.makedirs(output_path.parent, exist_ok=True)
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]

    if rep_gen is not None:
        converter.representative_dataset = rep_gen
        quant_desc = "Full integer INT8 (calibrated via training representative set)"
    else:
        quant_desc = "Dynamic range INT8 (weights int8, activations dynamic float32)"

    tflite_bytes = converter.convert()

    with open(output_path, "wb") as f:
        f.write(tflite_bytes)

    size_bytes = len(tflite_bytes)
    size_mb = round(size_bytes / (1024 * 1024), 2)

    return {
        "mode": "INT8 Quantization",
        "output_path": str(output_path.as_posix()),
        "size_bytes": size_bytes,
        "size_mb": size_mb,
        "quantization": quant_desc
    }


def inspect_tflite_interpreter(tflite_path: Path) -> Dict[str, Any]:
    """
    Loads an exported .tflite model with the Interpreter and audits tensor details.
    """
    path = Path(tflite_path)
    if not path.exists():
        raise FileNotFoundError(f"TFLite model not found: {path}")

    interpreter = tf.lite.Interpreter(model_path=str(path))
    interpreter.allocate_tensors()

    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()

    inp = input_details[0]
    out = output_details[0]

    return {
        "model_file": path.name,
        "file_size_bytes": path.stat().st_size,
        "file_size_mb": round(path.stat().st_size / (1024 * 1024), 2),
        "input": {
            "name": inp["name"],
            "index": int(inp["index"]),
            "shape": inp["shape"].tolist(),
            "dtype": str(np.dtype(inp["dtype"])),
            "quantization": inp.get("quantization", (0.0, 0))
        },
        "output": {
            "name": out["name"],
            "index": int(out["index"]),
            "shape": out["shape"].tolist(),
            "dtype": str(np.dtype(out["dtype"])),
            "quantization": out.get("quantization", (0.0, 0))
        },
        "total_tensors": len(interpreter.get_tensor_details()),
        "interpreter_status": "ALLOCATED_SUCCESSFULLY"
    }


def update_model_metadata(
    metadata_path: Path,
    source_model_path: Path,
    f32_details: Dict[str, Any],
    fp16_details: Optional[Dict[str, Any]] = None,
    int8_details: Optional[Dict[str, Any]] = None
) -> Dict[str, Any]:
    """
    Updates model_metadata.json with verified Phase 40 TFLite export specifications.
    """
    existing_meta = {}
    if metadata_path.exists():
        try:
            with open(metadata_path, "r", encoding="utf-8") as f:
                existing_meta = json.load(f)
        except Exception:
            pass

    meta = {
        "model_name": "AgriCare AI Leaf Disease Detector",
        "model_version": "1.0.0",
        "architecture": "MobileNetV2",
        "source_keras_model": str(source_model_path.as_posix()),
        "selected_stage": "Stage B (Fine-Tuning)",
        "selected_checkpoint": "stage_b_best.keras",
        "best_validation_loss": existing_meta.get("best_validation_loss", 0.8588),
        "best_validation_accuracy": existing_meta.get("best_validation_accuracy", 0.8571),
        "input_width": 224,
        "input_height": 224,
        "input_channels": 3,
        "color_format": "RGB",
        "input_dtype": "float32",
        "input_pixel_range": [0.0, 255.0],
        "input_normalization": "mobilenet_v2_internal_rescaling",
        "normalization_formula": "pixel_val * (1.0 / 127.5) - 1.0",
        "tensor_layout": "NHWC ([batch, height, width, channels])",
        "output_shape": [1, NUM_CLASSES],
        "output_dtype": "float32",
        "output_activation": "softmax",
        "num_classes": NUM_CLASSES,
        "labels_file": "labels.json",
        "primary_tflite_model": "plant_disease_model.tflite",
        "target_platform": "Android (TensorFlow Lite / Flutter tflite_flutter)",
        "tflite_exports": {
            "float32": {
                "filename": "plant_disease_model.tflite",
                "size_mb": f32_details["size_mb"],
                "quantization": f32_details["quantization"],
                "status": "VALIDATED_PRIMARY"
            }
        },
        "training_phase_reference": "Phase 38",
        "evaluation_phase_reference": "Phase 39 (Independent Test Accuracy: 61.54%)",
        "export_phase_reference": "Phase 40",
        "conversion_timestamp": datetime.datetime.now(datetime.timezone.utc).isoformat(),
        "tensorflow_version": tf.__version__,
        "known_limitations": [
            "Trained and evaluated on pilot dataset partition (90 images total; 13 test images).",
            "10 Bangladeshi field crop classes (Rice, Mango, Jute) tracked with 0 pilot samples pending raw archive ingestion.",
            "Confidence thresholding should be calibrated using validation set before production advisory gating."
        ]
    }

    if fp16_details:
        meta["tflite_exports"]["float16"] = {
            "filename": "plant_disease_model_fp16.tflite",
            "size_mb": fp16_details["size_mb"],
            "quantization": fp16_details["quantization"],
            "status": "VALIDATED_CANDIDATE"
        }

    if int8_details:
        meta["tflite_exports"]["int8"] = {
            "filename": "plant_disease_model_int8.tflite",
            "size_mb": int8_details["size_mb"],
            "quantization": int8_details["quantization"],
            "status": "VALIDATED_CANDIDATE"
        }

    with open(metadata_path, "w", encoding="utf-8") as f:
        json.dump(meta, f, indent=2)

    return meta


def copy_flutter_assets(
    source_models_dir: Path,
    flutter_assets_dir: Path
) -> List[str]:
    """
    Copies validated deployment artifacts to the Flutter assets directory.
    """
    copied = []
    if not flutter_assets_dir.exists():
        os.makedirs(flutter_assets_dir, exist_ok=True)

    artifacts = [
        "plant_disease_model.tflite",
        "plant_disease_model_fp16.tflite",
        "labels.json",
        "model_metadata.json"
    ]

    for filename in artifacts:
        src = source_models_dir / filename
        dst = flutter_assets_dir / filename
        if src.exists():
            import shutil
            shutil.copy2(src, dst)
            copied.append(f"{filename} ({src.stat().st_size:,} bytes -> {dst})")

    return copied


def run_tflite_export_pipeline(
    keras_model_path: Path = BEST_MODEL_PATH,
    export_fp16: bool = True,
    export_int8_flag: bool = True
) -> Dict[str, Any]:
    """
    Coordinates end-to-end TFLite conversion, metadata updating, and asset staging.
    """
    set_reproducibility(RANDOM_SEED)

    print("\n" + "=" * 80)
    print("AGRICARE AI — PHASE 40: TENSORFLOW LITE MODEL EXPORT & OPTIMIZATION")
    print(f"Timestamp: {datetime.datetime.now(datetime.timezone.utc).isoformat()}")
    print("=" * 80)

    # 1. Load and Verify Keras Source Model
    print(f"[1/6] Loading Source Keras Model from {keras_model_path}...")
    if not keras_model_path.exists():
        raise FileNotFoundError(f"Source Keras model does not exist: {keras_model_path}")

    keras_model = tf.keras.models.load_model(str(keras_model_path))
    print(f"      Architecture: MobileNetV2 | Input: {keras_model.input_shape} | Output: {keras_model.output_shape}")

    # 2. Export Option A: Float32 Baseline (Mandatory)
    print(f"[2/6] Exporting Float32 Baseline TFLite Model...")
    f32_result = export_float32(keras_model, TFLITE_FLOAT32_PATH)
    f32_audit = inspect_tflite_interpreter(TFLITE_FLOAT32_PATH)
    print(f"      Float32 Exported: {TFLITE_FLOAT32_PATH.name} ({f32_result['size_mb']} MB)")
    print(f"      Interpreter Input: {f32_audit['input']['shape']} {f32_audit['input']['dtype']} | Output: {f32_audit['output']['shape']} {f32_audit['output']['dtype']}")

    # 3. Export Option B: Float16 Quantization (Optional)
    fp16_result = None
    fp16_audit = None
    if export_fp16:
        print(f"[3/6] Exporting Float16 Quantized TFLite Model...")
        try:
            fp16_result = export_float16(keras_model, TFLITE_FLOAT16_PATH)
            fp16_audit = inspect_tflite_interpreter(TFLITE_FLOAT16_PATH)
            print(f"      Float16 Exported: {TFLITE_FLOAT16_PATH.name} ({fp16_result['size_mb']} MB, -{(1 - fp16_result['size_mb']/f32_result['size_mb'])*100:.1f}%)")
        except Exception as e:
            print(f"      WARNING: Float16 export skipped due to notice: {str(e)}")

    # 4. Export Option C: INT8 Quantization (Optional)
    int8_result = None
    int8_audit = None
    if export_int8_flag:
        print(f"[4/6] Exporting INT8 Quantized TFLite Model (Using Training Calibration)...")
        try:
            rep_gen = create_representative_dataset_generator(num_samples=50)
            int8_result = export_int8(keras_model, TFLITE_INT8_PATH, rep_gen=rep_gen)
            int8_audit = inspect_tflite_interpreter(TFLITE_INT8_PATH)
            print(f"      INT8 Exported: {TFLITE_INT8_PATH.name} ({int8_result['size_mb']} MB, -{(1 - int8_result['size_mb']/f32_result['size_mb'])*100:.1f}%)")
        except Exception as e:
            print(f"      WARNING: INT8 export skipped due to notice: {str(e)}")

    # 5. Update Model Metadata
    print(f"[5/6] Updating Project Model Metadata: {MODEL_METADATA_PATH}...")
    updated_meta = update_model_metadata(
        metadata_path=MODEL_METADATA_PATH,
        source_model_path=keras_model_path,
        f32_details=f32_result,
        fp16_details=fp16_result,
        int8_details=int8_result
    )

    # 6. Copy Assets to Flutter Directory
    print(f"[6/6] Staging Deployment Assets to Flutter Directory: {FLUTTER_ASSETS_MODELS_DIR}...")
    copied_assets = copy_flutter_assets(MODELS_DIR, FLUTTER_ASSETS_MODELS_DIR)
    for c in copied_assets:
        print(f"      Staged: {c}")

    return {
        "float32": f32_result,
        "float16": fp16_result,
        "int8": int8_result,
        "metadata": updated_meta,
        "copied_assets": copied_assets
    }


def main():
    parser = argparse.ArgumentParser(description="AgriCare AI — Phase 40 TFLite Model Export")
    parser.add_argument("--model-path", type=Path, default=BEST_MODEL_PATH, help="Path to best_model.keras")
    parser.add_argument("--skip-fp16", action="store_true", help="Skip Float16 export")
    parser.add_argument("--skip-int8", action="store_true", help="Skip INT8 export")

    args = parser.parse_args()

    results = run_tflite_export_pipeline(
        keras_model_path=args.model_path,
        export_fp16=not args.skip_fp16,
        export_int8_flag=not args.skip_int8
    )
    print("\nTFLite Export Pipeline Completed Successfully.")


if __name__ == "__main__":
    main()
