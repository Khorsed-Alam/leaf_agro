# AgriCare AI — Phase 35: Dataset Splitting & Leakage Prevention Report

## 1. Executive Summary
- **Project Name:** AgriCare AI (LeafAgro)
- **Phase:** Phase 35 – Train, Validation & Test Dataset Splitting
- **Execution Date:** 2026-11-13T15:11:27.082124+00:00
- **Pipeline Version:** 1.0.0-phase35
- **Random Seed:** 42
- **Input Manifest Fingerprint:** `bf936ec8aba0cb76c32c6239...`

---

## 2. Partition Summary & Proportions

| Split Partition | Target Ratio | Actual Image Count | Actual Percentage | Independent Group Count |
| :--- | :---: | :---: | :---: | :---: |
| **Training** | 70.0% | **63** | **70.0%** | 63 groups |
| **Validation** | 15.0% | **14** | **15.56%** | 14 groups |
| **Testing** | 15.0% | **13** | **14.44%** | 13 groups |
| **Total** | 100.0% | **90** | **100.0%** | **90 groups** |

---

## 3. Class-by-Class Partition Distribution

### Active Standardized Classes (PlantVillage Benchmark)

| Class ID | Standardized Class Name | Total Images | Groups | Train | Val | Test | Train % | Val % | Test % | Readiness |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :--- |
| 6 | `Potato___Early_blight` | 10 | 10 | 7 | 2 | 1 | 70.0% | 20.0% | 10.0% | SUFFICIENT_FOR_PILOT_BENCHMARK |
| 7 | `Potato___Late_blight` | 10 | 10 | 7 | 1 | 2 | 70.0% | 10.0% | 20.0% | SUFFICIENT_FOR_PILOT_BENCHMARK |
| 8 | `Potato___healthy` | 10 | 10 | 7 | 2 | 1 | 70.0% | 20.0% | 10.0% | SUFFICIENT_FOR_PILOT_BENCHMARK |
| 13 | `Tomato___Bacterial_spot` | 10 | 10 | 7 | 1 | 2 | 70.0% | 10.0% | 20.0% | SUFFICIENT_FOR_PILOT_BENCHMARK |
| 14 | `Tomato___Early_blight` | 10 | 10 | 7 | 2 | 1 | 70.0% | 20.0% | 10.0% | SUFFICIENT_FOR_PILOT_BENCHMARK |
| 15 | `Tomato___Late_blight` | 10 | 10 | 7 | 1 | 2 | 70.0% | 10.0% | 20.0% | SUFFICIENT_FOR_PILOT_BENCHMARK |
| 16 | `Tomato___Leaf_Mold` | 10 | 10 | 7 | 2 | 1 | 70.0% | 20.0% | 10.0% | SUFFICIENT_FOR_PILOT_BENCHMARK |
| 17 | `Tomato___Septoria_leaf_spot` | 10 | 10 | 7 | 1 | 2 | 70.0% | 10.0% | 20.0% | SUFFICIENT_FOR_PILOT_BENCHMARK |
| 18 | `Tomato___healthy` | 10 | 10 | 7 | 2 | 1 | 70.0% | 20.0% | 10.0% | SUFFICIENT_FOR_PILOT_BENCHMARK |

### Conditionally Approved Classes Pending Archive Extraction (Bangladesh Field Datasets)

| Class Index | Standardized Class Name | Total Images | Independent Groups | Status |
| :---: | :--- | :---: | :---: | :--- |
| 0 | `Jute___Anthracnose` | 0 | 0 | Pending Manual Archive Extraction |
| 1 | `Jute___Stem_rot` | 0 | 0 | Pending Manual Archive Extraction |
| 2 | `Jute___healthy` | 0 | 0 | Pending Manual Archive Extraction |
| 3 | `Mango___Anthracnose` | 0 | 0 | Pending Manual Archive Extraction |
| 4 | `Mango___Bacterial_canker` | 0 | 0 | Pending Manual Archive Extraction |
| 5 | `Mango___healthy` | 0 | 0 | Pending Manual Archive Extraction |
| 9 | `Rice___Bacterial_leaf_blight` | 0 | 0 | Pending Manual Archive Extraction |
| 10 | `Rice___Brown_spot` | 0 | 0 | Pending Manual Archive Extraction |
| 11 | `Rice___Leaf_smut` | 0 | 0 | Pending Manual Archive Extraction |
| 12 | `Rice___healthy` | 0 | 0 | Pending Manual Archive Extraction |

---

## 4. Leakage-Prevention Strategy
1. **Specimen & Series Boundary Isolation:**
   - Every PlantVillage specimen is assigned a stable group ID derived from its capture series identifier (`GRP_PLANTVILLAGE_<SERIES_TAG>`).
   - All images sharing a group are placed exclusively into one partition.
   - Zero exact duplicate hashes (SHA-256) cross split boundaries.
   - Zero perceptual near-duplicates (pHash) cross split boundaries.
2. **Deterministic Class Stratification:**
   - A deterministic random seed (`42`) and class index offset ensure 100% reproducible group assignment.
   - Class representation is preserved across train, validation, and test splits without artificial duplication or synthetic image fabrication.

---

## 5. Storage Strategy
- **Manifest-Based Loading:** Canonical reference via `split_manifest.csv` pointing to verified image paths.
- **Physical Partition Directories:** Structured under `ai_model/dataset/processed/{train,validation,test}/<class_name>/` for direct compatibility with standard directory-based Keras utilities.
