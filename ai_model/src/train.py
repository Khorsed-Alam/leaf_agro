import os
import json
import pandas as pd
import tensorflow as tf
from pathlib import Path

try:
    from .config import (
        TRAIN_DIR, VAL_DIR, MODELS_DIR, REPORTS_DIR,
        KERAS_MODEL_NAME, LABELS_FILE_NAME, INITIAL_EPOCHS,
        FINE_TUNE_EPOCHS, FINE_TUNE_LEARNING_RATE
    )
    from .dataset import load_datasets
    from .model import build_model, unfreeze_for_fine_tuning
except ImportError:
    from config import (
        TRAIN_DIR, VAL_DIR, MODELS_DIR, REPORTS_DIR,
        KERAS_MODEL_NAME, LABELS_FILE_NAME, INITIAL_EPOCHS,
        FINE_TUNE_EPOCHS, FINE_TUNE_LEARNING_RATE
    )
    from dataset import load_datasets
    from model import build_model, unfreeze_for_fine_tuning


def main():
    MODELS_DIR.mkdir(parents=True, exist_ok=True)
    REPORTS_DIR.mkdir(parents=True, exist_ok=True)

    print("=== Step 1: Loading Datasets ===")
    if not TRAIN_DIR.exists() or not any(TRAIN_DIR.iterdir()):
        print(f"Warning: {TRAIN_DIR} is empty. Please place your processed training images into subfolders.")
        return

    train_ds, val_ds, _, class_names = load_datasets(TRAIN_DIR, VAL_DIR)
    num_classes = len(class_names)
    print(f"Found {num_classes} classes: {class_names}")

    # Save labels.json
    labels_path = MODELS_DIR / LABELS_FILE_NAME
    with open(labels_path, "w", encoding="utf-8") as f:
        json.dump(class_names, f, indent=2)
    print(f"Saved class labels to {labels_path}")

    print("=== Step 2: Building MobileNetV2 Model ===")
    model, base_model = build_model(num_classes=num_classes)
    model.summary()

    callbacks = [
        tf.keras.callbacks.EarlyStopping(monitor="val_loss", patience=5, restore_best_weights=True),
        tf.keras.callbacks.ModelCheckpoint(
            filepath=str(MODELS_DIR / KERAS_MODEL_NAME),
            monitor="val_accuracy",
            save_best_only=True,
            verbose=1
        ),
        tf.keras.callbacks.ReduceLROnPlateau(monitor="val_loss", factor=0.2, patience=3, min_lr=1e-6)
    ]

    print("=== Step 3: Phase 1 Training (Feature Extraction) ===")
    history_initial = model.fit(
        train_ds,
        validation_data=val_ds,
        epochs=INITIAL_EPOCHS,
        callbacks=callbacks
    )

    print("=== Step 4: Phase 2 Fine-Tuning ===")
    model = unfreeze_for_fine_tuning(model, base_model, fine_tune_at=100, learning_rate=FINE_TUNE_LEARNING_RATE)
    history_fine = model.fit(
        train_ds,
        validation_data=val_ds,
        epochs=INITIAL_EPOCHS + FINE_TUNE_EPOCHS,
        initial_epoch=history_initial.epoch[-1] + 1 if history_initial.epoch else 0,
        callbacks=callbacks
    )

    # Save training history
    history_dict = {}
    for k in history_initial.history:
        history_dict[k] = history_initial.history[k] + history_fine.history.get(k, [])

    history_df = pd.DataFrame(history_dict)
    history_df.to_csv(REPORTS_DIR / "training_history.csv", index=False)
    print(f"Saved training history to {REPORTS_DIR / 'training_history.csv'}")


if __name__ == "__main__":
    main()

