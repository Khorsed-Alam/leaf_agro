# AgriCare AI — Phase 32: Dataset Verification, Scientific Label Audit & Class Mapping Report

## 1. Executive Summary
This report documents the exhaustive scientific label audit, legal licensing verification, and deterministic class mapping for the **AgriCare AI (LeafAgro)** multi-crop plant disease recognition project.

- **Target Architecture**: MobileNetV2 (Quantized TensorFlow Lite)
- **Target Platform**: Android (Edge/Offline-first)
- **Standardized Classes**: 19 verified classes across 5 crops (Rice: 4, Potato: 3, Tomato: 6, Mango: 3, Jute: 3)
- **Approved Active Classes in Raw Directory**: 9 classes from PlantVillage (90 verified images, 10 per class)
- **Conditionally Approved Classes**: 10 classes from Bangladeshi field datasets (RiceLeafDiseaseBD, MLD24, YOLO-JD) pending local archive extraction
- **Rejected Non-Pathological Classes**: 10 classes cataloged in `rejected_classes.csv` (insect pest damage, out-of-scope diseases, and non-target crops)

---

## 2. Standardized 19-Class Catalog

| Class ID | Standardized Class Name | Crop | Common Name (EN) | Common Name (BN) | Scientific Disease Name / Pathogen | Status |
| :---: | :--- | :--- | :--- | :--- | :--- | :---: |
| **101** | `AGRI_RICE_BACTERIAL_LEAF_BLIGHT` | Rice | Bacterial Leaf Blight | ব্যাকটেরিয়াল লিফ ব্লাইট | *Xanthomonas oryzae* pv. *oryzae* | Conditional |
| **102** | `AGRI_RICE_BROWN_SPOT` | Rice | Brown Spot | বাদামি দাগ রোগ | *Bipolaris oryzae* | Conditional |
| **103** | `AGRI_RICE_LEAF_SMUT` | Rice | Leaf Smut | লিফ স্মাট | *Entyloma oryzae* | Conditional |
| **104** | `AGRI_RICE_HEALTHY` | Rice | Healthy Rice Foliage | সুস্থ ধান গাছ | *Oryza sativa* (healthy) | Conditional |
| **201** | `AGRI_POTATO_EARLY_BLIGHT` | Potato | Early Blight | আগাম ধসা রোগ | *Alternaria solani* | **Approved** |
| **202** | `AGRI_POTATO_LATE_BLIGHT` | Potato | Late Blight | নাবি ধসা রোগ | *Phytophthora infestans* | **Approved** |
| **203** | `AGRI_POTATO_HEALTHY` | Potato | Healthy Potato Foliage | সুস্থ আলু গাছ | *Solanum tuberosum* (healthy) | **Approved** |
| **301** | `AGRI_TOMATO_BACTERIAL_SPOT` | Tomato | Bacterial Spot | ব্যাকটেরিয়াল স্পট | *Xanthomonas perforans* | **Approved** |
| **302** | `AGRI_TOMATO_EARLY_BLIGHT` | Tomato | Early Blight | টমেটো আর্লি ব্লাইট | *Alternaria solani* | **Approved** |
| **303** | `AGRI_TOMATO_LATE_BLIGHT` | Tomato | Late Blight | টমেটো লেট ব্লাইট | *Phytophthora infestans* | **Approved** |
| **304** | `AGRI_TOMATO_LEAF_MOLD` | Tomato | Leaf Mold | লিফ মোল্ড | *Passalora fulva* | **Approved** |
| **305** | `AGRI_TOMATO_SEPTORIA_LEAF_SPOT` | Tomato | Septoria Leaf Spot | সেপ্টোরিয়া পাতার দাগ | *Septoria lycopersici* | **Approved** |
| **306** | `AGRI_TOMATO_HEALTHY` | Tomato | Healthy Tomato Foliage | সুস্থ টমেটো গাছ | *Solanum lycopersicum* (healthy) | **Approved** |
| **401** | `AGRI_MANGO_ANTHRACNOSE` | Mango | Anthracnose | অ্যানথ্রাকনোজ | *Colletotrichum gloeosporioides* | Conditional |
| **402** | `AGRI_MANGO_BACTERIAL_CANKER` | Mango | Bacterial Canker | ব্যাকটেরিয়াল ক্যাঙ্কার | *Xanthomonas citri* pv. *mangiferaeindicae* | Conditional |
| **403** | `AGRI_MANGO_HEALTHY` | Mango | Healthy Mango Foliage | সুস্থ আম গাছ | *Mangifera indica* (healthy) | Conditional |
| **501** | `AGRI_JUTE_STEM_ROT` | Jute | Stem Rot | কান্ড পচা রোগ | *Macrophomina phaseolina* | Conditional |
| **502** | `AGRI_JUTE_ANTHRACNOSE` | Jute | Anthracnose | অ্যানথ্রাকনোজ ক্ষত | *Colletotrichum corchori* | Conditional |
| **503** | `AGRI_JUTE_HEALTHY` | Jute | Healthy Jute Foliage | সুস্থ পাট গাছ | *Corchorus olitorius* (healthy) | Conditional |

---

## 3. Scientific Audit & Separation Rules
1. **Insect Pest Segregation**: Mechanical leaf chewing (e.g. *Deporaus marginatus* / Cutting Weevil) and gall formation (e.g. *Procontarinia matteiana* / Gall Midge) are strictly segregated from microbial plant pathologies into `rejected_classes.csv`.
2. **Laboratory vs. Field Balance**: PlantVillage provides laboratory-controlled baseline imagery for Potato and Tomato; Bangladeshi field datasets provide ambient sunlight and complex background field validation.
3. **Database & TFLite 1:1 Determinism**: Standardized class IDs strictly correlate with Supabase `disease_catalog.id` and mobile `assets/models/labels.json`.
