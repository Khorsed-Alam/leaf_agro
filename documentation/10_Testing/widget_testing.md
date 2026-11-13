# AgriCare AI — Widget Testing

## 1. Scope of Widget Tests
Widget tests verify that Material 3 UI widgets render cleanly, respond properly to user interactions, and adhere to accessibility and localization rules.

---

## 2. Tested Screen Suites
The test suite includes dedicated widget test suites across the application:
- `test/about_screen_test.dart` (11 tests): Verifies academic metadata, tech stack, 5 crops, legal modals, and academic disclaimer.
- `test/feedback_screen_test.dart` (9 tests): Tests 5-star rating interaction, category selection, character counter, photo attachment, and submission.
- `test/help_screen_test.dart` (11 tests): Verifies quick photo guides, 12 FAQs, live bilingual search, and contact support modal.
- `test/notifications_screen_test.dart` (13 tests): Tests unread indicators, mark single as read, mark all as read, and empty states.
- `test/settings_screen_test.dart`: Verifies preferences, language selection, cache management, and logout confirmation.
- `test/history_detail_screen_test.dart`: Verifies previous prediction banner, historical details, and navigation links.
- `test/recovery_screen_test.dart`: Tests observation timeline, condition picker, and honest non-fabricated recovery advisory.
- `test/crop_detail_screen_test.dart`: Verifies agronomy details and crop-disease linkage.
- `test/global_search_screen_test.dart`: Tests fuzzy keyword querying and result cards.
- `test/treatment_screen_test.dart`: Tests tabbed cultural, organic, and chemical remedy layouts in English and Bangla.
- `test/solutions_screen_test.dart`: Verifies registered product tables and active ingredient listings.

