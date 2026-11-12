# AgriCare AI — Complete System Architecture

## 1. Executive Summary
AgriCare AI is an offline-first, mobile-centric agricultural assistant designed to diagnose plant diseases across major Bangladesh and global crops (Rice, Potato, Tomato, Mango, Jute) using an on-device quantized MobileNetV2 TensorFlow Lite model. It integrates seamlessly with Supabase for cloud persistence, user profiles, field log history, and expert treatment/prevention recommendations.

## 2. Complete Application Flow & Architecture

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
    SupaAuth --> S06["Screen 06: Main Dashboard"]
    
    %% --- SIGN UP FLOW ---
    ActionChoice -->|Sign Up| S04["Screen 04: Registration Screen"]
    S04 --> EnterReg["Enter Full Name, Email, Phone & Password"]
    EnterReg --> AcceptTerms["Accept Terms & Conditions"]
    AcceptTerms --> ValReg["Validate Registration Form"]
    ValReg --> IsRegValid{"Valid Data?"}
    IsRegValid -->|No| S04
    IsRegValid -->|Yes| CreateAuth["Create Account in Supabase Auth"]
    CreateAuth --> CreateProfile["Create Farmer Profile in PostgreSQL"]
    CreateProfile --> EmailVerifCheck{"Email Verification Required?"}
    EmailVerifCheck -->|Yes| VerifyEmail["Verify Email"]
    VerifyEmail --> RegSuccess["Registration Successful"]
    EmailVerifCheck -->|No| RegSuccess
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
```

## 3. Layered Architecture

```mermaid
graph TD
    subgraph Presentation ["Presentation Layer (Flutter 3.x)"]
        UI["30 Material 3 Screens (GoRouter)"]
        VerdantTokens["Verdant Intelligence Design Tokens"]
    end

    subgraph StateManagement ["State Management Layer"]
        Riverpod["Riverpod Notifiers & AsyncValue"]
    end

    subgraph DomainLogic ["Domain & Business Logic"]
        DetectionService["AI Prediction Engine"]
        SyncService["Offline SQLite / Supabase Sync Engine"]
    end

    subgraph DataAccess ["Data Layer"]
        LocalData["Local: TFLite + SQLite + SharedPreferences"]
        RemoteData["Remote: Supabase REST + Storage + Auth"]
    end

    UI --> Riverpod
    Riverpod --> DomainLogic
    DomainLogic --> DataAccess
```

## 3. Offline-First Inference Pipeline
1. **Camera / Gallery Capture**: User selects or snaps leaf photo.
2. **Preprocessing (Client-Side)**: 224x224 RGB image normalization to `[-1.0, 1.0]`.
3. **On-Device Inference**: MobileNetV2 `.tflite` runs directly via `tflite_flutter` in isolated background thread.
4. **Offline Local SQLite Storage**: Scan result is saved instantly without requiring network access.
5. **Background Sync**: When internet is detected, telemetry and scans sync to Supabase PostgreSQL.

