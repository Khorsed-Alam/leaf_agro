# AgriCare AI — Entity-Relationship Diagram (ERD)

## 1. Complete Entity-Relationship Diagram
The following Crow's Foot ERD maps all entities, primary keys (PK), foreign keys (FK), and cardinality relationships across the AgriCare AI database.

```mermaid
erDiagram
    PROFILES ||--o{ FARMER_CROPS : "grows"
    PROFILES ||--o{ DISEASE_SCANS : "scans"
    PROFILES ||--o{ PLANT_OBSERVATIONS : "records"
    PROFILES ||--o{ NOTIFICATIONS : "receives"
    PROFILES ||--o{ FEEDBACK : "submits"

    CROPS ||--|{ DISEASE_CATALOG : "has"
    DISEASE_CATALOG ||--|{ RECOMMENDATIONS : "provides"

    FARMER_CROPS ||--o{ DISEASE_SCANS : "associates"
    DISEASE_SCANS ||--o{ TREATMENT_HISTORY : "tracks"
    DISEASE_SCANS ||--o{ PLANT_OBSERVATIONS : "monitors"

    PROFILES {
        uuid id PK
        text full_name
        text email
        text phone_number
        text district
        text preferred_language
        text role
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

    FARMER_CROPS {
        uuid id PK
        uuid user_id FK
        text crop_name
        text crop_variety
        date planting_date
        text farm_location
    }

    DISEASE_SCANS {
        uuid id PK
        uuid user_id FK
        uuid crop_id FK
        text image_url
        text crop_name
        text detected_disease
        numeric confidence_score
        text severity
        jsonb detection_result
        timestamptz created_at
    }

    TREATMENT_HISTORY {
        uuid id PK
        uuid user_id FK
        uuid scan_id FK
        text treatment_name
        text treatment_description
        jsonb prevention_tips
        timestamptz created_at
    }

    PLANT_OBSERVATIONS {
        text id PK
        text scan_id FK
        uuid user_id FK
        text condition_label
        text notes
        text image_path
        timestamptz next_inspection_date
        timestamptz created_at
    }

    NOTIFICATIONS {
        uuid id PK
        uuid user_id FK
        text title
        text message
        boolean is_read
        timestamptz created_at
    }

    FEEDBACK {
        uuid id PK
        uuid user_id FK
        integer rating
        text category
        text message
        timestamptz created_at
    }
```

