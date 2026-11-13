# AgriCare AI — Deep Learning Pipeline & Environment

This directory (`ai_model/`) contains the deep learning, computer vision, and dataset engineering infrastructure for **AgriCare AI (LeafAgro)**, an AI-powered multi-crop plant disease detection and advisory system tailored for Bangladeshi agriculture.

---

## 1. Supported Agricultural Classes

The model classifies leaves into 19 standardized categories across 5 target crops:
1. **Rice (BRRI):** Bacterial Leaf Blight, Brown Spot, Leaf Smut, Healthy.
2. **Potato (BARI):** Early Blight, Late Blight, Healthy.
3. **Tomato (BARI):** Bacterial Spot, Early Blight, Late Blight, Leaf Mold, Septoria Leaf Spot, Healthy.
4. **Mango:** Anthracnose, Bacterial Canker, Healthy.
5. **Jute (BJRI):** Stem Rot, Anthracnose, Healthy.

---

## 2. Directory Structure

```text
ai_model/
├── .venv/                      # Isolated Python 3.14 virtual environment
├── dataset/
│   ├── raw/                    # Original raw datasets (git-ignored)
│   ├── metadata/               # Phase 31 & 32 verified class mappings & catalogs
│   └── processed/
│       ├── train/              # Group-aware training split (hash-verified)
│       ├── validation/         # Group-aware validation split (unaugmented)
│       ├── test/               # Group-aware test split (leakage-free holdout)
│       └── metadata/
│           ├── split_manifest.csv  # 90 pilot records with cryptographic hashes & groups
│           ├── split_summary.csv   # Class-level split metrics
│           └── split_config.json   # Reproducibility seed & ratio configuration
├── documentation/
│   └── ai_environment_setup.md # Beginner-friendly Windows setup guide
├── models/                     # Saved models (.keras, .tflite) (git-ignored)
├── notebooks/                  # Interactive experimentation notebooks
├── reports/                    # Diagnostic audit reports & distribution charts
├── src/
│   ├── __init__.py             # Source package initializer
│   ├── config.py               # Centralized path, seed, and MobileNetV2 constants
│   ├── dataset_loader.py       # Streaming tf.data pipeline with augmentation switches
│   ├── environment_check.py    # Comprehensive environment & dataset auditor
│   ├── preprocessing.py        # 224x224 RGB image decoder & contract validator
│   ├── augmentation.py         # Agricultural physiological training-only augmentation
│   ├── split_dataset.py        # Group-aware stratified splitting engine
│   └── validate_splits.py      # Independent cryptographic & pHash leakage auditor
├── tests/                      # Automated test suites (28 tests)
├── requirements.txt            # Tested and verified dependency versions
└── README.md                   # This overview
```

---

## 3. Quick Start (Windows PowerShell)

### Step 1: Open PowerShell and navigate to the project
```powershell
cd F:\leaf_agro\ai_model
```

### Step 2: Set execution policy for the current session (if blocked)
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

### Step 3: Activate the virtual environment
```powershell
.\.venv\Scripts\Activate.ps1
```

### Step 4: Run the environment diagnostic check
```powershell
python src/environment_check.py
```

### Step 5: Run the full test suite
```powershell
python -m unittest discover -s tests -p "test_*.py"
```

---

## 4. Input Contract for Future Model Development (MobileNetV2)

All dataset loaders enforce the official MobileNetV2 preprocessing contract:
* **Dimensions:** $224 \times 224 \times 3$ (RGB)
* **Data Type:** `tf.float32`
* **Pixel Range:** $[0.0, 255.0]$ (Feeding into internal model `layers.Rescaling(1/127.5, offset=-1.0)`)
* **Augmentation:** Applied **strictly** during training. Validation and test streams serve unaugmented, authentic leaf images.

