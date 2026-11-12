# AgriCare AI — Complete System Architecture
*Comprehensive Flow, On-Device Neural Vision, and Cloud Persistence for Screens 01–07*

## 1. Executive Summary
AgriCare AI is an offline-first, mobile-centric agricultural assistant designed to diagnose plant diseases across major Bangladeshi and global crops (**Rice**, **Potato**, **Tomato**, **Mango**, **Jute**) using an on-device quantized MobileNetV2 TensorFlow Lite model. It integrates seamlessly with Supabase for cloud persistence, user profiles, field log history, and expert treatment/prevention recommendations.

---

## 2. Complete Application Flow & Architecture (Screens 01–07)

![AgriCare AI Complete Application Flow](images/agricare_ai_application_flowchart.jpg)

### Complete Flowchart (Mermaid)

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
