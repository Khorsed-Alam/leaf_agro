# AgriCare AI — Tables and Columns Dictionary

## 1. Data Dictionary

### Table: `public.profiles`
Represents the farmer or agronomist user profile extending `auth.users`.
- `id` (UUID, PK): References `auth.users(id)` ON DELETE CASCADE.
- `full_name` (TEXT, NOT NULL, DEFAULT 'Farmer'): User's display name.
- `email` (TEXT, NULLABLE): Synced from auth user account.
- `phone` / `phone_number` (TEXT, NULLABLE): Bangladeshi mobile contact number.
- `district` (TEXT, NULLABLE): Home district in Bangladesh (e.g., Bogura, Rajshahi, Rangpur).
- `preferred_language` (TEXT, NOT NULL, DEFAULT 'en'): Language preference (`'en'` or `'bn'`).
- `role` (TEXT, NOT NULL, DEFAULT 'farmer'): Access role (`'farmer'`, `'agronomist'`, `'admin'`).
- `avatar_url` (TEXT, NULLABLE): URL path to profile picture in `farmer-avatars` bucket.
- `terms_accepted_at` (TIMESTAMPTZ, NULLABLE): Timestamp when terms were accepted.
- `created_at` / `updated_at` (TIMESTAMPTZ, NOT NULL, DEFAULT now()).

---

### Table: `public.crops`
Agricultural catalog of supported crops.
- `id` (BIGINT, PK): Identity autoincrementing ID.
- `name_en` (TEXT, NOT NULL, UNIQUE): English crop name (e.g., "Rice", "Potato").
- `name_bn` (TEXT, NOT NULL): Bengali crop name (e.g., "ধান", "আলু").
- `description_en` / `description_bn` (TEXT): Agronomic summaries.
- `image_url` (TEXT): Public URL of crop illustration.
- `is_active` (BOOLEAN, NOT NULL, DEFAULT true): Active catalog status.

---

### Table: `public.disease_catalog`
Encyclopedia of 19 disease and healthy conditions.
- `id` (BIGINT, PK): Primary key.
- `crop_id` (BIGINT, FK): References `public.crops(id)` ON DELETE CASCADE.
- `class_name` (TEXT, NOT NULL, UNIQUE): Exact class label matching `labels.json`.
- `disease_name_en` (TEXT, NOT NULL): English common name.
- `disease_name_bn` (TEXT, NOT NULL): Bengali common name.
- `symptoms_en` / `symptoms_bn` (TEXT): Pathological symptoms.
- `causes_en` / `causes_bn` (TEXT): Causal fungal/bacterial vectors.
- `is_healthy` (BOOLEAN, NOT NULL, DEFAULT false): True for healthy leaf classes.

---

### Table: `public.disease_scans`
Stores all AI disease diagnosis history records.
- `id` (UUID, PK): Auto-generated unique identifier.
- `user_id` (UUID, FK): References `public.profiles(id)` ON DELETE CASCADE.
- `crop_id` (UUID, FK, NULLABLE): Optional association to `public.farmer_crops(id)`.
- `image_url` (TEXT, NOT NULL): Public URL of the photographed leaf in `plant-images`.
- `crop_name` (TEXT, NOT NULL): Crop name at scan time.
- `detected_disease` (TEXT, NOT NULL): Human-readable disease prediction name.
- `confidence_score` (NUMERIC(5,4), NOT NULL): Model confidence between $0.0000$ and $1.0000$.
- `severity` (TEXT, NOT NULL, DEFAULT 'moderate'): `'low'`, `'moderate'`, `'high'`, or `'critical'`.
- `detection_result` (JSONB, NULLABLE): Complete inference result containing top-3 class probabilities.
- `created_at` (TIMESTAMPTZ, NOT NULL, DEFAULT now()).

---

### Table: `public.plant_observations`
Longitudinal recovery tracking entries for Screen 21.
- `id` (TEXT, PK): Unique string identifier.
- `scan_id` (TEXT, NOT NULL): Reference to associated scan.
- `user_id` (UUID, FK): References `public.profiles(id)` ON DELETE CASCADE.
- `crop_name` (TEXT, NULLABLE): Name of observed crop.
- `condition_label` (TEXT, NOT NULL): Observation checkpoint: `'better'`, `'no_change'`, `'worse'`, or `'not_sure'`.
- `notes` (TEXT, NOT NULL): Farmer's subjective field notes.
- `image_path` (TEXT, NULLABLE): Optional follow-up photo path.
- `next_inspection_date` (TIMESTAMPTZ, NULLABLE): Scheduled follow-up inspection date.
- `created_at` / `updated_at` (TIMESTAMPTZ, NOT NULL, DEFAULT now()).
