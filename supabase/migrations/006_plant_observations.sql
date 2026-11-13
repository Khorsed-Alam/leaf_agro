-- ====================================================================
-- AgriCare AI — Plant Observations & Recovery Follow-up Schema
-- Migration: 006_plant_observations.sql
-- Supports Screen 21 (Plant Recovery & Follow-up)
-- ====================================================================

-- 1. PLANT OBSERVATIONS TABLE
-- Stores farmer-reported visual observations and condition changes over time
CREATE TABLE IF NOT EXISTS public.plant_observations (
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

-- 2. INDEXES FOR PERFORMANCE
CREATE INDEX IF NOT EXISTS idx_plant_observations_scan_id
ON public.plant_observations(scan_id);

CREATE INDEX IF NOT EXISTS idx_plant_observations_user_id
ON public.plant_observations(user_id);

CREATE INDEX IF NOT EXISTS idx_plant_observations_created_at
ON public.plant_observations(created_at DESC);

-- 3. ROW LEVEL SECURITY (RLS)
ALTER TABLE public.plant_observations ENABLE ROW LEVEL SECURITY;

-- Allow farmers to view only their own observations
DROP POLICY IF EXISTS "Farmers can view their own observations" ON public.plant_observations;
CREATE POLICY "Farmers can view their own observations"
ON public.plant_observations
FOR SELECT
USING (auth.uid() = user_id);

-- Allow farmers to insert their own observations
DROP POLICY IF EXISTS "Farmers can insert their own observations" ON public.plant_observations;
CREATE POLICY "Farmers can insert their own observations"
ON public.plant_observations
FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Allow farmers to update their own observations
DROP POLICY IF EXISTS "Farmers can update their own observations" ON public.plant_observations;
CREATE POLICY "Farmers can update their own observations"
ON public.plant_observations
FOR UPDATE
USING (auth.uid() = user_id);

