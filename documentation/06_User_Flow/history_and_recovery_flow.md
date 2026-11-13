# AgriCare AI — History and Recovery Flow

## 1. Longitudinal Monitoring Journey
This workflow details how farmers browse past diagnosis records (Screens 22 & 23) and record visual observation milestones (Screen 21).

```mermaid
sequenceDiagram
    autonumber
    actor Farmer as Farmer
    participant Home as Screen 06: Home Dashboard
    participant Hist as Screen 22: Detection History
    participant Detail as Screen 23: History Details
    participant Recov as Screen 21: Plant Recovery
    participant Detect as Screen 11: Detection Start

    Home->>Hist: Tap "History" in Bottom Nav
    Hist->>Hist: Render chronological scan feed
    Farmer->>Hist: Apply Filter (e.g., Crop: Rice, Date Range)
    Hist-->>Farmer: Render filtered scan records
    Farmer->>Hist: Tap past scan card
    Hist->>Detail: Navigate to Screen 23 with scanId

    Detail-->>Farmer: Display original scan image, prediction & date
    alt Revisit Guidance
        Farmer->>Detail: Tap "View Treatments" -> Screen 18
    else Track Condition
        Farmer->>Detail: Tap "Monitor Recovery" -> Screen 21
        Recov-->>Farmer: Render chronological observation timeline
        Farmer->>Recov: Select Condition ('Better', 'No Change', 'Worse')
        Farmer->>Recov: Enter notes & tap "Save Checkpoint"
        Recov->>Recov: Append observation to timeline
    else Re-Scan Plant
        Farmer->>Recov: Tap "Scan Plant Again"
        Recov->>Detect: Navigate to Screen 11 for fresh diagnosis
    end
```

---

## 2. Key Safeguards & Integrity Rules
- **No Automatic Recovery**: Screen 21 never assumes or displays that a plant has recovered purely due to elapsed days.
- **Independent Record**: Observations are stored in `plant_observations` without altering the historical baseline in `disease_scans`.
- **Re-Scan CTA**: A prominent button on both Screen 21 and Screen 23 allows farmers to initiate a genuine new scan to verify plant health.

