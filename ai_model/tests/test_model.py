"""
AgriCare AI — Unit and Integration Tests for MobileNetV2 Architecture.
Phase 37: MobileNetV2 Transfer Learning Model Architecture.
"""

import json
import os
import shutil
import tempfile
import unittest
import numpy as np
import tensorflow as tf

from ai_model.src.model import (
    build_model,
    build_feature_extraction_model,
    configure_fine_tuning,
    validate_model_output,
)
from ai_model.src.config import (
    IMG_HEIGHT,
    IMG_WIDTH,
    CHANNELS,
    NUM_CLASSES,
    DROPOUT_RATE,
    FINE_TUNE_AT_LAYER,
    LABELS_PATH,
    MODEL_ARCHITECTURE_PATH,
)
from ai_model.src.model_utils import validate_labels_file


class TestMobileNetV2Architecture(unittest.TestCase):

    def test_model_construction_and_shapes(self):
        """Verifies MobileNetV2 construction, input/output shapes, and layer presence."""
        model, base_model = build_model(num_classes=NUM_CLASSES)

        # Input shape contract: (None, 224, 224, 3)
        self.assertEqual(model.input_shape, (None, IMG_HEIGHT, IMG_WIDTH, CHANNELS))

        # Output shape contract: (None, 19)
        self.assertEqual(model.output_shape, (None, NUM_CLASSES))

        # Check key layers
        layer_names = [l.name for l in model.layers]
        self.assertTrue(any("rescaling" in n.lower() for n in layer_names))
        self.assertTrue(any("global_avg_pool" in n.lower() for n in layer_names))
        self.assertTrue(any("dropout" in n.lower() for n in layer_names))
        self.assertTrue(any("predictions" in n.lower() for n in layer_names))

    def test_stage_a_feature_extraction_freeze(self):
        """Verifies that Stage A freezes the backbone completely and leaves only the classifier head trainable."""
        model, base_model = build_feature_extraction_model(num_classes=NUM_CLASSES)

        # Backbone should not be trainable
        self.assertFalse(base_model.trainable)

        # Head dense layer should have exactly 2 trainable tensors (kernel + bias)
        self.assertEqual(len(model.trainable_weights), 2)
        # 1280 * 19 + 19 = 24,339 parameters
        trainable_params = sum(w.numpy().size for w in model.trainable_weights)
        self.assertEqual(trainable_params, 1280 * NUM_CLASSES + NUM_CLASSES)

    def test_stage_b_fine_tuning_unfreeze(self):
        """Verifies that Stage B selectively unfreezes upper layers while keeping BatchNormalization frozen."""
        model, base_model = build_feature_extraction_model(num_classes=NUM_CLASSES)
        fine_tune_model = configure_fine_tuning(
            model,
            base_model,
            fine_tune_at=FINE_TUNE_AT_LAYER
        )

        # Base model is now trainable
        self.assertTrue(base_model.trainable)

        # Layers before cutoff must be frozen
        for layer in base_model.layers[:FINE_TUNE_AT_LAYER]:
            self.assertFalse(layer.trainable, f"Layer {layer.name} before cutoff must be frozen")

        # Layers after cutoff: BatchNormalization must be frozen; conv layers trainable
        for layer in base_model.layers[FINE_TUNE_AT_LAYER:]:
            if isinstance(layer, tf.keras.layers.BatchNormalization):
                self.assertFalse(layer.trainable, f"BatchNorm layer {layer.name} must remain frozen")

        # Trainable weights should be significantly greater than Stage A
        self.assertGreater(len(fine_tune_model.trainable_weights), 2)

    def test_dummy_forward_pass_softmax(self):
        """Verifies forward pass numerical stability and softmax probability properties."""
        model, _ = build_model(num_classes=NUM_CLASSES)
        val_result = validate_model_output(model, num_classes=NUM_CLASSES, batch_size=4)

        self.assertEqual(val_result["status"], "PASS")
        self.assertTrue(val_result["shape_valid"])
        self.assertFalse(val_result["has_nan"])
        self.assertFalse(val_result["has_inf"])
        self.assertTrue(val_result["sums_valid"])
        self.assertTrue(val_result["range_valid"])

    def test_save_and_reload_parity(self):
        """Verifies saving architecture to disk and reloading it without numeric drift."""
        model, _ = build_model(num_classes=NUM_CLASSES)
        temp_dir = tempfile.mkdtemp(prefix="agricare_test_save_")

        try:
            save_path = os.path.join(temp_dir, "test_arch.keras")
            model.save(save_path)
            self.assertTrue(os.path.exists(save_path))

            reloaded_model = tf.keras.models.load_model(save_path)
            self.assertEqual(reloaded_model.input_shape, model.input_shape)
            self.assertEqual(reloaded_model.output_shape, model.output_shape)

            # Compare outputs on deterministic dummy tensor
            dummy = tf.random.uniform((2, IMG_HEIGHT, IMG_WIDTH, CHANNELS), seed=42)
            preds_orig = model(dummy, training=False).numpy()
            preds_reloaded = reloaded_model(dummy, training=False).numpy()

            np.testing.assert_allclose(preds_orig, preds_reloaded, rtol=1e-5, atol=1e-5)
        finally:
            shutil.rmtree(temp_dir, ignore_errors=True)

    def test_labels_json_consistency(self):
        """Verifies that labels.json exists and strictly satisfies the 19-class project catalog."""
        result = validate_labels_file(LABELS_PATH)
        self.assertEqual(result["status"], "PASS")
        self.assertEqual(result["num_classes"], NUM_CLASSES)
        self.assertEqual(len(result["class_names"]), NUM_CLASSES)
        self.assertTrue(result["stable_order_verified"])

    def test_model_architecture_metadata_json(self):
        """Verifies that model_architecture.json is properly formatted and populated."""
        self.assertTrue(MODEL_ARCHITECTURE_PATH.exists())
        with open(MODEL_ARCHITECTURE_PATH, mode="r", encoding="utf-8") as f:
            data = json.load(f)

        self.assertEqual(data["architecture_name"], "AgriCare_MobileNetV2")
        self.assertEqual(data["num_classes"], NUM_CLASSES)
        self.assertEqual(data["input_shape"], [None, IMG_HEIGHT, IMG_WIDTH, CHANNELS])
        self.assertEqual(data["output_shape"], [None, NUM_CLASSES])
        self.assertEqual(data["parameters"]["total_parameters"], 2282323)
        self.assertEqual(data["parameters"]["trainable_parameters_stage_a"], 24339)
        self.assertEqual(data["parameters"]["non_trainable_parameters_stage_a"], 2257984)


if __name__ == "__main__":
    unittest.main()
