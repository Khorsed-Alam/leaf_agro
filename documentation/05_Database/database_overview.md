# AgriCare AI — Database Overview

## 1. Relational Database Engine
AgriCare AI utilizes **PostgreSQL 15+** managed on Supabase Cloud. PostgreSQL provides enterprise-class ACID transactions, JSONB document querying, Row Level Security (RLS), custom triggers, and spatial scalability.

```mermaid
graph TD
    AUTH_U[auth.users] -->|1:1 Primary Key| PROFILES[public.profiles]
    PROFILES -->|1:N| FARMER_CROPS[public.farmer_crops]
    PROFILES -->|1:N| SCANS[public.disease_scans]
    PROFILES -->|1:N| OBS[public.plant_observations]
    PROFILES -->|1:N| NOTIF[public.notifications]
    PROFILES -->|1:N| FEED[public.feedback]

    CROPS[public.crops] -->|1:N| DISEASES[public.disease_catalog]
    DISEASES -->|1:N| RECOM[public.recommendations]
    SCANS -->|1:N| TREAT[public.treatment_history]
    SCANS -->|1:N| OBS
```

---

## 2. Dual-Persistence (Offline + Cloud Sync)
To support rural agricultural reality:
1. **Local SQLite Cache**: Stores local copies of the crop catalog, 19 disease profiles, local treatment guidelines, and the farmer's recent scans.
2. **Cloud PostgreSQL**: Acts as the authoritative source of truth when internet connectivity is active, synchronizing historical scans and backup observations.
