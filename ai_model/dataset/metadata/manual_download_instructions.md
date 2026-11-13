# AgriCare AI — Manual Dataset Download & Ingestion Instructions
## Phase 31: Plant Disease Dataset Collection & Verification

This guide provides official, step-by-step instructions for downloading and verifying datasets that cannot be retrieved via automated CLI scripts due to platform bot mitigation, Cloudflare challenges, or interactive portal session requirements (such as Mendeley Data and institutional research portals).

---

## 1. Candidate B: Bangladesh Rice Leaf Disease Dataset (RiceLeafDiseaseBD)

### Official Dataset Metadata
- **Dataset Name:** RiceLeafDiseaseBD: A Field-Based Annotated Smartphone Image Dataset of Healthy and Diseased Rice Leaves from Bangladesh
- **Official Dataset Page:** [https://data.mendeley.com/datasets/86s4jzj2m4/1](https://data.mendeley.com/datasets/86s4jzj2m4/1)
- **Persistent DOI:** `10.17632/86s4jzj2m4.1`
- **Published License:** Creative Commons Attribution 4.0 International (CC BY 4.0)
- **Target Folder:** `ai_model/dataset/raw/bangladesh_rice/`

### Step-by-Step Download & Extraction Procedure
1. **Navigate to the Official Page**: Open [https://data.mendeley.com/datasets/86s4jzj2m4/1](https://data.mendeley.com/datasets/86s4jzj2m4/1) in your web browser.
2. **Verify License**: Confirm the license section displays **CC BY 4.0**.
3. **Locate Download Button**:
   - In the top-right header section of the Mendeley Data page, click the blue **"Download All"** or **"Download"** button.
   - Alternatively, expand the **Files** section and download the zip archive (e.g., `RiceLeafDiseaseBD.zip`).
4. **Save the Archive**:
   - Save the downloaded archive into:
     ```text
     ai_model/dataset/raw/bangladesh_rice/
     ```
   - Keep the original `.zip` or `.tar` archive file preserved.
5. **Extract the Contents Safely**:
   - Extract the contents directly inside `ai_model/dataset/raw/bangladesh_rice/` preserving the publisher's internal class folders:
     - `Healthy/`
     - `Blast/`
     - `Brown Spot/`
     - `Leaf Smut/`
     - `Rice Tungro/`
     - `Sheath Blight/`
   - *PowerShell Extraction Command*:
     ```powershell
     Expand-Archive -Path "ai_model\dataset\raw\bangladesh_rice\RiceLeafDiseaseBD.zip" -DestinationPath "ai_model\dataset\raw\bangladesh_rice" -Force
     ```
6. **Preserve Original Folders**: Do not rename folders, flatten paths, or delete duplicate files.
7. **Run Post-Download Image Validation**:
   ```bash
   python ai_model/validate_dataset_images.py
   ```
   The script will verify image decodability with Pillow, compute SHA-256 hashes, detect any corrupted files, and update `download_manifest.csv` and `class_inventory.csv`.

---

## 2. Candidate C: Bangladesh Vegetable Disease Dataset

### Official Dataset Metadata
- **Dataset Name:** Plant Leaf Freshness and Disease Detection Dataset From Bangladesh
- **Official Dataset Page:** [https://data.mendeley.com/datasets/n67gctmjyj/3](https://data.mendeley.com/datasets/n67gctmjyj/3)
- **Persistent DOI:** `10.17632/n67gctmjyj.3`
- **Published License:** Creative Commons Attribution 4.0 International (CC BY 4.0)
- **Target Folder:** `ai_model/dataset/raw/bangladesh_vegetables/`

### Step-by-Step Download & Extraction Procedure
1. **Navigate to the Official Page**: Open [https://data.mendeley.com/datasets/n67gctmjyj/3](https://data.mendeley.com/datasets/n67gctmjyj/3) in your web browser.
2. **Verify License**: Confirm that **CC BY 4.0** is specified under licensing.
3. **Download the Dataset**:
   - Click **"Download All"** in the top action banner.
   - Save the archive (`Plant_Leaf_Freshness_and_Disease_Detection_Dataset_From_Bangladesh.zip`) to:
     ```text
     ai_model/dataset/raw/bangladesh_vegetables/
     ```
4. **Extract Preserving Structure**:
   - Extract into `ai_model/dataset/raw/bangladesh_vegetables/`.
   - Preserve original crop and condition subfolders (Tomato, Eggplant, Cucumber, etc.).
   - *PowerShell Extraction Command*:
     ```powershell
     Expand-Archive -Path "ai_model\dataset\raw\bangladesh_vegetables\Plant_Leaf_Freshness.zip" -DestinationPath "ai_model\dataset\raw\bangladesh_vegetables" -Force
     ```
5. **Run Validation Script**:
   ```bash
   python ai_model/validate_dataset_images.py
   ```

---

## 3. Candidate D: Mango Leaf Disease Dataset (MLD24)

### Official Dataset Metadata
- **Dataset Name:** MLD24: An image dataset for mango leaf disease detection
- **Official Dataset Page:** [https://data.mendeley.com/datasets/6dvpywm2m2/1](https://data.mendeley.com/datasets/6dvpywm2m2/1)
- **Persistent DOI:** `10.17632/6dvpywm2m2.1`
- **Published License:** Creative Commons Attribution 4.0 International (CC BY 4.0)
- **Target Folder:** `ai_model/dataset/raw/bangladesh_mango/`

### Step-by-Step Download & Extraction Procedure
1. **Navigate to the Official Page**: Open [https://data.mendeley.com/datasets/6dvpywm2m2/1](https://data.mendeley.com/datasets/6dvpywm2m2/1) in your web browser.
2. **Verify License**: Confirm **CC BY 4.0** license.
3. **Download**: Click **"Download All"** and place the archive in `ai_model/dataset/raw/bangladesh_mango/`.
4. **Extract**:
   - Extract preserving all 8 original class directories:
     - `Healthy/`
     - `Anthracnose/`
     - `Bacterial Canker/`
     - `Cutting Weevil/` (Note: Pest damage)
     - `Die Back/`
     - `Gall Midge/` (Note: Pest damage)
     - `Powdery Mildew/`
     - `Sooty Mould/`
5. **Execute Validation**:
   ```bash
   python ai_model/validate_dataset_images.py
   ```

---

## 4. Candidate E: Bangladesh Jute Disease Dataset (YOLO-JD)

### Official Dataset Metadata
- **Dataset Name:** YOLO-JD: Jute Disease and Pest Dataset in Bangladesh
- **Official Source Page:** [https://github.com/foysalahmed10/YOLO-JD](https://github.com/foysalahmed10/YOLO-JD)
- **Alternative Mirror:** Mendeley Data DOI `10.17632/49kpx3y4m7.1`
- **Published License:** Open Access / CC BY 4.0
- **Target Folder:** `ai_model/dataset/raw/bangladesh_jute/`

### Step-by-Step Download & Extraction Procedure
1. **Navigate to the Official Source Page**: Open [https://github.com/foysalahmed10/YOLO-JD](https://github.com/foysalahmed10/YOLO-JD) or the Mendeley mirror.
2. **Verify License**: Check licensing terms in repository `CITATION.cff` or license descriptor.
3. **Download the Dataset Archive**: Download the image release zip from the repository's releases or documented cloud storage link.
4. **Place & Extract**:
   - Save and extract into `ai_model/dataset/raw/bangladesh_jute/`.
   - Ensure original disease subdirectories (`Stem_rot/`, `Anthracnose/`, `Healthy/`, etc.) remain unflattened.
5. **Run Validation Script**:
   ```bash
   python ai_model/validate_dataset_images.py
   ```

---

## 5. Post-Download Verification Protocol
Whenever any new dataset is downloaded or extracted:
1. Ensure the original archive (`.zip`, `.tar.gz`) is retained in the dataset root for provenance and hash checking.
2. Never rename image files or directory structures.
3. Execute the automated validation tool:
   ```bash
   python ai_model/validate_dataset_images.py
   ```
4. Verify that `download_manifest.csv` and `class_inventory.csv` are automatically updated with 100% accurate file counts, image dimensions, and SHA-256 hashes.
