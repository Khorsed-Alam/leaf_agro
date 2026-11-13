# AgriCare AI — Testing Guide

## 1. Automated Test Suite Execution
AgriCare AI incorporates a thorough suite of unit, widget, and integration tests covering business logic, UI rendering, localization, and offline fallbacks.

To run the entire test suite:
```bash
flutter test
```

To run a specific test file:
```bash
flutter test test/about_screen_test.dart
flutter test test/feedback_screen_test.dart
flutter test test/help_screen_test.dart
flutter test test/notifications_screen_test.dart
```

---

## 2. Test Architecture Best Practices
- **Riverpod Overrides**: Tests utilize `ProviderScope(overrides: [...])` to mock backend repositories, authentication states, and hardware cameras.
- **Mock SharedPreferences**: State tests initialize mock key-value storage via `SharedPreferences.setMockInitialValues({})`.
- **Golden & Image Mocking**: Tests render synthetic 1x1 PNG byte arrays with `Image.memory` to verify image attachment cards without relying on disk filesystem reads.
- **Zero Real Network Calls**: All tests run completely offline and independent of live Supabase network servers.

