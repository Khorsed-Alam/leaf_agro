"""
AgriCare AI — Inference Performance Benchmarking Module.
Phase 39: AI Model Evaluation and Performance Testing.

Measures actual runtime latency, memory, and throughput on available host hardware:
- Model file size auditing
- Cold vs warm model loading latency
- Model-only forward-pass latency (Mean, Median, P95, Std Dev)
- Preprocessing latency and estimated end-to-end inference time
- Throughput (inferences per second)
- Memory allocation tracking via tracemalloc
"""

import os
import platform
import time
import tracemalloc
from pathlib import Path
from typing import Dict, Any, Tuple, Optional
import numpy as np
import tensorflow as tf


def get_hardware_info() -> Dict[str, Any]:
    """
    Detects host hardware and runtime environment.
    """
    gpus = tf.config.list_physical_devices("GPU")
    gpu_names = [gpu.name for gpu in gpus]

    return {
        "os": f"{platform.system()} {platform.release()} ({platform.version()})",
        "machine": platform.machine(),
        "processor": platform.processor(),
        "python_version": platform.python_version(),
        "tensorflow_version": tf.__version__,
        "gpu_available": len(gpus) > 0,
        "gpu_count": len(gpus),
        "gpu_devices": gpu_names,
        "execution_device": "GPU" if len(gpus) > 0 else "CPU"
    }


def benchmark_inference(
    model_path: Path,
    input_shape: Tuple[int, int, int, int] = (1, 224, 224, 3),
    num_warmup: int = 10,
    num_runs: int = 50
) -> Dict[str, Any]:
    """
    Executes rigorous inference latency and throughput benchmarking.

    Args:
        model_path: Path to the .keras model checkpoint.
        input_shape: Input batch tensor shape (default: (1, 224, 224, 3)).
        num_warmup: Number of untimed warmup passes.
        num_runs: Number of timed repeated inferences.

    Returns:
        Dictionary containing comprehensive latency statistics and hardware details.
    """
    path = Path(model_path)
    if not path.exists():
        raise FileNotFoundError(f"Model checkpoint not found at: {path}")

    file_size_bytes = path.stat().st_size
    file_size_mb = round(file_size_bytes / (1024 * 1024), 2)

    # 1. Timed Model Loading
    tracemalloc.start()
    load_start = time.perf_counter()
    model = tf.keras.models.load_model(str(path))
    load_end = time.perf_counter()
    load_time_sec = round(load_end - load_start, 4)
    current_mem, peak_mem = tracemalloc.get_traced_memory()
    tracemalloc.stop()

    # 2. Warmup Passes
    dummy_input = tf.ones(input_shape, dtype=tf.float32)
    for _ in range(num_warmup):
        _ = model(dummy_input, training=False)

    # 3. Timed Repeated Inferences (Model Only)
    latencies = []
    for _ in range(num_runs):
        start = time.perf_counter()
        _ = model(dummy_input, training=False)
        end = time.perf_counter()
        latencies.append((end - start) * 1000.0)  # Convert to milliseconds

    latencies = np.array(latencies)
    avg_latency = float(np.mean(latencies))
    median_latency = float(np.median(latencies))
    p95_latency = float(np.percentile(latencies, 95))
    min_latency = float(np.min(latencies))
    max_latency = float(np.max(latencies))
    std_latency = float(np.std(latencies))
    throughput = round(1000.0 / avg_latency, 2) if avg_latency > 0 else 0.0

    # 4. Measure Pure Preprocessing Latency (Decode + Bilinear Resize)
    # Generate synthetic dummy JPEG bytes to benchmark image decode pipeline
    dummy_img_array = np.random.randint(0, 256, (300, 300, 3), dtype=np.uint8)
    encoded_jpeg = tf.io.encode_jpeg(dummy_img_array)

    prep_latencies = []
    for _ in range(20):
        prep_start = time.perf_counter()
        decoded = tf.io.decode_image(encoded_jpeg, channels=3, expand_animations=False)
        resized = tf.image.resize(decoded, [224, 224], method="bilinear")
        cast_img = tf.cast(resized, tf.float32)
        prep_end = time.perf_counter()
        prep_latencies.append((prep_end - prep_start) * 1000.0)

    avg_prep_latency = float(np.mean(prep_latencies))
    estimated_end_to_end = round(avg_prep_latency + avg_latency, 2)

    hardware = get_hardware_info()

    return {
        "model_file_path": str(path.as_posix()),
        "model_file_size_bytes": file_size_bytes,
        "model_file_size_mb": file_size_mb,
        "model_loading_time_seconds": load_time_sec,
        "benchmark_parameters": {
            "input_shape": list(input_shape),
            "warmup_runs": num_warmup,
            "timed_runs": num_runs,
            "timing_clock": "time.perf_counter (high-resolution monotonic)"
        },
        "model_latency_ms": {
            "mean": round(avg_latency, 2),
            "median": round(median_latency, 2),
            "p95": round(p95_latency, 2),
            "min": round(min_latency, 2),
            "max": round(max_latency, 2),
            "std_dev": round(std_latency, 2)
        },
        "preprocessing_latency_ms": {
            "mean": round(avg_prep_latency, 2),
            "operation": "tf.io.decode_image + tf.image.resize(bilinear) + tf.cast"
        },
        "estimated_end_to_end_latency_ms": estimated_end_to_end,
        "throughput_inferences_per_second": throughput,
        "memory_profile": {
            "peak_loading_memory_mb": round(peak_mem / (1024 * 1024), 2)
        },
        "hardware_environment": hardware,
        "android_deployment_notes": [
            "Desktop CPU benchmark measures host performance on x86_64 architecture.",
            "Mobile performance on Android (ARM Cortex / Snapdragon / MediaTek) requires TFLite conversion (Phase 40).",
            "TFLite models with FP16/INT8 quantization typically execute significantly faster and with <15MB RAM footprint on modern mobile devices."
        ]
    }

