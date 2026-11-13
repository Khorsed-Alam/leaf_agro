"""
Unit tests for Data Augmentation Module.
Phase 34: Image Preprocessing, Normalization & Data Augmentation.
"""

import sys
from pathlib import Path
PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))

import unittest
import tensorflow as tf
from ai_model.src.augmentation import get_training_augmentation_layer, apply_augmentation


class TestAugmentation(unittest.TestCase):
    def test_augmentation_layer_creation(self):
        aug_layer = get_training_augmentation_layer()
        self.assertIsNotNone(aug_layer)
        self.assertTrue(len(aug_layer.layers) >= 5)

    def test_eval_mode_inactivity(self):
        # In eval mode (training=False), output tensor must equal input tensor
        inp = tf.ones((2, 224, 224, 3), dtype=tf.float32) * 100.0
        out = apply_augmentation(inp, is_training=False)
        diff = tf.reduce_max(tf.abs(inp - out))
        self.assertEqual(diff.numpy(), 0.0)

    def test_training_mode_shape(self):
        # In training mode, output shape must strictly match input shape
        inp = tf.ones((4, 224, 224, 3), dtype=tf.float32) * 150.0
        out = apply_augmentation(inp, is_training=True)
        self.assertEqual(out.shape, inp.shape)


if __name__ == "__main__":
    unittest.main()
