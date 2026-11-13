# AgriCare AI — Phase 34 Preprocessing & Normalization Report

## 1. Executive Summary
- **Project:** AgriCare AI (LeafAgro)
- **Phase:** Phase 34 – Image Preprocessing, Normalization & Data Augmentation
- **Target Architecture:** MobileNetV2 ($224 \times 224 \times 3$)
- **Execution Date:** 2026-11-13T15:05:19.612143+00:00
- **Python Version:** 3.14.6
- **TensorFlow Version:** 2.22.0-rc0
- **Keras Version:** 3.16.0.dev2026111303

---

## 2. Dataset & Image Inventory
- **Approved Source Images:** 90 images (from Phase 33 verified cleaning pipeline).
- **Successfully Decoded & Processed:** 90 images (100%).
- **Failed Images:** 0.
- **Active Standardized Classes:** 19 target classes.

### Distribution by Standardized Class

| Class Name | Approved Sample Count | Status |
| :--- | :---: | :--- |
| `Rice___Bacterial_leaf_blight` | 0 | Pending Manual Archive Extraction (0) |
| `Rice___Brown_spot` | 0 | Pending Manual Archive Extraction (0) |
| `Rice___Leaf_smut` | 0 | Pending Manual Archive Extraction (0) |
| `Rice___healthy` | 0 | Pending Manual Archive Extraction (0) |
| `Potato___Early_blight` | 10 | **Ready (10/10)** |
| `Potato___Late_blight` | 10 | **Ready (10/10)** |
| `Potato___healthy` | 10 | **Ready (10/10)** |
| `Tomato___Bacterial_spot` | 10 | **Ready (10/10)** |
| `Tomato___Early_blight` | 10 | **Ready (10/10)** |
| `Tomato___Late_blight` | 10 | **Ready (10/10)** |
| `Tomato___Leaf_Mold` | 10 | **Ready (10/10)** |
| `Tomato___Septoria_leaf_spot` | 10 | **Ready (10/10)** |
| `Tomato___healthy` | 10 | **Ready (10/10)** |
| `Mango___Anthracnose` | 0 | Pending Manual Archive Extraction (0) |
| `Mango___Bacterial_canker` | 0 | Pending Manual Archive Extraction (0) |
| `Mango___healthy` | 0 | Pending Manual Archive Extraction (0) |
| `Jute___Stem_rot` | 0 | Pending Manual Archive Extraction (0) |
| `Jute___Anthracnose` | 0 | Pending Manual Archive Extraction (0) |
| `Jute___healthy` | 0 | Pending Manual Archive Extraction (0) |

---

## 3. Preprocessing Specifications & Contract

| Parameter | Specification | Verification Result |
| :--- | :--- | :--- |
| **Input Shape** | $224 \times 224 \times 3$ | **PASSED** (Strict bilinear resizing) |
| **Color Mode** | 3-Channel RGB | **PASSED** (Grayscale & RGBA automatically unified) |
| **Data Type** | `float32` | **PASSED** |
| **External Pixel Range** | $[0.0, 255.0]$ | **PASSED** |
| **Normalization Method** | MobileNetV2 `(x / 127.5) - 1.0` | **PASSED** |
| **Normalization Location** | Inside Model Graph (`layers.Rescaling`) | **PASSED** (Single step) |
| **Double Normalization Prevention** | External pipeline preserves $[0, 255]$ | **PASSED** (Strictly zero duplicate rescaling) |
| **Augmentation Mode** | Training-Only | **PASSED** (Inactive during validation/inference) |

---

## 4. Biologically Safe Data Augmentation
All transformations are implemented as Keras Sequential layers (`ai_model/src/augmentation.py`) and executed dynamically only when `training=True`:
1. **Horizontal Flip (`layers.RandomFlip("horizontal")`):** Retains biological leaf bilateral symmetry while doubling variation.
2. **Controlled Rotation (`layers.RandomRotation(0.03)`):** Small $\pm 10^\circ$ orientation variation without clipping leaf edges.
3. **Moderate Zoom (`layers.RandomZoom((-0.1, 0.1))`):** $0.90\times$ to $1.10\times$ scale mirroring real-world field camera distances.
4. **Small Translation (`layers.RandomTranslation(0.05, 0.05)`):** $\pm 5\%$ translation simulating imperfect leaf centring.
5. **Controlled Brightness (`layers.RandomBrightness(0.1)`):** $\pm 10\%$ luminance variation reflecting changing cloud cover and sunlight.
6. **Controlled Contrast (`layers.RandomContrast(0.1)`):** $\pm 10\%$ contrast adjusting for camera sensor variations.

---

## 5. Automated Verification Results

| Test Category | Executed Test Function | Result |
| :--- | :--- | :---: |
| **RGB Conversion** | `test_rgb_conversion` | **PASSED** |
| **Dimensions** | `test_dimensions` | **PASSED** |
| **Data Type** | `test_pixel_range_and_dtype` | **PASSED** |
| **Pixel Range** | `test_mobilenetv2_normalization_formula` | **PASSED** |
| **Label Alignment** | `test_label_encoding_stability` | **PASSED** |
| **Reproducibility** | `run_all_validation_checks (diff == 0.0)` | **PASSED** |
| **Augmentation Policy** | `test_eval_mode_inactivity` | **PASSED** |
| **Normalization Count** | Single inside-model normalization check | **PASSED** |
| **Layer Serialization** | Model config serialization round-trip | **PASSED** |

---

## 6. Prohibited Operations Compliance
- [x] **No model training performed.**
- [x] **No fine-tuning executed.**
- [x] **No train/val/test splitting performed.**
- [x] **Original and approved images unmodified.**
- [x] **No augmented images saved as persistent originals.**
- [x] **No Supabase or Android code changed.**
