# AgriCare AI — Phase 35 Completion Report: Dataset Splitting & Leakage Prevention

## A. Project Inspection & Context
- **Project Name:** AgriCare AI (LeafAgro)
- **Phase:** Phase 35 – Train, Validation & Test Dataset Splitting
- **Framework & Stack:** Python 3.14, TensorFlow 2.22.0-rc0, Keras 3.16.0, Pillow 12.3.0
- **Upstream Artifacts Inspected:**
  - Phase 31: `ai_model/dataset/metadata/dataset_sources.csv`, `download_manifest.csv`
  - Phase 32: `ai_model/dataset/metadata/verified_class_mapping.csv`, `label_mapping.json` (19 verified standardized classes)
  - Phase 33: `ai_model/dataset/metadata/cleaning_manifest.csv`, `class_cleaning_summary.csv` (90 approved images across 9 PlantVillage classes; 10 Bangladeshi field classes pending manual download)
  - Phase 34: `ai_model/src/config.py`, `preprocessing.py`, `augmentation.py`, `dataset.py`, `reports/preprocessing_contract.md`
- **Reused Components:**
  - Canonical 19-class alphabetical indexing from `config.py`
  - MobileNetV2 single-rescaling contract from `preprocessing_contract.md`
  - Memory-safe `tf.data` pipeline generation from `dataset.py`

---

## B. Dataset Statistics & Partition Distribution

### Overall Partition Proportions

| Split Partition | Target Ratio | Actual Image Count | Actual Percentage | Independent Group Count | Leakage Rate |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **Training (`train`)** | 70.0% | **63** | **70.00%** | 63 groups | **0.0%** |
| **Validation (`validation`)** | 15.0% | **14** | **15.56%** | 14 groups | **0.0%** |
| **Testing (`test`)** | 15.0% | **13** | **14.44%** | 13 groups | **0.0%** |
| **Total** | 100.0% | **90** | **100.00%** | **90 groups** | **0.0%** |

### Class-by-Class Breakdown (9 Active Standardized Classes)

| Class Index | Standardized Class Name | Total Images | Independent Groups | Train Images (70%) | Val Images (~15%) | Test Images (~15%) | Readiness Status |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :--- |
| **4** | `Potato___Early_blight` | 10 | 10 | 7 | 2 | 1 | SUFFICIENT_FOR_PILOT_BENCHMARK |
| **5** | `Potato___healthy` | 10 | 10 | 7 | 1 | 2 | SUFFICIENT_FOR_PILOT_BENCHMARK |
| **6** | `Potato___Late_blight` | 10 | 10 | 7 | 2 | 1 | SUFFICIENT_FOR_PILOT_BENCHMARK |
| **11** | `Tomato___Bacterial_spot` | 10 | 10 | 7 | 1 | 2 | SUFFICIENT_FOR_PILOT_BENCHMARK |
| **12** | `Tomato___Early_blight` | 10 | 10 | 7 | 2 | 1 | SUFFICIENT_FOR_PILOT_BENCHMARK |
| **13** | `Tomato___healthy` | 10 | 10 | 7 | 1 | 2 | SUFFICIENT_FOR_PILOT_BENCHMARK |
| **14** | `Tomato___Late_blight` | 10 | 10 | 7 | 2 | 1 | SUFFICIENT_FOR_PILOT_BENCHMARK |
| **15** | `Tomato___Leaf_Mold` | 10 | 10 | 7 | 1 | 2 | SUFFICIENT_FOR_PILOT_BENCHMARK |
| **16** | `Tomato___Septoria_leaf_spot` | 10 | 10 | 7 | 2 | 1 | SUFFICIENT_FOR_PILOT_BENCHMARK |

*Note: The remaining 10 standardized classes for Rice, Mango, and Jute have 0 local images pending manual extraction of field archives, cataloged with status `INSUFFICIENT_ZERO_SAMPLES` in `split_summary.csv`.*

---

## C. Independent Leakage Audit Results
Audited via `ai_model/src/validate_splits.py` across all 90 records:

1. **Exact Duplicate Leakage (SHA-256):**
   - Collisions between Train and Validation: **0**
   - Collisions between Train and Test: **0**
   - Collisions between Validation and Test: **0**
   - Status: **PASSED (100% Leakage-Free)**
2. **Perceptual Near-Duplicate Leakage (pHash Hamming distance $\le 4$):**
   - Cross-split near-duplicate pairs: **0**
   - Status: **PASSED (100% Leakage-Free)**
3. **Group Integrity Leakage:**
   - Specimen/session group IDs shared across partitions: **0**
   - Status: **PASSED (100% Leakage-Free)**
4. **Manifest Integrity:**
   - Missing files: **0**
   - Image hash mismatches: **0**
   - Duplicate image IDs: **0**
   - Status: **PASSED**
5. **Image Decodability & Quality:**
   - Successfully decoded: **90 / 90 (100%)**
   - Sub-threshold dimensions ($< 64 \times 64$): **0**
   - Status: **PASSED**

---

## D. Implementation Details
1. **Splitting Algorithm:**
   - Group-Aware Stratified Partitioning implemented in `ai_model/src/split_dataset.py`.
   - Seed: `RANDOM_SEED = 42` (with deterministic class index offset for uniform group shuffling).
   - Groups are held atomic; images from the same specimen/series never cross partition boundaries.
2. **Image Storage Strategy:**
   - **Canonical Manifest:** `ai_model/dataset/processed/metadata/split_manifest.csv`
   - **Physical Partition Directories:** Structured under `ai_model/dataset/processed/{train,validation,test}/<class_name>/` enabling both directory-based and manifest-based `tf.data` workflows.
3. **TensorFlow & MobileNetV2 Compatibility:**
   - Preprocessing: Bilinear resize to $224 \times 224 \times 3$, `float32` range $[0.0, 255.0]$ before model.
   - Normalization: Executed strictly once inside the model graph via `layers.Rescaling(1/127.5, offset=-1.0)`.
   - Augmentation: Applied dynamically strictly on the training partition; disabled on validation and test partitions.

---

## E. Automated Testing Summary
- **Test Discovery:** `python -m unittest discover -s ai_model/tests -p "test_*.py"`
- **Total Tests Executed:** **18**
- **Tests Passed:** **18 (100%)**
- **Tests Failed:** **0**
- **Tests Skipped:** **0**
- **Execution Time:** **0.574 seconds**

---

## F. Final Readiness Decision

- **Phase 35 Status:** **COMPLETED**
- **Dataset Ready for Phase 36 (Model Architecture & Baseline Evaluation):** **YES (WITH DOCUMENTED PILOT LIMITATIONS)**
- **Model Training Started:** **NO**

### Documented Limitations & Safeguards
1. **Sample Size:** 90 approved images across 9 active classes provide an ideal pilot testbed for benchmarking MobileNetV2 training scripts, loss convergence, and Android TFLite pipeline testing. Full production training will require incorporating the remaining Bangladeshi field archives once extracted.
2. **Group Independence Guarantee:** Verified against all known specimen tags, SHA-256 hashes, and perceptual hashes.
