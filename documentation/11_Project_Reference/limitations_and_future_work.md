# AgriCare AI — Limitations and Future Work

## 1. Current Project Limitations
1. **Target Crop Scope**:
   - The deep learning model is specifically trained on 5 crops (Rice, Potato, Tomato, Mango, Jute) across 19 classes. Symptoms on other agricultural crops (e.g., maize, wheat, cabbage, brinjal) cannot be reliably diagnosed.
2. **Foliar Only**:
   - Only visual symptoms manifested on plant leaves can be evaluated. Soil-borne root rot, subterranean tuber rotting, or stem-boring insects without distinct foliar signs cannot be detected.
3. **Single Pathology Assumption**:
   - When a leaf exhibits multi-disease co-infection or both insect damage and fungal lesions, the classifier identifies the dominant visual symptom.
4. **No Automated Recovery Assurances**:
   - The application does not automatically certify that an infection is eradicated without an authentic new camera scan.

---

## 2. Roadmap for Future Development
- **Expansion of Crop Catalog**:
  Incorporate additional key Bangladeshi crops including Brinjal (বেগুন), Chili (মরিচ), Maize (ভুট্টা), and Mustard (সরিষা).
- **Object Detection & Bounding Boxes**:
  Transition from whole-image classification to fine-grained object detection (YOLOv8-nano / SSD-MobileNet) to locate and count individual disease lesions on leaves.
- **Multimodal LLM Agronomic Chatbot**:
  Integrate an offline or low-bandwidth voice-enabled agricultural assistant allowing farmers to speak in regional Bengali dialects.
- **Hyperlocal Weather-Driven Epidemic Forecasting**:
  Correlate meteorological humidity and temperature data from the Bangladesh Meteorological Department (BMD) to issue early-warning alerts for late blight in potatoes.

