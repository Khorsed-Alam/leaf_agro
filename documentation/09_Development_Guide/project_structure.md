# AgriCare AI — Project Structure

## 1. Directory Hierarchy
The project adheres to a clean, feature-first directory layout:

```text
leaf_agro/
├── android/                   # Native Android host project (Gradle, NDK, manifest)
├── assets/                    # Static runtime assets
│   ├── icons/                 # SVG and PNG UI icons
│   ├── images/                # High-res illustrations and logos
│   ├── models/                # ML artifacts: TFLite model, labels.json, metadata
│   └── translations/          # Bilingual JSON translation dictionaries (en, bn)
├── documentation/             # 11-folder technical, architectural & user documentation
├── lib/                       # Main Dart source code
│   ├── core/                  # Cross-cutting foundational modules
│   │   ├── config/            # Supabase and academic project metadata configs
│   │   ├── localization/      # Dual-language services and string resolvers
│   │   ├── router/            # GoRouter 14.x navigation definitions
│   │   ├── services/          # Low-level hardware & ML services (TFLiteService)
│   │   └── theme/             # Material 3 colors, typography, and card tokens
│   ├── data/                  # Data layer
│   │   ├── models/            # Freezed/JSON domain models
│   │   └── repositories/      # Repository implementations (SQLite + Supabase)
│   ├── features/              # Feature modules (Screens 00 to 30)
│   │   ├── about/             # Screen 30: Academic capstone information
│   │   ├── auth/              # Screens 03-05: Login, Register, Forgot Password
│   │   ├── crops/             # Screens 07-08: Crop selection and agronomy
│   │   ├── detection/         # Screens 11-16: Camera, Gallery, Analyzing, Result
│   │   ├── diseases/          # Screens 09, 17: Disease catalog and pathology
│   │   ├── feedback/          # Screen 29: 5-star ratings and feedback
│   │   ├── help/              # Screen 28: Support center and searchable FAQs
│   │   ├── history/           # Screens 22-23: Detection history and details
│   │   ├── home/              # Screen 06: Main dashboard
│   │   ├── notifications/     # Screen 27: Notification center
│   │   ├── onboarding/        # Screen 02: Introduction carousel
│   │   ├── profile/           # Screen 24: Farmer profile
│   │   ├── recommendations/   # Screens 18-20: Treatments, Prevention, Products
│   │   ├── recovery/          # Screen 21: Plant recovery checkpoints
│   │   ├── search/            # Screen 10: Global search
│   │   ├── settings/          # Screens 25-26: Settings and language picker
│   │   └── splash/            # Screen 01: Splash screen
│   └── main.dart              # Application bootstrap entrypoint
├── supabase/                  # Backend infrastructure
│   └── migrations/            # Version-controlled SQL database migrations (001-006)
├── test/                      # Comprehensive test suite (Unit, Widget, Riverpod tests)
└── pubspec.yaml               # Project dependencies and asset declarations
```

