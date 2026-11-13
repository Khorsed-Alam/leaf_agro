# AgriCare AI — Complete System Architecture
*Comprehensive Flow, On-Device Neural Vision, and Cloud Persistence for Screens 00–30*

## 1. Executive Summary
AgriCare AI is an offline-first, mobile-centric agricultural assistant designed to diagnose plant diseases across major Bangladeshi and global crops (**Rice**, **Potato**, **Tomato**, **Mango**, **Jute**) using an on-device quantized MobileNetV2 TensorFlow Lite model. It integrates seamlessly with Supabase for cloud persistence, user profiles, field log history, and expert treatment/prevention recommendations.

---

## 2. Complete Application Flow & Architecture (Screens 00–30)

![AgriCare AI Complete Application Flow (Screens 00–30)](images/agricare_ai_user_flow_00_30.png)

> **Developer Architecture Reference**: The full user flow, modular sub-flows, and navigation mapping tables are documented in [user_flow_architecture_00_30.md](user_flow_architecture_00_30.md) and [agricare_ai_user_flow_00_30.mmd](agricare_ai_user_flow_00_30.mmd). Legacy Screen 00–20 reference remains at [user_flow_architecture_00_20.md](user_flow_architecture_00_20.md).

### Master Application Flowchart (Mermaid)

```mermaid
flowchart TD
    %% AgriCare AI - Master Application Flowchart (Screens 00 to 30)
    %% 7 Functional Modules | 31 Completed Production Screens

    classDef screenNode fill:#102A43,stroke:#2563EB,stroke-width:2px,color:#F8FAFC;
    classDef highlightScreen fill:#064E3B,stroke:#10B981,stroke-width:2.5px,color:#ECFDF5;

    %% Module 1: Initialization & Authentication
    subgraph M1 ["Module 1: Initialization & Authentication"]
        S00["Screen 00: Route Resolver / Splash Gate"]:::screenNode
        S01["Screen 01: Animated Splash Screen"]:::screenNode
        S02["Screen 02: Onboarding Carousel"]:::screenNode
        S03["Screen 03: Farmer Login"]:::screenNode
        S04["Screen 04: Farmer Registration"]:::screenNode
        S05["Screen 05: Forgot / Reset Password"]:::screenNode

        S00 --> S01
        S01 -->|First Launch| S02
        S01 -->|Logged In| S06
        S01 -->|Logged Out| S03
        S02 --> S03
        S03 -->|Need Account| S04
        S04 -->|Account Created| S06
        S03 -->|Forgot Password| S05
        S05 -->|Reset Complete| S03
        S03 -->|Login Success| S06
    end

    %% Module 2: Home & Discovery
    subgraph M2 ["Module 2: Home & Discovery"]
        S06["Screen 06: Home Dashboard"]:::highlightScreen
        S07["Screen 07: Crop Selection Screen"]:::screenNode
        S08["Screen 08: Crop Detail Screen"]:::screenNode
        S09["Screen 09: Disease Catalog Screen"]:::screenNode
        S10["Screen 10: Global Search Screen"]:::screenNode
        S17["Screen 17: Disease Detail Screen"]:::screenNode

        S06 -->|Select Crop| S07
        S06 -->|Browse Diseases| S09
        S06 -->|Tap Search Bar| S10
        S07 -->|Select Specific Crop| S08
        S08 -->|View Crop Disease| S17
        S09 -->|Tap Disease Card| S17
        S10 -->|Select Search Result| S17
    end

    %% Module 3: AI Vision Detection Pipeline
    subgraph M3 ["Module 3: AI Vision Detection Pipeline"]
        S11["Screen 11: Detection Start Screen"]:::screenNode
        S12["Screen 12: Real-time Camera Viewfinder"]:::screenNode
        S13["Screen 13: Gallery Upload Screen"]:::screenNode
        S14["Screen 14: Image Review Screen"]:::screenNode
        S15["Screen 15: AI Analyzing Screen"]:::screenNode
        S16["Screen 16: AI Detection Result Screen"]:::highlightScreen

        S06 -->|Tap Diagnose Leaf| S11
        S11 -->|Take Photo| S12
        S11 -->|Choose From Gallery| S13
        S12 -->|Capture Photo| S14
        S13 -->|Select Photo| S14
        S14 -->|Retake| S11
        S14 -->|Confirm & Analyze| S15
        S15 -->|TFLite Inference| S16
        S16 -->|View Disease Details| S17
    end

    %% Module 4: Recommendations & Remedies
    subgraph M4 ["Module 4: Recommendations & Remedies"]
        S18["Screen 18: Treatment Recommendations"]:::screenNode
        S19["Screen 19: Prevention & Plant Care"]:::screenNode
        S20["Screen 20: Product & Solution Info"]:::screenNode
        S21["Screen 21: Plant Recovery & Follow-up"]:::screenNode

        S16 -->|View Treatments| S18
        S17 -->|View Treatments| S18
        S18 -->|View Prevention| S19
        S19 -->|View Registered Products| S20
        S18 -->|Record Observation| S21
        S16 -->|Monitor Plant| S21
    end

    %% Module 5: History & Monitoring
    subgraph M5 ["Module 5: History & Monitoring"]
        S22["Screen 22: Detection History Dashboard"]:::screenNode
        S23["Screen 23: History Details Screen"]:::screenNode

        S06 -->|Open History| S22
        S22 -->|Filter/Search| S22
        S22 -->|Tap Past Scan| S23
        S23 -->|Revisit Treatments| S18
        S23 -->|Open Recovery Log| S21
        S23 -->|Scan Plant Again| S11
    end

    %% Module 6: Profile & Settings
    subgraph M6 ["Module 6: Profile & Settings"]
        S24["Screen 24: User Profile Screen"]:::screenNode
        S25["Screen 25: Settings Screen"]:::screenNode
        S26["Screen 26: Language Selection Screen"]:::screenNode

        S06 -->|Open Profile| S24
        S24 -->|Open Settings| S25
        S24 -->|Change Language| S26
        S25 -->|Change Language| S26
        S25 -->|Log Out| S03
    end

    %% Module 7: Support & Governance
    subgraph M7 ["Module 7: Support & Governance"]
        S27["Screen 27: Notifications Screen"]:::screenNode
        S28["Screen 28: Help & FAQ Screen"]:::screenNode
        S29["Screen 29: Feedback Screen"]:::screenNode
        S30["Screen 30: About Application Screen"]:::screenNode

        S06 -->|Bell Icon| S27
        S24 -->|Help & Support| S28
        S25 -->|Help & Support| S28
        S24 -->|Submit Feedback| S29
        S25 -->|Submit Feedback| S29
        S25 -->|About App| S30
        S28 -->|Send Feedback| S29
    end
```

```mermaid
flowchart TD
    Start([START]) --> S01["Screen 01: Animated Splash Screen"]
    S01 --> S02["Screen 02: Onboarding Screen"]
    
    S02 --> UserAction{"User Action"}
    UserAction -->|Get Started| S03["Screen 03: Login Screen"]
    UserAction -->|Skip| S03
    
    S03 --> ActionChoice{"Choose Action"}
    
    %% --- LOGIN FLOW ---
    ActionChoice -->|Login| EnterCreds["Enter Email & Password"]
    EnterCreds --> ValCreds["Validate Login Credentials"]
    ValCreds --> IsCredsValid{"Valid Credentials?"}
    IsCredsValid -->|No| S03
    IsCredsValid -->|Yes| SupaAuth["Supabase Authentication"]
    SupaAuth --> S06["Screen 06: Main Home Dashboard"]
    
    %% --- SIGN UP FLOW ---
    ActionChoice -->|Sign Up| S04["Screen 04: Registration Screen"]
    S04 --> EnterReg["Enter Full Name, Email, Phone & Password"]
    EnterReg --> AcceptTerms["Accept Terms & Conditions"]
    AcceptTerms --> ValReg["Validate Registration Form"]
    ValReg --> IsRegValid{"Valid Data?"}
    IsRegValid -->|No| S04
    IsRegValid -->|Yes| CreateAuth["Create Account in Supabase Auth"]
    CreateAuth --> CreateProfile["Create Farmer Profile in PostgreSQL"]
    CreateProfile --> RegSuccess["Registration Successful"]
    RegSuccess --> S03
    
    %% --- FORGOT PASSWORD FLOW ---
    ActionChoice -->|Forgot Password| S05["Screen 05: Forgot Password Screen"]
    S05 --> EnterResetEmail["Enter Registered Email"]
    EnterResetEmail --> ValEmail["Validate Email Address"]
    ValEmail --> IsEmailValid{"Valid Email Format?"}
    IsEmailValid -->|No| S05
    IsEmailValid -->|Yes| SupaRecovery["Supabase Password Recovery"]
    SupaRecovery --> CheckEmail["Check Your Email Confirmation"]
    CheckEmail --> OpenLink["Open Password Reset Link"]
    OpenLink --> ResetScreen["Reset Password Screen"]
    ResetScreen --> SetNewPass["Set New Password"]
    SetNewPass --> UpdatePass["Update Password in Supabase"]
    UpdatePass --> S03

    %% --- SCREEN 06: MAIN HOME DASHBOARD FLOW ---
    S06 --> DashActions{"Dashboard Action"}
    DashActions -->|Tap 'Scan Plant' / Detect Tab| S07["Screen 07: Crop Selection Screen"]
    DashActions -->|Explore Crops / View All| CropList["Crop Encyclopedia (/crops)"]
    DashActions -->|Tap Crop Card| CropDetail["Crop Details Screen (/crops/:id)"]
    DashActions -->|Recent Scans / View All| ScanHistory["Diagnosis History (/history)"]
    DashActions -->|Tap Scan Record| HistoryDetail["History Detail Screen (/history/:id)"]
    DashActions -->|Profile Nav / Avatar| ProfileScreen["Farmer Profile Screen (/profile)"]
    
    %% --- SCREEN 07: CROP SELECTION FLOW ---
    S07 --> LoadModelCrops["Load Verified AI Crops (Rice, Potato, Tomato, Mango, Jute)"]
    LoadModelCrops --> CropSearch{"Search Crop?"}
    CropSearch -->|Query Input| FilterGrid["Filter by English or Bengali Name"]
    FilterGrid --> HasMatch{"Matching Crops Found?"}
    HasMatch -->|No| EmptySearch["Empty Search State (Clear Search Action)"]
    EmptySearch --> LoadModelCrops
    HasMatch -->|Yes| GridView["2-Column Responsive Crop Grid"]
    CropSearch -->|No Search Query| GridView
    
    GridView --> SelectCrop["Farmer Taps Crop Card (Single Selection)"]
    SelectCrop --> VisualState["Highlight Card (Fresh Green Border & Check Indicator)"]
    VisualState --> CheckSupport{"Crop AI-Supported?"}
    CheckSupport -->|No| DisabledCTA["Continue Button Disabled"]
    CheckSupport -->|Yes| EnabledCTA["Continue Button Enabled ('Continue to Scan')"]
    
    EnabledCTA --> TapContinue["Tap 'Continue to Scan'"]
    TapContinue --> SaveCropState["Store in selectedCropProvider (Riverpod)"]
    SaveCropState --> S08["Screen 08: Plant Image Capture & AI Detection (/detect)"]
    
    S07 -->|Tap Back Button| S06
```

---

## 3. Implemented Production Screens (Screens 01–07)

### Screen 01: Animated Splash Screen
- **Centerpiece:** Vector leaf silhouette, circuit nodes, HUD ring, and animated AI laser sweep.
- **Route:** `/splash`

### Screen 02: Onboarding Screen
- **Components:** 3 curated farmer cards (Smart Disease Detection, Offline Diagnosis, Maximum Yield), interactive `EN` \| `বাংলা` language toggle, and smooth PageView.
- **Route:** `/onboarding`

### Screen 03: Login Screen
- **Components:** `AuthLogoBadge`, bilingual form with email regex validation, password visibility toggle, "Remember me", guest offline bypass, and Google OAuth button.
- **Route:** `/login`

### Screen 04: Registration Screen
- **Components:** 5 core form fields, Bangladesh `+880` mobile standardizer, real-time password checklist, interactive Terms & Privacy dialogs, and Supabase Auth creation.
- **Route:** `/register`

### Screen 05: Forgot Password & Password Recovery
- **Components:** `RecoveryHeroIllustration`, 3-phase animated recovery (Input → Progress → Check Email), spam folder advisory, 30s resend cooldown timer, and deep link `/reset-password`.
- **Route:** `/forgot-password` & `/reset-password`

### Screen 06: Main Home Dashboard
- **Components:**
  - `DashboardHeader`: Dynamic morning/afternoon/evening greeting, authenticated farmer name, avatar with initials/photo, unread notification counter, and language toggle.
  - `DashboardHeroCard`: Deep Forest Green to Fresh Green gradient, animated continuous laser scanning effect, and high-contrast `ScanPlantButton`.
  - `DashboardStatistics`: Real-time computed stats from actual scan logs (**Total Scans**, **Healthy Detections**, **Disease Detections**).
  - `ExploreCropsSection`: Horizontal carousel with 5 supported crops and "View All" encyclopedia link.
  - `RecentDetectionsSection`: Authenticated user's recent scans sorted newest first, status pills, confidence badges, and friendly empty state.
  - `DashboardBottomNavigation`: Fixed 4-tab bar (**Home**, **Detect**, **History**, **Profile**).
- **Route:** `/home`

### Screen 07: Crop Selection Screen
- **Components:**
  - `CropSelectionHeader`: Back button returning to dashboard, Step 01 badge, heading *"Select Your Crop"*, and bilingual subtitle.
  - `CropSearchField`: High-contrast search input filtering crop names in English and Bengali with instant clear-search action.
  - `CropSelectionGrid`: Responsive 2-column grid (`crossAxisCount: 2`) strictly displaying the 5 AI-supported crops (Rice, Potato, Tomato, Mango, Jute).
  - `CropSelectionCard`: Realistic agricultural imagery, "AI Ready" tag, detectable disease count, and tactile press animation.
  - `CropSelectionIndicator`: Fresh Green check-circle icon on selected card.
  - `EmptyCropSearchState`: Informative empty query prompt with supported crop advisory and reset button.
  - `ContinueButton`: Fixed bottom action button enabled only upon single-crop selection, writing to `selectedCropProvider` and navigating to Screen 08 (`/detect`).
- **Route:** `/crop-select`

---

## 4. Layered System Architecture

```mermaid
graph TD
    subgraph Presentation ["Presentation Layer (Flutter 3.x)"]
        UI["Material 3 Production Screens (GoRouter)"]
        VerdantTokens["Verdant Intelligence Tokens (#14532D, #22C55E, #A3E635)"]
    end

    subgraph StateManagement ["State Management Layer"]
        Riverpod["Riverpod (selectedCropProvider, authProvider, cropProvider, historyProvider)"]
    end

    subgraph DomainLogic ["Domain & Business Logic"]
        DetectionService["AI Prediction Engine (MobileNetV2 TFLite)"]
        AiCatalog["AiCropCatalog (5 Model-Verified Crops)"]
        SyncService["Offline SQLite / Supabase Sync Engine"]
    end

    subgraph DataAccess ["Data Layer"]
        LocalData["Local: TFLite + SQLite + SharedPreferences"]
        RemoteData["Remote: Supabase REST + Storage + GoTrue Auth"]
    end

    UI --> Riverpod
    Riverpod --> DomainLogic
    DomainLogic --> DataAccess
```

---

## 5. Offline-First AI Inference Pipeline
1. **Crop Selection (Screen 07)**: Farmer selects plant species (Rice, Potato, Tomato, Mango, or Jute), setting active context.
2. **Camera / Gallery Capture (Screen 08)**: User snaps leaf photo under natural daylight.
3. **Preprocessing (Client-Side)**: 224x224 RGB image normalized to `[-1.0, 1.0]`.
4. **On-Device Inference**: MobileNetV2 quantized `.tflite` model evaluates tensor data locally via `tflite_flutter` in under 300ms without requiring internet.
5. **Local SQLite Persistence**: Prediction record and confidence score are saved immediately.
6. **Cloud Synchronization**: When cellular or Wi-Fi connectivity is established, scans and images sync to Supabase PostgreSQL and private storage buckets.
