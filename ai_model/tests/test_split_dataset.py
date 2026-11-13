"""
Unit tests for Dataset Splitting Module.
Phase 35: Train, Validation & Test Dataset Splitting.
"""

import sys
import unittest
import csv
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))

from ai_model.src.split_dataset import construct_group_id
from ai_model.src.config import PROCESSED_DATASET_DIR

SPLIT_METADATA_DIR = PROCESSED_DATASET_DIR / "metadata"
SPLIT_MANIFEST_PATH = SPLIT_METADATA_DIR / "split_manifest.csv"
SPLIT_SUMMARY_PATH = SPLIT_METADATA_DIR / "split_summary.csv"


class TestSplitDataset(unittest.TestCase):
    def test_manifest_exists_and_complete(self):
        self.assertTrue(SPLIT_MANIFEST_PATH.exists(), "split_manifest.csv must exist")
        with open(SPLIT_MANIFEST_PATH, "r", encoding="utf-8") as f:
            records = list(csv.DictReader(f))
        self.assertEqual(len(records), 90, "Expected exactly 90 approved records in manifest")

    def test_group_construction(self):
        sample_rec = {
            "original_file_name": "001187a0-57ab-4329-baff-e7246a9edeb0___RS_Early.B 8178.JPG",
            "dataset_name": "plantvillage",
            "exact_duplicate_group": "NONE",
            "near_duplicate_group": "NONE"
        }
        gid, method = construct_group_id(sample_rec)
        self.assertTrue(gid.startswith("GRP_PLANTVILLAGE_RS_Early_B_8178"))
        self.assertEqual(method, "SPECIMEN_SERIES_TAG")

    def test_groups_remain_intact(self):
        with open(SPLIT_MANIFEST_PATH, "r", encoding="utf-8") as f:
            records = list(csv.DictReader(f))
        group_to_splits = {}
        for r in records:
            gid = r["group_id"]
            sp = r["split"]
            if gid not in group_to_splits:
                group_to_splits[gid] = set()
            group_to_splits[gid].add(sp)
        # Verify no group spans multiple splits
        for gid, splits in group_to_splits.items():
            self.assertEqual(len(splits), 1, f"Group {gid} spans multiple splits: {splits}")

    def test_split_summary_proportions(self):
        self.assertTrue(SPLIT_SUMMARY_PATH.exists(), "split_summary.csv must exist")
        with open(SPLIT_SUMMARY_PATH, "r", encoding="utf-8") as f:
            summary = list(csv.DictReader(f))
        self.assertEqual(len(summary), 19, "Expected 19 classes in split summary")
        active = [s for s in summary if int(s["total_images"]) > 0]
        self.assertEqual(len(active), 9, "Expected 9 active classes with images")

        total_train = sum(int(s["training_images"]) for s in active)
        total_val = sum(int(s["validation_images"]) for s in active)
        total_test = sum(int(s["testing_images"]) for s in active)

        self.assertEqual(total_train, 63, "Expected 63 train images (70%)")
        self.assertEqual(total_val, 14, "Expected 14 val images (15.56%)")
        self.assertEqual(total_test, 13, "Expected 13 test images (14.44%)")


if __name__ == "__main__":
    unittest.main()

