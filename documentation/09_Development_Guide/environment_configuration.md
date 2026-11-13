# AgriCare AI — Environment Configuration

## 1. Environment Parameters
AgriCare AI communicates with Supabase Cloud using project configuration parameters defined in `lib/core/config/supabase_config.dart`.

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'https://your-project.supabase.co';
  static const String supabaseAnonKey = 'your-anon-key-here';

  static SupabaseClient get client => Supabase.instance.client;
}
```

---

## 2. Setting Up Local Credentials
For security, production secrets and API keys should never be committed to public repositories. You can pass them at build time using Dart environment defines:
```bash
flutter run \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

Or configure a local `.env` configuration file loaded via `flutter_dotenv` during local staging builds.
