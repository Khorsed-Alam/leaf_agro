# AgriCare AI — Database Indexes and Triggers

## 1. Performance Indexes
PostgreSQL B-tree indexes are strategically established on foreign keys, user identities, and descending timestamp fields to accelerate common farmer dashboard queries.

```sql
-- Indexes on Disease Scans
CREATE INDEX IF NOT EXISTS idx_disease_scans_user_id ON public.disease_scans(user_id);
CREATE INDEX IF NOT EXISTS idx_disease_scans_created_at ON public.disease_scans(created_at DESC);

-- Indexes on Plant Observations (Recovery Checks)
CREATE INDEX IF NOT EXISTS idx_plant_observations_scan_id ON public.plant_observations(scan_id);
CREATE INDEX IF NOT EXISTS idx_plant_observations_user_id ON public.plant_observations(user_id);
CREATE INDEX IF NOT EXISTS idx_plant_observations_created_at ON public.plant_observations(created_at DESC);

-- Indexes on Farmer Crops & Treatments
CREATE INDEX IF NOT EXISTS idx_farmer_crops_user_id ON public.farmer_crops(user_id);
CREATE INDEX IF NOT EXISTS idx_treatment_history_scan_id ON public.treatment_history(scan_id);
CREATE INDEX IF NOT EXISTS idx_treatment_history_user_id ON public.treatment_history(user_id);

-- Indexes on Notifications & Feedback
CREATE INDEX IF NOT EXISTS idx_notifications_user_id_read ON public.notifications(user_id, is_read);
CREATE INDEX IF NOT EXISTS idx_feedback_user_id ON public.feedback(user_id);
```

---

## 2. Automated PostgreSQL Triggers

### A. Automatic Profile Provisioning (`on_auth_user_created`)
When a new user signs up through Supabase GoTrue Auth, this trigger automatically populates a default farmer profile in `public.profiles`:
```sql
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
    INSERT INTO public.profiles (
        id, full_name, email, phone_number, preferred_language, role, terms_accepted_at, created_at, updated_at
    )
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data ->> 'full_name', 'Farmer'),
        NEW.email,
        NEW.raw_user_meta_data ->> 'phone_number',
        COALESCE(NEW.raw_user_meta_data ->> 'preferred_language', 'en'),
        'farmer',
        COALESCE((NEW.raw_user_meta_data ->> 'terms_accepted_at')::timestamptz, now()),
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

CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
```

### B. Security Role Escalation Guard (`trg_prevent_role_escalation`)
Prevents authenticated farmers from tampering with the `role` column to claim administrative privileges:
```sql
CREATE OR REPLACE FUNCTION public.prevent_role_escalation()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
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

CREATE TRIGGER trg_prevent_role_escalation
BEFORE UPDATE ON public.profiles
FOR EACH ROW EXECUTE FUNCTION public.prevent_role_escalation();
```

