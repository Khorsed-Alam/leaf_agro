import tensorflow as tf
from tensorflow.keras import layers


def get_augmentation_layer():
    """
    Data augmentation pipeline tailored for plant leaf images under variable field lighting,
    angles, and camera zoom levels.
    """
    return tf.keras.Sequential([
        layers.RandomFlip("horizontal_and_vertical", name="aug_flip"),
        layers.RandomRotation(0.15, fill_mode="reflect", name="aug_rotation"),
        layers.RandomZoom(0.1, fill_mode="reflect", name="aug_zoom"),
        layers.RandomContrast(0.15, name="aug_contrast"),
        layers.RandomTranslation(height_factor=0.08, width_factor=0.08, fill_mode="reflect", name="aug_translation"),
    ], name="data_augmentation")

