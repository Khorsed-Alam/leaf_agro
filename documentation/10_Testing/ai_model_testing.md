# AgriCare AI — AI Model Testing

## 1. On-Device Verification Protocol
The on-device machine learning pipeline undergoes dedicated automated testing to ensure numerical consistency and memory safety.

---

## 2. Model Test Scenarios
1. **Asset Loading Verification**:
   - Asserts that `assets/models/plant_disease_model.tflite` is present, readable, and non-empty.
   - Asserts that `assets/models/labels.json` parses successfully and contains **exactly 19 unique string labels**.
   - Asserts that `assets/models/model_metadata.json` conforms to the MobileNetV2 $224 \times 224$ specification.
2. **Buffer Shape & Normalization Invariance**:
   - Asserts that input tensor buffers have length $1 \times 224 \times 224 \times 3 = 150,528$ single-precision floats.
   - Verifies that all normalized pixel values fall strictly within $[-1.0, 1.0]$.
3. **Softmax Output Summation**:
   - Verifies that the sum of output class probabilities equals $1.0 \pm 0.001$.
4. **Offline Resilience**:
   - Asserts that inference completes without throwing network exceptions when cellular and Wi-Fi adapters are disabled.
