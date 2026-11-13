# AgriCare AI — Database Schema Specification

## 1. Schema Namespaces
The database structure is organized into two primary PostgreSQL schemas:
1. `auth`: Internal Supabase authentication schema managing cryptographic user identities, hashed passwords, and token sessions.
2. `public`: Application domain schema housing all agronomic catalogs, user profiles, detection histories, and recovery observation logs.

---

## 2. DDL Schema Definition (Consolidated)

```sql
-- Profiles Table
CREATE TABLE public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL DEFAULT 'Farmer',
    email TEXT,
    phone TEXT,
    phone_number TEXT,
    district TEXT,
    preferred_language TEXT NOT NULL DEFAULT 'en' CHECK (preferred_language IN ('en', 'bn')),
    role TEXT NOT NULL DEFAULT 'farmer' CHECK (role IN ('farmer', 'agronomist', 'admin')),
    avatar_url TEXT,
    terms_accepted_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Crops Catalog
CREATE TABLE public.crops (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name_en TEXT NOT NULL UNIQUE,
    name_bn TEXT NOT NULL,
    description_en TEXT,
    description_bn TEXT,
    image_url TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Disease Catalog (19 classes)
CREATE TABLE public.disease_catalog (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    crop_id BIGINT NOT NULL REFERENCES public.crops(id) ON DELETE CASCADE,
    class_name TEXT NOT NULL UNIQUE,
    disease_name_en TEXT NOT NULL,
    disease_name_bn TEXT NOT NULL,
    symptoms_en TEXT,
    symptoms_bn TEXT,
    causes_en TEXT,
    causes_bn TEXT,
    is_healthy BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Recommendations (Treatment, Prevention, Care)
CREATE TABLE public.recommendations (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    disease_id BIGINT NOT NULL REFERENCES public.disease_catalog(id) ON DELETE CASCADE,
    recommendation_type TEXT NOT NULL CHECK (recommendation_type IN ('treatment', 'prevention', 'care')),
    title_en TEXT NOT NULL,
    title_bn TEXT NOT NULL,
    content_en TEXT NOT NULL,
    content_bn TEXT NOT NULL,
    source_name TEXT,
    source_url TEXT,
    is_verified BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Farmer Crops
CREATE TABLE public.farmer_crops (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    crop_name TEXT NOT NULL,
    crop_variety TEXT,
    planting_date DATE,
    farm_location TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Disease Scans
CREATE TABLE public.disease_scans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    crop_id UUID REFERENCES public.farmer_crops(id) ON DELETE SET NULL,
    image_url TEXT NOT NULL,
    crop_name TEXT NOT NULL,
    detected_disease TEXT NOT NULL,
    confidence_score NUMERIC(5,4) NOT NULL CHECK (confidence_score >= 0 AND confidence_score <= 1),
    severity TEXT NOT NULL DEFAULT 'moderate' CHECK (severity IN ('low', 'moderate', 'high', 'critical')),
    detection_result JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Plant Observations (Longitudinal Recovery Checkpoints)
CREATE TABLE public.plant_observations (
    id TEXT PRIMARY KEY,
    scan_id TEXT NOT NULL,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    crop_name TEXT,
    condition_label TEXT NOT NULL CHECK (condition_label IN ('better', 'no_change', 'worse', 'not_sure')),
    notes TEXT NOT NULL,
    image_path TEXT,
    next_inspection_date TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Notifications
CREATE TABLE public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- User Feedback
CREATE TABLE public.feedback (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    rating INTEGER CHECK (rating BETWEEN 1 AND 5),
    category TEXT,
    message TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```
