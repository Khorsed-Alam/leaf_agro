"""
AgriCare AI — Unit and Integration Tests for Unified Dataset Loader.
Phase 36: Environment and Infrastructure Verification.
"""

import unittest
from pathlib import Path
import tensorflow as tf

from ai_model.src.dataset_loader import (
    get_verified_class_index_map,
    load_manifest_records,
    resolve_image_path,
    create_split_dataset,
    load_train_dataset,
    load_validation_dataset,
    load_test_dataset,
    audit_manifest_integrity,
)
from ai_model.src.config import (
    SPLIT_MANIFEST_PATH,
    NUM_CLASSES,
    IMAGE_SIZE,
    CHANNELS,
)


class TestDatasetLoader(unittest.TestCase):

    def test_verified_class_index_map(self):
        """Tests that verified class mapping builds bidirectional, stable indices."""
        c2i, i2c = get_verified_class_index_map()
        self.assertGreaterEqual(len(i2c), 19, "Must map at least 19 standardized classes")
        # Indices must span 0 to NUM_CLASSES - 1
        indices = set(i2c.keys())
        self.assertEqual(indices, set(range(len(i2c))))

    def test_load_manifest_records(self):
        """Tests loading split manifests and filtering."""
        all_recs = load_manifest_records()
        self.assertEqual(len(all_recs), 90, "Expected 90 approved pilot records")

        train_recs = load_manifest_records(split="train")
        val_recs = load_manifest_records(split="validation")
        test_recs = load_manifest_records(split="test")

        self.assertEqual(len(train_recs), 63, "Expected 63 train records (70%)")
        self.assertEqual(len(val_recs), 14, "Expected 14 val records (15.56%)")
        self.assertEqual(len(test_recs), 13, "Expected 13 test records (14.44%)")

    def test_resolve_image_paths(self):
        """Tests that all records in split manifest point to real physical files."""
        records = load_manifest_records()
        for r in records:
            p = resolve_image_path(r)
            self.assertTrue(p.exists(), f"Image not found at {p}")

    def test_audit_manifest_integrity(self):
        """Tests that audit_manifest_integrity reports zero errors on current dataset."""
        audit = audit_manifest_integrity()
        self.assertEqual(audit["status"], "PASS")
        self.assertEqual(audit["missing_files_count"], 0)
        self.assertEqual(audit["invalid_labels_count"], 0)

    def test_streaming_dataset_batches(self):
        """Tests real tf.data pipeline batch extraction, shape and dtype contracts."""
        train_ds = load_train_dataset(batch_size=4)
        val_ds = load_validation_dataset(batch_size=4)
        test_ds = load_test_dataset(batch_size=4)

        for ds_name, ds in [("train", train_ds), ("val", val_ds), ("test", test_ds)]:
            for img_batch, label_batch in ds.take(1):
                # Shape contract: (batch_size, 224, 224, 3)
                self.assertEqual(img_batch.shape[1:], (IMAGE_SIZE[0], IMAGE_SIZE[1], CHANNELS))
                # Dtype contract: float32
                self.assertEqual(img_batch.dtype, tf.float32)
                # Pixel contract: [0.0, 255.0] range
                min_val = tf.reduce_min(img_batch).numpy()
                max_val = tf.reduce_max(img_batch).numpy()
                self.assertGreaterEqual(min_val, 0.0)
                self.assertLessEqual(max_val, 255.0)
                # Labels contract: int32 within valid range
                self.assertEqual(label_batch.dtype, tf.int32)
                for lbl in label_batch.numpy():
                    self.assertGreaterEqual(lbl, 0)
                    self.assertLess(lbl, NUM_CLASSES)

    def test_invalid_split_raises_value_error(self):
        """Tests that querying an invalid split throws ValueError."""
        with self.assertRaises(ValueError):
            load_manifest_records(split="unknown_split_name")

        with self.assertRaises(ValueError):
            create_split_dataset(split="invalid_split")


if __name__ == "__main__":
    unittest.main()

