-- ====================================================================
-- AgriCare AI — Supabase Storage Buckets & Policies
-- Migration: 004_storage_policies.sql
-- ====================================================================

-- Create buckets for leaf scan uploads and user avatars
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES 
    ('plant-images', 'plant-images', false, 10485760, ARRAY['image/jpeg', 'image/png', 'image/webp']),
    ('user-avatars', 'user-avatars', true, 5242880, ARRAY['image/jpeg', 'image/png'])
ON CONFLICT (id) DO NOTHING;

-- STORAGE POLICIES: plant-images
-- User can upload images strictly into their own folder: <bucket>/<user_id>/<filename>
CREATE POLICY "Users can upload their own leaf images"
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (
    bucket_id = 'plant-images' AND
    (storage.foldername(name))[1] = auth.uid()::text
);

-- User can view their own leaf images
CREATE POLICY "Users can view their own leaf images"
ON storage.objects FOR SELECT TO authenticated
USING (
    bucket_id = 'plant-images' AND
    (storage.foldername(name))[1] = auth.uid()::text
);

-- User can delete their own leaf images
CREATE POLICY "Users can delete their own leaf images"
ON storage.objects FOR DELETE TO authenticated
USING (
    bucket_id = 'plant-images' AND
    (storage.foldername(name))[1] = auth.uid()::text
);

-- STORAGE POLICIES: user-avatars (Public Read, Owner Write)
CREATE POLICY "Public can view avatars"
ON storage.objects FOR SELECT TO anon, authenticated
USING (bucket_id = 'user-avatars');

CREATE POLICY "Users can upload own avatar"
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (
    bucket_id = 'user-avatars' AND
    (storage.foldername(name))[1] = auth.uid()::text
);

