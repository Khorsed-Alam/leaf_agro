# AgriCare AI — Phase 38 Model Training & Fine-Tuning Report

---

## A. Dataset Overview

- **Target Agricultural Classes:** 19 verified classes
- **Active Pilot Classes:** 9 classes
- **Zero-Sample Baseline Classes (Documented Limitation):** 10 classes
- **Total Training Images:** 63
- **Total Validation Images:** 14
- **Independent Test Images:** 13 *(Strictly preserved for Phase 39; zero leakage)*
- **Class Imbalance Ratio:** 1.0:1
- **Class Weighting Applied:** No (Equal per-class pilot distribution)

### Per-Class Training & Validation Distribution

| Standardized Class Name | Train Samples | Validation Samples |
| :--- | :---: | :---: |
| `Potato___Early_blight` | 7 | 2 |
| `Potato___Late_blight` | 7 | 1 |
| `Potato___healthy` | 7 | 2 |
| `Tomato___Bacterial_spot` | 7 | 1 |
| `Tomato___Early_blight` | 7 | 2 |
| `Tomato___Late_blight` | 7 | 1 |
| `Tomato___Leaf_Mold` | 7 | 2 |
| `Tomato___Septoria_leaf_spot` | 7 | 1 |
| `Tomato___healthy` | 7 | 2 |

## B. Model Architecture & Preprocessing Contract

- **Backbone:** MobileNetV2 with ImageNet pretrained weights
- **Input Dimensions:** 224 $\times$ 224 $\times$ 3 (RGB)
- **Preprocessing Contract:** Raw $[0.0, 255.0]$ float32 pixel values feeding internal `layers.Rescaling(1/127.5, offset=-1.0)`
- **Classifier Head:** `GlobalAveragePooling2D` $\to$ `Dropout(0.3)` $\to$ `Dense(19, softmax)`
- **Total Model Parameters:** 2,282,323 (~8.71 MB float32)
- **Stage A Trainable Parameters:** 24,339
- **Stage B Trainable Parameters:** 1,863,955

## C. Training Environment & Hardware

- **Operating System:** Windows 11 (Version: 10.0.26300)
- **Python Version:** 3.14.6
- **TensorFlow Version:** 2.22.0-rc0
- **Execution Hardware:** Native Windows CPU (`/physical_device:CPU:0`)
- **Batch Size:** 16
- **Random Seed:** 42

## D. Stage A — Feature Extraction Results

- **Status:** COMPLETED
- **Epochs Executed:** 15
- **Best Validation Loss:** 1.0879
- **Best Validation Accuracy:** 0.7857
- **Checkpoint Path:** `stage_a_best.keras`
- **Duration:** 19.75 seconds

## E. Stage B — Controlled Fine-Tuning Results

- **Status:** COMPLETED
- **Cutoff Layer:** Unfrozen from index $\ge 100$ (BatchNorm frozen)
- **Learning Rate:** 1e-05
- **Epochs Executed:** 10
- **Best Validation Loss:** 0.8588
- **Best Validation Accuracy:** 0.8571
- **Checkpoint Path:** `stage_b_best.keras`
- **Duration:** 15.20 seconds

## F. Final Validation-Based Model Selection

- **Selected Checkpoint:** `F:\leaf_agro\ai_model\models\checkpoints\stage_b_best.keras`
- **Selected Stage:** **Stage B (Fine-Tuning)**
- **Validation Loss:** 0.8588
- **Validation Accuracy:** 0.8571
- **Selection Rule:** Validation loss minimization on unaugmented validation images.
- **Deployed Model:** `best_model.keras`

## G. Overfitting & Convergence Observations

1. **Feature Extraction Convergence:** In Stage A, the frozen backbone provided reliable feature representations, enabling rapid reduction in cross-entropy loss without gradient explosions.
2. **Batch Normalization Safeguard:** Keeping all BatchNormalization layers frozen during Stage B fine-tuning successfully prevented statistical drift on the pilot batch size.
3. **Early Stopping & Weight Restoration:** Best weights were restored automatically based on validation loss, protecting against late-epoch overfitting.

## H. Documented Limitations & Next Steps

1. **Pilot Dataset Size:** Current training executed on the 90-image pilot set across 9 active classes. Full production model scaling will require extracting the remaining Bangladeshi field collections (Rice, Mango, Jute) once local archives are decompressed.
2. **Phase 39 Evaluation Readiness:** The test dataset remains 100% untouched and isolated, ready for unbiased generalization evaluation in Phase 39.
