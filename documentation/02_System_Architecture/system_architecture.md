# AgriCare AI — System Architecture

## 1. High-Level Architecture
The **AgriCare AI (LeafAgro)** system follows a hybrid offline-first, client-server edge computing architecture. By decoupling on-device computer vision inference from cloud data synchronization, the system guarantees that farmers can inspect damaged crops in remote locations without network connectivity.

```mermaid
graph TB
    subgraph Client_Device [Android Smartphone - Field Environment]
        subgraph UI_Layer [Presentation Layer: Material 3 UI]
            S01[Screens 00-05: Auth & Onboarding]
            S06[Screens 06-10: Dashboard & Catalog]
            S11[Screens 11-16: Camera & AI Detection]
            S17[Screens 17-20: Remedies & Products]
            S21[Screens 21-23: History & Recovery]
            S24[Screens 24-30: Profile & Support]
        end

        subgraph Core_Layer [Domain & State Management: Riverpod 2.5]
            RP[State Notifiers & Providers]
            TS[TFLite Vision Service]
            IMG[Image Processing Pipeline]
        end

        subgraph Offline_Cache [Local Storage Layer]
            SP[Shared Preferences: Settings & Session]
            SQL[SQLite Database: Local Scans & Cache]
            FS[App Sandbox File Storage: Images]
        end
    end

    subgraph Cloud_Infrastructure [Supabase Cloud BaaS]
        AUTH[Supabase GoTrue Auth]
        REST[PostgREST Auto-Generated API]
        STORAGE[S3-Compatible Cloud Storage]
        DB[(PostgreSQL 15 Database + RLS)]
    end

    UI_Layer --> Core_Layer
    Core_Layer --> TS
    Core_Layer --> IMG
    Core_Layer --> Offline_Cache

    Core_Layer -.->|Sync when online| AUTH
    Core_Layer -.->|Sync when online| REST
    Core_Layer -.->|Upload photos| STORAGE
    REST --> DB
    AUTH --> DB
```

---

## 2. Core Architectural Principles

### A. Offline-First Mandate
- Deep learning inference operates strictly on the local hardware through `tflite_flutter` using native C++ TFLite runtime bindings.
- Seed catalogs (crops, diseases, treatments, prevention protocols, registered solutions) are stored directly inside local assets (`assets/translations/`, local mock databases) as well as cached in SQLite.
- When an internet connection is unavailable, the user can capture or upload images, perform complete disease analysis, view multi-tier treatments, and record observations without encountering blocking dialogs or errors.

### B. Unidirectional Data Flow (UDF)
- User interactions emit intents to Riverpod `StateNotifier` controllers.
- Notifiers communicate with domain repositories and mutate state in an immutable fashion.
- The UI listens reactively to provider states using `ref.watch()`, preventing race conditions, stale UI renders, or inconsistent back-stack transitions.

### C. Zero-Trust Security at the Edge
- The client app never possesses elevated database credentials.
- All database operations are mediated via Supabase PostgreSQL Row Level Security (RLS) policies locked to the authenticated user's JWT `auth.uid()`.
- Client role escalation is prevented at the database trigger layer (`prevent_role_escalation` trigger).
