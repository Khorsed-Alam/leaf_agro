# AgriCare AI — API & Client Integration Documentation

## 1. Supabase Client Configuration
The mobile application communicates with Supabase PostgreSQL via the official `supabase_flutter` SDK over HTTPS with Row-Level Security (RLS) enforcement.

### Environment Parameters:
```dart
const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const String supabasePublishableKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
```

## 2. Key Data Endpoints
- **Authentication**:
  - `supabase.auth.signUp(email, password, data: {'full_name': name})`
  - `supabase.auth.signInWithPassword(email, password)`
  - `supabase.auth.signOut()`
- **Crops Catalog**:
  - `supabase.from('crops').select('*').eq('is_active', true)`
- **Disease & Recommendations**:
  - `supabase.from('disease_catalog').select('*, recommendations(*)').eq('class_name', predictedClass).single()`
- **Field Scan History**:
  - `supabase.from('prediction_history').insert({...})`
  - `supabase.from('prediction_history').select('*, disease_catalog(*)').order('created_at', ascending: false)`
- **Cloud Storage**:
  - `supabase.storage.from('plant-images').upload('<user_id>/<scan_id>.jpg', file)`

