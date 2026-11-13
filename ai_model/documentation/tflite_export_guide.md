# AgriCare AI — Phase 40 TensorFlow Lite Export & Optimization Guide

This beginner-friendly guide explains how to convert, validate, and benchmark the **AgriCare AI** MobileNetV2 plant disease detection model for mobile deployment on Android and Flutter.

---

## 1. Overview of TensorFlow Lite (TFLite)
TensorFlow Lite is Google's lightweight framework for running deep learning models on mobile, embedded, and IoT devices. 
Converting our trained Keras model (`best_model.keras`) to TFLite (`plant_disease_model.tflite`) provides:
- **Smaller Footprint:** Reduces model file size from **23.5 MB down to 8.58 MB** (Float32) or **4.37 MB** (Float16).
- **Fast Execution:** Executes in **~4.7 ms** per image on modern processors using the XNNPACK engine.
- **Offline Reliability:** Enables farmers to diagnose plant diseases in remote rural fields without internet connectivity.

---

## 2. Quick Execution (PowerShell on Windows 10/11)

Open PowerShell in the project root (`F:\leaf_agro`):

```powershell
# 1. Activate the Python virtual environment
.\ai_model\.venv\Scripts\Activate.ps1

# 2. Run the full TFLite export pipeline
python ai_model\src\export_tflite.py

# 3. Validate all exported TFLite models
python ai_model\src\tflite_validation.py

# 4. Compare Keras vs TFLite predictions
python ai_model\src\model_comparison.py

# 5. Benchmark inference latency
python ai_model\src\benchmark_tflite.py
```

---

## 3. Supported Model Formats

| Format | Filename | Size | Key Advantage | Recommended Use |
| :--- | :--- | :---: | :--- | :--- |
| **Float32 Baseline** | `plant_disease_model.tflite` | **8.58 MB** | Bit-exact parity with training weights ($3\times 10^{-6}$ max diff) | **Primary Production Model** |
| **Float16 Quantized**| `plant_disease_model_fp16.tflite`| **4.37 MB** | 50% smaller size with 100% Top-1 agreement | Mobile GPU / Constrained Storage |
| **INT8 Quantized** | `plant_disease_model_int8.tflite`| **2.63 MB** | 70% smaller size, 2.3 ms latency | Ultra-low RAM Edge Devices |

---

## 4. The Preprocessing Contract for Flutter Developers

> [!IMPORTANT]
> The MobileNetV2 rescaling operation is **embedded directly inside the TFLite model graph** (`mobilenetv2_rescaling`).

### Expected Flutter Input:
- **Resolution:** $224 \times 224$ pixels.
- **Color Format:** RGB (3 channels).
- **Data Type:** `float32`.
- **Value Range:** `[0.0, 255.0]`.

```dart
// Flutter (Dart) Example:
// Pass unnormalized RGB pixel values directly into the input tensor!
// DO NOT divide by 127.5 or subtract 1.0 in Dart code!
var inputTensor = [224, 224, 3]; // values in 0.0 - 255.0
```

---

## 5. Running Automated Tests

To run the Phase 40 unit and integration tests:
```powershell
python -m unittest ai_model\tests\test_tflite_export.py
```

To run all 55 project tests across all phases:
```powershell
python -m unittest discover -s ai_model\tests -p "test_*.py"
```

---

## 6. Staged Flutter Assets Reference
All deployment artifacts are automatically copied into the Flutter application's assets directory (`assets/models/`):
- `assets/models/plant_disease_model.tflite` (Primary Float32 model)
- `assets/models/plant_disease_model_fp16.tflite` (Float16 candidate model)
- `assets/models/labels.json` (19 verified class names matching output neurons)
- `assets/models/model_metadata.json` (Complete technical specification)

