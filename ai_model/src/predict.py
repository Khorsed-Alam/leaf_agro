import sys
import json
import numpy as np
import tensorflow as tf
from pathlib import Path
try:
    from .config import MODELS_DIR, TFLITE_MODEL_NAME, LABELS_FILE_NAME
    from .preprocessing import preprocess_image_file
except ImportError:
    from config import MODELS_DIR, TFLITE_MODEL_NAME, LABELS_FILE_NAME
    from preprocessing import preprocess_image_file


def predict_leaf_disease(image_path):
    tflite_path = MODELS_DIR / TFLITE_MODEL_NAME
    labels_path = MODELS_DIR / LABELS_FILE_NAME

    if not tflite_path.exists() or not labels_path.exists():
        print("Model or labels file not found. Ensure model is exported.")
        return None

    with open(labels_path, "r", encoding="utf-8") as f:
        labels = json.load(f)

    # Initialize TFLite interpreter
    interpreter = tf.lite.Interpreter(model_path=str(tflite_path))
    interpreter.allocate_tensors()

    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()

    input_data = preprocess_image_file(image_path)

    interpreter.set_tensor(input_details[0]["index"], input_data)
    interpreter.invoke()

    output_data = interpreter.get_tensor(output_details[0]["index"])[0]
    top_index = int(np.argmax(output_data))
    confidence = float(output_data[top_index])
    predicted_class = labels[top_index]

    crop_name = predicted_class.split("___")[0]
    disease_name = predicted_class.split("___")[1].replace("_", " ")

    result = {
        "class_name": predicted_class,
        "crop": crop_name,
        "disease": disease_name,
        "confidence": round(confidence, 4),
        "is_healthy": "healthy" in disease_name.lower()
    }

    print("Prediction Result:")
    print(json.dumps(result, indent=2))
    return result


if __name__ == "__main__":
    if len(sys.argv) > 1:
        predict_leaf_disease(sys.argv[1])
    else:
        print("Usage: python predict.py <path_to_leaf_image>")

