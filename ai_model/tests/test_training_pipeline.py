"""
AgriCare AI — Post-Training Pipeline & Artifact Verification Tests.
Phase 38: AI Model Training and Fine-Tuning.
"""

import json
import unittest
import numpy as np
import tensorflow as tf

from ai_model.src.config import (
    BEST_MODEL_PATH,
    STAGE_A_CHECKPOINT_PATH,
    STAGE_B_CHECKPOINT_PATH,
    TRAINING_HISTORY_PATH,
    STAGE_A_HISTORY_PATH,
    STAGE_B_HISTORY_PATH,
    TRAINING_CONFIG_PATH,
    TRAINING_REPORT_PATH,
    ACCURACY_PLOT_PATH,
    LOSS_PLOT_PATH,
    LR_PLOT_PATH,
    MODEL_METADATA_PATH,
    LABELS_PATH,
    NUM_CLASSES,
    IMAGE_SIZE,
    CHANNELS,
)
from ai_model.src.dataset_loader import load_validation_dataset


class TestTrainingPipeline(unittest.TestCase):

    def test_checkpoint_artifacts_exist(self):
        """Verifies that Stage A, Stage B, and best_model.keras checkpoints exist and are non-empty."""
        for path, name in [
            (STAGE_A_CHECKPOINT_PATH, "Stage A Checkpoint"),
            (STAGE_B_CHECKPOINT_PATH, "Stage B Checkpoint"),
            (BEST_MODEL_PATH, "Best Model Checkpoint"),
        ]:
            self.assertTrue(path.exists(), f"{name} not found at {path}")
            self.assertGreater(path.stat().st_size, 1024 * 1024, f"{name} file size unexpectedly small")

    def test_training_reports_and_histories_exist(self):
        """Verifies that all history CSVs, config JSON, and markdown reports were generated."""
        for path, name in [
            (TRAINING_HISTORY_PATH, "Combined History CSV"),
            (STAGE_A_HISTORY_PATH, "Stage A History CSV"),
            (STAGE_B_HISTORY_PATH, "Stage B History CSV"),
            (TRAINING_CONFIG_PATH, "Training Config JSON"),
            (TRAINING_REPORT_PATH, "Training Report MD"),
            (ACCURACY_PLOT_PATH, "Accuracy Plot PNG"),
            (LOSS_PLOT_PATH, "Loss Plot PNG"),
            (LR_PLOT_PATH, "Learning Rate Plot PNG"),
        ]:
            self.assertTrue(path.exists(), f"{name} not found at {path}")

    def test_selected_model_inference_on_real_validation_sample(self):
        """Loads best_model.keras, verifies input/output shapes, and runs inference on a real validation batch."""
        model = tf.keras.models.load_model(str(BEST_MODEL_PATH))

        # Check input and output shapes
        self.assertEqual(model.input_shape, (None, IMAGE_SIZE[0], IMAGE_SIZE[1], CHANNELS))
        self.assertEqual(model.output_shape, (None, NUM_CLASSES))

        # Load real validation dataset
        val_ds = load_validation_dataset(batch_size=4)
        for images, labels in val_ds.take(1):
            preds = model(images, training=False).numpy()

            # Shape contract
            self.assertEqual(preds.shape, (len(images), NUM_CLASSES))

            # Finiteness contract
            self.assertFalse(np.isnan(preds).any(), "Predictions contain NaN values")
            self.assertFalse(np.isinf(preds).any(), "Predictions contain Inf values")

            # Softmax probability distribution axioms
            sums = np.sum(preds, axis=-1)
            for s in sums:
                self.assertAlmostEqual(s, 1.0, places=4)

            # Probabilities range [0, 1]
            self.assertGreaterEqual(preds.min(), 0.0)
            self.assertLessEqual(preds.max(), 1.0)

            # Check predicted classes map into valid labels.json range
            with open(LABELS_PATH, mode="r", encoding="utf-8") as f:
                labels_data = json.load(f)
                class_names = labels_data["class_names"]

            top_classes = np.argmax(preds, axis=-1)
            for cls_idx in top_classes:
                self.assertIn(cls_idx, range(NUM_CLASSES))
                self.assertIsInstance(class_names[cls_idx], str)

    def test_model_metadata_consistency(self):
        """Verifies that model_metadata.json records real training metrics and valid checkpoints."""
        self.assertTrue(MODEL_METADATA_PATH.exists())
        with open(MODEL_METADATA_PATH, mode="r", encoding="utf-8") as f:
            data = json.load(f)

        self.assertIn("selected_stage", data)
        self.assertIn("best_validation_loss", data)
        self.assertIn("best_validation_accuracy", data)
        self.assertLess(data["best_validation_loss"], 1.5)
        self.assertGreater(data["best_validation_accuracy"], 0.5)


if __name__ == "__main__":
    unittest.main()
