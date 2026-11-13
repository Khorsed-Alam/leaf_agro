# AgriCare AI — MobileNetV2 Transfer Learning Architecture
**Phase 37: Deep Learning Architecture Design & Verification**

---

## 1. Introduction to MobileNetV2

**MobileNetV2** is a lightweight, high-performance deep convolutional neural network developed by Google Research, engineered specifically for mobile and embedded computer vision tasks.

### Why MobileNetV2 for AgriCare AI?
In rural Bangladeshi agricultural fields, farmers often have low-cost or mid-range Android smartphones and limited internet connectivity. Complex architectures like ResNet-50 or EfficientNet-B4 are computationally heavy, require gigabytes of RAM, and drain phone batteries quickly.

MobileNetV2 achieves state-of-the-art accuracy with:
* **Total Parameters:** ~2.28 million (compared to ~25 million for ResNet-50)
* **Model Size:** ~8.7 MB in float32; compressed to ~2.5 MB with 8-bit quantization in TensorFlow Lite.
* **Low Latency:** Real-time inference (< 50 milliseconds per leaf photo) directly on mobile CPUs without requiring internet access.

### The Secret: Depthwise Separable Convolutions & Inverted Residuals
Standard convolutions apply spatial filtering and channel cross-correlation simultaneously, which requires huge numbers of multiplications. MobileNetV2 splits standard convolutions into two distinct steps:
1. **Depthwise Convolution:** Applies a single convolutional filter per input color channel.
2. **Pointwise Convolution ($1 \times 1$):** Linearly combines the outputs across channels.

This factorization reduces computational cost by roughly **8 to 9 times** with virtually zero loss in disease diagnostic accuracy.

```
Standard Convolution:
  [Input Channels] ──(Multi-channel 3x3 Filters)──> [Output Channels]  (High compute)

Depthwise Separable Convolution:
  [Input Channels] ──(3x3 Depthwise Filter per channel)──> [Intermediate]
                   ──(1x1 Pointwise Filter across channels)──> [Output Channels] (Low compute)
```

---

## 2. Transfer Learning Strategy

Instead of training a neural network from scratch (which requires millions of labeled photos and weeks of supercomputer time), AgriCare AI utilizes **Transfer Learning**.

### Pretrained ImageNet Weights
The backbone is initialized with weights trained on **ImageNet** (1.4 million real-world images across 1,000 diverse categories). These weights have already learned foundational visual representations:
* Early layers detect edges, color gradients, and simple textures.
* Middle layers detect complex patterns, curves, and surface variations.
* Deep layers detect domain structures (veins, spots, margins, and geometric leaf shapes).

---

## 3. Two-Stage Training Configuration (Prepared for Phase 38)

To preserve the rich pretrained features while adapting the model to plant pathology, we configure a **Two-Stage Training Strategy**:

```
Stage A: Feature Extraction
┌───────────────────────────────────────────────┬──────────────────────────────┐
│ MobileNetV2 Backbone (154 layers)             │ Classifier Head              │
│ Frozen (trainable = False)                    │ Trainable (trainable = True) │
│ Weights: Pretrained ImageNet                  │ Weights: Initialized         │
│ Non-trainable Parameters: 2,257,984           │ Trainable Parameters: 24,339 │
└───────────────────────────────────────────────┴──────────────────────────────┘
  Optimizer: Adam (learning_rate = 0.001)
  Loss: SparseCategoricalCrossentropy

Stage B: Fine-Tuning
┌──────────────────────────────┬──────────────────────────────┬────────────────┐
│ Lower Backbone (< Layer 100) │ Upper Backbone (>= Layer 100)│ Classifier Head│
│ Frozen (trainable = False)   │ Unfrozen (trainable = True)  │ Trainable      │
│ Non-trainable: 418,368       │ (BatchNorm Frozen)           │ Trainable      │
└──────────────────────────────┴──────────────────────────────┴────────────────┘
  Optimizer: Adam (learning_rate = 0.00001)
  Loss: SparseCategoricalCrossentropy
```

### Stage A: Feature Extraction (Frozen Backbone)
* **Backbone Status:** Completely frozen (`backbone.trainable = False`).
* **Classifier Head:** Trainable (`trainable = True`).
* **Trainable Parameters:** **24,339** (only the final dense classification weights).
* **Non-trainable Parameters:** **2,257,984**.
* **Learning Rate:** `0.001` with Adam optimizer.
* **Goal:** Train the random classification weights to align with MobileNetV2 features without destroying ImageNet representations.

### Stage B: Fine-Tuning (Selective Unfreezing)
* **Backbone Status:** Layers before index 100 remain frozen. Layers from index 100 upwards are unfrozen.
* **Critical Safeguard — Batch Normalization Frozen:** All `BatchNormalization` layers in the unfrozen upper backbone remain explicitly frozen (`layer.trainable = False`). On small agricultural datasets, allowing small-batch statistics to update running mean/variance parameters can destroy model convergence.
* **Trainable Parameters:** **1,863,955**.
* **Non-trainable Parameters:** **418,368**.
* **Learning Rate:** `0.00001` (100 times smaller) to gently adapt specialized plant lesion representations.

---

## 4. Classifier Head Design

The custom classification head transforms high-level 2D feature maps into plant disease class probabilities:

1. **GlobalAveragePooling2D:**
   Collapses the $7 \times 7 \times 1280$ feature map output from the backbone into a single 1D vector of length $1280$. This replaces traditional heavy fully connected layers and reduces parameter count by millions.
2. **Dropout ($rate = 0.3$):**
   Randomly sets 30% of input units to 0 during training to prevent overfitting to specific laboratory backgrounds.
3. **Dense Classification Layer:**
   A single fully connected layer with exactly **19 units** (matching our verified disease catalog).
4. **Softmax Activation:**
   Normalizes the raw logits into a valid probability distribution where each probability $p_i \in [0, 1]$ and $\sum_{i=1}^{19} p_i = 1.0$.

---

## 5. Input Preprocessing Contract & Normalization Safeguards

To prevent subtle performance bugs (such as double normalization or mismatched color channels), AgriCare AI establishes a strict contract:

| Property | Value | Notes |
| :--- | :--- | :--- |
| **Input Shape** | `(224, 224, 3)` | Height $\times$ Width $\times$ Channels |
| **Color Order** | `RGB` | Standard digital photo color space |
| **Data Type** | `float32` | 32-bit floating point tensor |
| **External Range** | $[0.0, 255.0]$ | Fed directly into the model graph |
| **Internal Normalization** | Embedded `Rescaling` | `(pixel / 127.5) - 1.0` |
| **Normalized Range** | $[-1.0, 1.0]$ | Required by MobileNetV2 convolution kernels |

> [!IMPORTANT]
> **Zero Double-Normalization Guarantee:**
> Normalization is embedded **once** directly inside the model graph via `layers.Rescaling(scale=1.0/127.5, offset=-1.0, name="mobilenetv2_rescaling")`.
> The dataset loaders (`dataset_loader.py`) supply raw $[0.0, 255.0]$ RGB tensors. The future Flutter mobile app simply passes raw pixel bitmaps without needing separate pre-scaling code.

---

## 6. Class Label Mapping (19 Standardized Classes)

The output dense layer outputs 19 probabilities corresponding strictly to the stable indices defined in `ai_model/models/labels.json`:

```
Index  Class Name                       Target Pathogen / Health Baseline
─────  ───────────────────────────────  ─────────────────────────────────
[00]   Rice___Bacterial_leaf_blight     Xanthomonas oryzae pv. oryzae
[01]   Rice___Brown_spot                Bipolaris oryzae
[02]   Rice___Leaf_smut                 Entyloma oryzae
[03]   Rice___healthy                   Oryza sativa (Healthy baseline)
[04]   Potato___Early_blight            Alternaria solani
[05]   Potato___Late_blight             Phytophthora infestans
[06]   Potato___healthy                 Solanum tuberosum (Healthy baseline)
[07]   Tomato___Bacterial_spot          Xanthomonas perforans
[08]   Tomato___Early_blight            Alternaria solani
[09]   Tomato___Late_blight             Phytophthora infestans
[10]   Tomato___Leaf_Mold               Passalora fulva
[11]   Tomato___Septoria_leaf_spot      Septoria lycopersici
[12]   Tomato___healthy                 Solanum lycopersicum (Healthy baseline)
[13]   Mango___Anthracnose              Colletotrichum gloeosporioides
[14]   Mango___Bacterial_canker         Xanthomonas citri pv. mangiferaeindicae
[15]   Mango___healthy                  Mangifera indica (Healthy baseline)
[16]   Jute___Stem_rot                  Macrophomina phaseolina
[17]   Jute___Anthracnose               Colletotrichum corchori
[18]   Jute___healthy                   Corchorus olitorius (Healthy baseline)
```

Inference translates the predicted class index:
$$\text{predicted\_index} = \arg\max_{i} (p_0, p_1, \dots, p_{18})$$
The mobile application takes this index, queries `labels.json`, and loads treatment recommendations from the Supabase `disease_catalog` table.

---

## 7. Model Parameters & Size Analysis

| Stage / Component | Trainable Parameters | Non-Trainable Parameters | Total Parameters | Estimated Size (FP32) |
| :--- | :--- | :--- | :--- | :--- |
| **MobileNetV2 Backbone** | 2,223,872 (unfrozen) | 34,112 (BatchNorm) | 2,257,984 | 8.61 MB |
| **Classifier Head** | 24,339 | 0 | 24,339 | 0.09 MB |
| **Stage A Full Model** | **24,339** | **2,257,984** | **2,282,323** | **8.71 MB** |
| **Stage B Full Model** | **1,863,955** | **418,368** | **2,282,323** | **8.71 MB** |

* **Parameter Count vs. File Size:**
  * 2,282,323 parameters $\times$ 4 bytes per `float32` float $\approx 9,129,292$ bytes ($\approx 8.71$ MB).
  * Serialized `.keras` archive: $\approx 9.2$ MB (includes graph definition and optimizer state).
  * Future TensorFlow Lite `.tflite` model: $\approx 8.7$ MB (FP32) or $\approx 2.4$ MB with post-training INT8 quantization.

---

## 8. Mobile Deployment & TensorFlow Lite Considerations

When exported to TensorFlow Lite in Phase 39:
1. **Input Tensors:** The TFLite interpreter will accept a single `[1, 224, 224, 3]` float32 buffer with values in $[0.0, 255.0]$.
2. **Embedded Normalization:** The `mobilenetv2_rescaling` layer converts to $[-1.0, 1.0]$ inside the TFLite binary, eliminating platform-dependent preprocessing bugs.
3. **Inference Parity:** Numerical validation guarantees that predictions from the `.keras` model and `.tflite` model match within an absolute tolerance of $< 1\text{e-}5$.
4. **Dart Integration:** The model will plug directly into `lib/core/services/tflite_service.dart`.

---

## 9. Next Steps: Transition to Phase 38

Phase 37 has established the architecture, parameters, loss configuration, and verified class mappings.

In **Phase 38 (Model Training & Fine-Tuning)**:
1. Stage A will train the classifier head using `sparse_categorical_crossentropy` and early stopping on validation loss.
2. Stage B will load the best Stage A checkpoint, unfreeze layers $\ge 100$, and fine-tune with `lr = 1e-5`.
3. Model checkpoints will be saved to `ai_model/models/best_model.keras`.
