# AgriCare AI — User Profile API

## 1. Overview
The User Profile API allows clients to read and update farmer profile information stored in the `public.profiles` table. All requests require valid JWT Bearer authentication and are constrained by Row Level Security (RLS) to the requesting farmer (`auth.uid() = id`).

```mermaid
graph LR
    CLIENT[Client Request] -->|GET /rest/v1/profiles?id=eq.uid| RLS[RLS: auth.uid() == id]
    RLS -->|Authorized| ROW[(Profile Record)]
```

---

## 2. Endpoints Specification

### A. Get Current Farmer Profile
- **Endpoint**: `GET /rest/v1/profiles?id=eq.{user_id}&select=*`
- **Headers**:
  - `apikey: <ANON_KEY>`
  - `Authorization: Bearer <USER_JWT>`
- **Success Response (200 OK)**:
```json
[
  {
    "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "full_name": "Md. Rafiqul Islam",
    "email": "farmer@example.com",
    "phone": "+8801712345678",
    "phone_number": "+8801712345678",
    "district": "Bogura",
    "preferred_language": "bn",
    "role": "farmer",
    "avatar_url": null,
    "terms_accepted_at": "2026-11-13T10:00:00Z",
    "created_at": "2026-11-13T10:00:01Z",
    "updated_at": "2026-11-13T10:00:01Z"
  }
]
```

### B. Update Farmer Profile
- **Endpoint**: `PATCH /rest/v1/profiles?id=eq.{user_id}`
- **Headers**:
  - `apikey: <ANON_KEY>`
  - `Authorization: Bearer <USER_JWT>`
  - `Prefer: return=representation`
- **Request Body**:
```json
{
  "full_name": "Md. Rafiqul Islam",
  "district": "Rajshahi",
  "preferred_language": "bn",
  "phone_number": "+8801712345678"
}
```
- **Success Response (200 OK)**: Returns the updated JSON profile record.
- **Error Response (403 Forbidden)**: If a client attempts to alter the `role` field from `'farmer'` to `'admin'`, the `trg_prevent_role_escalation` trigger aborts the transaction with `Role escalation is not permitted`.
