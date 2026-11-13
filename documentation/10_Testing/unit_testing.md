# AgriCare AI — Unit Testing

## 1. Scope of Unit Tests
Unit tests in AgriCare AI isolate pure Dart logic and business rules from the Flutter widget tree and UI rendering cycles.

---

## 2. Tested Components
1. **`PredictionModel` & `PredictionResult`**:
   - Validates JSON serialization and deserialization.
   - Tests confidence clamping between $0.000$ and $1.000$.
   - Validates severity level derivation logic based on class metadata.
2. **`TFLiteService` Tensor Transformation**:
   - Tests image resizing to $224 \times 224$ dimensions.
   - Validates pixel normalization formula:
     $$\text{pixel}_{\text{norm}} = \frac{\text{pixel} - 127.5}{127.5} \in [-1.0, 1.0]$$
   - Tests output label lookup against `assets/models/labels.json`.
3. **Repository Units**:
   - `CropRepository`: Validates local seed catalog extraction when offline.
   - `ObservationRepository`: Validates condition label enum constraints (`better`, `worse`, etc.).
   - `FeedbackRepository`: Validates payload construction and rating boundaries ($1 \le \text{rating} \le 5$).

