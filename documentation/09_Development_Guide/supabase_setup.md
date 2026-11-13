# AgriCare AI — Supabase Backend Setup Guide

## 1. Creating a New Supabase Project
1. Log in to your [Supabase Dashboard](https://supabase.com/dashboard).
2. Click **"New Project"**.
3. Choose an organization, enter **"AgriCare AI"** as the project name, and generate a strong database password.
4. Select the **Singapore (`ap-southeast-1`)** region for optimal latency to Bangladesh.

---

## 2. Running Migrations
Deploy the database schema using the Supabase CLI or the SQL Editor:
1. Navigate to the SQL Editor in your Supabase Dashboard.
2. Run the migration files sequentially from `supabase/migrations/`:
   - `001_initial_schema.sql`
   - `002_rls_policies.sql`
   - `003_seed_catalog.sql`
   - `004_storage_policies.sql`
   - `005_complete_backend_architecture.sql`
   - `006_plant_observations.sql`

---

## 3. Configuring Storage Buckets
Ensure the following three buckets are created and set to **Public**:
- `plant-images` (Max size: 10MB)
- `farmer-avatars` (Max size: 5MB)
- `disease-assets` (Max size: 10MB)
Verify that the storage policies in `004_storage_policies.sql` are active.

