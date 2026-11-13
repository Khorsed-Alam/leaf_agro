# AgriCare AI — Phase 39 Model Evaluation & Performance Testing Guide

This guide provides beginner-friendly instructions for running and understanding the independent evaluation of the **MobileNetV2** plant disease detection model in **AgriCare AI**.

---

## 1. Evaluation Overview
In Phase 39, we test the trained model against the **untouched test split** created in Phase 35. 
- **Strict Independence:** The test set images were never seen by the model during training, validation, or checkpoint selection.
- **Pure Inference Mode:** No gradient updates, no weights modification, and no threshold tuning on the test set.
- **Reproducibility:** Seed 42 is set across Python, NumPy, and TensorFlow.

---

## 2. Quick Execution (Windows 10/11 PowerShell)

Open PowerShell in the project root (`F:\leaf_agro`) and activate the virtual environment:

```powershell
# 1. Activate the Python virtual environment
.\ai_model\.venv\Scripts\Activate.ps1

# 2. Run the complete evaluation pipeline
python ai_model\src\evaluate.py
```

### Optional Command-Line Arguments:
```powershell
# Custom model path or batch size
python ai_model\src\evaluate.py --model-path ai_model\models\best_model.keras --batch-size 16
```

---

## 3. Running Automated Tests

To verify that metric calculations, probability bounds, and test isolation pass all assertions:

```powershell
python -m unittest ai_model\tests\test_evaluation_pipeline.py
```

To run all project tests:
```powershell
python -m unittest discover -s ai_model\tests -p "test_*.py"
```

---

## 4. Key Metrics Explained

### Top-1 Accuracy & Top-3 Accuracy
- **Top-1 Accuracy ({accuracy}):** Proportion of predictions where the model's highest-probability class exactly matches ground truth.
- **Top-3 Accuracy ({top_3}):** Proportion of samples where the true class is within the model's top 3 candidate predictions.

### Macro vs Weighted Averaging
- **Macro Averaging:** Computes the metric independently for each class and averages them with equal weight. Treats rare and frequent classes equally.
- **Weighted Averaging:** Weights each class by its number of true samples (support).

### Expected Calibration Error (ECE)
- Measures whether the model's predicted confidence matches its real-world empirical accuracy.
- If the model is 80% confident on a group of predictions, approximately 80% of them should actually be correct. Lower ECE values indicate better calibration.

### Multiclass Brier Score
- The mean squared error across all 19 predicted probabilities and the one-hot ground-truth vector:
  $$\text{BS} = \frac{1}{N} \sum_{i=1}^N \sum_{k=1}^K (p_{ik} - y_{ik})^2$$
- Lower is better ($0.0$ is perfect certainty and accuracy).

---

## 5. Generated Artifacts Reference

All evaluation artifacts are saved under `ai_model/reports/`:

| Artifact | File Path | Purpose |
| :--- | :--- | :--- |
| **Predictions CSV** | `ai_model/reports/predictions.csv` | Sample-by-sample predictions, confidence, and correctness. |
| **Classification Report** | `ai_model/reports/classification_report.csv` | Per-class Support, TP, FP, FN, TN, Precision, Recall, F1. |
| **Overall Metrics** | `ai_model/reports/overall_metrics.json` | JSON summary of Accuracy, Macro/Weighted metrics, and ECE. |
| **Raw Confusion Matrix** | `ai_model/reports/confusion_matrix.csv` | Numerical counts of true vs predicted classes. |
| **Normalized Matrix** | `ai_model/reports/normalized_confusion_matrix.csv` | Recall-normalized matrix showing proportion of correct diagnoses. |
| **Error Analysis** | `ai_model/reports/error_analysis.csv` | Agricultural risk categorization (e.g. Disease mistaken for Healthy). |
| **Calibration Metrics** | `ai_model/reports/calibration_metrics.json` | ECE, Multiclass Brier score, and binning details. |
| **Performance Benchmark**| `ai_model/reports/performance_benchmark.json`| Host CPU inference latency, throughput, model size, and memory profile. |
| **Phase Report** | `ai_model/reports/PHASE_39_COMPLETION_REPORT.md` | Formal engineering documentation and readiness audit. |

### Visualizations (`ai_model/reports/plots/`):
- `confusion_matrix.png` & `normalized_confusion_matrix.png`: Heatmap matrices.
- `classwise_f1.png` & `precision_recall.png`: Per-class diagnostic bar charts.
- `confidence_distribution.png`: Histogram of model confidence scores.
- `reliability_diagram.png`: Calibration curve against the perfect calibration diagonal.
- `correct_vs_incorrect_confidence.png`: Boxplot showing confidence separation on correct vs erroneous predictions.

---

## 6. Next Step: Phase 40
With Phase 39 complete and the model achieving **READY WITH KNOWN LIMITATIONS**, the project is technically prepared to proceed to **Phase 40: TensorFlow Lite Model Conversion & Mobile Optimization**.

