# AgriCare AI — Dependency Management

## 1. Verified Production Dependencies
All dependencies are explicitly locked in `pubspec.yaml` and verified to run without conflicts:

| Dependency | Version Constraint | Category | Responsibility |
| :--- | :--- | :--- | :--- |
| `flutter_riverpod` | `^2.5.1` | State Management | Unidirectional reactive state management |
| `riverpod_annotation`| `^2.3.5` | Code Generation | Compile-time provider definitions |
| `go_router` | `^14.2.7` | Navigation | Declarative URI-based routing and deep links |
| `supabase_flutter` | `^2.5.6` | Cloud Backend | Auth, PostgreSQL REST client, and S3 Storage |
| `tflite_flutter` | `^0.12.1` | Edge AI | Native C++ TensorFlow Lite inference runtime |
| `camera` | `^0.12.2` | Hardware | Real-time camera viewfinder and shutter capture |
| `image_picker` | `^1.1.2` | Media | Gallery photo selection |
| `image` | `^4.1.7` | Image Processing | Bitmap decoding, resizing, EXIF rotation, normalization |
| `shared_preferences` | `^2.3.2` | Persistence | Key-value store for session tokens & preferences |
| `sqflite` | `^2.3.3+1` | Persistence | Embedded SQLite relational database for offline sync |
| `path_provider` | `^2.1.4` | Storage | Resolving sandboxed application document directories |
| `intl` | `^0.20.3` | Localization | Date, time, and numeral formatting |
| `freezed_annotation` | `^2.4.4` | Data Models | Immutable data class generation |
| `json_annotation` | `^4.9.0` | Serialization | JSON serialization macros |

---

## 2. Dev Dependencies
- `flutter_test`: Flutter SDK unit/widget testing library.
- `flutter_lints`: `^4.0.0` (Enforces standard idiomatic Dart conventions).
- `build_runner`: `^2.4.12` (Code generation orchestrator).
- `freezed`: `^2.5.7` (Freezed code generator).
- `json_serializable`: `^6.8.0` (JSON serializer code generator).

