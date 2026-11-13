# AgriCare AI — Notification Flow

## 1. Notification Center Flow
Covers how notifications are viewed, filtered, and marked as read on Screen 27 (Notifications Screen).

```mermaid
sequenceDiagram
    autonumber
    actor Farmer as Farmer
    participant Home as Screen 06: Home Dashboard
    participant Notif as Screen 27: Notifications Screen
    participant DB as PostgreSQL (notifications table)

    Home->>Home: Display unread badge count on Bell icon
    Farmer->>Home: Tap Bell icon in header
    Home->>Notif: Navigate to /notifications
    Notif->>DB: Query notifications for current user
    DB-->>Notif: Return notification items
    Notif-->>Farmer: Render chronological list with unread indicators

    alt Mark Single as Read
        Farmer->>Notif: Tap specific notification tile
        Notif->>DB: PATCH /notifications?id=eq.id (is_read=true)
        Notif-->>Farmer: Update badge & dim background
    else Mark All as Read
        Farmer->>Notif: Tap "Mark all as read" in AppBar
        Notif->>DB: PATCH /notifications?user_id=eq.uid (is_read=true)
        Notif-->>Farmer: Clear all unread badges
    end
```

---

## 2. Integrity Rule for Notifications
AgriCare AI only displays authentic notifications triggered by real application events:
- Completed offline/online scan confirmations.
- Observation checkpoint reminders for treated plants.
- Account updates and verified agronomic alerts.
Fabricated or simulated marketing notifications are strictly prohibited.
