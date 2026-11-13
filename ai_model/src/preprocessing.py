"""
AgriCare AI — Image Loading, Decoding & Preprocessing Module.
Phase 34: Image Preprocessing, Normalization & Data Augmentation.

Provides reusable image preprocessing utilities for MobileNetV2.
Enforces the external input contract:
  - RGB format
  - 224 x 224 x 3 shape
  - float32 data type
  - 0–255 pixel range (when fed into model with internal Rescaling layer)
"""

import io
from pathlib import Path
import numpy as np
from PIL import Image

try:
    from .config import (
        IMG_HEIGHT,
        IMG_WIDTH,
        IMAGE_SIZE,
        IMAGE_CHANNELS,
        IMAGE_DTYPE,
        INTERPOLATION_METHOD,
        EXTERNAL_PIXEL_MIN,
        EXTERNAL_PIXEL_MAX,
        NORMALIZED_PIXEL_MIN,
        NORMALIZED_PIXEL_MAX,
        MOBILENETV2_RESCALING_SCALE,
        MOBILENETV2_RESCALING_OFFSET,
    )
except ImportError:
    from config import (
        IMG_HEIGHT,
        IMG_WIDTH,
        IMAGE_SIZE,
        IMAGE_CHANNELS,
        IMAGE_DTYPE,
        INTERPOLATION_METHOD,
        EXTERNAL_PIXEL_MIN,
        EXTERNAL_PIXEL_MAX,
        NORMALIZED_PIXEL_MIN,
        NORMALIZED_PIXEL_MAX,
        MOBILENETV2_RESCALING_SCALE,
        MOBILENETV2_RESCALING_OFFSET,
    )


def load_image(filepath):
    """
    Safely opens an image from disk using PIL.
    Supports JPEG, JPG, PNG, BMP, TIFF, and WEBP.
    """
    path = Path(filepath)
    if not path.exists():
        raise FileNotFoundError(f"Image not found at path: {path}")
    try:
        img = Image.open(path)
        img.load()  # Ensure bytes are read into memory
        return img
    except Exception as e:
        raise ValueError(f"Failed to load image at {path}: {str(e)}") from e


def decode_image(image_bytes):
    """
    Decodes raw image bytes into a PIL Image object.
    """
    if not image_bytes:
        raise ValueError("Cannot decode empty image bytes.")
    try:
        buffer = io.BytesIO(image_bytes)
        img = Image.open(buffer)
        img.load()
        return img
    except Exception as e:
        raise ValueError(f"Failed to decode image bytes: {str(e)}") from e


def convert_to_rgb(image):
    """
    Converts any PIL image (RGB, RGBA, Grayscale 'L', Palette 'P', etc.) into 3-channel RGB.
    """
    if not isinstance(image, Image.Image):
        raise TypeError(f"Expected PIL.Image.Image, got {type(image)}")
    if image.mode == "RGB":
        return image
    return image.convert("RGB")


def resize_image(image, target_size=IMAGE_SIZE, method=INTERPOLATION_METHOD):
    """
    Resizes a PIL image to target_size (width, height) using high-quality interpolation.
    Default: Bilinear resampling matching standard edge inference decoders.
    """
    if not isinstance(image, Image.Image):
        raise TypeError(f"Expected PIL.Image.Image, got {type(image)}")

    resampling_map = {
        "bilinear": Image.Resampling.BILINEAR,
        "bicubic": Image.Resampling.BICUBIC,
        "nearest": Image.Resampling.NEAREST,
        "lanczos": Image.Resampling.LANCZOS,
    }
    resample_enum = resampling_map.get(method.lower(), Image.Resampling.BILINEAR)
    return image.resize(target_size, resample=resample_enum)


def validate_image(image):
    """
    Validates that the input image has non-zero dimensions and valid pixel data.
    """
    if not isinstance(image, Image.Image):
        raise TypeError(f"Expected PIL.Image.Image, got {type(image)}")
    width, height = image.size
    if width <= 0 or height <= 0:
        raise ValueError(f"Invalid image dimensions: {width}x{height}")
    return True


def preprocess_for_mobilenetv2(image_array):
    """
    Applies official MobileNetV2 normalization mapping [0, 255] -> [-1.0, 1.0].
    Formula: x = (x / 127.5) - 1.0
    Used for standalone inference when the model graph does not include the Rescaling layer.
    """
    arr = np.asarray(image_array, dtype=np.float32)
    return (arr * MOBILENETV2_RESCALING_SCALE) + MOBILENETV2_RESCALING_OFFSET


def prepare_single_image(image_input, target_size=IMAGE_SIZE, for_model_input=True):
    """
    Complete single-image preparation pipeline.
    Takes either a file path (str/Path), raw bytes, or a PIL Image.
    
    If for_model_input is True (PREFERRED):
      Returns a float32 numpy array with shape (1, 224, 224, 3) in pixel range [0.0, 255.0].
      The model's internal Rescaling layer will perform MobileNetV2 [-1, 1] normalization.
      This strictly PREVENTS DOUBLE-NORMALIZATION.
    
    If for_model_input is False:
      Returns a float32 numpy array in normalized range [-1.0, 1.0].
    """
    if isinstance(image_input, (str, Path)):
        img = load_image(image_input)
    elif isinstance(image_input, bytes):
        img = decode_image(image_input)
    elif isinstance(image_input, Image.Image):
        img = image_input
    else:
        raise TypeError(f"Unsupported image input type: {type(image_input)}")

    validate_image(img)
    rgb_img = convert_to_rgb(img)
    resized_img = resize_image(rgb_img, target_size=target_size)
    arr = np.array(resized_img, dtype=np.float32)

    if not for_model_input:
        arr = preprocess_for_mobilenetv2(arr)

    # Add batch dimension: (1, height, width, 3)
    return np.expand_dims(arr, axis=0)


def prepare_batch(image_inputs, target_size=IMAGE_SIZE, for_model_input=True):
    """
    Prepares a batch of image inputs into a single numpy tensor of shape (N, 224, 224, 3).
    """
    batch = [
        prepare_single_image(inp, target_size=target_size, for_model_input=for_model_input)
        for inp in image_inputs
    ]
    return np.vstack(batch)


# ---------------------------------------------------------------------------
# Backward Compatibility Wrappers
# ---------------------------------------------------------------------------
def preprocess_image_file(image_path, target_size=IMAGE_SIZE):
    """
    Backward-compatible helper returning normalized [-1.0, 1.0] tensor.
    """
    return prepare_single_image(image_path, target_size=target_size, for_model_input=False)


def preprocess_pil_image(pil_img, target_size=IMAGE_SIZE):
    """
    Backward-compatible helper returning normalized [-1.0, 1.0] tensor from PIL Image.
    """
    return prepare_single_image(pil_img, target_size=target_size, for_model_input=False)
