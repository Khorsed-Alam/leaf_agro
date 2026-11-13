# AgriCare AI — AI Model Overview

## 1. Executive Summary
The artificial intelligence capability at the heart of **AgriCare AI (LeafAgro)** is an on-device computer vision classifier engineered to identify foliar plant diseases across five major agricultural crops in Bangladesh: **Rice, Potato, Tomato, Mango, and Jute**.

The model is packaged as a quantized, highly optimized **TensorFlow Lite (`.tflite`)** model, allowing it to execute locally on standard Android hardware without requiring an internet connection or cloud GPU processing.

```mermaid
graph LR
    IMG[Leaf Image Input 224x224 RGB] --> PRE[Normalization: -1 to +1]
    PRE --> TFL[MobileNetV2 TFLite Engine]
    TFL --> SOFT[Softmax Activation]
    SOFT --> PROB[19 Class Probability Vector]
    PROB --> OUT[Predicted Class & Confidence Score]
```

---

## 2. Core Model Metadata
Verified directly against the project configuration (`assets/models/model_metadata.json`):

| Attribute | Verified Value |
| :--- | :--- |
| **Model Name** | AgriCare AI Leaf Disease Detector |
| **Model Version** | 1.0.0 |
| **Architecture** | MobileNetV2 |
| **Input Tensor Shape** | `[1, 224, 224, 3]` (Batch, Height, Width, Channels) |
| **Color Order** | RGB |
| **Input Normalization** | `mobilenet_v2_minus1_to_plus1` ($[-1.0, 1.0]$) |
| **Output Activation** | Softmax |
| **Output Classes** | 19 classes |
| **Model Weights File** | `assets/models/plant_disease_model.tflite` |
| **Class Labels File** | `assets/models/labels.json` |
| **Target Platform** | Android (TensorFlow Lite Runtime via C++ bindings) |

---

## 3. Supported Crops
The model is specifically trained on five economically critical crops cultivated widely across Bangladesh:
1. **Rice (ধান)**: Primary food staple covering over 75% of cultivated land.
2. **Potato (আলু)**: Leading winter cash crop with high susceptibility to devastating blights.
3. **Tomato (টমেটো)**: High-value commercial vegetable crop vulnerable to multiple bacterial and fungal pathogens.
4. **Mango (আম)**: Crucial horticultural crop in Rajshahi, Chapainawabganj, and Dinajpur divisions.
5. **Jute (পাট)**: Historic golden fiber crop of Bangladesh, susceptible to stem rot and anthracnose.

