"""
AgriCare AI — Model Confidence & Calibration Module.
Phase 39: AI Model Evaluation and Performance Testing.

Provides statistical probability calibration analysis:
- Expected Calibration Error (ECE) calculation with fixed-width binning
- Multiclass Brier Score computation with explicit mathematical convention
- Confidence distribution profiling for correct vs incorrect predictions
- Reliability diagram and calibration visualization generation
"""

import os
from pathlib import Path
from typing import Dict, Any, List, Tuple, Optional
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt


def compute_multiclass_brier_score(
    y_true: np.ndarray,
    y_probs: np.ndarray,
    num_classes: int = 19
) -> float:
    """
    Computes the standardized multiclass Brier score.

    Mathematical Convention:
        BS = (1 / N) * sum_{i=1}^N sum_{k=1}^K (p_{ik} - y_{ik})^2
        where y_{ik} is 1 if sample i belongs to class k and 0 otherwise,
        and p_{ik} is the model's predicted probability for class k.

    Properties:
        - Range: [0.0, 2.0]
        - Lower is better (0.0 represents perfect deterministic foresight).
    """
    n_samples = len(y_true)
    if n_samples == 0:
        return 0.0

    # One-hot encode ground truth
    y_onehot = np.zeros((n_samples, num_classes), dtype=np.float32)
    for i, label in enumerate(y_true):
        if 0 <= label < num_classes:
            y_onehot[i, label] = 1.0

    # Squared difference summed across classes, averaged across samples
    squared_diff = np.sum((y_probs - y_onehot) ** 2, axis=1)
    brier_score = float(np.mean(squared_diff))
    return round(brier_score, 5)


def compute_ece(
    y_true: np.ndarray,
    y_pred: np.ndarray,
    confidences: np.ndarray,
    num_bins: int = 10
) -> Tuple[float, List[Dict[str, Any]]]:
    """
    Computes Expected Calibration Error (ECE) using fixed-width confidence bins.

    Mathematical Definition:
        ECE = sum_{b=1}^B (n_b / N) * |acc(b) - conf(b)|
        where n_b is the number of predictions falling into bin b,
        acc(b) is the empirical accuracy in bin b,
        conf(b) is the average model confidence in bin b.

    Args:
        y_true: 1D array of ground truth labels.
        y_pred: 1D array of predicted labels.
        confidences: 1D array of maximum softmax probabilities (model confidence).
        num_bins: Number of equal-width bins in [0, 1] (default: 10).

    Returns:
        Tuple of (ece_value, bin_details_list)
    """
    n_samples = len(y_true)
    if n_samples == 0:
        return 0.0, []

    bin_boundaries = np.linspace(0.0, 1.0, num_bins + 1)
    bin_details = []
    ece = 0.0

    is_correct = (y_true == y_pred)

    for i in range(num_bins):
        bin_lower = bin_boundaries[i]
        bin_upper = bin_boundaries[i + 1]

        # Handle the upper edge of the last bin to include confidence == 1.0
        if i == num_bins - 1:
            in_bin = (confidences >= bin_lower) & (confidences <= bin_upper)
        else:
            in_bin = (confidences >= bin_lower) & (confidences < bin_upper)

        count = int(np.sum(in_bin))

        if count > 0:
            bin_acc = float(np.mean(is_correct[in_bin]))
            bin_conf = float(np.mean(confidences[in_bin]))
            bin_error = abs(bin_acc - bin_conf)
            weight = count / n_samples
            ece += weight * bin_error
        else:
            bin_acc = 0.0
            bin_conf = float((bin_lower + bin_upper) / 2.0)
            bin_error = 0.0

        bin_details.append({
            "bin_index": i,
            "bin_range": [round(float(bin_lower), 2), round(float(bin_upper), 2)],
            "sample_count": count,
            "mean_confidence": round(bin_conf, 4) if count > 0 else 0.0,
            "empirical_accuracy": round(bin_acc, 4) if count > 0 else 0.0,
            "calibration_gap": round(bin_error, 4) if count > 0 else 0.0
        })

    return round(float(ece), 4), bin_details


def compute_calibration_analysis(
    y_true: np.ndarray,
    y_pred: np.ndarray,
    y_probs: np.ndarray,
    num_classes: int = 19,
    num_bins: int = 10
) -> Dict[str, Any]:
    """
    Executes comprehensive model confidence and calibration analysis.
    """
    confidences = np.max(y_probs, axis=1)
    is_correct = (y_true == y_pred)

    ece, bin_details = compute_ece(y_true, y_pred, confidences, num_bins=num_bins)
    brier_score = compute_multiclass_brier_score(y_true, y_probs, num_classes=num_classes)

    # Statistical summaries of confidence
    correct_confs = confidences[is_correct]
    incorrect_confs = confidences[~is_correct]

    return {
        "expected_calibration_error": ece,
        "multiclass_brier_score": brier_score,
        "brier_score_convention": "Mean squared error summed over all 19 classes: (1/N)*sum(sum((p_ik - y_ik)^2)), range [0.0, 2.0]",
        "binning_method": f"Fixed-width {num_bins} equal-sized intervals between 0.0 and 1.0",
        "bins": bin_details,
        "confidence_statistics": {
            "overall_mean": round(float(np.mean(confidences)), 4) if len(confidences) > 0 else 0.0,
            "overall_median": round(float(np.median(confidences)), 4) if len(confidences) > 0 else 0.0,
            "overall_std": round(float(np.std(confidences)), 4) if len(confidences) > 0 else 0.0,
            "correct_mean": round(float(np.mean(correct_confs)), 4) if len(correct_confs) > 0 else 0.0,
            "incorrect_mean": round(float(np.mean(incorrect_confs)), 4) if len(incorrect_confs) > 0 else 0.0,
        },
        "threshold_policy": {
            "status": "UNTOUCHED_UNBOUND_TEST_EVALUATION",
            "reason": "Confidence thresholds must be tuned strictly using validation or external calibration sets; never optimized using the untouched test partition."
        }
    }


def plot_reliability_diagram(
    bin_details: List[Dict[str, Any]],
    ece: float,
    save_path: Path
) -> None:
    """
    Plots the calibration curve / reliability diagram against perfect calibration line.
    """
    os.makedirs(save_path.parent, exist_ok=True)
    fig, ax = plt.subplots(figsize=(8, 8))

    # Reference diagonal (perfect calibration)
    ax.plot([0, 1], [0, 1], linestyle="--", color="#64748B", label="Perfect Calibration")

    centers = []
    accuracies = []
    counts = []

    for b in bin_details:
        if b["sample_count"] > 0:
            centers.append(b["mean_confidence"])
            accuracies.append(b["empirical_accuracy"])
            counts.append(b["sample_count"])

    if centers:
        ax.bar(
            centers, accuracies, width=0.08,
            color="#3B82F6", alpha=0.7, edgecolor="#1E3A8A",
            label="Observed Accuracy per Bin"
        )
        for x_val, y_val, c in zip(centers, accuracies, counts):
            ax.annotate(f"n={c}", xy=(x_val, y_val), xytext=(0, 5),
                        textcoords="offset points", ha="center", fontsize=8, fontweight="bold")

    ax.set_xlabel("Mean Model Confidence", fontsize=12)
    ax.set_ylabel("Empirical Accuracy", fontsize=12)
    ax.set_title(f"AgriCare AI — Reliability Diagram (ECE = {ece:.4f})", fontsize=14, pad=15)
    ax.set_xlim(0.0, 1.05)
    ax.set_ylim(0.0, 1.05)
    ax.legend(loc="upper left")
    ax.grid(True, linestyle="--", alpha=0.5)

    plt.tight_layout()
    plt.savefig(save_path, dpi=300, bbox_inches="tight")
    plt.close(fig)


def plot_confidence_distribution(
    confidences: np.ndarray,
    is_correct: np.ndarray,
    save_dir: Path
) -> Tuple[Path, Path]:
    """
    Generates confidence distribution and correct vs incorrect confidence comparison plots.
    """
    os.makedirs(save_dir, exist_ok=True)
    dist_path = save_dir / "confidence_distribution.png"
    comp_path = save_dir / "correct_vs_incorrect_confidence.png"

    # 1. Overall Confidence Distribution
    fig, ax = plt.subplots(figsize=(8, 6))
    bins = np.linspace(0.0, 1.0, 11)
    ax.hist(confidences, bins=bins, color="#10B981", edgecolor="#064E3B", rwidth=0.85)
    ax.set_xlabel("Predicted Confidence (Softmax)", fontsize=12)
    ax.set_ylabel("Sample Count", fontsize=12)
    ax.set_title("AgriCare AI — Test Prediction Confidence Distribution", fontsize=14, pad=15)
    ax.set_xlim(0.0, 1.05)
    ax.grid(axis="y", linestyle="--", alpha=0.5)

    plt.tight_layout()
    plt.savefig(dist_path, dpi=300, bbox_inches="tight")
    plt.close(fig)

    # 2. Correct vs Incorrect Comparison
    fig, ax = plt.subplots(figsize=(8, 6))
    correct_confs = confidences[is_correct]
    incorrect_confs = confidences[~is_correct]

    data_to_plot = []
    labels = []
    if len(correct_confs) > 0:
        data_to_plot.append(correct_confs)
        labels.append(f"Correct (n={len(correct_confs)})")
    if len(incorrect_confs) > 0:
        data_to_plot.append(incorrect_confs)
        labels.append(f"Incorrect (n={len(incorrect_confs)})")

    if data_to_plot:
        try:
            bp = ax.boxplot(data_to_plot, tick_labels=labels, patch_artist=True, widths=0.5)
        except TypeError:
            bp = ax.boxplot(data_to_plot, labels=labels, patch_artist=True, widths=0.5)
        colors = ["#34D399", "#F87171"]
        for patch, color in zip(bp['boxes'], colors[:len(data_to_plot)]):
            patch.set_facecolor(color)
            patch.set_edgecolor("#1E293B")

    ax.set_ylabel("Confidence", fontsize=12)
    ax.set_title("AgriCare AI — Confidence: Correct vs Incorrect Predictions", fontsize=14, pad=15)
    ax.set_ylim(0.0, 1.05)
    ax.grid(axis="y", linestyle="--", alpha=0.5)

    plt.tight_layout()
    plt.savefig(comp_path, dpi=300, bbox_inches="tight")
    plt.close(fig)

    return dist_path, comp_path
