# AgriCare AI — Row Level Security (RLS) Policies

## 1. Overview
Row Level Security (RLS) in PostgreSQL ensures that authenticated users can only view, modify, or delete their own data, while preventing unauthorized cross-tenant data leaks at the database engine layer.

```mermaid
graph TD
    REQ[Client Request: SELECT / INSERT / UPDATE / DELETE] --> RLS{PostgreSQL RLS Policy Engine}
    RLS -->|auth.uid() == user_id| ALLOW[Permit Execution & Return Data]
    RLS -->|auth.uid() != user_id| DENY[Block Execution & Raise 42501 / Empty Set]
```

---

## 2. Policy Definitions by Table

### A. Profiles (`public.profiles`)
- **Read**: Authenticated users can view their own profile.
  ```sql
  CREATE POLICY "Users can view own profile"
  ON public.profiles FOR SELECT TO authenticated
  USING (auth.uid() = id);
  ```
- **Update**: Authenticated users can update their own profile.
  ```sql
  CREATE POLICY "Users can update own profile"
  ON public.profiles FOR UPDATE TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);
  ```

### B. Disease Scans (`public.disease_scans`)
- **Read**: `auth.uid() = user_id`
- **Insert**: `auth.uid() = user_id`
- **Delete**: `auth.uid() = user_id`

### C. Plant Observations (`public.plant_observations`)
- **Read**: `auth.uid() = user_id`
- **Insert**: `auth.uid() = user_id`
- **Update**: `auth.uid() = user_id`

### D. Catalogs (`crops`, `disease_catalog`, `recommendations`)
- **Read**: Publicly readable by all authenticated and anonymous clients (`FOR SELECT USING (true)`).
- **Write**: Locked; restricted exclusively to PostgreSQL `service_role` administrator.

### E. Feedback & Notifications
- **Feedback Insert**: `auth.uid() = user_id`
- **Notifications Read / Update**: `auth.uid() = user_id`

