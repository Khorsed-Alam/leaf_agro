import json
import numpy as np
import tensorflow as tf
from pathlib import Path
from sklearn.metrics import classification_report, confusion_matrix
import matplotlib.pyplot as plt
import seaborn as sns

try:
    from .config import TEST_DIR, MODELS_DIR, REPORTS_DIR, KERAS_MODEL_NAME, LABELS_FILE_NAME
    from .dataset import load_datasets
except ImportError:
    from config import TEST_DIR, MODELS_DIR, REPORTS_DIR, KERAS_MODEL_NAME, LABELS_FILE_NAME
    from dataset import load_datasets


def evaluate_model():
    model_path = MODELS_DIR / KERAS_MODEL_NAME
    if not model_path.exists():
        print(f"Error: {model_path} not found. Please train the model first.")
        return

    print("Loading model and labels...")
    model = tf.keras.models.load_model(model_path)
    with open(MODELS_DIR / LABELS_FILE_NAME, "r", encoding="utf-8") as f:
        class_names = json.load(f)

    if not TEST_DIR.exists() or not any(TEST_DIR.iterdir()):
        print(f"Warning: {TEST_DIR} does not exist or is empty.")
        return

    test_ds = tf.keras.utils.image_dataset_from_directory(
        TEST_DIR,
        labels="categorical",
        image_size=(224, 224),
        batch_size=32,
        shuffle=False
    )

    y_true = []
    y_pred = []

    print("Running evaluation on test set...")
    for images, labels in test_ds:
        preds = model.predict(images, verbose=0)
        y_true.extend(np.argmax(labels.numpy(), axis=1))
        y_pred.extend(np.argmax(preds, axis=1))

    # Metrics
    report_dict = classification_report(y_true, y_pred, target_names=class_names, output_dict=True)
    report_text = classification_report(y_true, y_pred, target_names=class_names)

    with open(REPORTS_DIR / "classification_report.txt", "w", encoding="utf-8") as f:
        f.write(report_text)

    with open(REPORTS_DIR / "model_metrics.json", "w", encoding="utf-8") as f:
        json.dump(report_dict, f, indent=2)

    # Confusion matrix plot
    cm = confusion_matrix(y_true, y_pred)
    plt.figure(figsize=(12, 10))
    sns.heatmap(cm, annot=True, fmt="d", cmap="Greens", xticklabels=class_names, yticklabels=class_names)
    plt.title("Confusion Matrix — AgriCare AI Leaf Disease Model")
    plt.xlabel("Predicted Label")
    plt.ylabel("True Label")
    plt.tight_layout()
    plt.savefig(REPORTS_DIR / "confusion_matrix.png", dpi=300)
    plt.close()

    print(f"Evaluation complete. Reports generated in {REPORTS_DIR}")


if __name__ == "__main__":
    evaluate_model()

