
-- ====================================================================
-- AgriCare AI — Complete Supabase Backend Architecture
-- Migration: 005_complete_backend_architecture.sql
-- Corrected and made rerunnable
-- ====================================================================

-- 1. PROFILES ENHANCEMENT
ALTER TABLE public.profiles
    ADD COLUMN IF NOT EXISTS email TEXT,
    ADD COLUMN IF NOT EXISTS phone_number TEXT,
    ADD COLUMN IF NOT EXISTS role TEXT NOT NULL DEFAULT 'farmer',
    ADD COLUMN IF NOT EXISTS terms_accepted_at TIMESTAMPTZ;

-- Add role constraint safely
ALTER TABLE public.profiles
DROP CONSTRAINT IF EXISTS profiles_role_check;

ALTER TABLE public.profiles
ADD CONSTRAINT profiles_role_check
CHECK (role IN ('farmer', 'agronomist', 'admin'));

-- Sync phone numbers
UPDATE public.profiles
SET phone_number = phone
WHERE phone_number IS NULL
AND phone IS NOT NULL;

-- Automatic profile creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    INSERT INTO public.profiles (
        id,
        full_name,
        email,
        phone_number,
        preferred_language,
        role,
        terms_accepted_at,
        created_at,
        updated_at
    )
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data ->> 'full_name', 'Farmer'),
        NEW.email,
        NEW.raw_user_meta_data ->> 'phone_number',
        COALESCE(NEW.raw_user_meta_data ->> 'preferred_language', 'en'),
        'farmer',
        COALESCE(
            (NEW.raw_user_meta_data ->> 'terms_accepted_at')::timestamptz,
            now()
        ),
        now(),
        now()
    )
    ON CONFLICT (id) DO UPDATE SET
        full_name = EXCLUDED.full_name,
        email = COALESCE(EXCLUDED.email, profiles.email),
        phone_number = COALESCE(EXCLUDED.phone_number, profiles.phone_number),
        updated_at = now();

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW
EXECUTE FUNCTION public.handle_new_user();


-- 2. PREVENT ROLE ESCALATION
CREATE OR REPLACE FUNCTION public.prevent_role_escalation()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    IF NEW.role IS DISTINCT FROM OLD.role
       AND COALESCE(auth.jwt() ->> 'role', '') <> 'service_role'
    THEN
        RAISE EXCEPTION 'Role escalation is not permitted';
    END IF;

    NEW.updated_at = now();
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_prevent_role_escalation
ON public.profiles;

CREATE TRIGGER trg_prevent_role_escalation
BEFORE UPDATE ON public.profiles
FOR EACH ROW
EXECUTE FUNCTION public.prevent_role_escalation();


-- 3. FARMER CROPS TABLE
CREATE TABLE IF NOT EXISTS public.farmer_crops (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    crop_name TEXT NOT NULL,
    crop_variety TEXT,
    planting_date DATE,
    farm_location TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_farmer_crops_user_id
ON public.farmer_crops(user_id);


-- 4. DISEASE SCANS TABLE
CREATE TABLE IF NOT EXISTS public.disease_scans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    crop_id UUID REFERENCES public.farmer_crops(id) ON DELETE SET NULL,
    image_url TEXT NOT NULL,
    crop_name TEXT NOT NULL,
    detected_disease TEXT NOT NULL,
    confidence_score NUMERIC(5,4) NOT NULL
        CHECK (confidence_score >= 0 AND confidence_score <= 1),
    severity TEXT NOT NULL DEFAULT 'moderate'
        CHECK (severity IN ('low', 'moderate', 'high', 'critical')),
    detection_result JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_disease_scans_user_id
ON public.disease_scans(user_id);

CREATE INDEX IF NOT EXISTS idx_disease_scans_created_at
ON public.disease_scans(created_at DESC);


-- 5. TREATMENT HISTORY TABLE
CREATE TABLE IF NOT EXISTS public.treatment_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    scan_id UUID NOT NULL REFERENCES public.disease_scans(id) ON DELETE CASCADE,
    treatment_name TEXT NOT NULL,
    treatment_description TEXT NOT NULL,
    prevention_tips JSONB NOT NULL DEFAULT '[]'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_treatment_history_scan_id
ON public.treatment_history(scan_id);

CREATE INDEX IF NOT EXISTS idx_treatment_history_user_id
ON public.treatment_history(user_id);


-- 6. NOTIFICATIONS TABLE
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- IMPORTANT FIX:
-- Add missing columns if notifications table already existed.
ALTER TABLE public.notifications
    ADD COLUMN IF NOT EXISTS is_read BOOLEAN NOT NULL DEFAULT false,
    ADD COLUMN IF NOT EXISTS title TEXT,
    ADD COLUMN IF NOT EXISTS message TEXT,
    ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE;

CREATE INDEX IF NOT EXISTS idx_notifications_user_id_read
ON public.notifications(user_id, is_read);


-- 7. FEEDBACK TABLE
CREATE TABLE IF NOT EXISTS public.feedback (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    rating INTEGER CHECK (rating BETWEEN 1 AND 5),
    message TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_feedback_user_id
ON public.feedback(user_id);


-- 8. ENABLE ROW LEVEL SECURITY
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.farmer_crops ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.disease_scans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.treatment_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.feedback ENABLE ROW LEVEL SECURITY;


-- 9. FARMER CROPS POLICIES
DROP POLICY IF EXISTS "Users can view own farmer crops" ON public.farmer_crops;
DROP POLICY IF EXISTS "Users can insert own farmer crops" ON public.farmer_crops;
DROP POLICY IF EXISTS "Users can update own farmer crops" ON public.farmer_crops;
DROP POLICY IF EXISTS "Users can delete own farmer crops" ON public.farmer_crops;

CREATE POLICY "Users can view own farmer crops"
ON public.farmer_crops FOR SELECT TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own farmer crops"
ON public.farmer_crops FOR INSERT TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own farmer crops"
ON public.farmer_crops FOR UPDATE TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own farmer crops"
ON public.farmer_crops FOR DELETE TO authenticated
USING (auth.uid() = user_id);


-- 10. DISEASE SCANS POLICIES
DROP POLICY IF EXISTS "Users can view own disease scans" ON public.disease_scans;
DROP POLICY IF EXISTS "Users can insert own disease scans" ON public.disease_scans;
DROP POLICY IF EXISTS "Users can delete own disease scans" ON public.disease_scans;

CREATE POLICY "Users can view own disease scans"
ON public.disease_scans FOR SELECT TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own disease scans"
ON public.disease_scans FOR INSERT TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own disease scans"
ON public.disease_scans FOR DELETE TO authenticated
USING (auth.uid() = user_id);


-- 11. TREATMENT HISTORY POLICIES
DROP POLICY IF EXISTS "Users can view own treatment history" ON public.treatment_history;
DROP POLICY IF EXISTS "Users can insert own treatment history" ON public.treatment_history;

CREATE POLICY "Users can view own treatment history"
ON public.treatment_history FOR SELECT TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own treatment history"
ON public.treatment_history FOR INSERT TO authenticated
WITH CHECK (auth.uid() = user_id);


-- 12. NOTIFICATIONS POLICIES
DROP POLICY IF EXISTS "Users can read own notifications" ON public.notifications;
DROP POLICY IF EXISTS "Users can update own notification read status" ON public.notifications;

CREATE POLICY "Users can read own notifications"
ON public.notifications FOR SELECT TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Users can update own notification read status"
ON public.notifications FOR UPDATE TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);


-- 13. FEEDBACK POLICIES
DROP POLICY IF EXISTS "Users can submit feedback" ON public.feedback;
DROP POLICY IF EXISTS "Users can read own feedback" ON public.feedback;

CREATE POLICY "Users can submit feedback"
ON public.feedback FOR INSERT TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can read own feedback"
ON public.feedback FOR SELECT TO authenticated
USING (auth.uid() = user_id);


-- 14. STORAGE BUCKETS
INSERT INTO storage.buckets (
    id,
    name,
    public,
    file_size_limit,
    allowed_mime_types
)
VALUES
(
    'profile-images',
    'profile-images',
    true,
    5242880,
    ARRAY['image/jpeg', 'image/png', 'image/webp']
),
(
    'disease-images',
    'disease-images',
    false,
    15728640,
    ARRAY['image/jpeg', 'image/png', 'image/webp']
)
ON CONFLICT (id) DO NOTHING;


-- 15. STORAGE POLICIES
DROP POLICY IF EXISTS "Public can view profile images" ON storage.objects;
DROP POLICY IF EXISTS "Users can upload their own profile image" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their own profile image" ON storage.objects;
DROP POLICY IF EXISTS "Users can upload their own disease scan images" ON storage.objects;
DROP POLICY IF EXISTS "Users can view their own disease scan images" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own disease scan images" ON storage.objects;

CREATE POLICY "Public can view profile images"
ON storage.objects FOR SELECT TO anon, authenticated
USING (bucket_id = 'profile-images');

CREATE POLICY "Users can upload their own profile image"
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (
    bucket_id = 'profile-images'
    AND (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Users can update their own profile image"
ON storage.objects FOR UPDATE TO authenticated
USING (
    bucket_id = 'profile-images'
    AND (storage.foldername(name))[1] = auth.uid()::text
)
WITH CHECK (
    bucket_id = 'profile-images'
    AND (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Users can upload their own disease scan images"
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (
    bucket_id = 'disease-images'
    AND (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Users can view their own disease scan images"
ON storage.objects FOR SELECT TO authenticated
USING (
    bucket_id = 'disease-images'
    AND (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Users can delete their own disease scan images"
ON storage.objects FOR DELETE TO authenticated
USING (
    bucket_id = 'disease-images'
    AND (storage.foldername(name))[1] = auth.uid()::text
);

-- ====================================================================
-- MIGRATION COMPLETE
-- ====================================================================
