-- ====================================================================
-- AgriCare AI — Initial PostgreSQL Schema
-- Migration: 001_initial_schema.sql
-- ====================================================================

-- 1. USER PROFILES
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT,
    phone TEXT,
    district TEXT,
    preferred_language TEXT NOT NULL DEFAULT 'en' CHECK (preferred_language IN ('en', 'bn')),
    avatar_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Trigger to create profile when new auth.users record is inserted
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
BEGIN
    INSERT INTO public.profiles (id, full_name)
    VALUES (new.id, new.raw_user_meta_data ->> 'full_name');
    RETURN new;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 2. CROPS CATALOG
CREATE TABLE IF NOT EXISTS public.crops (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name_en TEXT NOT NULL UNIQUE,
    name_bn TEXT NOT NULL,
    description_en TEXT,
    description_bn TEXT,
    image_url TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3. DISEASE CATALOG
CREATE TABLE IF NOT EXISTS public.disease_catalog (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    crop_id BIGINT NOT NULL REFERENCES public.crops(id) ON DELETE CASCADE,
    class_name TEXT NOT NULL UNIQUE, -- matches AI model labels.json exactly
    disease_name_en TEXT NOT NULL,
    disease_name_bn TEXT NOT NULL,
    symptoms_en TEXT,
    symptoms_bn TEXT,
    causes_en TEXT,
    causes_bn TEXT,
    is_healthy BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 4. RECOMMENDATIONS (Treatment, Prevention, Care)
CREATE TABLE IF NOT EXISTS public.recommendations (
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

-- 5. PREDICTION HISTORY
CREATE TABLE IF NOT EXISTS public.prediction_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    disease_id BIGINT REFERENCES public.disease_catalog(id) ON DELETE SET NULL,
    predicted_class TEXT NOT NULL,
    confidence NUMERIC(6,5) NOT NULL CHECK (confidence >= 0 AND confidence <= 1),
    image_path TEXT,
    model_version TEXT NOT NULL DEFAULT '1.0.0',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 6. USER FEEDBACK
CREATE TABLE IF NOT EXISTS public.feedback (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    rating INTEGER CHECK (rating BETWEEN 1 AND 5),
    category TEXT,
    message TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 7. NOTIFICATIONS
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title_en TEXT NOT NULL,
    title_bn TEXT NOT NULL,
    message_en TEXT,
    message_bn TEXT,
    read_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- INDEXES FOR FAST QUERYING
CREATE INDEX IF NOT EXISTS idx_disease_crop ON public.disease_catalog(crop_id);
CREATE INDEX IF NOT EXISTS idx_disease_class_name ON public.disease_catalog(class_name);
CREATE INDEX IF NOT EXISTS idx_recommendation_disease ON public.recommendations(disease_id);
CREATE INDEX IF NOT EXISTS idx_history_user_date ON public.prediction_history(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_feedback_user ON public.feedback(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user_date ON public.notifications(user_id, created_at DESC);

