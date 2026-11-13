"""
AgriCare AI — Evaluation Metrics Module.
Phase 39: AI Model Evaluation and Performance Testing.

Provides mathematical and statistical metric calculation functions:
- Overall classification metrics (Accuracy, Top-1, Macro/Weighted Precision, Recall, F1)
- Per-class classification metrics for all 19 canonical classes
- Confusion matrix generation (raw and row-normalized)
- Publication-quality Matplotlib visualization routines
"""

import os
from pathlib import Path
from typing import Dict, Any, List, Tuple, Optional
import numpy as np
import pandas as pd
import matplotlib
# Use headless backend for reproducible, non-interactive figure generation
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from sklearn.metrics import (
    accuracy_score,
    precision_recall_fscore_support,
    confusion_matrix,
    multilabel_confusion_matrix
)


def compute_overall_metrics(
    y_true: np.ndarray,
    y_pred: np.ndarray,
    y_prob: Optional[np.ndarray] = None,
    num_classes: int = 19
) -> Dict[str, Any]:
    """
    Computes overall multiclass classification metrics with explicit zero-division handling.

    Args:
        y_true: 1D array of ground truth class indices.
        y_pred: 1D array of predicted class indices.
        y_prob: Optional 2D array of predicted class probabilities.
        num_classes: Total number of canonical classes in catalog.

    Returns:
        Dictionary containing overall metrics and documentation definitions.
    """
    acc = float(accuracy_score(y_true, y_pred))

    # Macro-averaged metrics (equal weight to each class)
    macro_p, macro_r, macro_f1, _ = precision_recall_fscore_support(
        y_true, y_pred, average="macro", zero_division=0.0
    )

    # Weighted-averaged metrics (weighted by class support)
    weight_p, weight_r, weight_f1, _ = precision_recall_fscore_support(
        y_true, y_pred, average="weighted", zero_division=0.0
    )

    # Top-k accuracy if probability vectors are available
    top_3_acc = None
    if y_prob is not None and y_prob.shape[1] >= 3:
        top_3_correct = 0
        for i, true_label in enumerate(y_true):
            top_3_indices = np.argsort(y_prob[i])[-3:]
            if true_label in top_3_indices:
                top_3_correct += 1
        top_3_acc = float(top_3_correct / len(y_true)) if len(y_true) > 0 else 0.0

    return {
        "total_test_samples": int(len(y_true)),
        "accuracy": acc,
        "top_1_accuracy": acc,
        "top_3_accuracy": top_3_acc,
        "macro_precision": float(macro_p),
        "macro_recall": float(macro_r),
        "macro_f1_score": float(macro_f1),
        "weighted_precision": float(weight_p),
        "weighted_recall": float(weight_r),
        "weighted_f1_score": float(weight_f1),
        "metric_definitions": {
            "accuracy": "Proportion of total predictions that exactly match ground truth.",
            "top_1_accuracy": "Proportion where the highest-probability class matches ground truth (equivalent to accuracy in single-label classification).",
            "macro_averaging": "Unweighted mean across all classes; treats every class equally regardless of sample frequency.",
            "weighted_averaging": "Support-weighted mean across classes; reflects empirical class frequency distribution."
        }
    }


def compute_per_class_metrics(
    y_true: np.ndarray,
    y_pred: np.ndarray,
    class_names: List[str],
    zero_division: float = 0.0
) -> pd.DataFrame:
    """
    Calculates detailed per-class classification metrics across all verified classes.

    Args:
        y_true: 1D array of ground truth class indices.
        y_pred: 1D array of predicted class indices.
        class_names: List of all canonical class names in index order.
        zero_division: Value to substitute when precision/recall is undefined.

    Returns:
        pandas.DataFrame with columns:
        [class_index, class_name, support, true_positives, false_positives,
         false_negatives, true_negatives, precision, recall, f1_score, evaluation_status]
    """
    num_classes = len(class_names)
    labels = list(range(num_classes))

    # Multilabel confusion matrix calculates 2x2 confusion matrix for each class:
    # [[TN, FP], [FN, TP]]
    mcm = multilabel_confusion_matrix(y_true, y_pred, labels=labels)

    # Precision, recall, f1, support per class
    precision, recall, f1, support = precision_recall_fscore_support(
        y_true, y_pred, labels=labels, zero_division=zero_division
    )

    records = []
    for idx in range(num_classes):
        tn = int(mcm[idx, 0, 0])
        fp = int(mcm[idx, 0, 1])
        fn = int(mcm[idx, 1, 0])
        tp = int(mcm[idx, 1, 1])
        supp = int(support[idx])

        status = "EVALUATED_TEST_SUPPORT" if supp > 0 else "ZERO_TEST_SUPPORT_UNASSESSED"

        records.append({
            "class_index": idx,
            "class_name": class_names[idx],
            "support": supp,
            "true_positives": tp,
            "false_positives": fp,
            "false_negatives": fn,
            "true_negatives": tn,
            "precision": round(float(precision[idx]), 4),
            "recall": round(float(recall[idx]), 4),
            "f1_score": round(float(f1[idx]), 4),
            "evaluation_status": status
        })

    return pd.DataFrame(records)


def compute_confusion_matrices(
    y_true: np.ndarray,
    y_pred: np.ndarray,
    num_classes: int = 19
) -> Tuple[np.ndarray, np.ndarray]:
    """
    Computes raw count confusion matrix and row-normalized (recall-normalized) confusion matrix.

    Args:
        y_true: 1D array of ground truth class indices.
        y_pred: 1D array of predicted class indices.
        num_classes: Total class count.

    Returns:
        Tuple of (raw_confusion_matrix, normalized_confusion_matrix) as float numpy arrays.
    """
    labels = list(range(num_classes))
    raw_cm = confusion_matrix(y_true, y_pred, labels=labels)

    # Row normalization: divide by true support (row sum)
    row_sums = raw_cm.sum(axis=1, keepdims=True)
    with np.errstate(divide="ignore", invalid="ignore"):
        normalized_cm = np.where(row_sums > 0, raw_cm / row_sums, 0.0)

    return raw_cm, normalized_cm


def plot_confusion_matrix(
    cm: np.ndarray,
    class_names: List[str],
    normalized: bool = False,
    save_path: Optional[Path] = None,
    title: Optional[str] = None
) -> None:
    """
    Renders and saves a high-resolution confusion matrix heatmap.
    """
    fig, ax = plt.subplots(figsize=(14, 12))
    cmap = plt.cm.Blues if not normalized else plt.cm.Greens

    im = ax.imshow(cm, interpolation="nearest", cmap=cmap)
    cbar = ax.figure.colorbar(im, ax=ax, fraction=0.046, pad=0.04)
    cbar.set_label("Normalized Proportion" if normalized else "Sample Count", rotation=270, labelpad=20)

    # Format ticks and labels
    ax.set_xticks(np.arange(len(class_names)))
    ax.set_yticks(np.arange(len(class_names)))
    ax.set_xticklabels(class_names, rotation=45, ha="right", fontsize=9)
    ax.set_yticklabels(class_names, fontsize=9)

    ax.set_xlabel("Predicted Class", fontsize=12, labelpad=10)
    ax.set_ylabel("True Class", fontsize=12, labelpad=10)
    ax.set_title(title or ("Normalized Confusion Matrix (Recall)" if normalized else "Raw Confusion Matrix"), fontsize=14, pad=15)

    # Loop over data dimensions and create text annotations
    fmt = ".2f" if normalized else "d"
    thresh = cm.max() / 2.0 if cm.max() > 0 else 1.0

    for i in range(cm.shape[0]):
        for j in range(cm.shape[1]):
            val = cm[i, j]
            if val > 0:
                ax.text(
                    j, i, format(val, fmt),
                    ha="center", va="center",
                    color="white" if val > thresh else "black",
                    fontsize=8, fontweight="bold"
                )

    plt.tight_layout()
    if save_path:
        os.makedirs(Path(save_path).parent, exist_ok=True)
        plt.savefig(save_path, dpi=300, bbox_inches="tight")
    plt.close(fig)


def plot_classwise_metrics(
    per_class_df: pd.DataFrame,
    save_dir: Path
) -> Tuple[Path, Path]:
    """
    Generates class-wise F1 and Precision/Recall bar charts.
    """
    os.makedirs(save_dir, exist_ok=True)
    f1_path = save_dir / "classwise_f1.png"
    pr_path = save_dir / "precision_recall.png"

    # Filter to classes with support or display all 19
    df = per_class_df.copy()
    names = df["class_name"].tolist()
    x = np.arange(len(names))

    # 1. Class-wise F1 Chart
    fig, ax = plt.subplots(figsize=(14, 7))
    colors = ["#10B981" if s > 0 else "#CBD5E1" for s in df["support"]]
    bars = ax.bar(x, df["f1_score"], color=colors, edgecolor="#064E3B", width=0.6)

    ax.set_ylabel("F1 Score", fontsize=12)
    ax.set_title("AgriCare AI — Per-Class F1 Score (Green: Evaluated, Gray: Zero Support)", fontsize=14, pad=15)
    ax.set_xticks(x)
    ax.set_xticklabels(names, rotation=45, ha="right", fontsize=9)
    ax.set_ylim(0.0, 1.05)
    ax.grid(axis="y", linestyle="--", alpha=0.5)

    # Add value annotations
    for bar in bars:
        h = bar.get_height()
        if h > 0:
            ax.annotate(f"{h:.2f}",
                        xy=(bar.get_x() + bar.get_width() / 2, h),
                        xytext=(0, 3), textcoords="offset points",
                        ha="center", va="bottom", fontsize=8, fontweight="bold")

    plt.tight_layout()
    plt.savefig(f1_path, dpi=300, bbox_inches="tight")
    plt.close(fig)

    # 2. Precision & Recall Side-by-Side Chart
    fig, ax = plt.subplots(figsize=(15, 7))
    width = 0.35
    ax.bar(x - width/2, df["precision"], width, label="Precision", color="#3B82F6", edgecolor="#1E3A8A")
    ax.bar(x + width/2, df["recall"], width, label="Recall", color="#F59E0B", edgecolor="#78350F")

    ax.set_ylabel("Score", fontsize=12)
    ax.set_title("AgriCare AI — Per-Class Precision vs Recall", fontsize=14, pad=15)
    ax.set_xticks(x)
    ax.set_xticklabels(names, rotation=45, ha="right", fontsize=9)
    ax.set_ylim(0.0, 1.05)
    ax.legend(loc="upper right", frameon=True)
    ax.grid(axis="y", linestyle="--", alpha=0.5)

    plt.tight_layout()
    plt.savefig(pr_path, dpi=300, bbox_inches="tight")
    plt.close(fig)

    return f1_path, pr_path
