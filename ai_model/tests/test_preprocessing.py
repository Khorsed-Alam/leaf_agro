"""
Unit tests for Image Preprocessing Module.
Phase 34: Image Preprocessing, Normalization & Data Augmentation.
"""

import sys
from pathlib import Path
PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))

import unittest
import numpy as np
from PIL import Image
from ai_model.src.preprocessing import (
    convert_to_rgb,
    resize_image,
    validate_image,
    preprocess_for_mobilenetv2,
    prepare_single_image,
)
from ai_model.src.config import IMAGE_SIZE


class TestPreprocessing(unittest.TestCase):
    def test_rgb_conversion(self):
        # Grayscale
        gray = Image.new("L", (100, 100), color=128)
        rgb_from_gray = convert_to_rgb(gray)
        self.assertEqual(rgb_from_gray.mode, "RGB")
        self.assertEqual(len(rgb_from_gray.getbands()), 3)

        # RGBA
        rgba = Image.new("RGBA", (100, 100), color=(255, 0, 0, 128))
        rgb_from_rgba = convert_to_rgb(rgba)
        self.assertEqual(rgb_from_rgba.mode, "RGB")
        self.assertEqual(len(rgb_from_rgba.getbands()), 3)

    def test_dimensions(self):
        img = Image.new("RGB", (640, 480), color=(50, 100, 150))
        resized = resize_image(img, target_size=IMAGE_SIZE)
        self.assertEqual(resized.size, (224, 224))

    def test_validation(self):
        valid_img = Image.new("RGB", (100, 100))
        self.assertTrue(validate_image(valid_img))

    def test_pixel_range_and_dtype(self):
        img = Image.new("RGB", (256, 256), color=(200, 100, 50))
        tensor = prepare_single_image(img, for_model_input=True)
        self.assertEqual(tensor.shape, (1, 224, 224, 3))
        self.assertEqual(tensor.dtype, np.float32)
        self.assertGreaterEqual(np.min(tensor), 0.0)
        self.assertLessEqual(np.max(tensor), 255.0)

    def test_mobilenetv2_normalization_formula(self):
        raw_pixels = np.array([0.0, 127.5, 255.0], dtype=np.float32)
        norm = preprocess_for_mobilenetv2(raw_pixels)
        self.assertAlmostEqual(norm[0], -1.0, places=4)
        self.assertAlmostEqual(norm[1], 0.0, places=4)
        self.assertAlmostEqual(norm[2], 1.0, places=4)


if __name__ == "__main__":
    unittest.main()
