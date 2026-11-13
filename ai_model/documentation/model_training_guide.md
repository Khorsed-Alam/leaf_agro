# AgriCare AI — Beginner-Friendly Model Training & Fine-Tuning Guide
**Phase 38: Model Training and Fine-Tuning Execution**

Welcome to the AgriCare AI deep learning training guide. This guide explains how to run, monitor, and configure the two-stage transfer learning pipeline on Windows.

---

## 1. Quick Start: Running the Training Pipeline

Open Windows PowerShell, navigate to the `ai_model` directory, and activate your virtual environment:

```powershell
# 1. Navigate to ai_model directory
cd F:\leaf_agro\ai_model

# 2. Allow activation script for the current process
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# 3. Activate the virtual environment
.\.venv\Scripts\Activate.ps1

# 4. Run the end-to-end two-stage training script
python src/train.py
```

---

## 2. Training Parameters & Customization

You can customize epochs and batch size using simple command-line flags:

```powershell
# Run with custom epochs and batch size
python src/train.py --stage-a-epochs 20 --stage-b-epochs 15 --batch-size 16

# Run only Stage A (Feature extraction only, skipping Stage B)
python src/train.py --skip-stage-b
```

| Parameter | Default | Purpose |
| :--- | :---: | :--- |
| `--stage-a-epochs` | `15` | Maximum epochs for Stage A (classifier head training with frozen backbone) |
| `--stage-b-epochs` | `10` | Maximum epochs for Stage B (fine-tuning upper backbone layers) |
| `--batch-size` | `16` | Number of leaf photos per gradient step (optimized for 16GB RAM) |
| `--skip-stage-b` | `False` | Skips Stage B if you only want to train the classifier head |

---

## 3. How Two-Stage Transfer Learning Works

### Stage A: Feature Extraction
* **What happens:** The MobileNetV2 backbone (154 layers) is **frozen**. Only the final classification head ($1,280 \times 19 + 19 = 24,339$ weights) is trained.
* **Why:** This aligns the classification weights with plant disease features without destroying ImageNet representations.
* **Checkpoint saved to:** `ai_model/models/checkpoints/stage_a_best.keras`

### Stage B: Controlled Fine-Tuning
* **What happens:** The best checkpoint from Stage A is automatically loaded. The top layers of MobileNetV2 (from layer 100 upwards) are **unfrozen**, while all `BatchNormalization` layers remain strictly frozen. The learning rate is dropped to `0.00001` (100x smaller).
* **Why:** Allows high-level convolution kernels to specialize in fine-grained plant lesion margins and leaf spot textures.
* **Checkpoint saved to:** `ai_model/models/checkpoints/stage_b_best.keras`

### Final Model Selection
* Both checkpoints are evaluated on the exact same **unaugmented validation split**.
* The checkpoint achieving the **lowest validation loss** is automatically selected and deployed as:
  `ai_model/models/best_model.keras`

---

## 4. Where Artifacts and Reports Are Saved

```text
ai_model/
├── models/
│   ├── checkpoints/
│   │   ├── stage_a_best.keras      # Best Stage A model weights
│   │   └── stage_b_best.keras      # Best Stage B fine-tuned weights
│   ├── best_model.keras            # Winning model deployed for production
│   ├── labels.json                 # 19 verified disease classes
│   └── model_metadata.json         # Real measured metrics & training timestamp
│
├── reports/
│   ├── stage_a_history.csv         # Epoch-by-epoch loss & accuracy for Stage A
│   ├── stage_b_history.csv         # Epoch-by-epoch loss & accuracy for Stage B
│   ├── training_history.csv        # Consolidated global epoch history
│   ├── training_config.json        # Snapshot of all hyperparameter settings
│   ├── training_report.md          # Comprehensive executive training report
│   └── plots/
│       ├── accuracy.png            # Training vs. validation accuracy curve
│       ├── loss.png                # Training vs. validation loss curve
│       └── learning_rate.png       # Learning rate decay schedule
│
└── logs/
    └── tensorboard/                # Interactive TensorBoard event logs
```

---

## 5. How to View Real-Time Curves in TensorBoard

To open interactive training graphs in your web browser:

```powershell
# Start the TensorBoard server
tensorboard --logdir logs/tensorboard
```

Open your browser and navigate to:
```
http://localhost:6006/
```

You can zoom in on loss curves, compare Stage A vs. Stage B learning rates, and inspect the computational graph.

---

## 6. How to Identify a Successful Training Run

A training run is considered successful when:
1. Both `stage_a_best.keras` and `stage_b_best.keras` exist in `models/checkpoints/`.
2. `models/best_model.keras` is non-empty (~8.7 MB) and loadable.
3. `reports/plots/accuracy.png` and `reports/plots/loss.png` show decreasing loss and increasing accuracy.
4. Validation loss decreases steadily (in our run, loss dropped from 2.84 to 0.85).
5. The independent test set was **never touched** or loaded.
