"""
AgriCare AI — Comprehensive Environment and Infrastructure Verification Script.
Phase 36: Python Environment, TensorFlow Setup & Hardware Inspection.

Verifies:
1. Core Python runtime, pip, and required third-party libraries.
2. TensorFlow version, CPU/GPU physical device detection, tensor operations, and computation graphs.
3. Filesystem paths, directory structures, and manifest existence.
4. Dataset loading: manifest validation, image decoding, shape checks (224x224x3), and mini-batch streaming.
5. Emits structured PASS / WARNING / FAIL indicators with an accurate exit code.
"""

import sys
import os
import platform
import shutil
from pathlib import Path
from typing import Dict, List, Any, Tuple

# Exit codes
EXIT_SUCCESS = 0
EXIT_CRITICAL_FAILURE = 1


class EnvironmentAuditor:
    def __init__(self, environment_only: bool = False):
        self.environment_only = environment_only
        self.checks: List[Dict[str, Any]] = []
        self.pass_count = 0
        self.warning_count = 0
        self.fail_count = 0

    def record(self, category: str, name: str, status: str, details: str = "", metadata: Any = None):
        """Records a single check result."""
        status_clean = status.upper().strip()
        if status_clean == "PASS":
            self.pass_count += 1
        elif status_clean == "WARNING":
            self.warning_count += 1
        else:
            self.fail_count += 1

        self.checks.append({
            "category": category,
            "name": name,
            "status": status_clean,
            "details": details,
            "metadata": metadata
        })

        icon = "[PASS]" if status_clean == "PASS" else ("[WARN]" if status_clean == "WARNING" else "[FAIL]")
        print(f" {icon:<7} [{category}] {name}: {details}")

    def check_system_and_hardware(self):
        """Checks OS, CPU, RAM, Disk, and physical GPU availability."""
        print("\n--- 1. System Runtime & Hardware Inspection ---")

        # OS Details
        os_info = f"{platform.system()} {platform.release()} (Version: {platform.version()})"
        self.record("SYSTEM", "Operating System", "PASS", os_info)

        # CPU Architecture
        cpu_arch = f"{platform.machine()} / {platform.processor()}"
        self.record("SYSTEM", "CPU Architecture", "PASS", cpu_arch)

        # Disk Space
        try:
            cwd_drive = Path.cwd().anchor or "C:"
            usage = shutil.disk_usage(cwd_drive)
            free_gb = usage.free / (1024 ** 3)
            total_gb = usage.total / (1024 ** 3)
            disk_str = f"{cwd_drive} Free: {free_gb:.1f} GB / Total: {total_gb:.1f} GB"
            if free_gb > 5.0:
                self.record("SYSTEM", "Available Disk Space", "PASS", disk_str)
            else:
                self.record("SYSTEM", "Available Disk Space", "WARNING", f"Low disk space: {disk_str}")
        except Exception as e:
            self.record("SYSTEM", "Available Disk Space", "WARNING", f"Could not determine disk usage: {e}")

        # GPU Physical Hardware (nvidia-smi check)
        nvidia_smi = shutil.which("nvidia-smi")
        if nvidia_smi:
            self.record("GPU", "NVIDIA Driver CLI (nvidia-smi)", "PASS", f"Found at {nvidia_smi}")
        else:
            self.record(
                "GPU",
                "NVIDIA Physical GPU Detection",
                "WARNING",
                "nvidia-smi not detected in PATH. Defaulting to verified native Windows CPU pipeline."
            )

    def check_python_and_libraries(self):
        """Verifies Python version, pip, and required candidate libraries."""
        print("\n--- 2. Python Runtime & Library Verification ---")

        # Python Version
        py_ver = sys.version.split()[0]
        py_status = "PASS" if sys.version_info >= (3, 10) else "FAIL"
        self.record("PYTHON", "Python Version", py_status, f"{py_ver} ({sys.executable})")

        # pip check
        try:
            import pip
            self.record("PYTHON", "pip Package Manager", "PASS", f"pip version {pip.__version__}")
        except ImportError:
            self.record("PYTHON", "pip Package Manager", "FAIL", "pip is not installed or importable")

        # Required packages inspection
        required_packages = [
            ("tensorflow", "TensorFlow Deep Learning Framework"),
            ("numpy", "NumPy Numerical Operations"),
            ("pandas", "Pandas Data Analysis & Manifests"),
            ("PIL", "Pillow Image Decoding"),
            ("cv2", "OpenCV Computer Vision Utilities"),
            ("matplotlib", "Matplotlib Plotting Library"),
            ("seaborn", "Seaborn Statistical Visualizations"),
            ("sklearn", "scikit-learn Machine Learning Utilities"),
            ("tqdm", "tqdm Progress Meter"),
            ("yaml", "PyYAML Configuration Parser"),
            ("ipykernel", "IPython Kernel for Jupyter"),
        ]

        for module_name, desc in required_packages:
            try:
                mod = __import__(module_name)
                ver = getattr(mod, "__version__", "installed")
                self.record("LIBRARIES", desc, "PASS", f"Version {ver}")
            except ImportError as e:
                self.record("LIBRARIES", desc, "FAIL", f"Module '{module_name}' could not be imported: {e}")

    def check_tensorflow_runtime(self):
        """Verifies TensorFlow device enumeration, tensor creation, and basic math ops."""
        print("\n--- 3. TensorFlow Runtime & Computation Verification ---")

        try:
            import tensorflow as tf
            tf_ver = tf.__version__
            self.record("TENSORFLOW", "TensorFlow Version", "PASS", tf_ver)

            # CPU Device Detection
            cpus = tf.config.list_physical_devices("CPU")
            if cpus:
                self.record("TENSORFLOW", "CPU Physical Device", "PASS", f"Detected: {len(cpus)} CPU device(s)")
            else:
                self.record("TENSORFLOW", "CPU Physical Device", "FAIL", "No CPU physical device enumerated by TensorFlow")

            # GPU Device Detection
            gpus = tf.config.list_physical_devices("GPU")
            if gpus:
                self.record("TENSORFLOW", "GPU Physical Device", "PASS", f"Detected: {len(gpus)} GPU device(s): {gpus}")
            else:
                self.record(
                    "TENSORFLOW",
                    "GPU Physical Device",
                    "WARNING",
                    "No GPU detected by TensorFlow. Running in native Windows CPU-only mode (Standard for TF 2.11+ on Windows)."
                )

            # Tensor Creation
            a = tf.constant([[1.0, 2.0], [3.0, 4.0]], dtype=tf.float32)
            b = tf.constant([[5.0, 6.0], [7.0, 8.0]], dtype=tf.float32)
            self.record("TENSORFLOW", "Tensor Constant Creation", "PASS", f"Shape: {a.shape}, Dtype: {a.dtype}")

            # Basic Math Operation
            c = tf.add(a, b)
            expected_c = [[6.0, 8.0], [10.0, 12.0]]
            if (c.numpy() == expected_c).all():
                self.record("TENSORFLOW", "Tensor Addition (a + b)", "PASS", "Execution returned verified values")
            else:
                self.record("TENSORFLOW", "Tensor Addition", "FAIL", f"Unexpected result: {c.numpy()}")

            # Matrix Multiplication (Small Computation Graph)
            d = tf.matmul(a, b)
            expected_d = [[19.0, 22.0], [43.0, 50.0]]
            if (d.numpy() == expected_d).all():
                self.record("TENSORFLOW", "Matrix Multiplication (matmul)", "PASS", "Computation graph executed correctly")
            else:
                self.record("TENSORFLOW", "Matrix Multiplication", "FAIL", f"Unexpected result: {d.numpy()}")

        except Exception as e:
            self.record("TENSORFLOW", "TensorFlow Execution Engine", "FAIL", f"Runtime exception during test: {e}")

    def check_filesystem_and_paths(self):
        """Verifies repository paths, metadata files, and manifests."""
        print("\n--- 4. Filesystem & Manifest Verification ---")

        try:
            from ai_model.src.config import (
                PROJECT_ROOT,
                BASE_DIR,
                DATASET_DIR,
                METADATA_DIR,
                PROCESSED_METADATA_DIR,
                SPLIT_MANIFEST_PATH,
                SPLIT_SUMMARY_PATH,
                CLASS_MAPPING_PATH,
                MODELS_DIR,
                REPORTS_DIR,
            )
        except ImportError:
            from config import (
                PROJECT_ROOT,
                BASE_DIR,
                DATASET_DIR,
                METADATA_DIR,
                PROCESSED_METADATA_DIR,
                SPLIT_MANIFEST_PATH,
                SPLIT_SUMMARY_PATH,
                CLASS_MAPPING_PATH,
                MODELS_DIR,
                REPORTS_DIR,
            )

        paths_to_verify = [
            ("Project Root Directory", PROJECT_ROOT, True),
            ("AI Model Base Directory", BASE_DIR, True),
            ("Dataset Root Directory", DATASET_DIR, True),
            ("Metadata Directory", METADATA_DIR, True),
            ("Processed Metadata Directory", PROCESSED_METADATA_DIR, True),
            ("Verified Class Mapping (Phase 32)", CLASS_MAPPING_PATH, True),
            ("Split Manifest (Phase 35)", SPLIT_MANIFEST_PATH, True),
            ("Split Summary (Phase 35)", SPLIT_SUMMARY_PATH, True),
            ("Models Output Directory", MODELS_DIR, True),
            ("Reports Output Directory", REPORTS_DIR, True),
        ]

        for name, path_obj, is_critical in paths_to_verify:
            if path_obj.exists():
                self.record("FILESYSTEM", name, "PASS", f"Found at {path_obj}")
            else:
                stat = "FAIL" if is_critical else "WARNING"
                self.record("FILESYSTEM", name, stat, f"Missing target at {path_obj}")

    def check_dataset_and_batch_streaming(self):
        """Verifies dataset manifest records, image decoding, and streaming mini-batches."""
        print("\n--- 5. Dataset Loader & tf.data Streaming Verification ---")

        if self.environment_only:
            self.record("DATASET", "Dataset Verification", "WARNING", "Skipped due to --environment-only flag")
            return

        import tensorflow as tf

        try:
            from ai_model.src.dataset_loader import (
                load_manifest_records,
                get_verified_class_index_map,
                resolve_image_path,
                create_split_dataset,
                audit_manifest_integrity
            )
        except ImportError:
            from dataset_loader import (
                load_manifest_records,
                get_verified_class_index_map,
                resolve_image_path,
                create_split_dataset,
                audit_manifest_integrity
            )

        # 1. Audit split manifest integrity
        try:
            audit = audit_manifest_integrity()
            if audit["status"] == "PASS":
                self.record(
                    "DATASET",
                    "Manifest Record & Path Integrity",
                    "PASS",
                    f"{audit['total_records']} records verified with 0 missing files and 0 invalid labels"
                )
            else:
                self.record(
                    "DATASET",
                    "Manifest Record & Path Integrity",
                    "FAIL",
                    f"Missing: {audit['missing_files_count']}, Invalid: {audit['invalid_labels_count']}"
                )
        except Exception as e:
            self.record("DATASET", "Manifest Integrity Audit", "FAIL", str(e))

        # 2. Verify class mapping consistency
        try:
            c2i, i2c = get_verified_class_index_map()
            self.record("DATASET", "Verified Class Mapping Map", "PASS", f"Loaded {len(i2c)} unique class indices")
        except Exception as e:
            self.record("DATASET", "Verified Class Mapping Map", "FAIL", str(e))

        # 3. Stream a real mini-batch from each split
        for split_name in ["train", "validation", "test"]:
            try:
                ds = create_split_dataset(split=split_name, batch_size=4)
                # Take 1 batch
                for img_batch, label_batch in ds.take(1):
                    shape_match = (img_batch.shape[1:] == (224, 224, 3))
                    dtype_match = (img_batch.dtype == tf.float32)
                    labels_valid = (len(label_batch) > 0)

                    if shape_match and dtype_match and labels_valid:
                        self.record(
                            "DATASET",
                            f"Split Stream ({split_name})",
                            "PASS",
                            f"Batch shape: {img_batch.shape}, Dtype: {img_batch.dtype}, Labels: {label_batch.numpy().tolist()}"
                        )
                    else:
                        self.record(
                            "DATASET",
                            f"Split Stream ({split_name})",
                            "FAIL",
                            f"Invalid batch properties: shape={img_batch.shape}, dtype={img_batch.dtype}"
                        )
            except Exception as e:
                self.record("DATASET", f"Split Stream ({split_name})", "FAIL", f"Failed streaming batch: {e}")

    def run_full_audit(self) -> int:
        """Executes full diagnostic suite and returns process exit code."""
        print("=" * 70)
        print("  AgriCare AI — Phase 36 Environment & Infrastructure Audit")
        print("=" * 70)

        self.check_system_and_hardware()
        self.check_python_and_libraries()
        self.check_tensorflow_runtime()
        self.check_filesystem_and_paths()
        self.check_dataset_and_batch_streaming()

        print("\n" + "=" * 70)
        print("  Audit Summary")
        print("=" * 70)
        print(f" PASS:     {self.pass_count}")
        print(f" WARNINGS: {self.warning_count}")
        print(f" FAILURES: {self.fail_count}")

        if self.fail_count > 0:
            print("\n Result: FAILED — Critical environment or dataset issues detected.")
            return EXIT_CRITICAL_FAILURE
        elif self.warning_count > 0:
            print("\n Result: PASSED WITH WARNINGS — Environment is operational (non-blocking notices recorded).")
            return EXIT_SUCCESS
        else:
            print("\n Result: PASSED — All environment and dataset criteria satisfied.")
            return EXIT_SUCCESS


if __name__ == "__main__":
    env_only = "--environment-only" in sys.argv
    auditor = EnvironmentAuditor(environment_only=env_only)
    code = auditor.run_full_audit()
    sys.exit(code)

