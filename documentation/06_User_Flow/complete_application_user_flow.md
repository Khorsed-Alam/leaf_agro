# AgriCare AI — Complete Application User Flow (Screens 00 to 30)

## 1. Master Application Flowchart
The following diagram details the end-to-end navigational paths, decision forks, and screen transitions across all 31 screens in AgriCare AI.

![AgriCare AI Master Flowchart Screens 00 to 30](../images/agricare_ai_user_flow_00_30.png)

### Architectural Flow Graph


```mermaid
graph TD
    %% Module 1: Initialization & Authentication
    subgraph M1_Auth [Module 1: Initialization & Authentication]
        S00[Screen 00: Route Resolver / Splash Gate]
        S01[Screen 01: Animated Splash Screen]
        S02[Screen 02: Onboarding Carousel]
        S03[Screen 03: Farmer Login]
        S04[Screen 04: Farmer Registration]
        S05[Screen 05: Forgot / Reset Password]

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
    subgraph M2_Discovery [Module 2: Home & Discovery]
        S06[Screen 06: Home Dashboard]
        S07[Screen 07: Crop Selection Screen]
        S08[Screen 08: Crop Detail Screen]
        S09[Screen 09: Disease Catalog Screen]
        S10[Screen 10: Global Search Screen]

        S06 -->|Select Crop| S07
        S06 -->|Browse Diseases| S09
        S06 -->|Tap Search Bar| S10
        S07 -->|Select Specific Crop| S08
        S08 -->|View Crop Disease| S17[Screen 17: Disease Detail Screen]
        S09 -->|Tap Disease Card| S17
        S10 -->|Select Search Result| S17
    end

    %% Module 3: Detection Pipeline
    subgraph M3_Detection [Module 3: AI Vision Detection Pipeline]
        S11[Screen 11: Detection Start Screen]
        S12[Screen 12: Real-time Camera Viewfinder]
        S13[Screen 13: Gallery Upload Screen]
        S14[Screen 14: Image Preview Screen]
        S15[Screen 15: AI Analyzing Screen]
        S16[Screen 16: AI Detection Result Screen]

        S06 -->|Tap Diagnose Leaf| S11
        S11 -->|Take Photo| S12
        S11 -->|Choose from Gallery| S13
        S12 -->|Capture Photo| S14
        S13 -->|Select Photo| S14
        S14 -->|Retake| S11
        S14 -->|Confirm & Analyze| S15
        S15 -->|TFLite Inference| S16
    end

    %% Module 4: Recommendations & Remedies
    subgraph M4_Remedies [Module 4: Recommendations & Remedies]
        S17[Screen 17: Disease Detail Screen]
        S18[Screen 18: Treatment Recommendations]
        S19[Screen 19: Prevention & Plant Care]
        S20[Screen 20: Product & Solution Info]

        S16 -->|View Treatments| S18
        S16 -->|View Disease Details| S17
        S17 -->|View Treatments| S18
        S18 -->|View Prevention| S19
        S18 -->|View Registered Products| S20
        S19 -->|View Products| S20
        S16 -->|Monitor Plant| S21[Screen 21: Plant Recovery & Follow-up]
    end

    %% Module 5: History & Monitoring
    subgraph M5_History [Module 5: History & Monitoring]
        S21[Screen 21: Plant Recovery & Follow-up]
        S22[Screen 22: Detection History Dashboard]
        S23[Screen 23: History Details Screen]

        S06 -->|Open History| S22
        S22 -->|Filter/Search| S22
        S22 -->|Tap Past Scan| S23
        S23 -->|Revisit Treatments| S18
        S23 -->|Open Recovery Log| S21
        S21 -->|Record Observation| S21
        S21 -->|Scan Plant Again| S11
    end

    %% Module 6: Profile & Settings
    subgraph M6_Profile [Module 6: Profile & Settings]
        S24[Screen 24: User Profile Screen]
        S25[Screen 25: Settings Screen]
        S26[Screen 26: Language Selection Screen]

        S06 -->|Open Profile| S24
        S24 -->|Open Settings| S25
        S24 -->|Change Language| S26
        S25 -->|Change Language| S26
        S25 -->|Log Out| S03
    end

    %% Module 7: Support & Governance
    subgraph M7_Support [Module 7: Support & Governance]
        S27[Screen 27: Notifications Screen]
        S28[Screen 28: Help & FAQ Screen]
        S29[Screen 29: Feedback Screen]
        S30[Screen 30: About Application Screen]

        S06 -->|Bell Icon| S27
        S24 -->|Help & Support| S28
        S25 -->|Help & Support| S28
        S24 -->|Submit Feedback| S29
        S25 -->|Submit Feedback| S29
        S25 -->|About App| S30
        S28 -->|Send Feedback| S29
    end
```

---

## 2. Screen Reference Table (Screens 00 to 30)

| Screen # | Screen Name | Route Path | Primary Function |
| :---: | :--- | :--- | :--- |
| **00** | Splash Gate / Resolver | `/splash` (Gate) | Directs authenticated vs. unauthenticated launch. |
| **01** | Splash Screen | `/splash` | Animated branding, leaf scanner animation, logo display. |
| **02** | Onboarding Screen | `/onboarding` | 3-step introduction to detection, remedies, and recovery. |
| **03** | Farmer Login | `/login` | Phone/Email authentication, password visibility toggle. |
| **04** | Farmer Registration | `/register` | New account creation, district dropdown, terms agreement. |
| **05** | Forgot / Reset Password | `/forgot-password`, `/reset-password` | Password reset email trigger and new password entry. |
| **06** | Home Dashboard | `/home` | Quick scan CTA, recent scans, crop carousel, weather/alerts. |
| **07** | Crop Selection Screen | `/crop-select` | Grid of 5 supported crops with selection highlighting. |
| **08** | Crop Detail Screen | `/crops/:id` | Agronomic guides, growth stages, crop-specific diseases. |
| **09** | Disease Catalog Screen | `/diseases` | 19-class searchable disease encyclopedia with filters. |
| **10** | Global Search Screen | `/search` | Real-time bilingual fuzzy search across crops & diseases. |
| **11** | Detection Start Screen | `/detect` | Launchpad for camera capture or photo gallery upload. |
| **12** | Camera Screen | `/detect/camera` | Fullscreen viewfinder, leaf alignment guides, flash toggle. |
| **13** | Gallery Upload Screen | `/detect/gallery` | System photo picker with format and size validation. |
| **14** | Image Preview Screen | `/detect/preview` | Quality preflight: blur detection, crop adjustment, retake. |
| **15** | AI Analyzing Screen | `/detect/analyzing` | Pulsing radar animation, on-device MobileNetV2 inference. |
| **16** | AI Detection Result | `/detect/result` | Primary diagnosis, confidence gauge, severity badge, CTAs. |
| **17** | Disease Detail Screen | `/diseases/:id` | Comprehensive symptoms, causal pathogens, biology. |
| **18** | Treatment Recommendations | `/recommendations/:id` | Cultural, organic, and chemical treatment protocols. |
| **19** | Prevention & Plant Care | `/prevention` | Field sanitation, spacing, irrigation, and rotation rules. |
| **20** | Product & Solution Info | `/solutions` | Directory of registered agrochemicals, dosages, and safety. |
| **21** | Plant Recovery & Follow-up| `/recovery` | Longitudinal observation checkpoints, recovery timeline. |
| **22** | Detection History | `/history` | Searchable scan archive with date range and crop filters. |
| **23** | History Details Screen | `/history/:id` | Revisit past scan, historical prediction, and remedy links. |
| **24** | User Profile Screen | `/profile` | Farmer identity, scan counts, district, quick setting shortcuts. |
| **25** | Settings Screen | `/settings` | Cache manager, model info, offline settings, legal links. |
| **26** | Language Selection Screen | `/settings/language` | Instant switch between English and Bengali (বাংলা). |
| **27** | Notifications Screen | `/notifications` | Activity notifications, reminders, mark-as-read controls. |
| **28** | Help & FAQ Screen | `/help` | 4 quick photo guides, 12 searchable FAQs, support options. |
| **29** | Feedback Screen | `/feedback` | 5-star rating, category picker, character-counted comments. |
| **30** | About Application Screen | `/about` | Academic capstone details, tech stack, disclaimers. |

