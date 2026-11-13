# AgriCare AI — Detailed Screen Specifications

## 1. Specification by Functional Group

### A. Authentication & Onboarding (Screens 00–05)
- **Screen 00 (Resolver)**: Non-visual orchestrator inspecting `authNotifierProvider`. Redirects to `/splash` or `/home`.
- **Screen 01 (Splash)**: Displays animated pulsating leaf scanner outline, app wordmark, tagline "Smart Plant Care for Farmers", version indicator.
- **Screen 02 (Onboarding)**: 3 horizontal slides: (1) Rapid AI Detection, (2) Proven Agricultural Remedies, (3) Recovery Tracking. Features page indicator dots and "Get Started" CTA.
- **Screen 03 (Login)**: Input cards for phone/email and password, password reveal icon button, remember me checkbox, "Login" button, link to registration.
- **Screen 04 (Register)**: Input fields for full name, email/mobile number, password, confirm password, 64-district dropdown, terms agreement checkbox.
- **Screen 05 (Forgot/Reset Password)**: Email entry field, instructions dispatch confirmation, new password entry with strength validator.

### B. Discovery & Navigation (Screens 06–10)
- **Screen 06 (Home Dashboard)**: Top farmer greeting with district tag, notification bell with unread badge, prominent "Diagnose Plant" hero CTA card, quick stats summary (total scans, active crops), horizontal crop cards, recent scans list.
- **Screen 07 (Crop Selection)**: $2 \times 3$ grid displaying Rice, Potato, Tomato, Mango, and Jute with high-res photos and vernacular names.
- **Screen 08 (Crop Detail)**: Botanical profile, optimal season, soil requirements, yield potential, list of 3-6 specific diseases affecting this crop.
- **Screen 09 (Disease Catalog)**: Searchable list of all 19 disease classes, crop filter chips, expandable cards displaying thumbnail, severity, and description.
- **Screen 10 (Global Search)**: Auto-focused search input, recent query chips, instant bilingual results grouped by Crops and Diseases.

### C. Vision Detection Pipeline (Screens 11–16)
- **Screen 11 (Detection Start)**: Best-practice photography guide (good lighting, center leaf, avoid background clutter), Camera CTA, Gallery CTA.
- **Screen 12 (Camera)**: Custom camera viewfinder, rectangular leaf positioning box, flash mode toggle, flip camera button, large shutter button.
- **Screen 13 (Gallery Upload)**: Device image picker with instant size (<15MB) and format (JPEG/PNG) validation.
- **Screen 14 (Image Preview)**: Displays selected image, preflight blur detector alert, rotate button, retake button, "Analyze Leaf" primary CTA.
- **Screen 15 (Analyzing)**: Animated rotating radar scanner overlaying the leaf image, stage progress indicators ("Preprocessing", "Running AI Model", "Loading Remedies"), non-blocking background inference.
- **Screen 16 (Detection Result)**: Image thumbnail, verified disease title (English & Bangla), confidence gauge (percentage & colored bar), severity chip, primary CTA "View Treatments", secondary CTA "Monitor Recovery", "Scan Another Plant".

### D. Advisory & Interventions (Screens 17–20)
- **Screen 17 (Disease Detail)**: Pathogen scientific name, causal agent biology, high-resolution symptom gallery, transmission vectors.
- **Screen 18 (Treatments)**: Segmented tab view: (1) Cultural & Agronomic Practices, (2) Organic / Bio-controls, (3) Chemical Solutions. Detailed step-by-step instructions.
- **Screen 19 (Prevention)**: Soil treatment, crop rotation schedules, resistant seed varieties, field sanitation rules.
- **Screen 20 (Products & Solutions)**: Registered commercial agrochemical directory, trade names in Bangladesh, active ingredients, exact dosage (ml or g per liter), application interval, safety precautions.

### E. Monitoring & History (Screens 21–23)
- **Screen 21 (Recovery & Follow-up)**: Initial scan reference card, chronological observation timeline, condition picker ('Better', 'No Change', 'Worse', 'Not Sure'), note text area, follow-up inspection date selector, prominent "Scan Plant Again" CTA.
- **Screen 22 (History Dashboard)**: Chronological scan archive, date range picker, crop filter chips, scan count summary, swipe-to-delete action.
- **Screen 23 (History Details)**: Detailed historical record review, original scan photo, timestamp, historical confidence, action buttons to revisit treatments or launch recovery log.

### F. Profile, Support & Governance (Screens 24–30)
- **Screen 24 (Profile)**: Farmer avatar, name, email, phone number, district, joined date, scan statistics card, shortcuts to Settings, Help, and Feedback.
- **Screen 25 (Settings)**: Preferences group (Language, Appearance, Notifications), Offline AI Model information tile, Cache & Storage management, Privacy Policy & Terms modals, Log Out dialog.
- **Screen 26 (Language)**: Radio tile selection between English and বাংলা with instant app-wide locale reconfiguration.
- **Screen 27 (Notifications)**: Unread notification list, mark all as read action, timestamps, clear notification button.
- **Screen 28 (Help & FAQ)**: 4 visual photography guides ("Clear Leaf Photos", "Understanding Confidence", "Offline Mode", "Safe Treatment"), 12 categorized searchable FAQs, contact support bottom sheet.
- **Screen 29 (Feedback)**: 5-star interactive rating, 5 feedback categories, 2,000-character multiline text area with counter, optional photo picker, safe submission.
- **Screen 30 (About Application)**: University final-year capstone banner, Department of CSE & Faculty of Engineering metadata, verified tech stack, 5 model-trained crops list, in-app Privacy Policy & Terms viewer, academic disclaimer.

