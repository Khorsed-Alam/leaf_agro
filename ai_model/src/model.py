import tensorflow as tf
from tensorflow.keras import layers, models
try:
    from .config import IMG_HEIGHT, IMG_WIDTH, CHANNELS, NUM_CLASSES, INITIAL_LEARNING_RATE
except ImportError:
    from config import IMG_HEIGHT, IMG_WIDTH, CHANNELS, NUM_CLASSES, INITIAL_LEARNING_RATE


def build_model(num_classes=NUM_CLASSES, dropout_rate=0.25):
    """
    Builds a MobileNetV2-based transfer learning classifier
    optimized for edge deployment on mobile devices via TensorFlow Lite.
    """
    inputs = layers.Input(shape=(IMG_HEIGHT, IMG_WIDTH, CHANNELS), name="input_image")

    # MobileNetV2 requires input normalized to [-1, 1]
    # x = (x / 127.5) - 1.0
    x = layers.Rescaling(scale=1.0 / 127.5, offset=-1.0, name="mobilenetv2_rescaling")(inputs)

    # Base pretrained model
    base_model = tf.keras.applications.MobileNetV2(
        input_shape=(IMG_HEIGHT, IMG_WIDTH, CHANNELS),
        include_top=False,
        weights="imagenet"
    )
    base_model.trainable = False

    x = base_model(x, training=False)
    x = layers.GlobalAveragePooling2D(name="global_avg_pool")(x)
    x = layers.BatchNormalization(name="head_batch_norm")(x)
    x = layers.Dropout(dropout_rate, name="head_dropout")(x)
    outputs = layers.Dense(num_classes, activation="softmax", name="predictions")(x)

    model = models.Model(inputs=inputs, outputs=outputs, name="AgriCare_MobileNetV2")

    optimizer = tf.keras.optimizers.Adam(learning_rate=INITIAL_LEARNING_RATE)
    model.compile(
        optimizer=optimizer,
        loss="categorical_crossentropy",
        metrics=["accuracy", tf.keras.metrics.Precision(name="precision"), tf.keras.metrics.Recall(name="recall")]
    )

    return model, base_model


def unfreeze_for_fine_tuning(model, base_model, fine_tune_at=100, learning_rate=1e-5):
    """
    Unfreezes the top layers of MobileNetV2 backbone for fine-tuning.
    """
    base_model.trainable = True

    # Freeze all layers before fine_tune_at
    for layer in base_model.layers[:fine_tune_at]:
        layer.trainable = False

    optimizer = tf.keras.optimizers.Adam(learning_rate=learning_rate)
    model.compile(
        optimizer=optimizer,
        loss="categorical_crossentropy",
        metrics=["accuracy", tf.keras.metrics.Precision(name="precision"), tf.keras.metrics.Recall(name="recall")]
    )
    return model

