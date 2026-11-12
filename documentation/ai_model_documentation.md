# AgriCare AI — AI Model Architecture & Training Documentation

## 1. Backbone Architecture
- **Base Model**: MobileNetV2 pretrained on ImageNet.
- **Input Resolution**: 224 x 224 x 3 (RGB).
- **Normalization**: Scaled to `[-1.0, 1.0]` via `(x / 127.5) - 1.0`.
- **Top Layers**:
  - GlobalAveragePooling2D
  - BatchNormalization
  - Dropout (0.25)
  - Dense (19 classes, Softmax)

## 2. Training Regimen
1. **Phase 1 (Feature Extraction)**:
   - Backbone frozen.
   - Epochs: 20
   - Optimizer: Adam (`lr=1e-3`)
   - Loss: Categorical Crossentropy.
2. **Phase 2 (Fine-Tuning)**:
   - Backbone unfrozen from layer 100 onwards.
   - Epochs: 15
   - Optimizer: Adam (`lr=1e-5`)
   - Early stopping on `val_loss` with patience 5.

## 3. TensorFlow Lite Quantization & Flutter Hand-off
The model is converted with post-training float-fallback quantization (`tf.lite.Optimize.DEFAULT`) producing an ~8.7MB `.tflite` model capable of running inference under 50ms on standard budget Android smartphones.
`labels.json` guarantees 1-to-1 matching with PostgreSQL `disease_catalog.class_name`.

