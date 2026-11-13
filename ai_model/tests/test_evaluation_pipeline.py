"""
AgriCare AI — Phase 39 Model Evaluation Pipeline Tests.

Unit and integration tests for:
1. Synthetic metric verification (accuracy, macro/weighted metrics, zero-division safety)
2. Confusion matrix properties (dimensions, row normalization, zero-row handling)
3. Calibration calculation verification (ECE and Multiclass Brier Score)
4. Split integrity & zero data leakage on test dataset
5. Model inference contract, probability vector validity, and weight immutability
6. Generation and non-emptiness of all evaluation reports and plots
"""

import json
import unittest
from pathlib import Path
import numpy as np
import pandas as pd
import tensorflow as tf

from ai_model.src.config import (
    BEST_MODEL_PATH,
    LABELS_PATH,
    SPLIT_MANIFEST_PATH,
    REPORTS_DIR,
    PLOTS_DIR,
    NUM_CLASSES,
)
from ai_model.src.dataset_loader import (
    load_manifest_records,
    get_verified_class_index_map,
    load_test_dataset,
)
from ai_model.src.evaluation_metrics import (
    compute_overall_metrics,
    compute_per_class_metrics,
    compute_confusion_matrices,
)
from ai_model.src.calibration import (
    compute_ece,
    compute_multiclass_brier_score,
)
from ai_model.src.error_analysis import (
    categorize_error,
)
from ai_model.src.benchmark import (
    get_hardware_info,
)


class TestEvaluationPipeline(unittest.TestCase):

    def setUp(self):
        self.num_classes = 19
        self.class_to_idx, self.idx_to_class = get_verified_class_index_map()
        self.ordered_class_names = [self.idx_to_class[i] for i in range(self.num_classes)]

    def test_synthetic_metrics_calculation(self):
        """Validates mathematical correctness of accuracy, macro, and weighted precision/recall."""
        # 4 samples across 3 classes: [0, 0, 1, 2]
        y_true = np.array([0, 0, 1, 2])
        y_pred = np.array([0, 1, 1, 2])  # 3 correct, 1 wrong (sample 1 predicted as 1 instead of 0)

        metrics = compute_overall_metrics(y_true, y_pred, num_classes=3)
        self.assertEqual(metrics["accuracy"], 0.75)
        self.assertEqual(metrics["top_1_accuracy"], 0.75)
        self.assertAlmostEqual(metrics["macro_recall"], (0.5 + 1.0 + 1.0) / 3.0)
        self.assertAlmostEqual(metrics["macro_precision"], (1.0 + 0.5 + 1.0) / 3.0)

    def test_per_class_metrics_zero_division_safety(self):
        """Verifies that classes with zero support do not trigger NaN or exceptions."""
        y_true = np.array([6, 7, 8])
        y_pred = np.array([6, 7, 8])

        df = compute_per_class_metrics(y_true, y_pred, self.ordered_class_names)
        self.assertEqual(len(df), self.num_classes)
        # Class 0 (Jute___Anthracnose) has 0 support
        jute_row = df[df["class_index"] == 0].iloc[0]
        self.assertEqual(jute_row["support"], 0)
        self.assertEqual(jute_row["precision"], 0.0)
        self.assertEqual(jute_row["recall"], 0.0)
        self.assertEqual(jute_row["f1_score"], 0.0)
        self.assertEqual(jute_row["evaluation_status"], "ZERO_TEST_SUPPORT_UNASSESSED")

    def test_confusion_matrix_dimensions_and_normalization(self):
        """Ensures confusion matrix is exactly 19x19 and row-normalized rows sum to 1.0 (or 0 for 0 support)."""
        y_true = np.array([6, 7, 7, 8, 13])
        y_pred = np.array([6, 7, 8, 8, 13])

        raw_cm, norm_cm = compute_confusion_matrices(y_true, y_pred, num_classes=self.num_classes)
        self.assertEqual(raw_cm.shape, (19, 19))
        self.assertEqual(norm_cm.shape, (19, 19))

        # Row 7 (Potato___Late_blight) has 2 samples: 1 correct (7), 1 wrong (8) -> 0.5 each
        self.assertAlmostEqual(norm_cm[7, 7], 0.5)
        self.assertAlmostEqual(norm_cm[7, 8], 0.5)
        self.assertAlmostEqual(np.sum(norm_cm[7]), 1.0)

        # Row 0 has 0 support -> all zeros
        self.assertEqual(np.sum(norm_cm[0]), 0.0)

    def test_calibration_ece_and_brier_score(self):
        """Verifies ECE and multiclass Brier score calculations with known values."""
        # Perfect predictions: confidence 1.0, all correct -> ECE = 0.0, BS = 0.0
        y_true = np.array([0, 1])
        y_pred = np.array([0, 1])
        confidences = np.array([1.0, 1.0])
        ece, _ = compute_ece(y_true, y_pred, confidences, num_bins=10)
        self.assertAlmostEqual(ece, 0.0)

        # Perfect one-hot probabilities
        y_probs = np.array([[1.0, 0.0], [0.0, 1.0]])
        bs = compute_multiclass_brier_score(y_true, y_probs, num_classes=2)
        self.assertAlmostEqual(bs, 0.0)

        # Totally wrong predictions: confidence 1.0, all wrong
        y_pred_wrong = np.array([1, 0])
        ece_wrong, _ = compute_ece(y_true, y_pred_wrong, confidences, num_bins=10)
        self.assertAlmostEqual(ece_wrong, 1.0)

    def test_error_categorization_logic(self):
        """Tests agricultural severity error categorization logic."""
        # Correct
        cat1 = categorize_error("Potato___healthy", "Potato___healthy", 0.95, is_correct=True)
        self.assertEqual(cat1, "CORRECT")

        # Healthy mistaken for disease
        cat2 = categorize_error("Potato___healthy", "Potato___Early_blight", 0.70, is_correct=False)
        self.assertEqual(cat2, "HEALTHY_TO_DISEASE")

        # Disease mistaken for healthy
        cat3 = categorize_error("Potato___Early_blight", "Potato___healthy", 0.70, is_correct=False)
        self.assertEqual(cat3, "DISEASE_TO_HEALTHY")

        # High confidence error
        cat4 = categorize_error("Tomato___Early_blight", "Tomato___Late_blight", 0.85, is_correct=False)
        self.assertEqual(cat4, "HIGH_CONFIDENCE_ERROR")

    def test_split_integrity_and_isolation(self):
        """Verifies that the test split is completely independent with zero leakage into train/val."""
        all_records = load_manifest_records()
        train_ids = {r["image_id"] for r in all_records if r["split"] == "train"}
        val_ids = {r["image_id"] for r in all_records if r["split"] == "validation"}
        test_ids = {r["image_id"] for r in all_records if r["split"] == "test"}

        # Disjoint ID sets
        self.assertEqual(len(train_ids.intersection(test_ids)), 0, "Test set contains samples from train set!")
        self.assertEqual(len(val_ids.intersection(test_ids)), 0, "Test set contains samples from val set!")
        self.assertEqual(len(test_ids), 13, "Expected 13 test samples in pilot partition.")

    def test_model_inference_and_weight_immutability(self):
        """Ensures model inference produces valid probability vectors without mutating weights."""
        model = tf.keras.models.load_model(str(BEST_MODEL_PATH))
        initial_weights = [w.numpy() for w in model.weights[:5]]

        # Run inference on test dataset
        test_ds = load_test_dataset(batch_size=13)
        images, labels = next(iter(test_ds))
        preds = model(images, training=False).numpy()

        # Dimension checks
        self.assertEqual(preds.shape, (13, NUM_CLASSES))

        # Finite, valid bounds, sums to ~1.0
        self.assertTrue(np.all(np.isfinite(preds)))
        self.assertTrue(np.all(preds >= 0.0))
        self.assertTrue(np.all(preds <= 1.0))
        sums = np.sum(preds, axis=1)
        np.testing.assert_allclose(sums, np.ones(13), atol=1e-5)

        # Check weights are completely unchanged
        for w_init, w_after in zip(initial_weights, model.weights[:5]):
            np.testing.assert_array_equal(w_init, w_after.numpy())

    def test_evaluation_artifacts_exist(self):
        """Verifies that all required CSV, JSON, and PNG evaluation artifacts exist on disk."""
        expected_files = [
            REPORTS_DIR / "predictions.csv",
            REPORTS_DIR / "classification_report.csv",
            REPORTS_DIR / "overall_metrics.json",
            REPORTS_DIR / "confusion_matrix.csv",
            REPORTS_DIR / "normalized_confusion_matrix.csv",
            REPORTS_DIR / "error_analysis.csv",
            REPORTS_DIR / "calibration_metrics.json",
            REPORTS_DIR / "performance_benchmark.json",
            REPORTS_DIR / "evaluation_report.md",
            REPORTS_DIR / "PHASE_39_COMPLETION_REPORT.md",
            PLOTS_DIR / "confusion_matrix.png",
            PLOTS_DIR / "normalized_confusion_matrix.png",
            PLOTS_DIR / "classwise_f1.png",
            PLOTS_DIR / "precision_recall.png",
            PLOTS_DIR / "confidence_distribution.png",
            PLOTS_DIR / "reliability_diagram.png",
            PLOTS_DIR / "correct_vs_incorrect_confidence.png",
        ]
        for f in expected_files:
            self.assertTrue(f.exists(), f"Expected artifact missing: {f}")
            self.assertGreater(f.stat().st_size, 0, f"Artifact is empty: {f}")


if __name__ == "__main__":
    unittest.main()

