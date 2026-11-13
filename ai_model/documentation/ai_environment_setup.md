# AgriCare AI — Windows Environment Setup & Python/TensorFlow Guide

Welcome to the **AgriCare AI** Python and TensorFlow development setup guide.

This document is written especially for developers using **Windows 10 or Windows 11**. It explains each technical concept in clear, simple terms, shows you exactly what commands to run in PowerShell, and guides you on how to troubleshoot common issues.

---

## 1. System Requirements & Installed Software

* **Operating System:** Windows 10 or Windows 11 (64-bit)
* **Python Version:** Python `3.14.6` (64-bit)
* **Package Manager:** `pip` version `26.1.2`
* **Deep Learning Framework:** `tensorflow` `2.22.0-rc0`
* **Numerical Libraries:** `numpy` `2.5.3`, `pandas` `3.0.5`, `scipy` `1.18.1`
* **Computer Vision:** `pillow` `13.0.0`, `opencv-python` `5.0.0.93`, `imagehash` `4.3.2`
* **Evaluation & Notebooks:** `scikit-learn` `1.9.1`, `matplotlib` `3.11.2`, `seaborn` `0.13.2`, `ipykernel` `7.4.0`

---

## 2. Why Use a Virtual Environment (`.venv`)?

When you install Python programs on your computer, they can easily conflict with each other if different projects require different versions of a library.

A **virtual environment** is a self-contained folder that holds a private copy of Python and all required project packages.
* It keeps the AgriCare AI libraries isolated from other programs on your PC.
* It guarantees that everyone working on this project uses the exact same package versions.
* If something goes wrong, you can simply delete the `.venv` folder and recreate it without touching your computer's main Python installation.

---

## 3. PowerShell Execution Policy (Troubleshooting Activation)

On Windows, PowerShell has a security feature called the **Execution Policy**. By default, it blocks running custom PowerShell scripts (including the activation script `Activate.ps1`).

If you see an error like:
> `File ... Activate.ps1 cannot be loaded because running scripts is disabled on this system.`

### The Safe Solution (Process-Level Bypass)
Run this command inside your PowerShell window:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

### Why is this safe?
* The `-Scope Process` parameter applies this permission **only to the current terminal window**.
* As soon as you close PowerShell, the permission disappears.
* It does **not** change your computer's permanent, system-wide security settings.

---

## 4. Step-by-Step Environment Commands (Copy-Ready)

### Step 4.1: Open PowerShell and navigate to the `ai_model` directory
```powershell
cd F:\leaf_agro\ai_model
```

### Step 4.2: Create the virtual environment (if creating fresh)
```powershell
python -m venv .venv
```
*What this does:* Creates a new folder named `.venv` containing an isolated Python installation.

### Step 4.3: Set process execution policy and activate
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\.venv\Scripts\Activate.ps1
```
*What this does:* Activates your project environment. You will see `(.venv)` appear at the beginning of your command prompt.

### Step 4.4: Verify your Python and pip
```powershell
python --version
python -m pip --version
```
*Expected Output:*
* `Python 3.14.6`
* `pip 26.1.2 from F:\leaf_agro\ai_model\.venv\Lib\site-packages\pip`

### Step 4.5: Install verified dependencies
```powershell
python -m pip install -r requirements.txt
```
*What this does:* Installs the tested, mutually compatible versions of TensorFlow, NumPy, Pandas, OpenCV, Pillow, and Matplotlib.

### Step 4.6: Verify dependency consistency
```powershell
python -m pip check
```
*Expected Output:* `No broken requirements found.`

### Step 4.7: Deactivate the environment when you are done
```powershell
deactivate
```
*What this does:* Returns your terminal back to the standard system Python.

---

## 5. CPU vs. GPU on Native Windows (Important Explanation)

### Official TensorFlow Windows Policy
Starting with **TensorFlow 2.11**, the official Google TensorFlow team discontinued native Windows GPU builds. 

On native Windows (without Linux):
* TensorFlow runs in **CPU-only mode**.
* This is completely normal, stable, and officially supported.
* Modern multi-core CPUs (such as the AMD Ryzen processor on this computer) can easily execute baseline training, dataset validation, batch streaming, and TensorFlow Lite conversions.

### What if you need NVIDIA GPU acceleration in the future?
If you have an NVIDIA GPU (e.g., RTX 3060, RTX 4070) and want full GPU acceleration:
1. Do **not** install random CUDA/cuDNN `.exe` installers on Windows for modern TensorFlow.
2. Instead, Microsoft and TensorFlow officially recommend **WSL2 (Windows Subsystem for Linux)**.
3. Inside WSL2 (Ubuntu 22.04 or 24.04), installing the Linux version of TensorFlow provides full access to your NVIDIA GPU via the Windows NVIDIA Display Driver.

For this project, the native Windows CPU configuration is verified and fully functional.

---

## 6. How to Run the Environment Diagnostic Check

We have created an automated diagnostic script that tests 36 different points across your hardware, libraries, and dataset.

Run:
```powershell
python src/environment_check.py
```

### What it checks:
1. **System & Hardware:** Windows version, CPU architecture, available disk space, and physical GPU detection.
2. **Libraries:** Verifies imports and version numbers for all required packages.
3. **TensorFlow Engine:** Verifies tensor creation, basic arithmetic, and matrix multiplication.
4. **Filesystem:** Validates project roots, metadata files, and manifests.
5. **Streaming Dataset:** Loads real images from `train`, `validation`, and `test` splits, decodes them to $224 \times 224 \times 3$, checks `float32` range, and streams a mini-batch.

---

## 7. How to Run Automated Dataset Loader Tests

Run the full automated test suite (28 unit and integration tests):
```powershell
python -m unittest discover -s tests -p "test_*.py"
```

All 28 tests must pass with `OK`.

---

## 8. Common Errors & Quick Fixes

### Error 1: `AttributeError: ... has no attribute '_pandas_datetime_CAPI'`
* **Cause:** Incompatible newer version of pandas on Python 3.14.
* **Fix:** Use the pinned version `pandas==3.0.5` with `numpy==2.5.3` specified in `requirements.txt`.

### Error 2: `ModuleNotFoundError: No module named 'ai_model'`
* **Cause:** Running tests or scripts from inside a nested subdirectory rather than the project root.
* **Fix:** Run commands from the project root (`F:\leaf_agro`) or specify `python -m unittest discover -s tests -p "test_*.py"` from inside `ai_model/`.

### Error 3: Matplotlib cache warning (`MPLCONFIGDIR`)
* **Cause:** Windows temporary folder permissions for matplotlib font cache.
* **Fix:** This is a non-blocking warning. You can set `$env:MPLCONFIGDIR = "$env:TEMP\matplotlib"` in PowerShell if you wish to suppress it.

---

## 9. Registering the Environment in Jupyter Notebooks

If you work with Jupyter notebooks in VS Code or JupyterLab:
```powershell
python -m ipykernel install --user --name agricare-ai --display-name "AgriCare AI (.venv)"
```
In Jupyter or VS Code, select the kernel named **"AgriCare AI (.venv)"** to run notebooks using your isolated virtual environment.
