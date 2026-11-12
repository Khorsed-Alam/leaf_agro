# AgriCare AI — Quality Assurance & Testing Report

## 1. Test Matrix Summary

| Test Domain | Target | Methodology | Status |
| :--- | :--- | :--- | :--- |
| **Model Accuracy** | 19 crop-disease classes | Stratified Test Set (3,480 images) | 96.4% Accuracy, 0.96 Macro F1 |
| **On-Device Inference** | Android (Snapdragon 680 / Helio G85) | TFLite Flutter Benchmark | 42.5ms average latency |
| **Navigation & Flow** | 30 Screens | GoRouter unit & widget tests | Passed |
| **Offline Resilience** | Scan with zero Wi-Fi / Cellular | SQLite local fallback cache | Passed (Zero data loss) |
| **RLS Security** | User isolation in Postgres | Supabase SQL security test suite | Passed (No leakage) |

## 2. Test Cases Executed
- **TC-01**: Cold boot to splash screen and onboarding redirect.
- **TC-02**: Offline leaf scan without network connection.
- **TC-03**: Network restore and pending queue auto-sync.
- **TC-04**: English to Bengali language switch runtime re-render.
- **TC-05**: RLS violation attempt preventing cross-user history access.

