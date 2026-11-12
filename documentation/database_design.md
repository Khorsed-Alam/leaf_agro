# AgriCare AI — Database Design (PostgreSQL & SQLite)

## 1. Cloud Database Schema (Supabase PostgreSQL)

```mermaid
erDiagram
    PROFILES ||--o{ PREDICTION_HISTORY : has
    PROFILES ||--o{ FEEDBACK : writes
    PROFILES ||--o{ NOTIFICATIONS : receives
    CROPS ||--o{ DISEASE_CATALOG : categorizes
    DISEASE_CATALOG ||--o{ RECOMMENDATIONS : provides
    DISEASE_CATALOG ||--o{ PREDICTION_HISTORY : classifies

    PROFILES {
        uuid id PK
        text full_name
        text phone
        text district
        text preferred_language
        text avatar_url
        timestamptz created_at
    }

    CROPS {
        bigint id PK
        text name_en
        text name_bn
        text description_en
        text description_bn
        text image_url
        boolean is_active
    }

    DISEASE_CATALOG {
        bigint id PK
        bigint crop_id FK
        text class_name
        text disease_name_en
        text disease_name_bn
        text symptoms_en
        text symptoms_bn
        boolean is_healthy
    }

    RECOMMENDATIONS {
        bigint id PK
        bigint disease_id FK
        text recommendation_type
        text title_en
        text title_bn
        text content_en
        text content_bn
        boolean is_verified
    }

    PREDICTION_HISTORY {
        uuid id PK
        uuid user_id FK
        bigint disease_id FK
        text predicted_class
        numeric confidence
        text image_path
        text model_version
        timestamptz created_at
    }
```

## 2. Local Database Schema (SQLite / Drift)
The local SQLite database mirrors `prediction_history` with an added `sync_status` (`pending`, `synced`, `failed`) column to ensure seamless offline resilience and zero data loss in rural agricultural environments.

