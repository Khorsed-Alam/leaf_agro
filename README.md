# AgriCare AI 🌿

AgriCare AI is a Flutter-based mobile application designed to help Bangladeshi farmers detect crop diseases, get treatment recommendations, and access agricultural knowledge — all powered by on-device AI and a Supabase cloud backend.

---

## Features

- **AI-Powered Disease Detection** — Identify crop diseases from leaf photos using a TFLite MobileNetV2 model running entirely on-device (offline capable).
- **Bilingual Support** — Full English and Bangla (বাংলা) localization.
- **Crop & Disease Catalog** — Browse diseases, symptoms, treatments, and prevention tips.
- **History** — Track past scans and results with timestamps.
- **Recommendations** — Context-aware treatment and prevention advice.
- **User Profiles** — Auth via Supabase with district and phone data.
- **Notifications** — Push alerts for seasonal advisories.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x (Dart 3) |
| State Management | Riverpod 2 (code-gen) |
| Navigation | GoRouter 14 |
| Backend | Supabase (Auth + PostgreSQL + Storage) |
| ML Inference | TFLite Flutter (MobileNetV2) |
| Local DB | SQLite (sqflite) |
| Localization | Custom JSON-based (en, bn) |

---

## Getting Started

### Prerequisites

- Flutter SDK >= 3.13.0
- Dart SDK >= 3.0.0
- A Supabase project (get URL and anon key from your project dashboard)

### Setup

1. **Clone the repo**
   ```bash
   git clone https://github.com/your-org/leaf_agro.git
   cd leaf_agro
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run code generation**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Configure Supabase credentials**

   Pass them via `--dart-define` at build/run time:
   ```bash
   flutter run \
     --dart-define=SUPABASE_URL=https://your-project.supabase.co \
     --dart-define=SUPABASE_ANON_KEY=your-anon-key
   ```

5. **Place TFLite model**

   Copy your MobileNetV2 TFLite model and labels file into:
   ```
   assets/models/plant_disease_model.tflite
   assets/models/labels.txt
   ```

6. **Run the app**
   ```bash
   flutter run
   ```

---

## Project Structure

```
lib/
├── main.dart                   # Entry point
├── app.dart                    # Root app widget
├── core/
│   ├── constants/              # App & Supabase constants
│   ├── theme/                  # Colors & ThemeData
│   ├── router/                 # GoRouter config
│   ├── localization/           # JSON-based i18n
│   ├── errors/                 # Exception hierarchy
│   └── utils/                  # Image & validation utils
├── data/
│   ├── models/                 # Freezed data classes
│   ├── repositories/           # Data access layer
│   └── datasources/            # Supabase + local DB sources
├── domain/
│   └── usecases/               # Business logic
└── presentation/
    ├── screens/                # UI screens
    ├── widgets/                # Reusable widgets
    └── providers/              # Riverpod providers
assets/
├── models/                     # TFLite model & labels
├── images/                     # Static images
├── icons/                      # Custom icons
└── translations/               # en.json, bn.json
```

---

## Supabase Schema (key tables)

- `profiles` — user profile data
- `crops` — crop catalog
- `disease_catalog` — disease info, symptoms, images
- `recommendations` — treatment recommendations
- `prediction_history` — scan results per user
- `feedback` — user feedback submissions
- `notifications` — push notification records

---

## License

MIT © 2024 AgriCare AI Team
