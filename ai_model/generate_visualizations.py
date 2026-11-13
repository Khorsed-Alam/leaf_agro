"""
AgriCare AI — Visual Validation Generator for Phase 34.
Generates:
  1. Original vs. Resized comparisons (ai_model/visualizations/original_vs_resized/)
  2. Training Augmentation Demonstrations (ai_model/visualizations/augmentation_examples/)
  3. MobileNetV2 Pixel Normalization Verification Plot (ai_model/visualizations/normalization_verification.png)
"""

import os
import sys
from pathlib import Path

# Add project root to sys.path
PROJECT_ROOT = Path(__file__).resolve().parent.parent
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))

import numpy as np
from PIL import Image
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import tensorflow as tf

from ai_model.src.config import (
    VISUALIZATIONS_DIR,
    IMAGE_SIZE,
    RANDOM_SEED,
)
from ai_model.src.preprocessing import load_image, resize_image, convert_to_rgb, prepare_single_image
from ai_model.src.augmentation import get_training_augmentation_layer
from ai_model.src.dataset import discover_approved_images

def generate_original_vs_resized():
    out_dir = VISUALIZATIONS_DIR / "original_vs_resized"
    out_dir.mkdir(parents=True, exist_ok=True)
    
    approved = discover_approved_images()
    # Pick representative samples from different classes
    sample_classes = {}
    for r in approved:
        c = r["original_class_name"]
        if c not in sample_classes:
            sample_classes[c] = r
        if len(sample_classes) >= 4:
            break

    print(f"Generating original vs. resized comparisons for {len(sample_classes)} classes...")
    for cname, record in sample_classes.items():
        img_path = record["full_file_path"]
        orig_img = load_image(img_path)
        orig_w, orig_h = orig_img.size
        
        resized_img = resize_image(convert_to_rgb(orig_img), target_size=IMAGE_SIZE)
        
        fig, axes = plt.subplots(1, 2, figsize=(8, 4))
        axes[0].imshow(orig_img)
        axes[0].set_title(f"Original: {orig_w}x{orig_h}\n{cname}", fontsize=10)
        axes[0].axis("off")
        
        axes[1].imshow(resized_img)
        axes[1].set_title(f"Resized: {IMAGE_SIZE[0]}x{IMAGE_SIZE[1]} (Bilinear)\nClass ID: {record.get('standardized_class_id', cname)}", fontsize=10)
        axes[1].axis("off")
        
        plt.tight_layout()
        save_path = out_dir / f"comparison_{cname}.png"
        plt.savefig(save_path, dpi=120)
        plt.close(fig)
        print(f"  Saved: {save_path.name}")

def generate_augmentation_examples():
    out_dir = VISUALIZATIONS_DIR / "augmentation_examples"
    out_dir.mkdir(parents=True, exist_ok=True)
    
    approved = discover_approved_images()
    if not approved:
        print("No approved images found for augmentation visualization.")
        return

    sample = approved[0]
    img_path = sample["full_file_path"]
    base_tensor = prepare_single_image(img_path, for_model_input=True) # shape (1, 224, 224, 3) in [0, 255]
    
    aug_pipeline = get_training_augmentation_layer(seed=RANDOM_SEED)

    fig, axes = plt.subplots(2, 4, figsize=(14, 7))
    axes = axes.flatten()

    # Original
    axes[0].imshow(base_tensor[0].astype(np.uint8))
    axes[0].set_title("1. Original Image (224x224)\nPixel range: [0, 255]", fontsize=9)
    axes[0].axis("off")

    # Generate 7 stochastic training augmentations
    for idx in range(1, 8):
        aug_tensor = aug_pipeline(base_tensor, training=True)
        arr = np.clip(aug_tensor[0].numpy(), 0, 255).astype(np.uint8)
        axes[idx].imshow(arr)
        axes[idx].set_title(f"Augmentation Sample {idx}\n(Flip/Rot/Zoom/Trans/Bright)", fontsize=9)
        axes[idx].axis("off")

    plt.suptitle(f"Dynamic Training-Only Augmentation Examples\nSpecimen: {sample['original_class_name']} (Class ID: {sample.get('standardized_class_id', '')})", fontsize=12, y=1.02)
    plt.tight_layout()
    save_path = out_dir / "augmentation_grid_sample.png"
    plt.savefig(save_path, dpi=120)
    plt.close(fig)
    print(f"  Saved augmentation grid: {save_path.name}")

def generate_normalization_verification():
    approved = discover_approved_images()
    if not approved:
        return
    sample = approved[0]
    img_path = sample["full_file_path"]
    
    # 1. External Input Tensor (float32, [0, 255])
    external_tensor = prepare_single_image(img_path, for_model_input=True)[0]
    
    # 2. Inside-model Rescaling layer: x / 127.5 - 1.0 -> [-1, 1]
    rescaling = tf.keras.layers.Rescaling(scale=1.0/127.5, offset=-1.0)
    normalized_tensor = rescaling(tf.convert_to_tensor(external_tensor)).numpy()

    fig, axes = plt.subplots(1, 2, figsize=(10, 4))
    
    # External Input Histogram
    axes[0].hist(external_tensor.flatten(), bins=50, color="#10B981", alpha=0.85)
    axes[0].set_title(f"External Input Contract\nRange: [{external_tensor.min():.1f}, {external_tensor.max():.1f}] (float32)", fontsize=10)
    axes[0].set_xlabel("Pixel Value (0 - 255)")
    axes[0].set_ylabel("Pixel Frequency")
    axes[0].grid(True, linestyle="--", alpha=0.4)

    # Normalized Model Graph Input Histogram
    axes[1].hist(normalized_tensor.flatten(), bins=50, color="#2563EB", alpha=0.85)
    axes[1].set_title(f"Inside-Model MobileNetV2 Input\nRange: [{normalized_tensor.min():.2f}, {normalized_tensor.max():.2f}] (float32)", fontsize=10)
    axes[1].set_xlabel("Normalized Value (-1.0 to +1.0)")
    axes[1].set_ylabel("Pixel Frequency")
    axes[1].grid(True, linestyle="--", alpha=0.4)

    plt.suptitle("MobileNetV2 Single Normalization Verification (Contract Parity)", fontsize=12, y=1.02)
    plt.tight_layout()
    save_path = VISUALIZATIONS_DIR / "normalization_verification.png"
    plt.savefig(save_path, dpi=120)
    plt.close(fig)
    print(f"  Saved normalization plot: {save_path.name}")

if __name__ == "__main__":
    generate_original_vs_resized()
    generate_augmentation_examples()
    generate_normalization_verification()
    print("All Phase 34 visual artifacts successfully generated.")
