# AgriCare AI — Architectural Decision Records (ADRs)

## 1. Summary of Architectural Decisions

| ADR ID | Decision Title | Status | Primary Driver |
| :--- | :--- | :--- | :--- |
| **ADR-01** | Edge ML Inference vs. Cloud-Only Vision API | **Accepted** | Offline field availability in rural Bangladesh |
| **ADR-02** | Riverpod 2.x for State Management | **Accepted** | Compile-time safety, testability, no BuildContext dependency |
| **ADR-03** | GoRouter 14.x Declarative Routing | **Accepted** | Deep linking, typed route arguments, sub-route scoping |
| **ADR-04** | Supabase as Cloud Backend (BaaS) | **Accepted** | Integrated PostgreSQL, Row Level Security, instant setup |
| **ADR-05** | Separation of Recovery Logs from Diagnostics | **Accepted** | Scientific honesty; prevention of fabricated recovery claims |

---

## 2. Detailed Decision Records

### ADR-01: Edge ML Inference vs. Cloud-Only Vision API
- **Context**: Rural farmlands in Bangladesh experience frequent network drops and high mobile data costs for marginal farmers.
- **Decision**: Embed the lightweight MobileNetV2 TensorFlow Lite model directly inside the app bundle and execute inference on the client CPU/NPU.
- **Consequences**:
  - *Positive*: Zero network latency; 100% functional without cellular connection; zero recurring inference server costs.
  - *Negative*: Model updates require an application update (or dynamic asset bundle download); mobile app size is slightly larger (~15-20 MB).

### ADR-02: Riverpod 2.x for State Management
- **Context**: Complex multi-step flows (detection pipeline, recovery checkpoints, global search) require state that persists across screen transitions and permits straightforward mocking during automated tests.
- **Decision**: Adopt Riverpod 2.x with `StateNotifierProvider` and `FutureProvider`.
- **Consequences**:
  - *Positive*: Independent of widget tree; compile-time safe; trivial to override providers in unit and widget tests.
  - *Negative*: Learning curve for team members accustomed to standard `setState` or basic `Provider`.

### ADR-03: GoRouter 14.x Declarative Routing
- **Context**: Screen navigation requires explicit URI pathways, path parameters (`/crops/:id`), query parameters (`?scanId=...`), and reliable back-stack handling across 31 screens.
- **Decision**: Standardize on `go_router` 14.x.
- **Consequences**:
  - *Positive*: Declarative, unified router table; easy web/deep-linking support; robust error boundaries.

### ADR-04: Supabase as Cloud Backend
- **Context**: Needed an enterprise-grade relational database with built-in auth, file storage, and fine-grained access control without maintaining custom server software.
- **Decision**: Use Supabase managed PostgreSQL with Row Level Security (RLS).
- **Consequences**:
  - *Positive*: Native PostgreSQL support; rapid development; enterprise security policies directly enforced in SQL.
  - *Negative*: Dependent on Supabase cloud availability when performing online synchronization.

### ADR-05: Separation of Recovery Logs from Diagnostics
- **Context**: Farmers need to monitor treated crops over time. However, automated systems that assume a plant is "cured" after 7 days without re-scanning are scientifically inaccurate and dangerous.
- **Decision**: Implement Screen 21 (Recovery & Follow-up) as an observational journal (`plant_observations`) with an explicit "Scan Again" CTA, forbidding any automated calculation of disease eradication.
- **Consequences**:
  - *Positive*: Upholds academic integrity; protects farmers from premature cessation of necessary plant care.
