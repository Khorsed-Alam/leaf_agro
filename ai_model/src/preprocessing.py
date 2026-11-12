import numpy as np
from PIL import Image
try:
    from .config import IMG_HEIGHT, IMG_WIDTH
except ImportError:
    from config import IMG_HEIGHT, IMG_WIDTH


def preprocess_image_file(image_path, target_size=(IMG_HEIGHT, IMG_WIDTH)):
    """
    Reads an image from disk, converts to RGB, resizes to target_size,
    and returns a normalized numpy array ready for inference or model consumption.
    Matches MobileNetV2 input normalization [-1.0, 1.0].
    """
    img = Image.open(image_path).convert("RGB")
    img = img.resize(target_size, Image.Resampling.BILINEAR)
    img_array = np.array(img, dtype=np.float32)

    # Scale to [-1, 1]
    normalized_array = (img_array / 127.5) - 1.0
    return np.expand_dims(normalized_array, axis=0)


def preprocess_pil_image(pil_img, target_size=(IMG_HEIGHT, IMG_WIDTH)):
    """
    Preprocesses in-memory PIL image.
    """
    img = pil_img.convert("RGB")
    img = img.resize(target_size, Image.Resampling.BILINEAR)
    img_array = np.array(img, dtype=np.float32)
    normalized_array = (img_array / 127.5) - 1.0
    return np.expand_dims(normalized_array, axis=0)

