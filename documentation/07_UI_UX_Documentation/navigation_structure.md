# AgriCare AI — Navigation Structure

## 1. Declarative Routing Architecture
AgriCare AI utilizes `go_router` 14.x for centralized declarative routing. All screen paths, path parameters (`:id`), and query parameters (`?scanId=...`) are mapped directly in `lib/core/router/app_router.dart`.

![AgriCare AI Complete Flowchart](../images/agricare_ai_user_flow_00_30.png)

```mermaid
graph TD
    ROOT[/splash] --> ONB[/onboarding]
    ROOT --> AUTH[/login]
    AUTH --> REG[/register]
    AUTH --> FORGOT[/forgot-password]

    ROOT --> HOME[/home]
    HOME --> CROPS[/crops]
    CROPS --> CROP_D[/crops/:id]
    HOME --> CROP_SEL[/crop-select]
    HOME --> DIS[/diseases]
    DIS --> DIS_D[/diseases/:id]
    HOME --> SEARCH[/search]

    HOME --> DETECT[/detect]
    DETECT --> CAM[/detect/camera]
    DETECT --> GAL[/detect/gallery]
    DETECT --> PREV[/detect/preview]
    DETECT --> ANA[/detect/analyzing]
    DETECT --> RES[/detect/result]

    RES --> TREAT[/recommendations/:id]
    RES --> PREV_S[/prevention]
    RES --> SOL[/solutions]
    RES --> RECOV[/recovery]

    HOME --> HIST[/history]
    HIST --> HIST_F[/history/filter]
    HIST --> HIST_D[/history/:id]
    HIST_D --> RECOV

    HOME --> PROF[/profile]
    PROF --> EDIT_P[/profile/edit]
    PROF --> SETT[/settings]
    SETT --> LANG[/settings/language]

    HOME --> NOTIF[/notifications]
    HOME --> HELP[/help]
    HOME --> FEED[/feedback]
    HOME --> ABOUT[/about]
```

---

## 2. Parameter Contracts & Guards
- **Typed Navigation Parameters**:
  - `/crops/:id`: ID integer (e.g., `1` for Rice).
  - `/diseases/:id`: ID integer (e.g., `101` for Rice Bacterial Leaf Blight).
  - `/recommendations/:id`: Disease ID integer.
  - `/history/:id`: Scan UUID string.
  - `/recovery?scanId=...`: Optional scan UUID query parameter.
  - `/feedback?category=...`: Optional preselected category query parameter.
  - `/search?q=...`: Optional search query string.
- **Deep Linking**: All routes are structured to support Android deep links (e.g., `agricare://leafagro/diseases/101`).
- **Error Page**: Unknown routes are caught by GoRouter's `errorBuilder` and redirected gracefully to `/home`.

