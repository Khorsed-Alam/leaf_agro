"""
AgriCare AI — Phase 40 TensorFlow Lite Export Tests.

Unit and integration tests for:
1. TFLite model file existence and size sanity
2. TFLite Interpreter initialization and tensor allocation
3. Input and output tensor shape and dtype compliance
4. Numerical probability validity (finite, bounded in [0, 1], softmax sum ~ 1)
5. Keras vs TFLite Top-1 prediction consistency on validation samples
6. Metadata JSON structure and class mapping parity
7. Flutter asset staging in assets/models/
"""

import json
import unittest
from pathlib import Path
import numpy as np
import tensorflow as tf

from ai_model.src.config import (
    PROJECT_ROOT,
    MODELS_DIR,
    REPORTS_DIR,
    BEST_MODEL_PATH,
    LABELS_PATH,
    MODEL_METADATA_PATH,
    NUM_CLASSES,
)
from ai_model.src.dataset_loader import (
    load_manifest_records,
    load_validation_dataset,
    get_verified_class_index_map,
)
from ai_model.src.tflite_validation import validate_single_tflite_model
from ai_model.src.export_tflite import (
    TFLITE_FLOAT32_PATH,
    TFLITE_FLOAT16_PATH,
    FLUTTER_ASSETS_MODELS_DIR,
)


class TestTFLiteExport(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        cls.val_records = load_manifest_records(split="validation")
        val_ds = load_validation_dataset(batch_size=len(cls.val_records))
        cls.val_images, cls.val_labels = next(iter(val_ds))
        cls.val_labels_np = cls.val_labels.numpy()

    def test_float32_tflite_file_exists_and_size(self):
        """Verifies primary Float32 TFLite model exists and has plausible payload size."""
        self.assertTrue(TFLITE_FLOAT32_PATH.exists(), f"Missing {TFLITE_FLOAT32_PATH}")
        size_bytes = TFLITE_FLOAT32_PATH.stat().st_size
        self.assertGreater(size_bytes, 1_000_000, "TFLite file is unexpectedly small (<1MB)")
        self.assertLess(size_bytes, 15_000_000, "TFLite file is unexpectedly large (>15MB)")

    def test_float16_tflite_file_exists_and_compression(self):
        """Verifies Float16 TFLite model exists and achieves ~50% compression vs Float32."""
        self.assertTrue(TFLITE_FLOAT16_PATH.exists(), f"Missing {TFLITE_FLOAT16_PATH}")
        f32_size = TFLITE_FLOAT32_PATH.stat().st_size
        fp16_size = TFLITE_FLOAT16_PATH.stat().st_size
        self.assertLess(fp16_size, f32_size * 0.60, "Float16 model did not achieve expected compression")

    def test_tflite_interpreter_contract(self):
        """Verifies input/output shapes, data types, and tensor allocation."""
        interpreter = tf.lite.Interpreter(model_path=str(TFLITE_FLOAT32_PATH))
        interpreter.allocate_tensors()

        input_details = interpreter.get_input_details()[0]
        output_details = interpreter.get_output_details()[0]

        # Shape assertions
        self.assertEqual(input_details["shape"].tolist(), [1, 224, 224, 3])
        self.assertEqual(output_details["shape"].tolist(), [1, NUM_CLASSES])

        # Type assertions
        self.assertEqual(input_details["dtype"], np.float32)
        self.assertEqual(output_details["dtype"], np.float32)

    def test_tflite_validation_pass(self):
        """Verifies that validate_single_tflite_model passes all assertions on validation data."""
        res = validate_single_tflite_model(
            tflite_path=TFLITE_FLOAT32_PATH,
            val_images=self.val_images,
            val_labels=self.val_labels_np
        )
        self.assertEqual(res["status"], "PASS")
        self.assertTrue(res["assertions"]["outputs_finite"])
        self.assertTrue(res["assertions"]["outputs_bounded_zero_to_one"])
        self.assertTrue(res["assertions"]["softmax_sums_to_one"])
        self.assertEqual(res["validation_empirical_accuracy"], 0.8571)

    def test_keras_vs_tflite_prediction_agreement(self):
        """Verifies 100% Top-1 agreement between Keras source and TFLite Float32 baseline."""
        keras_model = tf.keras.models.load_model(str(BEST_MODEL_PATH))
        interpreter = tf.lite.Interpreter(model_path=str(TFLITE_FLOAT32_PATH))
        interpreter.allocate_tensors()
        inp_idx = interpreter.get_input_details()[0]["index"]
        out_idx = interpreter.get_output_details()[0]["index"]

        keras_probs = keras_model(self.val_images, training=False).numpy()
        keras_preds = np.argmax(keras_probs, axis=1)

        tflite_preds = []
        max_diff = 0.0

        for i in range(len(self.val_images)):
            img_tensor = tf.expand_dims(self.val_images[i], axis=0).numpy().astype(np.float32)
            interpreter.set_tensor(inp_idx, img_tensor)
            interpreter.invoke()
            tflite_out = interpreter.get_tensor(out_idx)[0]

            tflite_pred = int(np.argmax(tflite_out))
            tflite_preds.append(tflite_pred)

            diff = np.max(np.abs(keras_probs[i] - tflite_out))
            if diff > max_diff:
                max_diff = diff

        # Assert 100% Top-1 agreement across all validation images
        np.testing.assert_array_equal(keras_preds, np.array(tflite_preds))
        # Float32 difference must be extremely small (< 1e-4)
        self.assertLess(max_diff, 1e-4)

    def test_metadata_and_labels_integrity(self):
        """Ensures labels.json and model_metadata.json have matching class counts."""
        self.assertTrue(LABELS_PATH.exists())
        self.assertTrue(MODEL_METADATA_PATH.exists())

        with open(LABELS_PATH, "r", encoding="utf-8") as f:
            labels_data = json.load(f)
        self.assertEqual(len(labels_data["class_names"]), NUM_CLASSES)
        self.assertEqual(labels_data["num_classes"], NUM_CLASSES)

        with open(MODEL_METADATA_PATH, "r", encoding="utf-8") as f:
            meta = json.load(f)
        self.assertEqual(meta["num_classes"], NUM_CLASSES)
        self.assertIn("float32", meta["tflite_exports"])

    def test_flutter_assets_presence(self):
        """Verifies that deployment files were staged into Flutter assets/models/."""
        expected = [
            FLUTTER_ASSETS_MODELS_DIR / "plant_disease_model.tflite",
            FLUTTER_ASSETS_MODELS_DIR / "labels.json",
            FLUTTER_ASSETS_MODELS_DIR / "model_metadata.json"
        ]
        for f in expected:
            self.assertTrue(f.exists(), f"Staged Flutter asset missing: {f}")
            self.assertGreater(f.stat().st_size, 0, f"Staged asset is empty: {f}")

    def test_report_artifacts_exist(self):
        """Verifies that Phase 40 reports and CSVs were written to disk."""
        expected = [
            REPORTS_DIR / "tflite_export_report.md",
            REPORTS_DIR / "PHASE_40_COMPLETION_REPORT.md",
            REPORTS_DIR / "model_size_comparison.csv",
            REPORTS_DIR / "prediction_comparison.csv",
            REPORTS_DIR / "tflite_benchmark.json"
        ]
        for f in expected:
            self.assertTrue(f.exists(), f"Missing report: {f}")
            self.assertGreater(f.stat().st_size, 0, f"Report is empty: {f}")


if __name__ == "__main__":
    unittest.main()
