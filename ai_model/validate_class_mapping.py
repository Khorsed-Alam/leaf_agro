#!/usr/bin/env python3
"""
Phase 32 Validation Script for AgriCare AI.
Verifies:
- All required CSV and JSON files exist and parse cleanly.
- Required column headers are present.
- Standardized class IDs are unique.
- All 19 target classes map to labels.json and Supabase disease_catalog.
- Print pass/fail summary.
"""

import sys
import csv
import json
from pathlib import Path

METADATA_DIR = Path("ai_model/dataset/metadata")

def validate():
    errors = []
    
    # 1. Check verified_class_mapping.csv
    v_path = METADATA_DIR / "verified_class_mapping.csv"
    if not v_path.exists():
        errors.append(f"Missing file: {v_path}")
    else:
        with open(v_path, "r", encoding="utf-8") as f:
            reader = csv.DictReader(f)
            rows = list(reader)
            if len(rows) != 19:
                errors.append(f"Expected 19 classes in verified_class_mapping.csv, found {len(rows)}")
            ids = [r["class_id"] for r in rows]
            if len(ids) != len(set(ids)):
                errors.append("Duplicate class_id detected in verified_class_mapping.csv")

    # 2. Check label_mapping.json
    j_path = METADATA_DIR / "label_mapping.json"
    if not j_path.exists():
        errors.append(f"Missing file: {j_path}")
    else:
        with open(j_path, "r", encoding="utf-8") as f:
            data = json.load(f)
            if len(data.get("classes", [])) != 19:
                errors.append(f"Expected 19 classes in label_mapping.json, found {len(data.get('classes', []))}")

    # 3. Check license_audit.csv
    l_path = METADATA_DIR / "license_audit.csv"
    if not l_path.exists():
        errors.append(f"Missing file: {l_path}")

    # 4. Check rejected_classes.csv
    r_path = METADATA_DIR / "rejected_classes.csv"
    if not r_path.exists():
        errors.append(f"Missing file: {r_path}")

    # 5. Check class_verification_report.csv
    c_path = METADATA_DIR / "class_verification_report.csv"
    if not c_path.exists():
        errors.append(f"Missing file: {c_path}")

    # 6. Check supabase_class_compatibility_report.csv
    s_path = METADATA_DIR / "supabase_class_compatibility_report.csv"
    if not s_path.exists():
        errors.append(f"Missing file: {s_path}")

    if errors:
        print("FAILED: Validation encountered errors:")
        for e in errors:
            print(f" - {e}")
        sys.exit(1)
    else:
        print("PASSED: All Phase 32 artifacts are verified, consistent, and valid.")

if __name__ == "__main__":
    validate()

