"""
AgriCare AI — Class-Wise Error Analysis Module.
Phase 39: AI Model Evaluation and Performance Testing.

Provides structured error inspection, diagnosis, and categorization:
- Per-sample prediction breakdown and metadata association
- Agricultural safety error categorization (e.g. Disease mistaken for Healthy)
- High-confidence error flagging and low-confidence prediction tracking
- Traceable CSV generation without exporting or copying raw image files
"""

from pathlib import Path
from typing import List, Dict, Any, Tuple
import numpy as np
import pandas as pd


def categorize_error(
    actual_name: str,
    pred_name: str,
    confidence: float,
    is_correct: bool
) -> str:
    """
    Categorizes the prediction outcome according to agricultural diagnostic severity.

    Categories:
    - CORRECT: Model prediction matches ground truth.
    - HEALTHY_TO_DISEASE: Asymptomatic healthy leaf misdiagnosed as diseased (unnecessary treatment risk).
    - DISEASE_TO_HEALTHY: Pathogen-infected leaf misdiagnosed as healthy (untreated outbreak risk).
    - DISEASE_CROSS_CONFUSION: One disease misdiagnosed as another disease on the same or different crop.
    - HIGH_CONFIDENCE_ERROR: Any incorrect prediction made with confidence >= 0.80.
    """
    if is_correct:
        if confidence < 0.60:
            return "CORRECT_LOW_CONFIDENCE"
        return "CORRECT"

    actual_is_healthy = "healthy" in actual_name.lower()
    pred_is_healthy = "healthy" in pred_name.lower()

    if confidence >= 0.80:
        return "HIGH_CONFIDENCE_ERROR"
    if actual_is_healthy and not pred_is_healthy:
        return "HEALTHY_TO_DISEASE"
    if not actual_is_healthy and pred_is_healthy:
        return "DISEASE_TO_HEALTHY"

    return "DISEASE_CROSS_CONFUSION"


def perform_error_analysis(
    records: List[Dict[str, Any]],
    y_true: np.ndarray,
    y_pred: np.ndarray,
    y_probs: np.ndarray,
    idx_to_class: Dict[int, str]
) -> pd.DataFrame:
    """
    Constructs a detailed error analysis table across all evaluated test samples.

    Args:
        records: List of manifest dictionaries corresponding to test samples.
        y_true: 1D array of ground truth class indices.
        y_pred: 1D array of predicted class indices.
        y_probs: 2D array of class probability vectors.
        idx_to_class: Mapping from integer index to standardized class name.

    Returns:
        pandas.DataFrame with columns:
        [sample_id, image_path, actual_class_index, actual_class_name,
         predicted_class_index, predicted_class_name, confidence,
         correct_class_probability, is_correct, error_category]
    """
    rows = []
    for i in range(len(y_true)):
        rec = records[i] if i < len(records) else {}
        actual_idx = int(y_true[i])
        pred_idx = int(y_pred[i])
        probs = y_probs[i]

        actual_name = idx_to_class.get(actual_idx, f"Class_{actual_idx}")
        pred_name = idx_to_class.get(pred_idx, f"Class_{pred_idx}")

        conf = float(probs[pred_idx])
        correct_prob = float(probs[actual_idx])
        is_correct = (actual_idx == pred_idx)

        category = categorize_error(
            actual_name=actual_name,
            pred_name=pred_name,
            confidence=conf,
            is_correct=is_correct
        )

        rows.append({
            "sample_id": rec.get("image_id", f"TEST_SAMPLE_{i:04d}"),
            "image_path": rec.get("image_path", ""),
            "actual_class_index": actual_idx,
            "actual_class_name": actual_name,
            "predicted_class_index": pred_idx,
            "predicted_class_name": pred_name,
            "confidence": round(conf, 4),
            "correct_class_probability": round(correct_prob, 4),
            "is_correct": is_correct,
            "error_category": category
        })

    return pd.DataFrame(rows)


def summarize_error_patterns(error_df: pd.DataFrame) -> Dict[str, Any]:
    """
    Aggregates error counts, failure modes, and confusion pairs from the error table.
    """
    total = len(error_df)
    correct_count = int(error_df["is_correct"].sum())
    incorrect_count = total - correct_count
    accuracy = correct_count / total if total > 0 else 0.0

    errors_only = error_df[~error_df["is_correct"]]

    # Category counts
    cat_counts = error_df["error_category"].value_counts().to_dict()

    # Most frequent confusion pairs: (Actual, Predicted)
    confusion_pairs = {}
    for _, row in errors_only.iterrows():
        pair = f"{row['actual_class_name']} -> {row['predicted_class_name']}"
        confusion_pairs[pair] = confusion_pairs.get(pair, 0) + 1

    # Sort confusion pairs by frequency
    sorted_pairs = sorted(confusion_pairs.items(), key=lambda x: x[1], reverse=True)

    # High confidence errors
    high_conf_errors = errors_only[errors_only["confidence"] >= 0.80]

    # Healthy vs diseased misclassification counts
    disease_to_healthy = int(errors_only["error_category"].str.contains("DISEASE_TO_HEALTHY").sum())
    healthy_to_disease = int(errors_only["error_category"].str.contains("HEALTHY_TO_DISEASE").sum())

    return {
        "total_evaluated_samples": total,
        "correct_predictions": correct_count,
        "incorrect_predictions": incorrect_count,
        "empirical_accuracy": round(accuracy, 4),
        "category_distribution": cat_counts,
        "most_confused_pairs": sorted_pairs[:10],
        "high_confidence_error_count": len(high_conf_errors),
        "disease_mistaken_for_healthy_count": disease_to_healthy,
        "healthy_mistaken_for_disease_count": healthy_to_disease,
    }
