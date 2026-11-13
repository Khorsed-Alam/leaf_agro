"""
AgriCare AI — Training-Only Data Augmentation Module.
Phase 34: Image Preprocessing, Normalization & Data Augmentation.

Provides biologically safe, agricultural data augmentation layers for plant disease imagery.
Designed for dynamic application strictly during training:
  - Preserves disease diagnostic markers and lesion margins
  - Avoids extreme rotations or excessive zoom
  - Disables vertical flip to maintain physiological stem/petiole gravity orientation
  - Inactive during validation, testing, and inference
"""

import tensorflow as tf
from tensorflow.keras import layers

try:
    from .config import (
        AUG_HORIZONTAL_FLIP,
        AUG_ROTATION_FACTOR,
        AUG_ZOOM_LOWER,
        AUG_ZOOM_UPPER,
        AUG_TRANSLATION_HEIGHT,
        AUG_TRANSLATION_WIDTH,
        AUG_BRIGHTNESS_FACTOR,
        AUG_CONTRAST_FACTOR,
        RANDOM_SEED,
    )
except ImportError:
    from config import (
        AUG_HORIZONTAL_FLIP,
        AUG_ROTATION_FACTOR,
        AUG_ZOOM_LOWER,
        AUG_ZOOM_UPPER,
        AUG_TRANSLATION_HEIGHT,
        AUG_TRANSLATION_WIDTH,
        AUG_BRIGHTNESS_FACTOR,
        AUG_CONTRAST_FACTOR,
        RANDOM_SEED,
    )


def get_training_augmentation_layer(seed=RANDOM_SEED):
    """
    Constructs a sequential Keras preprocessing pipeline for training-only data augmentation.
    All operations are active only when training=True.
    """
    aug_layers = []

    # 1. Horizontal Flip (Preserves natural horizontal symmetry of leaves)
    if AUG_HORIZONTAL_FLIP:
        aug_layers.append(
            layers.RandomFlip("horizontal", seed=seed, name="aug_horizontal_flip")
        )

    # 2. Controlled Rotation (+/- 10 degrees ~ 0.03 factor of 2*pi)
    aug_layers.append(
        layers.RandomRotation(
            AUG_ROTATION_FACTOR,
            fill_mode="reflect",
            seed=seed,
            name="aug_controlled_rotation"
        )
    )

    # 3. Moderate Zoom (0.90x to 1.10x scale)
    aug_layers.append(
        layers.RandomZoom(
            height_factor=(AUG_ZOOM_LOWER, AUG_ZOOM_UPPER),
            width_factor=(AUG_ZOOM_LOWER, AUG_ZOOM_UPPER),
            fill_mode="reflect",
            seed=seed,
            name="aug_moderate_zoom"
        )
    )

    # 4. Small Translation (+/- 5% height/width shift)
    aug_layers.append(
        layers.RandomTranslation(
            height_factor=AUG_TRANSLATION_HEIGHT,
            width_factor=AUG_TRANSLATION_WIDTH,
            fill_mode="reflect",
            seed=seed,
            name="aug_small_translation"
        )
    )

    # 5. Controlled Brightness Variation (+/- 10%)
    aug_layers.append(
        layers.RandomBrightness(
            factor=AUG_BRIGHTNESS_FACTOR,
            value_range=(0.0, 255.0),
            seed=seed,
            name="aug_controlled_brightness"
        )
    )

    # 6. Controlled Contrast Variation (+/- 10%)
    aug_layers.append(
        layers.RandomContrast(
            factor=AUG_CONTRAST_FACTOR,
            seed=seed,
            name="aug_controlled_contrast"
        )
    )

    return tf.keras.Sequential(aug_layers, name="agricare_training_augmentation")


def apply_augmentation(image_tensor, is_training=True):
    """
    Applies augmentation to a tensor if and only if is_training is True.
    During validation, testing, or inference, returns the original tensor untouched.
    """
    if not is_training:
        return image_tensor
    aug_pipeline = get_training_augmentation_layer()
    return aug_pipeline(image_tensor, training=True)


# ---------------------------------------------------------------------------
# Backward Compatibility Wrapper
# ---------------------------------------------------------------------------
def get_augmentation_layer():
    """
    Backward-compatible alias pointing to get_training_augmentation_layer.
    """
    return get_training_augmentation_layer()
