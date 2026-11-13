# AgriCare AI — Machine Learning Preprocessing & Input Contract

## 1. Executive Contract Overview
To prevent **silent accuracy degradation** caused by mismatched color spaces, conflicting normalization scales, or double-normalization bugs, this document establishes the **mandatory input contract** between external data pipelines, the TensorFlow/Keras training model graph, and edge Android/Flutter runtime inference.

---

## 2. The Architectural Data Contract

```text
========================================================================================
EXTERNAL DATA PIPELINE (Python tf.data / Android Bitmap)
========================================================================================
Input Image File (.jpg, .png, etc.)
  │
  ▼
1. Decode to 3-Channel RGB (Discard Alpha, Expand Grayscale)
2. Bilinear Resize to Exactly 224 x 224 Pixels
3. Cast to float32
4. External Pixel Range: [0.0, 255.0]  <--- STRICT BOUNDARY CONTRACT
  │
  ▼
========================================================================================
MODEL GRAPH INGRESS (TensorFlow Keras / TFLite Ingress)
========================================================================================
Input Layer: shape=(None, 224, 224, 3), dtype=float32
  │
  ▼
Layer "mobilenetv2_rescaling": layers.Rescaling(scale=1.0/127.5, offset=-1.0)
Normalized Output Range: [-1.0, 1.0]  <--- OFFICIAL MOBILENETV2 CONTRACT
  │
  ▼
MobileNetV2 Convolutional Backbone
  │
  ▼
GlobalAveragePooling2D -> Dropout(0.25) -> Dense(19, activation="softmax")
========================================================================================
```

---

## 3. Strict Rules for TensorFlow Developers
1. **Never divide by 255.0 in the external dataset loading pipeline.**
   - If an external script divides by 255.0, the inside-model `Rescaling` layer will compute:
     `((x / 255.0) / 127.5) - 1.0 ≈ -0.9999`
     collapsing all pixels to -1.0 and destroying all feature recognition!
2. **Never call `mobilenet_v2.preprocess_input` externally if the model contains the Rescaling layer.**
   - The model in `ai_model/src/model.py` already includes:
     ```python
     layers.Rescaling(scale=1.0 / 127.5, offset=-1.0, name="mobilenetv2_rescaling")(inputs)
     ```
   - Therefore, the dataset pipeline outputs float32 values in $[0.0, 255.0]$.
3. **Augmentation is strictly training-only.**
   - Augmentation must be applied dynamically using `ai_model.src.augmentation.get_training_augmentation_layer`.
   - Never augment validation or test sets.

---

## 4. Contract for Android / Flutter Inference (`tflite_engine_io.dart`)
1. **Current Mobile Implementation Status:**
   - In `lib/data/datasources/local/tflite/tflite_engine_io.dart`, the image is resized to $224 \times 224$ and preprocessed as:
     ```dart
     [
       (pixel.r / 127.5) - 1.0,
       (pixel.g / 127.5) - 1.0,
       (pixel.b / 127.5) - 1.0,
     ]
     ```
2. **Export Parity Rule for Future TFLite Model (Phase 36/37):**
   - **Option A (Recommended):** The exported `.tflite` model includes the `mobilenetv2_rescaling` layer directly inside the model graph.
     - *Android Requirement:* Supply raw RGB `float32` values in $[0.0, 255.0]$.
   - **Option B:** The exported `.tflite` model strips the `Rescaling` layer to accept pre-normalized input.
     - *Android Requirement:* Continue supplying $[(pixel / 127.5) - 1.0]$ in $[-1.0, 1.0]$.
3. **Decoupling Guarantee:**
   - The final model export report in Phase 37 will explicitly document whether Option A or Option B is deployed, ensuring zero ambiguity.
