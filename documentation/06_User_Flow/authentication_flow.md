# AgriCare AI — Authentication Flow

## 1. Authentication Journey
The authentication flow guides farmers from initial splash launch to authenticated dashboard access.

```mermaid
sequenceDiagram
    autonumber
    actor Farmer as Farmer
    participant Splash as Screen 01: Splash
    participant Onboard as Screen 02: Onboarding
    participant Login as Screen 03: Login
    participant Register as Screen 04: Register
    participant Forgot as Screen 05: Forgot Password
    participant Home as Screen 06: Dashboard

    Splash->>Splash: Check local auth token
    alt Token Valid
        Splash->>Home: Direct Navigate to /home
    else First Launch
        Splash->>Onboard: Navigate to /onboarding
        Onboard->>Login: Complete Onboarding -> /login
    else Logged Out
        Splash->>Login: Navigate to /login
    end

    alt Farmer Registers
        Login->>Register: Tap "Create Account"
        Farmer->>Register: Enter Name, Email/Phone, District, Password
        Register->>Home: Registration Success -> /home
    else Farmer Logs In
        Farmer->>Login: Enter Credentials
        Login->>Home: Authentication Success -> /home
    else Password Recovery
        Login->>Forgot: Tap "Forgot Password?"
        Farmer->>Forgot: Enter Email Address
        Forgot-->>Login: Instructions Dispatched -> Return to /login
    end
```

---

## 2. Form Validations and Rules
- **Email/Phone**: Validates standard email regex or 11-digit Bangladeshi mobile format (`+8801XXXXXXXXX` or `01XXXXXXXXX`).
- **Password**: Minimum 8 characters; requires at least one numeral and one special character.
- **District Picker**: Displays searchable list of the 64 administrative districts of Bangladesh.
- **Terms Agreement**: Requires explicit checkbox agreement to privacy terms prior to registration.

