"""
Unit tests for Dataset Pipeline Module.
Phase 34: Image Preprocessing, Normalization & Data Augmentation.
"""

import sys
from pathlib import Path
PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))

import unittest
import tensorflow as tf
from ai_model.src.dataset import (
    load_cleaning_manifest,
    load_verified_class_mapping,
    discover_approved_images,
    encode_labels,
    decode_label,
    create_image_dataset,
)


class TestDataset(unittest.TestCase):
    def test_load_manifest(self):
        records = load_cleaning_manifest()
        self.assertGreater(len(records), 0)

    def test_discover_approved_images(self):
        approved = discover_approved_images()
        self.assertEqual(len(approved), 90)
        for r in approved:
            self.assertEqual(r["cleaning_status"], "APPROVED")

    def test_label_encoding_stability(self):
        c2i, i2c = encode_labels()
        self.assertEqual(len(c2i), 19)
        self.assertEqual(len(i2c), 19)
        # Verify deterministic round-trip
        for idx in range(19):
            name = decode_label(idx, i2c)
            self.assertEqual(c2i[name], idx)

    def test_dataset_stream(self):
        approved = discover_approved_images()
        # Test creating a batch of 8 images
        ds = create_image_dataset(approved[:8], batch_size=4, is_training=False)
        for batch_x, batch_y in ds.take(1):
            self.assertEqual(batch_x.shape, (4, 224, 224, 3))
            self.assertEqual(batch_y.shape, (4, 19))
            self.assertGreaterEqual(tf.reduce_min(batch_x).numpy(), 0.0)
            self.assertLessEqual(tf.reduce_max(batch_x).numpy(), 255.0)


if __name__ == "__main__":
    import tensorflow as tf
    unittest.main()
