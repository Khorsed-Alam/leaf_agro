# AgriCare AI — Supported Crops and Diseases

## 1. Complete Catalog of 19 Classes
AgriCare AI supports 19 specific diagnostic classes across 5 essential crops grown in Bangladesh.

```mermaid
graph TD
    subgraph Crops [5 Supported Crops]
        R[Rice / ধান]
        P[Potato / আলু]
        T[Tomato / টমেটো]
        M[Mango / আম]
        J[Jute / পাট]
    end

    subgraph Rice_Classes [Rice (4 Classes)]
        R1[Bacterial Leaf Blight]
        R2[Brown Spot]
        R3[Leaf Smut]
        R4[Healthy Rice]
    end

    subgraph Potato_Classes [Potato (3 Classes)]
        P1[Early Blight]
        P2[Late Blight]
        P3[Healthy Potato]
    end

    subgraph Tomato_Classes [Tomato (6 Classes)]
        T1[Bacterial Spot]
        T2[Early Blight]
        T3[Late Blight]
        T4[Leaf Mold]
        T5[Septoria Leaf Spot]
        T6[Healthy Tomato]
    end

    subgraph Mango_Classes [Mango (3 Classes)]
        M1[Anthracnose]
        M2[Bacterial Canker]
        M3[Healthy Mango]
    end

    subgraph Jute_Classes [Jute (3 Classes)]
        J1[Stem Rot]
        J2[Anthracnose]
        J3[Healthy Jute]
    end

    R --> Rice_Classes
    P --> Potato_Classes
    T --> Tomato_Classes
    M --> Mango_Classes
    J --> Jute_Classes
```

---

## 2. Detailed Diagnostic Descriptions

### 1. Rice (*Oryza sativa* / ধান)
1. **`Rice___Bacterial_leaf_blight` (ব্যাকটেরিয়াল লিফ ব্লাইট)**
   - *Causal Agent*: *Xanthomonas oryzae* pv. *oryzae*
   - *Symptoms*: Water-soaked to yellowish stripes along leaf margins; stripes enlarge and turn grayish-white with milky bacterial ooze beads.
2. **`Rice___Brown_spot` (বাদামী দাগ রোগ)**
   - *Causal Agent*: *Bipolaris oryzae*
   - *Symptoms*: Small, circular to oval dark-brown lesions with distinct yellow or chlorotic halo; common in potassium/nitrogen-deficient fields.
3. **`Rice___Leaf_smut` (লিফ স্মাট)**
   - *Causal Agent*: *Entyloma oryzae*
   - *Symptoms*: Tiny, raised, angular black spots scattered across leaf blades; spots burst under damp conditions to release black spores.
4. **`Rice___healthy` (সুস্থ ধানের পাতা)**
   - Clean, vibrant green blades without necrotic spots or marginal drying.

### 2. Potato (*Solanum tuberosum* / আলু)
5. **`Potato___Early_blight` (আগাম ধসা রোগ)**
   - *Causal Agent*: *Alternaria solani*
   - *Symptoms*: Dark brown to black spots with concentric rings ("target-board" appearance) primarily on older, lower foliage.
6. **`Potato___Late_blight` (নাবি ধসা রোগ)**
   - *Causal Agent*: *Phytophthora infestans*
   - *Symptoms*: Rapidly expanding water-soaked purplish-black lesions with white cottony down on leaf undersides in cold, foggy weather.
7. **`Potato___healthy` (সুস্থ আলুর পাতা)**
   - Broad, deep green compound leaflets with smooth margins.

### 3. Tomato (*Solanum lycopersicum* / টমেটো)
8. **`Tomato___Bacterial_spot` (ব্যাকটেরিয়াল স্পট)**
   - *Causal Agent*: *Xanthomonas perforans*
   - *Symptoms*: Small (2-3 mm) angular dark lesions surrounded by vivid yellow halos.
9. **`Tomato___Early_blight` (আগাম ব্লাইট)**
   - *Causal Agent*: *Alternaria solani*
   - *Symptoms*: Concentric rings forming irregular brown necrotic blotches surrounded by chlorotic leaf yellowing.
10. **`Tomato___Late_blight` (নাবি ব্লাইট)**
    - *Causal Agent*: *Phytophthora infestans*
    - *Symptoms*: Greasy-looking dark water-soaked patches that rapidly wither whole foliage during cool wet periods.
11. **`Tomato___Leaf_Mold` (লিফ মোল্ড)**
    - *Causal Agent*: *Passalora fulva*
    - *Symptoms*: Pale green to yellowish spots on upper surfaces with olive-green to brown velvety fungal growth underneath.
12. **`Tomato___Septoria_leaf_spot` (সেপ্টোরিয়া লিফ স্পট)**
    - *Causal Agent*: *Septoria lycopersici*
    - *Symptoms*: Numerous circular spots with dark brown margins and sunken grayish-white centers containing tiny black pycnidia.
13. **`Tomato___healthy` (সুস্থ টমেটোর পাতা)**
    - Lush, fragrant green compound foliage without lesions.

### 4. Mango (*Mangifera indica* / আম)
14. **`Mango___Anthracnose` (অ্যানথ্রাকনোজ)**
    - *Causal Agent*: *Colletotrichum gloeosporioides*
    - *Symptoms*: Irregular dark brown to black necrotic spots that coalesce, causing leaf shot-holes and tip dieback.
15. **`Mango___Bacterial_canker` (ব্যাকটেরিয়াল ক্যাঙ্কার)**
    - *Causal Agent*: *Xanthomonas citri* pv. *mangiferaeindicae*
    - *Symptoms*: Water-soaked angular lesions bounded by leaf veins, turning black and raised with gummy exudate.
16. **`Mango___healthy` (সুস্থ আমের পাতা)**
    - Glossy, lanceolate dark green foliage.

### 5. Jute (*Corchorus olitorius* / পাট)
17. **`Jute___Stem_rot` (কান্ডের পচন রোগ)**
    - *Causal Agent*: *Macrophomina phaseolina*
    - *Symptoms*: Blackish-brown necrotic lesions spreading along stems and petiole bases, causing severe leaf wilting.
18. **`Jute___Anthracnose` (পাট অ্যানথ্রাকনোজ)**
    - *Causal Agent*: *Colletotrichum corchori*
    - *Symptoms*: Sunken, reddish-brown necrotic spots on leaf margins and veins that tear easily.
19. **`Jute___healthy` (সুস্থ পাটের পাতা)**
    - Serrated, bright green ovate leaves without blemishes.

