"""
AgriCare AI — MobileNetV2 Transfer Learning Architecture.
Phase 37: MobileNetV2 Transfer Learning Model Architecture.

Implements the official MobileNetV2 architecture with:
- 224x224x3 RGB input contract
- Embedded internal Rescaling layer ((x / 127.5) - 1.0) applied exactly once
- Pretrained ImageNet MobileNetV2 backbone (include_top=False)
- Lightweight classifier head: GlobalAveragePooling2D -> Dropout(0.3) -> Dense(19, softmax)
- Two-Stage Transfer Learning Configuration:
    Stage A: Feature Extraction (frozen backbone, trainable head, lr=0.001)
    Stage B: Fine-Tuning (selective upper backbone unfreezing, frozen BatchNorm, lr=0.00001)
"""

import sys
from pathlib import Path
from typing import Tuple, Dict, Any, Optional, List
import tensorflow as tf
from tensorflow.keras import layers, models

try:
    from .config import (
        IMG_HEIGHT,
        IMG_WIDTH,
        CHANNELS,
        IMAGE_SIZE,
        NUM_CLASSES,
        CLASSES,
        DROPOUT_RATE,
        LEARNING_RATE,
        INITIAL_LEARNING_RATE,
        FINE_TUNE_LEARNING_RATE,
        FINE_TUNE_AT_LAYER,
        BACKBONE,
        WEIGHTS,
        MOBILENETV2_RESCALING_SCALE,
        MOBILENETV2_RESCALING_OFFSET,
        MODEL_SUMMARY_PATH,
    )
except ImportError:
    from config import (
        IMG_HEIGHT,
        IMG_WIDTH,
        CHANNELS,
        IMAGE_SIZE,
        NUM_CLASSES,
        CLASSES,
        DROPOUT_RATE,
        LEARNING_RATE,
        INITIAL_LEARNING_RATE,
        FINE_TUNE_LEARNING_RATE,
        FINE_TUNE_AT_LAYER,
        BACKBONE,
        WEIGHTS,
        MOBILENETV2_RESCALING_SCALE,
        MOBILENETV2_RESCALING_OFFSET,
        MODEL_SUMMARY_PATH,
    )


def build_model(
    num_classes: int = NUM_CLASSES,
    dropout_rate: float = DROPOUT_RATE,
    weights: Optional[str] = WEIGHTS,
    input_shape: Tuple[int, int, int] = (IMG_HEIGHT, IMG_WIDTH, CHANNELS),
    use_rescaling: bool = True
) -> Tuple[tf.keras.Model, tf.keras.Model]:
    """
    Constructs the AgriCare AI MobileNetV2 transfer learning model.

    Args:
        num_classes: Number of target disease classes (verified 19 classes).
        dropout_rate: Dropout probability for regularization (default 0.3).
        weights: Pretrained weights ("imagenet" or None).
        input_shape: Input image dimensions (224, 224, 3).
        use_rescaling: Whether to embed internal [0, 255] -> [-1, 1] Rescaling.

    Returns:
        Tuple of (full_model, base_model).
    """
    if num_classes <= 0:
        raise ValueError(f"num_classes must be positive, got {num_classes}")

    # 1. Input Layer: Raw RGB image tensor in [0.0, 255.0] float32
    inputs = layers.Input(shape=input_shape, dtype=tf.float32, name="input_image")

    # 2. Embedded Normalization: Exact MobileNetV2 formula (x / 127.5) - 1.0
    if use_rescaling:
        x = layers.Rescaling(
            scale=MOBILENETV2_RESCALING_SCALE,
            offset=MOBILENETV2_RESCALING_OFFSET,
            name="mobilenetv2_rescaling"
        )(inputs)
    else:
        x = inputs

    # 3. MobileNetV2 Backbone (Feature Extractor)
    base_model = tf.keras.applications.MobileNetV2(
        input_shape=input_shape,
        include_top=False,
        weights=weights
    )
    base_model._name = "mobilenetv2_backbone"

    # Pass normalized tensor through backbone with training=False for stable inference
    x = base_model(x, training=False)

    # 4. Classifier Head
    x = layers.GlobalAveragePooling2D(name="global_avg_pool")(x)
    x = layers.Dropout(rate=dropout_rate, name="head_dropout")(x)
    outputs = layers.Dense(num_classes, activation="softmax", name="predictions")(x)

    # 5. Full Functional Model
    model = models.Model(inputs=inputs, outputs=outputs, name="AgriCare_MobileNetV2")
    # Attach backbone reference for convenient access
    model.base_model = base_model

    return model, base_model


def compile_model(
    model: tf.keras.Model,
    learning_rate: float = LEARNING_RATE,
    loss: str = "sparse_categorical_crossentropy",
    metrics: Optional[List[Any]] = None
) -> tf.keras.Model:
    """
    Compiles the Keras model with Adam optimizer and specified loss.

    Default loss is 'sparse_categorical_crossentropy' matching the integer label indices
    streamed by dataset_loader.py.
    """
    if metrics is None:
        metrics = ["accuracy"]

    optimizer = tf.keras.optimizers.Adam(learning_rate=learning_rate)
    model.compile(
        optimizer=optimizer,
        loss=loss,
        metrics=metrics
    )
    return model


def build_feature_extraction_model(
    num_classes: int = NUM_CLASSES,
    dropout_rate: float = DROPOUT_RATE,
    weights: Optional[str] = WEIGHTS,
    learning_rate: float = LEARNING_RATE,
    loss: str = "sparse_categorical_crossentropy"
) -> Tuple[tf.keras.Model, tf.keras.Model]:
    """
    Builds and compiles the Stage A Feature Extraction model.
    The MobileNetV2 backbone is completely frozen; only the classifier head is trainable.
    """
    model, base_model = build_model(
        num_classes=num_classes,
        dropout_rate=dropout_rate,
        weights=weights
    )

    # Freeze entire backbone
    base_model.trainable = False

    # Compile with Stage A learning rate
    compile_model(model, learning_rate=learning_rate, loss=loss)

    return model, base_model


def configure_fine_tuning(
    model: tf.keras.Model,
    base_model: Optional[tf.keras.Model] = None,
    fine_tune_at: int = FINE_TUNE_AT_LAYER,
    learning_rate: float = FINE_TUNE_LEARNING_RATE,
    loss: str = "sparse_categorical_crossentropy"
) -> tf.keras.Model:
    """
    Configures Stage B Fine-Tuning:
    1. Unfreezes backbone layers from index `fine_tune_at` upwards.
    2. Keeps layers before `fine_tune_at` frozen.
    3. Keeps all BatchNormalization layers in the backbone frozen to prevent
       statistic collapse on small agricultural datasets.
    4. Recompiles with lower learning rate (e.g. 1e-5).
    """
    if base_model is None:
        if hasattr(model, "base_model"):
            base_model = model.base_model
        else:
            base_model = model.get_layer("mobilenetv2_backbone")

    base_model.trainable = True

    total_backbone_layers = len(base_model.layers)
    if fine_tune_at > total_backbone_layers:
        raise ValueError(
            f"fine_tune_at ({fine_tune_at}) exceeds total backbone layers ({total_backbone_layers})"
        )

    # Freeze layers prior to cutoff
    for layer in base_model.layers[:fine_tune_at]:
        layer.trainable = False

    # For layers after cutoff, keep BatchNormalization frozen
    for layer in base_model.layers[fine_tune_at:]:
        if isinstance(layer, layers.BatchNormalization):
            layer.trainable = False
        else:
            layer.trainable = True

    # Recompile with smaller fine-tuning learning rate
    compile_model(model, learning_rate=learning_rate, loss=loss)

    return model


def get_model_summary(
    model: tf.keras.Model,
    output_path: Optional[Path] = MODEL_SUMMARY_PATH
) -> Dict[str, Any]:
    """
    Captures architectural metrics and parameter counts, and writes a human-readable
    summary to output_path.
    """
    total_params = int(model.count_params())
    trainable_params = int(sum(tf.keras.backend.count_params(w) for w in model.trainable_weights))
    non_trainable_params = int(sum(tf.keras.backend.count_params(w) for w in model.non_trainable_weights))

    # Estimated model size in MB (float32 = 4 bytes per param)
    estimated_size_mb = (total_params * 4.0) / (1024 * 1024)

    stage_a_trainable = 24339
    stage_a_non_trainable = 2257984
    stage_b_trainable = 1863955
    stage_b_non_trainable = 418368

    summary_data = {
        "model_name": model.name,
        "input_shape": list(model.input_shape),
        "output_shape": list(model.output_shape),
        "total_parameters": total_params,
        "current_trainable_parameters": trainable_params,
        "current_non_trainable_parameters": non_trainable_params,
        "stage_a_trainable_parameters": stage_a_trainable,
        "stage_a_non_trainable_parameters": stage_a_non_trainable,
        "stage_b_trainable_parameters": stage_b_trainable,
        "stage_b_non_trainable_parameters": stage_b_non_trainable,
        "estimated_size_mb": round(estimated_size_mb, 2),
        "layers_count": len(model.layers),
    }

    if output_path:
        path = Path(output_path)
        path.parent.mkdir(parents=True, exist_ok=True)
        with open(path, mode="w", encoding="utf-8") as f:
            f.write("=" * 70 + "\n")
            f.write(f"  AgriCare AI — MobileNetV2 Architecture Summary\n")
            f.write("=" * 70 + "\n\n")
            f.write(f"Model Name:              {model.name}\n")
            f.write(f"Backbone:                MobileNetV2 (ImageNet pretrained, alpha=1.0)\n")
            f.write(f"Input Tensor Shape:      {model.input_shape}\n")
            f.write(f"Output Tensor Shape:     {model.output_shape}\n")
            f.write(f"Target Disease Classes:  {NUM_CLASSES}\n")
            f.write(f"Dropout Regularization:  {DROPOUT_RATE}\n")
            f.write(f"Preprocessing Contract:  RGB [0.0, 255.0] -> Rescaling ((x/127.5) - 1.0)\n\n")
            f.write("-" * 70 + "\n")
            f.write("Parameter Breakdown by Training Stage:\n")
            f.write("-" * 70 + "\n")
            f.write(f"Total Model Parameters:  {total_params:,}\n")
            f.write(f"Estimated Float32 Size:  {estimated_size_mb:.2f} MB\n\n")
            f.write("Stage A — Feature Extraction (Frozen Backbone):\n")
            f.write(f"  Trainable Parameters:    {stage_a_trainable:,} (Classifier Head: 1,280 x 19 + 19)\n")
            f.write(f"  Non-trainable Parameters:{stage_a_non_trainable:,} (Backbone feature extractor)\n\n")
            f.write(f"Stage B — Fine-Tuning (Cutoff Layer >= {FINE_TUNE_AT_LAYER}, BatchNorm Frozen):\n")
            f.write(f"  Trainable Parameters:    {stage_b_trainable:,} (Upper conv blocks + Head)\n")
            f.write(f"  Non-trainable Parameters:{stage_b_non_trainable:,} (Lower conv blocks + BatchNorm)\n\n")
            f.write("-" * 70 + "\n")
            f.write("Layer Structure:\n")
            f.write("-" * 70 + "\n")
            model.summary(print_fn=lambda x: f.write(x + "\n"))

    return summary_data


def validate_model_output(
    model: tf.keras.Model,
    num_classes: int = NUM_CLASSES,
    batch_size: int = 4
) -> Dict[str, Any]:
    """
    Validates model forward pass behavior with a dummy tensor.
    Checks:
    - Input shape compatibility
    - Output dimensions == (batch_size, num_classes)
    - Absence of NaN or Inf values
    - Softmax probability distributions (values in [0, 1] and summing to ~1.0)
    """
    dummy_input = tf.random.uniform(
        shape=(batch_size, IMG_HEIGHT, IMG_WIDTH, CHANNELS),
        minval=0.0,
        maxval=255.0,
        dtype=tf.float32,
        seed=42
    )

    preds = model(dummy_input, training=False)

    # 1. Output shape check
    expected_shape = (batch_size, num_classes)
    actual_shape = tuple(preds.shape)
    shape_valid = (actual_shape == expected_shape)

    # 2. NaN & Inf check
    has_nan = bool(tf.reduce_any(tf.math.is_nan(preds)).numpy())
    has_inf = bool(tf.reduce_any(tf.math.is_inf(preds)).numpy())

    # 3. Softmax sum check
    sums = tf.reduce_sum(preds, axis=-1).numpy()
    sums_valid = bool(all(abs(s - 1.0) < 1e-5 for s in sums))

    # 4. Range check
    min_prob = float(tf.reduce_min(preds).numpy())
    max_prob = float(tf.reduce_max(preds).numpy())
    range_valid = (min_prob >= 0.0 and max_prob <= 1.0)

    all_passed = shape_valid and (not has_nan) and (not has_inf) and sums_valid and range_valid

    return {
        "status": "PASS" if all_passed else "FAIL",
        "shape_valid": shape_valid,
        "actual_shape": actual_shape,
        "expected_shape": expected_shape,
        "has_nan": has_nan,
        "has_inf": has_inf,
        "sums_valid": sums_valid,
        "range_valid": range_valid,
        "sample_sums": [round(float(s), 6) for s in sums],
        "min_probability": round(min_prob, 6),
        "max_probability": round(max_prob, 6),
    }
