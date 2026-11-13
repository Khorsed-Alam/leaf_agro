"""
AgriCare AI — Configuration and Reproducibility Unit Tests.
Phase 36: Environment Setup & Infrastructure.
"""

import unittest
from pathlib import Path
from ai_model.src.config import (
    PROJECT_ROOT,
    BASE_DIR,
    DATASET_DIR,
    METADATA_DIR,
    PROCESSED_METADATA_DIR,
    SPLIT_MANIFEST_PATH,
    CLASS_MAPPING_PATH,
    IMAGE_SIZE,
    CHANNELS,
    NUM_CLASSES,
    CLASSES,
    validate_directories,
    set_reproducibility,
)


class TestEnvironmentConfig(unittest.TestCase):

    def test_directory_validation(self):
        """Verifies that all core project and dataset directories exist."""
        status_map = validate_directories()
        for dir_name, exists in status_map.items():
            self.assertTrue(exists, f"Directory/Path '{dir_name}' must exist")

    def test_class_definitions(self):
        """Verifies that classes are loaded dynamically and match the 19 standard classes."""
        self.assertEqual(NUM_CLASSES, 19, "Must have exactly 19 target agricultural classes")
        self.assertEqual(len(CLASSES), 19)

    def test_mobilenetv2_dimensions(self):
        """Verifies MobileNetV2 input specifications."""
        self.assertEqual(IMAGE_SIZE, (224, 224))
        self.assertEqual(CHANNELS, 3)

    def test_reproducibility_initialization(self):
        """Verifies setting seeds for random, numpy, and tensorflow."""
        status = set_reproducibility(seed=42)
        self.assertEqual(status["seed"], 42)
        self.assertTrue(status["python_random_set"])
        self.assertTrue(status["numpy_seed_set"])
        self.assertTrue(status["tensorflow_seed_set"])


if __name__ == "__main__":
    unittest.main()

