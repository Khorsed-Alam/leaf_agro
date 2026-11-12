-- ====================================================================
-- AgriCare AI — Row Level Security (RLS) Policies
-- Migration: 002_rls_policies.sql
-- ====================================================================

-- Enable RLS across all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.crops ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.disease_catalog ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recommendations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.prediction_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.feedback ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- 1. PROFILES POLICIES
CREATE POLICY "Users can read own profile"
    ON public.profiles FOR SELECT
    TO authenticated
    USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
    ON public.profiles FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own profile"
    ON public.profiles FOR UPDATE
    TO authenticated
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

-- 2. CROPS CATALOG (Public Read-Only)
CREATE POLICY "Public read-only active crops"
    ON public.crops FOR SELECT
    TO anon, authenticated
    USING (is_active = true);

-- 3. DISEASE CATALOG (Public Read-Only)
CREATE POLICY "Public read-only disease catalog"
    ON public.disease_catalog FOR SELECT
    TO anon, authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.crops c
            WHERE c.id = crop_id AND c.is_active = true
        )
    );

-- 4. RECOMMENDATIONS (Public Read-Only verified recommendations)
CREATE POLICY "Public read-only recommendations"
    ON public.recommendations FOR SELECT
    TO anon, authenticated
    USING (is_verified = true);

-- 5. PREDICTION HISTORY (Strict User Ownership)
CREATE POLICY "Users can view own prediction history"
    ON public.prediction_history FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own predictions"
    ON public.prediction_history FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own predictions"
    ON public.prediction_history FOR DELETE
    TO authenticated
    USING (auth.uid() = user_id);

-- 6. FEEDBACK
CREATE POLICY "Users can submit feedback"
    ON public.feedback FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can read own feedback"
    ON public.feedback FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);

-- 7. NOTIFICATIONS
CREATE POLICY "Users can read own notifications"
    ON public.notifications FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);

CREATE POLICY "Users can update own notification read status"
    ON public.notifications FOR UPDATE
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

