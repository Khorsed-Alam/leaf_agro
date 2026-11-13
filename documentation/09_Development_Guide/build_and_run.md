# AgriCare AI — Build and Run Guide

## 1. Running Locally on Device or Emulator
To run AgriCare AI in debug mode on a connected Android phone or emulator:
```bash
flutter run
```

---

## 2. Building Release Binaries

### A. Release APK (Direct Sideloading)
```bash
flutter build apk --release
```
The output file is generated at:
`build/app/outputs/flutter-apk/app-release.apk`

### B. Android App Bundle (Google Play Store)
```bash
flutter build appbundle --release
```
The output bundle is generated at:
`build/app/outputs/bundle/release/app-release.aab`

---

## 3. Signing the Release Build
Configure your upload keystore in `android/key.properties`:
```properties
storePassword=your_keystore_password
keyPassword=your_key_password
keyAlias=upload
storeFile=../upload-keystore.jks
```
Ensure your `android/app/build.gradle` file references this keystore configuration for release builds.
