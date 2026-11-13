"""
Unit tests for Split Leakage Audit & Validation Module.
Phase 35: Train, Validation & Test Dataset Splitting.
"""

import sys
import unittest
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))

from ai_model.src.validate_splits import audit_splits, SPLIT_MANIFEST_PATH
from ai_model.src.dataset import create_image_dataset
import csv
import tensorflow as tf


class TestValidateSplits(unittest.TestCase):
    def test_audit_passes(self):
        passed, results = audit_splits(SPLIT_MANIFEST_PATH)
        self.assertTrue(passed, f"Leakage audit must pass. Critical failures: {results.get('critical_failures')}")
        self.assertEqual(results["final_decision"], "APPROVED_LEAKAGE_FREE")
        self.assertEqual(len(results["exact_duplicate_leakage"]["conflicts"]), 0)
        self.assertEqual(len(results["group_leakage"]["conflicts"]), 0)
        self.assertEqual(len(results["perceptual_duplicate_leakage"]["conflicts"]), 0)

    def test_tensorflow_dataset_loading_per_split(self):
        with open(SPLIT_MANIFEST_PATH, "r", encoding="utf-8") as f:
            records = list(csv.DictReader(f))

        train_recs = [r for r in records if r["split"] == "train"]
        val_recs = [r for r in records if r["split"] == "validation"]
        test_recs = [r for r in records if r["split"] == "test"]

        for r in records:
            r["full_file_path"] = str(PROJECT_ROOT / r["image_path"])

        # Train dataset loading (with augmentation enabled)
        train_ds = create_image_dataset(train_recs, is_training=True, batch_size=16)
        for batch_x, batch_y in train_ds.take(1):
            self.assertEqual(batch_x.shape, (16, 224, 224, 3))
            self.assertEqual(batch_y.shape, (16, 19))
            self.assertEqual(batch_x.dtype, tf.float32)

        # Validation dataset loading (augmentation disabled)
        val_ds = create_image_dataset(val_recs, is_training=False, batch_size=14)
        for batch_x, batch_y in val_ds.take(1):
            self.assertEqual(batch_x.shape, (14, 224, 224, 3))
            self.assertEqual(batch_y.shape, (14, 19))

        # Test dataset loading (augmentation disabled)
        test_ds = create_image_dataset(test_recs, is_training=False, batch_size=13)
        for batch_x, batch_y in test_ds.take(1):
            self.assertEqual(batch_x.shape, (13, 224, 224, 3))
            self.assertEqual(batch_y.shape, (13, 19))


if __name__ == "__main__":
    unittest.main()
