# AgriCare AI — Development Setup Guide

## 1. Prerequisites
To set up and contribute to the AgriCare AI codebase, install:
- **Flutter SDK**: Version `>= 3.0.0 < 4.0.0` (Stable channel).
- **Dart SDK**: Included with Flutter.
- **Android Studio / VS Code**: With Flutter & Dart extensions.
- **Android SDK**: Build-tools `33.0.0+`, compileSdkVersion `34`, minSdkVersion `21`.
- **Git**: For version control.

---

## 2. Initial Setup Steps
1. **Clone the Repository**:
   ```bash
   git clone https://github.com/your-org/leaf_agro.git
   cd leaf_agro
   ```
2. **Install Flutter Dependencies**:
   ```bash
   flutter pub get
   ```
3. **Verify Environment**:
   ```bash
   flutter doctor
   ```
4. **Generate Code (Freezed & JSON Serializable)**:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
5. **Run the Test Suite**:
   ```bash
   flutter test
   ```

