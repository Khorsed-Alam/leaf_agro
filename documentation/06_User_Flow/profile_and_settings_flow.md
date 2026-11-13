# AgriCare AI — Profile and Settings Flow

## 1. User Profile & Settings Journey
Covers farmer profile review (Screen 24), system configuration (Screen 25), and language selection (Screen 26).

```mermaid
graph TD
    HOME[Screen 06: Home] -->|Tap Profile Tab| PROF[Screen 24: User Profile]
    PROF -->|Tap Edit Profile| EDIT[Screen 24b: Edit Profile Modal]
    PROF -->|Tap Settings| SETT[Screen 25: Settings Screen]
    PROF -->|Tap Language| LANG[Screen 26: Language Selection]
    SETT -->|Tap Language| LANG

    SETT -->|Offline Model Specs| M_SPEC[Model Specs Bottom Sheet]
    SETT -->|Manage Storage & Cache| M_CACHE[Clear Cache Dialog]
    SETT -->|Privacy Policy| M_PRIV[Legal Document Dialog]
    SETT -->|Terms & Conditions| M_TERM[Legal Document Dialog]
    SETT -->|Log Out| M_LOGOUT{Confirm Log Out?}
    M_LOGOUT -->|Yes| LOGIN[Screen 03: Farmer Login]
```

---

## 2. Real-Time Language Switching
When a farmer selects English or বাংলা on Screen 26:
1. `settingsProvider` updates the `Locale` state in Riverpod.
2. The change persists to `SharedPreferences` under key `app_locale`.
3. The UI rebuilds immediately without requiring an application restart.
4. All Bengali text renders through Google Fonts `Noto Sans Bengali`.

