"""
AgriCare AI — End-to-End Two-Stage Training Pipeline.
Phase 38: AI Model Training and Fine-Tuning.

Orchestrates:
1. Pre-training readiness and data leakage audit
2. Data streaming for training and validation splits (test set strictly excluded)
3. Stage A: Transfer learning / Feature extraction (frozen backbone, lr=0.001)
4. Stage B: Controlled fine-tuning (upper conv unfreezing >= layer 100, BatchNorm frozen, lr=0.00001)
5. Validation-based checkpoint comparison & selection
6. Training history consolidation and plot generation
7. Model metadata update and comprehensive training reporting
"""

import argparse
import datetime
import json
import os
import sys
import time
from pathlib import Path
from typing import Dict, Any, Optional
import tensorflow as tf

try:
    from .config import (
        PROJECT_ROOT,
        BASE_DIR,
        CHECKPOINTS_DIR,
        STAGE_A_CHECKPOINT_PATH,
        STAGE_B_CHECKPOINT_PATH,
        BEST_MODEL_PATH,
        STAGE_A_HISTORY_PATH,
        STAGE_B_HISTORY_PATH,
        TRAINING_HISTORY_PATH,
        TRAINING_CONFIG_PATH,
        TRAINING_REPORT_PATH,
        PLOTS_DIR,
        BATCH_SIZE,
        STAGE_A_EPOCHS,
        STAGE_B_EPOCHS,
        FINE_TUNE_AT_LAYER,
        LEARNING_RATE,
        FINE_TUNE_LEARNING_RATE,
        NUM_CLASSES,
        CLASSES,
        RANDOM_SEED,
        set_reproducibility,
    )
    from .dataset_loader import load_train_dataset, load_validation_dataset
    from .model import build_feature_extraction_model, configure_fine_tuning
    from .callbacks import get_training_callbacks
    from .training_utils import (
        run_pre_training_audit,
        analyze_class_distribution,
        generate_training_plots,
        select_best_model,
        generate_training_report_md,
    )
except ImportError:
    from config import (
        PROJECT_ROOT,
        BASE_DIR,
        CHECKPOINTS_DIR,
        STAGE_A_CHECKPOINT_PATH,
        STAGE_B_CHECKPOINT_PATH,
        BEST_MODEL_PATH,
        STAGE_A_HISTORY_PATH,
        STAGE_B_HISTORY_PATH,
        TRAINING_HISTORY_PATH,
        TRAINING_CONFIG_PATH,
        TRAINING_REPORT_PATH,
        PLOTS_DIR,
        BATCH_SIZE,
        STAGE_A_EPOCHS,
        STAGE_B_EPOCHS,
        FINE_TUNE_AT_LAYER,
        LEARNING_RATE,
        FINE_TUNE_LEARNING_RATE,
        NUM_CLASSES,
        CLASSES,
        RANDOM_SEED,
        set_reproducibility,
    )
    from dataset_loader import load_train_dataset, load_validation_dataset
    from model import build_feature_extraction_model, configure_fine_tuning
    from callbacks import get_training_callbacks
    from training_utils import (
        run_pre_training_audit,
        analyze_class_distribution,
        generate_training_plots,
        select_best_model,
        generate_training_report_md,
    )


def run_training_pipeline(
    stage_a_epochs: int = STAGE_A_EPOCHS,
    stage_b_epochs: int = STAGE_B_EPOCHS,
    batch_size: int = BATCH_SIZE,
    skip_stage_b: bool = False
) -> Dict[str, Any]:
    """
    Executes the complete two-stage transfer learning pipeline.
    """
    start_total_time = time.time()
    CHECKPOINTS_DIR.mkdir(parents=True, exist_ok=True)
    PLOTS_DIR.mkdir(parents=True, exist_ok=True)

    print("=" * 75)
    print("  AgriCare AI — Phase 38 Two-Stage Training & Fine-Tuning Pipeline")
    print("=" * 75)

    # 1. Reproducibility Configuration
    repro = set_reproducibility()
    print(f"[*] Deterministic seed initialized: {repro['seed']}")

    # 2. Pre-training Readiness Audit
    print("\n[Step 1/5] Executing Pre-Training Readiness & Leakage Audit...")
    audit = run_pre_training_audit()
    if audit["status"] != "PASS":
        print(f"[!] Pre-training audit FAILED: {audit['errors']}")
        raise RuntimeError(f"Pre-training audit failed with errors: {audit['errors']}")
    print(f"[*] Audit PASSED. Train samples: {audit['dataset_counts']['train_samples']}, Val samples: {audit['dataset_counts']['validation_samples']}")
    print(f"[*] Test samples: {audit['dataset_counts']['test_samples']} (Isolated and untouched)")

    # 3. Class Distribution & Imbalance Check
    print("\n[Step 2/5] Analyzing Class Distribution & Calculating Weights...")
    dist = analyze_class_distribution()
    class_weights = dist["class_weights"] if dist["use_class_weights"] else None
    print(f"[*] Active classes: {dist['active_classes_count']}, Imbalance ratio: {dist['imbalance_ratio']}:1")
    if dist["use_class_weights"]:
        print(f"[*] Applying training class weights: {class_weights}")
    else:
        print("[*] Classes are balanced; training without artificial weighting.")

    # 4. Stream Datasets
    print("\n[Step 3/5] Streaming Train and Validation Datasets...")
    train_ds = load_train_dataset(batch_size=batch_size)
    val_ds = load_validation_dataset(batch_size=batch_size)

    # 5. Stage A: Feature Extraction
    print("\n" + "-" * 75)
    print(f"  [Step 4/5: Stage A] Feature Extraction Training ({stage_a_epochs} Max Epochs)")
    print("-" * 75)

    stage_a_model, stage_a_base = build_feature_extraction_model(
        num_classes=NUM_CLASSES,
        learning_rate=LEARNING_RATE
    )
    callbacks_a = get_training_callbacks(
        stage_name="stage_a",
        checkpoint_path=STAGE_A_CHECKPOINT_PATH,
        log_csv_path=STAGE_A_HISTORY_PATH
    )

    t0 = time.time()
    history_a = stage_a_model.fit(
        train_ds,
        validation_data=val_ds,
        epochs=stage_a_epochs,
        callbacks=callbacks_a,
        class_weight=class_weights,
        verbose=1
    )
    t_stage_a = time.time() - t0

    # Retrieve Stage A best metrics
    eval_a = stage_a_model.evaluate(val_ds, verbose=0)
    best_val_loss_a = round(float(eval_a[0]), 4)
    best_val_acc_a = round(float(eval_a[1]), 4) if len(eval_a) > 1 else 0.0

    stage_a_results = {
        "status": "COMPLETED",
        "epochs_executed": len(history_a.epoch),
        "best_val_loss": best_val_loss_a,
        "best_val_accuracy": best_val_acc_a,
        "duration_sec": t_stage_a,
        "checkpoint": str(STAGE_A_CHECKPOINT_PATH)
    }
    print(f"[*] Stage A completed in {t_stage_a:.2f}s | Val Loss: {best_val_loss_a} | Val Acc: {best_val_acc_a}")

    # 6. Stage B: Fine-Tuning
    stage_b_results: Dict[str, Any] = {}
    if not skip_stage_b and STAGE_A_CHECKPOINT_PATH.exists():
        print("\n" + "-" * 75)
        print(f"  [Step 5/5: Stage B] Controlled Fine-Tuning ({stage_b_epochs} Max Epochs)")
        print(f"  Unfreezing Backbone from Layer {FINE_TUNE_AT_LAYER} upwards (BatchNorm frozen)")
        print("-" * 75)

        # Load best Stage A checkpoint for fine-tuning
        stage_b_model = tf.keras.models.load_model(str(STAGE_A_CHECKPOINT_PATH))
        stage_b_model = configure_fine_tuning(
            stage_b_model,
            fine_tune_at=FINE_TUNE_AT_LAYER,
            learning_rate=FINE_TUNE_LEARNING_RATE
        )

        callbacks_b = get_training_callbacks(
            stage_name="stage_b",
            checkpoint_path=STAGE_B_CHECKPOINT_PATH,
            log_csv_path=STAGE_B_HISTORY_PATH
        )

        t0 = time.time()
        history_b = stage_b_model.fit(
            train_ds,
            validation_data=val_ds,
            epochs=stage_b_epochs,
            callbacks=callbacks_b,
            class_weight=class_weights,
            verbose=1
        )
        t_stage_b = time.time() - t0

        eval_b = stage_b_model.evaluate(val_ds, verbose=0)
        best_val_loss_b = round(float(eval_b[0]), 4)
        best_val_acc_b = round(float(eval_b[1]), 4) if len(eval_b) > 1 else 0.0

        stage_b_results = {
            "status": "COMPLETED",
            "epochs_executed": len(history_b.epoch),
            "best_val_loss": best_val_loss_b,
            "best_val_accuracy": best_val_acc_b,
            "duration_sec": t_stage_b,
            "checkpoint": str(STAGE_B_CHECKPOINT_PATH)
        }
        print(f"[*] Stage B completed in {t_stage_b:.2f}s | Val Loss: {best_val_loss_b} | Val Acc: {best_val_acc_b}")
    else:
        stage_b_results = {
            "status": "SKIPPED",
            "reason": "skip_stage_b flag active or Stage A checkpoint missing"
        }

    # 7. Model Selection & Deployment
    print("\n" + "=" * 75)
    print("  Comparing Checkpoints on Validation Data & Selecting Final Model...")
    print("=" * 75)
    selection = select_best_model(
        stage_a_path=STAGE_A_CHECKPOINT_PATH,
        stage_b_path=STAGE_B_CHECKPOINT_PATH if STAGE_B_CHECKPOINT_PATH.exists() else STAGE_A_CHECKPOINT_PATH,
        best_model_out=BEST_MODEL_PATH
    )
    print(f"[*] Selected Winner: {selection['selected_stage']}")
    print(f"[*] Deployed to: {selection['best_model_path']}")
    print(f"[*] Best Val Loss: {selection['best_validation_loss']} | Best Val Acc: {selection['best_validation_accuracy']}")

    # 8. Consolidate History & Generate Training Plots
    print("\n[*] Generating Consolidated Training History & Plots...")
    plots = generate_training_plots(
        stage_a_history_csv=STAGE_A_HISTORY_PATH,
        stage_b_history_csv=STAGE_B_HISTORY_PATH,
        combined_history_csv=TRAINING_HISTORY_PATH,
        output_dir=PLOTS_DIR
    )
    for plot_name, ppath in plots.items():
        print(f"  - Plot created: {plot_name} -> {ppath}")

    # 9. Save Training Configuration
    total_pipeline_time = time.time() - start_total_time
    training_config_summary = {
        "pipeline_name": "AgriCare AI Two-Stage Transfer Learning",
        "timestamp": datetime.datetime.now(datetime.timezone.utc).isoformat(),
        "total_duration_sec": round(total_pipeline_time, 2),
        "batch_size": batch_size,
        "random_seed": RANDOM_SEED,
        "num_classes": NUM_CLASSES,
        "stage_a_configured_epochs": stage_a_epochs,
        "stage_b_configured_epochs": stage_b_epochs,
        "stage_a_actual_epochs": stage_a_results.get("epochs_executed", 0),
        "stage_b_actual_epochs": stage_b_results.get("epochs_executed", 0),
        "stage_a_learning_rate": LEARNING_RATE,
        "stage_b_learning_rate": FINE_TUNE_LEARNING_RATE,
        "fine_tune_at_layer": FINE_TUNE_AT_LAYER,
        "optimizer": "Adam",
        "loss": "sparse_categorical_crossentropy",
        "selected_stage": selection["selected_stage"],
        "best_val_loss": selection["best_validation_loss"],
        "best_val_accuracy": selection["best_validation_accuracy"],
        "active_classes_count": dist["active_classes_count"],
        "zero_sample_classes_count": dist["zero_sample_classes_count"],
    }
    with open(TRAINING_CONFIG_PATH, mode="w", encoding="utf-8") as f:
        json.dump(training_config_summary, f, indent=2)

    # 10. Generate Training Report
    generate_training_report_md(
        audit=audit,
        dist=dist,
        stage_a_res=stage_a_results,
        stage_b_res=stage_b_results,
        selection_res=selection,
        report_path=TRAINING_REPORT_PATH
    )
    print(f"\n[*] Training Report written to: {TRAINING_REPORT_PATH}")

    return {
        "status": "COMPLETE",
        "audit": audit,
        "stage_a": stage_a_results,
        "stage_b": stage_b_results,
        "selection": selection,
        "total_time_sec": total_pipeline_time
    }


def main():
    parser = argparse.ArgumentParser(description="AgriCare AI — Model Training & Fine-Tuning Pipeline")
    parser.add_argument("--stage-a-epochs", type=int, default=STAGE_A_EPOCHS, help="Max epochs for Stage A")
    parser.add_argument("--stage-b-epochs", type=int, default=STAGE_B_EPOCHS, help="Max epochs for Stage B")
    parser.add_argument("--batch-size", type=int, default=BATCH_SIZE, help="Batch size for training")
    parser.add_argument("--skip-stage-b", action="store_true", help="Skip Stage B fine-tuning")

    args = parser.parse_args()
    res = run_training_pipeline(
        stage_a_epochs=args.stage_a_epochs,
        stage_b_epochs=args.stage_b_epochs,
        batch_size=args.batch_size,
        skip_stage_b=args.skip_stage_b
    )
    print("\n" + "=" * 75)
    print(f"  Training Pipeline Finished: Status {res['status']}")
    print("=" * 75)


if __name__ == "__main__":
    main()
