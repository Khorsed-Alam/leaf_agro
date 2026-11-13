# AgriCare AI — Phase 37 Completion Report
**MobileNetV2 Transfer Learning Model Architecture**

---

## A. Project Inspection Summary

* **Previous-Phase Artifacts Inspected & Verified:**
  * Phase 31 & 32: Verified 19-class disease catalog ([verified_class_mapping.csv](file:///F:/leaf_agro/ai_model/dataset/metadata/verified_class_mapping.csv)).
  * Phase 33: Cleaned and quality-controlled image repository ([cleaning_manifest.csv](file:///F:/leaf_agro/ai_model/dataset/metadata/cleaning_manifest.csv)).
  * Phase 34: Input preprocessing contract ($224 \times 224 \times 3$, `float32`, RGB, range $[0.0, 255.0]$) in `preprocessing.py` and `augmentation.py`.
  * Phase 35: Leakage-resistant train, validation, and test split manifests ([split_manifest.csv](file:///F:/leaf_agro/ai_model/dataset/processed/metadata/split_manifest.csv)).
  * Phase 36: Verified Python `3.14.6` virtual environment (`.venv`), TensorFlow `2.22.0-rc0`, and unified `dataset_loader.py`.
* **Existing Modules Reused:** `config.py`, `dataset_loader.py`, `preprocessing.py`, `augmentation.py`.
* **Missing Prerequisites or Inconsistencies:** None. All prerequisites verified and tested.

---

## B. Class Information & Label Mapping

* **Actual Verified Class Count:** Exactly **19** classes across 5 target crops (Rice, Potato, Tomato, Mango, Jute).
* **Labels File Generated:** [labels.json](file:///F:/leaf_agro/ai_model/models/labels.json)
* **Class Ordering Validation:** Deterministic, stable ordering preserved identically from Phase 32.
* **Verified Disease Classes:**
  1. `Rice___Bacterial_leaf_blight` (index 0)
  2. `Rice___Brown_spot` (index 1)
  3. `Rice___Leaf_smut` (index 2)
  4. `Rice___healthy` (index 3)
  5. `Potato___Early_blight` (index 4)
  6. `Potato___Late_blight` (index 5)
  7. `Potato___healthy` (index 6)
  8. `Tomato___Bacterial_spot` (index 7)
  9. `Tomato___Early_blight` (index 8)
  10. `Tomato___Late_blight` (index 9)
  11. `Tomato___Leaf_Mold` (index 10)
  12. `Tomato___Septoria_leaf_spot` (index 11)
  13. `Tomato___healthy` (index 12)
  14. `Mango___Anthracnose` (index 13)
  15. `Mango___Bacterial_canker` (index 14)
  16. `Mango___healthy` (index 15)
  17. `Jute___Stem_rot` (index 16)
  18. `Jute___Anthracnose` (index 17)
  19. `Jute___healthy` (index 18)
* **Supabase 1:1 Compatibility:** All 19 class names match the production PostgreSQL schema (`disease_catalog.class_name`).

---

## C. Model Architecture Specification

* **Model Name:** `AgriCare_MobileNetV2`
* **Backbone:** `MobileNetV2` with `include_top=False`, $\alpha=1.0$, input shape `(224, 224, 3)`.
* **Internal Preprocessing Layer:** Embedded `layers.Rescaling(scale=1.0/127.5, offset=-1.0, name="mobilenetv2_rescaling")`.
  * Receives raw $[0.0, 255.0]$ RGB float32 pixels.
  * Linearly rescales to $[-1.0, 1.0]$ inside the model graph.
  * Applied exactly **once**. Zero double normalization risk.
* **Classifier Head:**
  * `GlobalAveragePooling2D(name="global_avg_pool")`
  * `Dropout(rate=0.3, name="head_dropout")`
  * `Dense(units=19, activation="softmax", name="predictions")`
* **Output Tensor Shape:** `(None, 19)`

---

## D. Model Parameters & Size Analysis

* **Total Parameters:** **2,282,323**
* **Estimated Model Size:** **8.71 MB** (float32 parameters)
* **Stage A (Feature Extraction) Parameter Allocation:**
  * **Trainable Parameters:** **24,339** (Classifier head only: $1280 \times 19 + 19$)
  * **Non-trainable Parameters:** **2,257,984** (Frozen MobileNetV2 backbone)
* **Stage B (Fine-Tuning) Parameter Allocation (cutoff $\ge 100$):**
  * **Trainable Parameters:** **1,863,955** (Upper conv blocks + Classifier head)
  * **Non-trainable Parameters:** **418,368** (Lower conv blocks + Frozen BatchNormalization layers)

---

## E. Pretrained Weights Status

* **Weights Initialized:** `weights="imagenet"`
* **Status:** Verified and loaded from local cache (`~/.keras/models/mobilenet_v2_weights_tf_dim_ordering_tf_kernels_1.0_224_no_top.h5`).
* **Random Initialization Used:** No. Official pretrained ImageNet weights successfully integrated.

---

## F. Test Results & Architecture Validation

Executed via [model_utils.py](file:///F:/leaf_agro/ai_model/src/model_utils.py) and [test_model.py](file:///F:/leaf_agro/ai_model/tests/test_model.py):

| Test ID | Test Description | Result | Details |
| :--- | :--- | :--- | :--- |
| **A** | Environment Test | **PASS** | TF `2.22.0-rc0`, Keras 3, CPU verified |
| **B** | Model Construction Test | **PASS** | MobileNetV2 + Head built (154 backbone layers) |
| **C** | Input Shape Test | **PASS** | Verified `(None, 224, 224, 3)` |
| **D** | Output Shape Test | **PASS** | Verified `(None, 19)` |
| **E** | Dummy Forward Pass Test | **PASS** | Finite, no NaNs, softmax sums $\approx 1.0$ ($\pm 1\text{e-}5$) |
| **F** | Transfer Learning Stages | **PASS** | Stage A: 24,339 trainable; Stage B: 1,863,955 trainable (BatchNorm frozen) |
| **G** | Model Save & Reload Test | **PASS** | Saved to `.keras`, reloaded, max abs diff $< 1\text{e-}5$ |
| **H** | Class Mapping Labels Test | **PASS** | 19 unique labels in `labels.json`, zero duplicates |
| **I** | Summary & Metadata Test | **PASS** | Generated `model_summary.txt` and `model_architecture.json` |

* **Full Automated Test Suite:** **35 / 35 tests passed (100%)** across all modules.

---

## G. Files Created or Modified

1. [ai_model/src/model.py](file:///F:/leaf_agro/ai_model/src/model.py): Implements `build_model`, `build_feature_extraction_model`, `configure_fine_tuning`, `compile_model`, `get_model_summary`, and `validate_model_output`.
2. [ai_model/src/model_utils.py](file:///F:/leaf_agro/ai_model/src/model_utils.py): Architecture serialization, labels audit, and 9-point validation engine.
3. [ai_model/src/config.py](file:///F:/leaf_agro/ai_model/src/config.py): Configured `DROPOUT_RATE = 0.3`, `LEARNING_RATE = 0.001`, `FINE_TUNE_LEARNING_RATE = 0.00001`, `FINE_TUNE_AT_LAYER = 100`, and artifact paths.
4. [ai_model/models/labels.json](file:///F:/leaf_agro/ai_model/models/labels.json): Updated with structured 19-class dictionary and index mapping.
5. [ai_model/models/model_architecture.json](file:///F:/leaf_agro/ai_model/models/model_architecture.json): Full architecture configuration and parameter specification.
6. [ai_model/reports/model_summary.txt](file:///F:/leaf_agro/ai_model/reports/model_summary.txt): Human-readable model summary and layer table.
7. [ai_model/reports/architecture_validation.json](file:///F:/leaf_agro/ai_model/reports/architecture_validation.json): Diagnostic validation results.
8. [ai_model/notebooks/05_model_architecture.ipynb](file:///F:/leaf_agro/ai_model/notebooks/05_model_architecture.ipynb): Interactive educational notebook with 8 beginner-friendly code sections.
9. [ai_model/documentation/model_architecture.md](file:///F:/leaf_agro/ai_model/documentation/model_architecture.md): Complete architecture reference documentation.
10. [ai_model/tests/test_model.py](file:///F:/leaf_agro/ai_model/tests/test_model.py): 7 unit and integration tests for MobileNetV2 architecture.

---

## H. Training Readiness for Phase 38

* **Loss Function:** `sparse_categorical_crossentropy` (matching integer label output from `dataset_loader.py`).
* **Stage A Optimizer:** Adam (`learning_rate = 0.001`), frozen backbone.
* **Stage B Optimizer:** Adam (`learning_rate = 0.00001`), unfreezing layers $\ge 100$, with all `BatchNormalization` layers remaining frozen.
* **Model Training Started:** **`NO`** (Zero training executed).

---

## I. Phase Status

**Phase 37 Status:** **`COMPLETE`**  
All acceptance criteria have been satisfied with real, verified evidence.

---

## J. Phase 38 Readiness

**Ready for Phase 38 – Model Training and Fine-Tuning:** **`YES`**
