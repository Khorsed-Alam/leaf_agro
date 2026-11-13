# AgriCare AI — Phase 40: TensorFlow Lite Model Export & Optimization Report

## Executive Summary
This report documents the successful completion of **Phase 40: TensorFlow Lite Model Export & Optimization** for the **AgriCare AI** multi-crop plant disease detection system. The Stage B fine-tuned MobileNetV2 Keras model ([best_model.keras](file:///F:/leaf_agro/ai_model/models/best_model.keras)) was successfully converted and validated across three TensorFlow Lite formats (Float32 baseline, Float16 quantized, and full INT8 quantized). All exported models were tested against the validation dataset, verified for 100% operator compatibility with Android and Flutter (`tflite_flutter`), and staged into the Flutter application assets directory.

---

## 1. Implementation Status & Phase Boundaries
- **Phase Status:** **`COMPLETE`**
- **Strict Scope Boundaries Maintained:**
  - Zero model retraining or fine-tuning was performed.
  - No model weights or architecture were modified.
  - The independent Phase 35 test dataset was strictly preserved and never touched for quantization calibration. Calibration was performed exclusively on approved training samples.
  - Flutter detection business logic implementation was reserved for Phase 43; only asset staging was performed.

---

## 2. Source Model Inspection
- **Source Model Path:** `ai_model/models/best_model.keras`
- **Architecture:** MobileNetV2 Transfer Learning (`GlobalAveragePooling2D` $\rightarrow$ `Dropout(0.3)` $\rightarrow$ `Dense(19, softmax)`)
- **Input Tensor Specification:** `(None, 224, 224, 3)`, dtype: `float32`, color format: RGB, range: `[0.0, 255.0]`
- **Embedded Preprocessing Layer:** `mobilenetv2_rescaling (Rescaling)` with scale $= 1.0 / 127.5$ and offset $= -1.0$.
- **Output Tensor Specification:** `(None, 19)`, dtype: `float32`, activation: `softmax`
- **Total Parameters:** 2,591,315 (all intact)
- **Source Model File Size:** 23.50 MB (24,644,940 bytes)

---

## 3. TensorFlow Lite Model Conversions

Three distinct conversion modes were attempted and successfully generated:

| Model Format | Filename | Size (Bytes) | Size (MB) | Reduction vs Keras | Optimization Method | Deployment Role |
| :--- | :--- | :---: | :---: | :---: | :--- | :--- |
| **Keras Source** | `best_model.keras` | 24,644,940 | 23.50 MB | 0.00% | Full Float32 checkpoint | Baseline Training Artifact |
| **TFLite Float32** | `plant_disease_model.tflite` | 9,000,436 | **8.58 MB** | **-63.48%** | Graph freezing & stripping | **Primary Android Production Target** |
| **TFLite Float16** | `plant_disease_model_fp16.tflite`| 4,582,628 | **4.37 MB** | **-81.41%** | 16-bit float weight quantization | High-Performance GPU/NPU Candidate |
| **TFLite INT8** | `plant_disease_model_int8.tflite`| 2,761,136 | **2.63 MB** | **-88.80%** | Full integer quantization (train calib) | Ultra-Low RAM Edge Candidate |

---

## 4. Preprocessing Contract Preservation
- **Embedded Normalization:** The input layer (`mobilenetv2_rescaling`) is preserved directly inside the `.tflite` graph.
- **Flutter Input Contract:**
  - Resolution: $224 \times 224$ pixels.
  - Color Channels: 3 (Red, Green, Blue).
  - Tensor Data Type: `float32`.
  - Pixel Value Range: `[0.0, 255.0]`.
  - **Critical Android Instruction:** The Flutter app must **NOT** pre-normalize pixels to $[-1.0, 1.0]$ or $[0.0, 1.0]$. Passing standard unnormalized RGB float32 values allows the embedded rescaling layer to map values to $[-1.0, 1.0]$ internally, preventing double-normalization errors.

---

## 5. Output Classes & Label Mapping
The 19 canonical agricultural classes from `ai_model/models/labels.json` match the 19 output neurons with 1-to-1 fidelity:
- `00`: `Jute___Anthracnose`
- `01`: `Jute___Stem_rot`
- `02`: `Jute___healthy`
- `03`: `Mango___Anthracnose`
- `04`: `Mango___Bacterial_canker`
- `05`: `Mango___healthy`
- `06`: `Potato___Early_blight`
- `07`: `Potato___Late_blight`
- `08`: `Potato___healthy`
- `09`: `Rice___Bacterial_leaf_blight`
- `10`: `Rice___Brown_spot`
- `11`: `Rice___Leaf_smut`
- `12`: `Rice___healthy`
- `13`: `Tomato___Bacterial_spot`
- `14`: `Tomato___Early_blight`
- `15`: `Tomato___Late_blight`
- `16`: `Tomato___Leaf_Mold`
- `17`: `Tomato___Septoria_leaf_spot`
- `18`: `Tomato___healthy`

---

## 6. Model Validation & Numerical Sanity
All exported models were validated using the TensorFlow Lite Interpreter across all 14 images of the unaugmented validation split:

| Check | Float32 Model | Float16 Model | INT8 Model | Requirement |
| :--- | :---: | :---: | :---: | :--- |
| **Interpreter Initialization** | PASSED | PASSED | PASSED | Allocates tensors cleanly |
| **Input Tensor Shape** | `[1, 224, 224, 3]` | `[1, 224, 224, 3]` | `[1, 224, 224, 3]` | Exactly matches $224 \times 224 \times 3$ |
| **Output Tensor Shape** | `[1, 19]` | `[1, 19]` | `[1, 19]` | Exactly matches 19 classes |
| **Input Data Type** | `float32` | `float32` | `float32` | Standard floating point input |
| **Output Data Type** | `float32` | `float32` | `float32` | Softmax probability output |
| **Outputs Finite** | PASSED | PASSED | PASSED | Zero NaN or Inf values |
| **Outputs in Range [0, 1]** | PASSED | PASSED | PASSED | Valid probability bounds |
| **Softmax Sums to ~1.0** | PASSED | PASSED | PASSED | $\sum p_i = 1.0000$ |
| **Validation Set Accuracy** | **85.71%** | **85.71%** | **85.71%** | Matches Phase 38 validation acc |

---

## 7. Keras vs TensorFlow Lite Prediction Comparison
Extracted from [prediction_comparison.csv](file:///F:/leaf_agro/ai_model/reports/prediction_comparison.csv):

| Comparison | Samples Tested | Top-1 Agreement | Max Absolute Probability Diff | Mean Absolute Probability Diff | Fidelity Classification |
| :--- | :---: | :---: | :---: | :---: | :--- |
| **Keras vs TFLite Float32** | 14 / 14 | **100.0%** ($14/14$) | **0.000003** ($3 \times 10^{-6}$) | **0.000000** | **PERFECT_EQUIVALENCE** |
| **Keras vs TFLite Float16** | 14 / 14 | **100.0%** ($14/14$) | **0.012605** ($1.26\%$) | **0.000510** | **HIGH_FIDELITY** |
| **Keras vs TFLite INT8** | 14 / 14 | **92.86%** ($13/14$) | **0.216036** | **0.008345** | **ACCEPTABLE_QUANTIZATION** |

---

## 8. Inference Latency & Performance Benchmarking
Extracted from [tflite_benchmark.json](file:///F:/leaf_agro/ai_model/reports/tflite_benchmark.json):
- **Host Hardware:** AMD64 Family 25, Windows 11, TensorFlow 2.22.0-rc0, XNNPACK CPU Delegate.
- **Benchmark Parameters:** Batch size $= 1$, 10 warmup runs, 50 timed repeated runs.

| Model Format | Cold Init Latency | Mean Inference Latency | Median Latency | P95 Latency | Throughput |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **TFLite Float32** | 12.3 ms | **4.76 ms** | 4.66 ms | 5.21 ms | **210.2 inferences/sec** |
| **TFLite Float16** | 11.8 ms | **4.68 ms** | 4.59 ms | 5.12 ms | **213.9 inferences/sec** |
| **TFLite INT8** | 9.4 ms | **2.33 ms** | 2.33 ms | 2.62 ms | **428.9 inferences/sec** |

*Note: These benchmarks reflect desktop CPU execution with XNNPACK. Mobile execution on physical Android ARM hardware will be measured in Phase 44.*

---

## 9. Android & Flutter Compatibility
Operator audit of `plant_disease_model.tflite`:
- **Total Subgraph Operators:** 67
- **Distinct Operator Types:** 7
  - `ADD`
  - `CONV_2D`
  - `DEPTHWISE_CONV_2D`
  - `FULLY_CONNECTED`
  - `MEAN`
  - `MUL`
  - `SOFTMAX`
- **Flex / Select TF Operators:** **NONE (0)**
- **Custom Operators:** **NONE (0)**
- **Flutter Compatibility:** 100% compatible with the standard `tflite_flutter` plugin without requiring extra C++ shared libraries or Flex delegate binaries.

---

## 10. Flutter Deployment Asset Staging
The following verified assets were copied and staged into the Flutter project's `assets/models/` directory:
- [assets/models/plant_disease_model.tflite](file:///F:/leaf_agro/assets/models/plant_disease_model.tflite) (9,000,436 bytes)
- [assets/models/plant_disease_model_fp16.tflite](file:///F:/leaf_agro/assets/models/plant_disease_model_fp16.tflite) (4,582,628 bytes)
- [assets/models/labels.json](file:///F:/leaf_agro/assets/models/labels.json) (1,501 bytes)
- [assets/models/model_metadata.json](file:///F:/leaf_agro/assets/models/model_metadata.json) (2,248 bytes)

`pubspec.yaml` already declares `- assets/models/`, confirming asset discovery.

---

## 11. Automated Test Summary
All 8 automated tests in `ai_model/tests/test_tflite_export.py` and the complete 55-test suite passed:
```powershell
ai_model\.venv\Scripts\python.exe -m unittest discover -s ai_model/tests -p "test_*.py"
# Ran 55 tests in 5.210s — OK
```

---

## 12. Known Limitations & Recommendations
1. **Primary Deployment Selection:** `plant_disease_model.tflite` (Float32) is selected as the primary production model because it guarantees numerical parity with the training weights ($3 \times 10^{-6}$ max diff) while achieving sub-5ms latency and an 8.58 MB payload.
2. **Alternative for Low-End Android Phones:** `plant_disease_model_fp16.tflite` (4.37 MB) is available as an approved drop-in replacement if APK size becomes a critical factor.
3. **Dataset Scope:** Pilot dataset partition of 90 images was used for training/validation/testing; regional field expansion remains planned.

---

## 13. Phase Status & Next Step
- **Phase 40 Status:** **`COMPLETE`**
- **Ready for Phase 41 (Backend Integration / Edge Validation):** **`YES`**

