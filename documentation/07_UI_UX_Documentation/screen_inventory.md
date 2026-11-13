# AgriCare AI — Complete Screen Inventory (Screens 00 to 30)

## 1. Master Screen Inventory Table

The following inventory details all 31 screens in AgriCare AI, their file locations, route definitions, implementation status, and key UI capabilities.

| Screen # | Screen Name | Route Path | Implementation File | Status | Key Features |
| :---: | :--- | :--- | :--- | :---: | :--- |
| **00** | Splash Gate / Resolver | `/splash` | `lib/core/router/app_router.dart` | **Completed** | Token verification, route direction, initial auth checks. |
| **01** | Splash Screen | `/splash` | `lib/features/splash/presentation/splash_screen.dart` | **Completed** | Animated leaf scanner, AgriCare AI branding, version subtitle. |
| **02** | Onboarding Screen | `/onboarding` | `lib/features/onboarding/presentation/onboarding_screen.dart` | **Completed** | 3-page swipeable carousel, progress dots, skip & continue buttons. |
| **03** | Farmer Login | `/login` | `lib/features/auth/presentation/login_screen.dart` | **Completed** | Email/phone input, password visibility toggle, forgot password link. |
| **04** | Farmer Registration | `/register` | `lib/features/auth/presentation/register_screen.dart` | **Completed** | Name, contact, district dropdown (64 districts), terms agreement. |
| **05** | Forgot / Reset Password | `/forgot-password`, `/reset-password` | `lib/features/auth/presentation/forgot_password_screen.dart` | **Completed** | Email recovery dispatcher, validation feedback, password update. |
| **06** | Home Dashboard | `/home` | `lib/features/home/presentation/home_screen.dart` | **Completed** | Hero scan CTA, quick stats, crop horizontal scroll, recent scans. |
| **07** | Crop Selection Screen | `/crop-select` | `lib/features/crops/presentation/crop_selection_screen.dart` | **Completed** | Grid of 5 supported crops, selection outline, search filter. |
| **08** | Crop Detail Screen | `/crops/:id` | `lib/features/crops/presentation/crop_detail_screen.dart` | **Completed** | Botanical summary, growing conditions, list of linked diseases. |
| **09** | Disease Catalog Screen | `/diseases` | `lib/features/diseases/presentation/disease_catalog_screen.dart` | **Completed** | 19-class pathology encyclopedia, crop filter chips, search bar. |
| **10** | Global Search Screen | `/search` | `lib/features/search/presentation/global_search_screen.dart` | **Completed** | Instant bilingual fuzzy query, recent searches, crop tags. |
| **11** | Detection Start Screen | `/detect` | `lib/features/detection/presentation/detection_start_screen.dart` | **Completed** | Photo tips, camera launcher, gallery upload launcher. |
| **12** | Real-time Camera Screen | `/detect/camera` | `lib/features/detection/presentation/camera_screen.dart` | **Completed** | Viewfinder, bounding box leaf guide, flash toggle, shutter button. |
| **13** | Gallery Upload Screen | `/detect/gallery` | `lib/features/detection/presentation/gallery_upload_screen.dart` | **Completed** | Device photo picker, size & format validation, permission checks. |
| **14** | Image Preview Screen | `/detect/preview` | `lib/features/detection/presentation/image_preview_screen.dart` | **Completed** | Quality inspection, blur alert, rotate/crop controls, confirm button. |
| **15** | AI Analyzing Screen | `/detect/analyzing` | `lib/features/detection/presentation/analyzing_screen.dart` | **Completed** | Pulsing radar scan animation, progress indicator, offline TFLite. |
| **16** | AI Detection Result | `/detect/result` | `lib/features/detection/presentation/detection_result_screen.dart` | **Completed** | Disease diagnosis card, confidence meter, severity badge, CTAs. |
| **17** | Disease Detail Screen | `/diseases/:id` | `lib/features/diseases/presentation/disease_detail_screen.dart` | **Completed** | High-res disease photos, symptoms, causes, biological background. |
| **18** | Treatment Screen | `/recommendations/:id` | `lib/features/recommendations/presentation/treatment_screen.dart` | **Completed** | Tabbed cultural, organic, and chemical treatment recommendations. |
| **19** | Prevention & Care Screen | `/prevention` | `lib/features/recommendations/presentation/prevention_screen.dart` | **Completed** | Long-term preventative agronomy, crop rotation, soil sanitation. |
| **20** | Product & Solutions Screen| `/solutions` | `lib/features/recommendations/presentation/solutions_screen.dart` | **Completed** | Registered agrochemicals directory, active ingredients, dosage rates. |
| **21** | Plant Recovery & Follow-up| `/recovery` | `lib/features/recovery/presentation/recovery_screen.dart` | **Completed** | Longitudinal recovery timeline, condition log ('Better', 'Worse'). |
| **22** | Detection History | `/history` | `lib/features/history/presentation/history_screen.dart` | **Completed** | Scan list, date range filter, crop chips, pull-to-refresh. |
| **23** | History Details Screen | `/history/:id` | `lib/features/history/presentation/history_detail_screen.dart` | **Completed** | Past scan review, historical prediction, revisit treatments, delete. |
| **24** | User Profile Screen | `/profile` | `lib/features/profile/presentation/profile_screen.dart` | **Completed** | Farmer avatar, name, email/phone, total scans counter, settings CTA. |
| **25** | Settings Screen | `/settings` | `lib/features/settings/presentation/settings_screen.dart` | **Completed** | Account settings, offline model specs, storage cache, legal links. |
| **26** | Language Selection Screen | `/settings/language` | `lib/features/settings/presentation/language_screen.dart` | **Completed** | Live bilingual toggle between English and Bengali (বাংলা). |
| **27** | Notifications Screen | `/notifications` | `lib/features/notifications/presentation/notifications_screen.dart` | **Completed** | Real notification list, unread indicators, mark-all-as-read. |
| **28** | Help & FAQ Screen | `/help` | `lib/features/help/presentation/help_screen.dart` | **Completed** | 4 visual quick guides, 12 searchable FAQs, contact support bottom sheet. |
| **29** | Feedback Screen | `/feedback` | `lib/features/feedback/presentation/feedback_screen.dart` | **Completed** | 5-star rating, 5 categories, 2,000-char feedback, photo upload. |
| **30** | About Application Screen | `/about` | `lib/features/about/presentation/about_screen.dart` | **Completed** | Academic capstone details, tech stack, 5 verified crops, legal modal. |

