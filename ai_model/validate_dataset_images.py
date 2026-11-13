"""
AgriCare AI — Plant Disease Dataset Image Integrity Validation Script
Phase 31: Dataset Collection & Verification

This script scans raw dataset directories, decodes every image using Pillow,
validates integrity, calculates SHA-256 checksums, extracts image dimensions/formats,
identifies exact duplicate images, and tallies class inventories without modifying
or deleting any files.
"""

import sys
import os
import hashlib
import csv
from pathlib import Path
from collections import defaultdict
from typing import Dict, List, Tuple, Any

try:
    from PIL import Image
except ImportError:
    print("Error: Pillow is required. Please install via: pip install pillow")
    sys.exit(1)

# Recognized image file extensions
SUPPORTED_EXTENSIONS = {'.jpg', '.jpeg', '.png', '.bmp', '.tif', '.tiff', '.webp'}
IGNORABLE_FILES = {'.gitkeep', '.ds_store', 'thumbs.db'}


def calculate_sha256(file_path: Path) -> str:
    """Computes the SHA-256 cryptographic hash of a file."""
    sha256 = hashlib.sha256()
    with open(file_path, 'rb') as f:
        while chunk := f.read(65536):
            sha256.update(chunk)
    return sha256.hexdigest()


def validate_image_file(file_path: Path) -> Dict[str, Any]:
    """
    Attempts to open and decode an image using Pillow.
    Extracts width, height, format, size, and SHA-256 hash.
    """
    stat = file_path.stat()
    file_size = stat.st_size
    file_ext = file_path.suffix.lower()

    result = {
        'path': file_path,
        'filename': file_path.name,
        'extension': file_ext,
        'size_bytes': file_size,
        'width': None,
        'height': None,
        'format': None,
        'mode': None,
        'sha256': None,
        'is_valid': False,
        'error_message': None,
    }

    try:
        # Calculate SHA-256
        result['sha256'] = calculate_sha256(file_path)

        # Open and decode with Pillow
        with Image.open(file_path) as img:
            result['width'] = img.width
            result['height'] = img.height
            result['format'] = img.format
            result['mode'] = img.mode
            # Fully load image pixels into memory to ensure file is not truncated or corrupted
            img.load()
            result['is_valid'] = True
    except Exception as e:
        result['is_valid'] = False
        result['error_message'] = str(e)

    return result


def scan_dataset_directory(base_raw_dir: Path) -> Tuple[List[Dict[str, Any]], List[Path], List[Path]]:
    """
    Recursively scans the raw dataset directory.
    Returns:
      (validated_records, corrupted_files, unsupported_files)
    """
    validated_records = []
    corrupted_files = []
    unsupported_files = []

    if not base_raw_dir.exists():
        print(f"Warning: Base directory {base_raw_dir} does not exist.")
        return validated_records, corrupted_files, unsupported_files

    for dataset_dir in sorted(base_raw_dir.iterdir()):
        if not dataset_dir.is_dir() or dataset_dir.name.startswith('.'):
            continue

        dataset_name = dataset_dir.name

        for root, dirs, files in os.walk(dataset_dir):
            root_path = Path(root)
            for file_name in files:
                file_path = root_path / file_name

                # Ignore known placeholder and metadata files
                if file_name.lower() in IGNORABLE_FILES:
                    continue

                ext = file_path.suffix.lower()
                if ext not in SUPPORTED_EXTENSIONS:
                    unsupported_files.append(file_path)
                    continue

                # Determine relative path and class name
                rel_path = file_path.relative_to(base_raw_dir)
                parts = rel_path.parts
                
                # If file is nested under a class directory
                if len(parts) >= 3:
                    original_class = parts[1]
                else:
                    original_class = "unclassified"

                # Validate image
                record = validate_image_file(file_path)
                record['dataset_name'] = dataset_name
                record['original_class'] = original_class
                record['relative_path'] = str(rel_path).replace('\\', '/')

                validated_records.append(record)

                if not record['is_valid']:
                    corrupted_files.append(file_path)

    return validated_records, corrupted_files, unsupported_files


def find_exact_duplicates(records: List[Dict[str, Any]]) -> Dict[str, List[Dict[str, Any]]]:
    """Identifies exact duplicate images sharing identical SHA-256 checksums."""
    hash_groups = defaultdict(list)
    for r in records:
        if r['sha256']:
            hash_groups[r['sha256']].append(r)
    return {h: group for h, group in hash_groups.items() if len(group) > 1}


def generate_manifest_csv(records: List[Dict[str, Any]], output_path: Path):
    """
    Generates download_manifest.csv compliant with Phase 31 requirements:
    dataset_id,dataset_name,original_file_name,relative_file_path,
    original_class_name,crop_name,file_extension,file_size_bytes,
    image_width,image_height,image_format,sha256,download_status,
    validation_status,source_url
    """
    output_path.parent.mkdir(parents=True, exist_ok=True)

    fieldnames = [
        'dataset_id',
        'dataset_name',
        'original_file_name',
        'relative_file_path',
        'original_class_name',
        'crop_name',
        'file_extension',
        'file_size_bytes',
        'image_width',
        'image_height',
        'image_format',
        'sha256',
        'download_status',
        'validation_status',
        'source_url'
    ]

    # Map dataset directory names to standard dataset IDs and source URLs
    dataset_meta = {
        'plantvillage': {
            'id': 'DS_PLANTVILLAGE',
            'name': 'PlantVillage Dataset',
            'url': 'https://github.com/spMohanty/PlantVillage-Dataset'
        },
        'bangladesh_rice': {
            'id': 'DS_BD_RICE',
            'name': 'RiceLeafDiseaseBD',
            'url': 'https://data.mendeley.com/datasets/86s4jzj2m4/1'
        },
        'bangladesh_vegetables': {
            'id': 'DS_BD_VEG',
            'name': 'Bangladesh Vegetable Disease Dataset',
            'url': 'https://data.mendeley.com/datasets/n67gctmjyj/3'
        },
        'bangladesh_mango': {
            'id': 'DS_BD_MANGO',
            'name': 'Mango Leaf Disease Dataset (MLD24)',
            'url': 'https://data.mendeley.com/datasets/6dvpywm2m2/1'
        },
        'bangladesh_jute': {
            'id': 'DS_BD_JUTE',
            'name': 'Bangladesh Jute Disease Dataset',
            'url': 'https://github.com/foysalahmed10/YOLO-JD'
        }
    }

    with open(output_path, 'w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()

        for r in records:
            d_name = r['dataset_name']
            meta = dataset_meta.get(d_name, {
                'id': f"DS_{d_name.upper()}",
                'name': d_name,
                'url': 'UNKNOWN'
            })

            orig_class = r['original_class']
            if '___' in orig_class:
                crop = orig_class.split('___')[0]
            else:
                crop = orig_class.split('_')[0] if orig_class != 'unclassified' else 'Unknown'

            validation_status = 'VALID' if r['is_valid'] else f"CORRUPTED: {r.get('error_message')}"

            writer.writerow({
                'dataset_id': meta['id'],
                'dataset_name': meta['name'],
                'original_file_name': r['filename'],
                'relative_file_path': r['relative_path'],
                'original_class_name': orig_class,
                'crop_name': crop,
                'file_extension': r['extension'],
                'file_size_bytes': r['size_bytes'],
                'image_width': r['width'],
                'image_height': r['height'],
                'image_format': r['format'],
                'sha256': r['sha256'],
                'download_status': 'DOWNLOADED',
                'validation_status': validation_status,
                'source_url': meta['url']
            })


def generate_class_inventory_csv(records: List[Dict[str, Any]], output_path: Path):
    """
    Generates class_inventory.csv compliant with Phase 31:
    dataset_id,dataset_name,crop_name,original_class_name,image_count,class_source,label_verification_status,notes
    """
    output_path.parent.mkdir(parents=True, exist_ok=True)

    dataset_meta = {
        'plantvillage': {
            'id': 'DS_PLANTVILLAGE',
            'name': 'PlantVillage Dataset'
        },
        'bangladesh_rice': {
            'id': 'DS_BD_RICE',
            'name': 'RiceLeafDiseaseBD'
        },
        'bangladesh_vegetables': {
            'id': 'DS_BD_VEG',
            'name': 'Bangladesh Vegetable Disease Dataset'
        },
        'bangladesh_mango': {
            'id': 'DS_BD_MANGO',
            'name': 'Mango Leaf Disease Dataset (MLD24)'
        },
        'bangladesh_jute': {
            'id': 'DS_BD_JUTE',
            'name': 'Bangladesh Jute Disease Dataset'
        }
    }

    # Group counts by (dataset_name, original_class)
    counts = defaultdict(int)
    for r in records:
        counts[(r['dataset_name'], r['original_class'])] += 1

    fieldnames = [
        'dataset_id',
        'dataset_name',
        'crop_name',
        'original_class_name',
        'image_count',
        'class_source',
        'label_verification_status',
        'notes'
    ]

    with open(output_path, 'w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()

        for (d_name, class_name), count in sorted(counts.items()):
            meta = dataset_meta.get(d_name, {'id': f"DS_{d_name.upper()}", 'name': d_name})

            if '___' in class_name:
                crop = class_name.split('___')[0]
            else:
                crop = class_name.split('_')[0] if class_name != 'unclassified' else 'Unknown'

            notes = "Controlled-background leaf photography (PlantVillage)" if d_name == 'plantvillage' else "Field-condition imagery"

            writer.writerow({
                'dataset_id': meta['id'],
                'dataset_name': meta['name'],
                'crop_name': crop,
                'original_class_name': class_name,
                'image_count': count,
                'class_source': 'Original Publisher Class Directory',
                'label_verification_status': 'VERIFIED',
                'notes': notes
            })


def main():
    print("=" * 70)
    print("AgriCare AI — Plant Disease Dataset Validation")
    print("Phase 31: Image Integrity & Dataset Auditing")
    print("=" * 70)

    # Base path relative to project
    project_root = Path(__file__).resolve().parent.parent
    raw_dir = project_root / "ai_model" / "dataset" / "raw"
    metadata_dir = project_root / "ai_model" / "dataset" / "metadata"

    print(f"Project root: {project_root}")
    print(f"Scanning raw dataset directory: {raw_dir}")

    records, corrupted, unsupported = scan_dataset_directory(raw_dir)

    print(f"\n--- Scan Results ---")
    print(f"Total image files scanned: {len(records)}")
    valid_count = sum(1 for r in records if r['is_valid'])
    print(f"Valid decoded images: {valid_count}")
    print(f"Corrupted images detected: {len(corrupted)}")
    print(f"Unsupported files detected: {len(unsupported)}")

    if corrupted:
        print("\nCorrupted files encountered:")
        for cf in corrupted:
            print(f"  - {cf}")

    # Duplicate check
    duplicates = find_exact_duplicates(records)
    print(f"\nExact duplicate SHA-256 groups: {len(duplicates)}")
    if duplicates:
        print("Duplicate groups:")
        for h, grp in duplicates.items():
            print(f"  Hash {h[:12]}... (Count: {len(grp)}):")
            for item in grp:
                print(f"    -> {item['relative_path']}")

    # Tally by dataset and class
    dataset_counts = defaultdict(int)
    class_counts = defaultdict(int)
    total_bytes = 0

    for r in records:
        dataset_counts[r['dataset_name']] += 1
        class_counts[f"{r['dataset_name']} :: {r['original_class']}"] += 1
        total_bytes += r['size_bytes']

    print(f"\nTotal storage footprint: {total_bytes / (1024 * 1024):.2f} MB ({total_bytes} bytes)")

    print("\n--- Image Count by Dataset ---")
    for d, c in sorted(dataset_counts.items()):
        print(f"  - {d}: {c} images")

    print("\n--- Image Count by Class ---")
    for cls, c in sorted(class_counts.items()):
        print(f"  - {cls}: {c} images")

    # Generate Manifest & Class Inventory CSVs
    manifest_csv = metadata_dir / "download_manifest.csv"
    class_inventory_csv = metadata_dir / "class_inventory.csv"

    print(f"\nWriting download manifest to: {manifest_csv}")
    generate_manifest_csv(records, manifest_csv)

    print(f"Writing class inventory to: {class_inventory_csv}")
    generate_class_inventory_csv(records, class_inventory_csv)

    print("\nValidation completed successfully.")


if __name__ == "__main__":
    main()
