# AgriCare AI — Plant Detection Flow

## 1. Visual Detection Journey
The detection flow covers the complete path from photo capture to diagnostic result presentation.

```mermaid
sequenceDiagram
    autonumber
    actor Farmer as Farmer
    participant Home as Screen 06: Home
    participant Start as Screen 11: Detect Start
    participant Cam as Screen 12: Camera Viewfinder
    participant Gal as Screen 13: Gallery Upload
    participant Prev as Screen 14: Image Preview
    participant Ana as Screen 15: AI Analyzing
    participant Res as Screen 16: Detection Result
    participant Treat as Screen 18: Treatments

    Home->>Start: Tap "Diagnose Plant Leaf"
    alt Capture via Camera
        Start->>Cam: Open Camera Viewfinder
        Cam->>Cam: Position leaf inside bounding guides
        Farmer->>Cam: Press Shutter Button
        Cam->>Prev: Pass captured image path
    else Upload from Gallery
        Start->>Gal: Launch Gallery Picker
        Farmer->>Gal: Select clear leaf photo
        Gal->>Prev: Pass selected image path
    end

    Prev->>Prev: Display preflight inspection & retake button
    Farmer->>Prev: Tap "Analyze Leaf"
    Prev->>Ana: Navigate with image argument
    Ana->>Ana: Execute TFLite MobileNetV2 Model (Offline)
    Ana->>Res: Navigate with PredictionModel
    Res-->>Farmer: Render Disease Name, Confidence & Severity
    Farmer->>Treat: Tap "View Treatments" -> Screen 18
```

---

## 2. Decision Points in Detection Flow
- **Blur Detection Warning**: On Screen 14, if the captured image exhibits low edge variance, an advisory banner encourages the user to retake.
- **Low Confidence Threshold**: On Screen 16, if confidence is $< 70\%$, a warning card suggests capturing a second photograph under indirect sunlight.
- **Save to History**: Detections are stored immediately in local SQLite and synchronized to Supabase `disease_scans` when online.
