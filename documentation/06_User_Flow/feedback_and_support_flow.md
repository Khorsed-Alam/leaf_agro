# AgriCare AI — Feedback and Support Flow

## 1. Support & Feedback Journey
Details farmer access to Help & FAQs (Screen 28), Feedback submission (Screen 29), and academic project disclosures (Screen 30).

```mermaid
graph TD
    PROF[Screen 24 / 25: Profile or Settings] -->|Help & FAQ| H_FAQ[Screen 28: Help & FAQ Screen]
    PROF -->|Feedback| FEED[Screen 29: Feedback Screen]
    PROF -->|About App| ABOUT[Screen 30: About Application Screen]

    H_FAQ -->|Search FAQs| H_FAQ
    H_FAQ -->|Expand Photo Guide| GUIDE[Visual Leaf Photo Guide Sheet]
    H_FAQ -->|Send Feedback| FEED

    FEED -->|Select Stars & Category| FEED
    FEED -->|Optional Photo Attachment| FEED
    FEED -->|Tap Submit Feedback| DB[(Supabase feedback Table)]
    DB -->|201 Created| SUCCESS[Feedback Success Dialog]
    SUCCESS --> HOME[Screen 06: Home Dashboard]

    ABOUT -->|View Tech Stack & Crops| ABOUT
    ABOUT -->|Open Privacy Policy| PRIV[LegalDocumentDialog]
    ABOUT -->|Open Terms & Conditions| TERM[LegalDocumentDialog]
```

---

## 2. Key Screen Capabilities
- **Screen 28 (Help & FAQ)**: Features 4 visual guides ("Taking Clear Leaf Photos", "Understanding AI Confidence", "Using Offline Mode", "Applying Treatment Safely") and 12 expandable FAQs with live search.
- **Screen 29 (Feedback)**: Interactive 5-star rating, 5 fixed categories, 2,000-character limit counter, optional image picker, and safe database submission.
- **Screen 30 (About Application)**: Academic capstone disclosures, tech stack, 5 verified crops, and legal terms.
