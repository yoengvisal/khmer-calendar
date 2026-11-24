# Khmer Calendar API — v1 contract

Base URL: `{API_BASE_URL}/api/v1` (dev: `http://localhost:3000/api/v1`).
All dates are civil dates `YYYY-MM-DD` (no timezone). Timestamps are ISO-8601 UTC.
Every response carries an `x-request-id` header (clients may send their own; `^[A-Za-z0-9-]{8,64}$`).

## Envelope

Success:

```json
{ "success": true, "data": { } }
```

Paginated success:

```json
{ "success": true, "data": [ ], "meta": { "page": 1, "limit": 20, "total": 57, "totalPages": 3 } }
```

Error (never contains stack traces):

```json
{
  "success": false,
  "error": { "code": "VALIDATION_ERROR", "message": "The request is invalid", "details": [], "requestId": "…" }
}
```

| HTTP | `error.code` | Meaning |
|------|--------------|---------|
| 400 | `VALIDATION_ERROR` | `details`: `[{ "field": "startDate", "messages": ["…"] }]` |
| 401 | `UNAUTHORIZED` | Missing/invalid access token |
| 401 | `TOKEN_EXPIRED` | Access token expired → client should refresh once |
| 401 | `INVALID_CREDENTIALS` | Wrong email/password (login only) |
| 401 | `INVALID_REFRESH_TOKEN` | Refresh token unknown/expired/revoked → force re-login |
| 403 | `FORBIDDEN` | Authenticated but role not allowed (do **not** refresh) |
| 404 | `NOT_FOUND` | |
| 409 | `CONFLICT` | e.g. duplicate email |
| 429 | `RATE_LIMITED` | |
| 500 | `INTERNAL_ERROR` | |

## Shared types

```ts
type MoonPhase = 'WAXING' | 'WANING';                 // កើត | រោច
type EventCategory = 'PUBLIC_HOLIDAY' | 'BUDDHIST_HOLY_DAY' | 'CULTURAL' | 'OBSERVANCE';
type EventStatus = 'DRAFT' | 'PUBLISHED' | 'ARCHIVED';
type UserRole = 'ADMIN' | 'EDITOR';

interface LunarDate {
  day: number;              // 1-15
  moonPhase: MoonPhase;
  monthIndex: number;       // 0-13 (12/13 = បឋមាសាឍ/ទុតិយាសាឍ in leap-month years)
  monthNameKm: string;      // "មិគសិរ"
  monthNameEn: string;      // "Migasir"
  beYear: number;           // ពុទ្ធសករាជ
  jsYear: number;           // ចុល្លសករាជ
  animalYear: number;       // 0=Rat … 11=Pig
  animalYearNameKm: string; // "មមី"
  animalYearNameEn: string; // "Horse"
  sak: number;              // 0-9
  sakNameKm: string;        // "អដ្ឋស័ក"
  isHolyDay: boolean;       // ថ្ងៃសីល
  formattedKm: string;      // "ថ្ងៃអាទិត្យ ១០កើត ខែមិគសិរ ឆ្នាំមមី អដ្ឋស័ក ពុទ្ធសករាជ ២៥៧០"
}

interface EventSummary {
  id: string;               // uuid
  titleKm: string;
  titleEn: string;
  titleZh: string | null;   // Simplified Chinese; clients fall back to titleEn when null
  category: EventCategory;
  startDate: string;        // inclusive
  endDate: string;          // inclusive, >= startDate
  isDayOff: boolean;
}

interface Event extends EventSummary {
  descriptionKm: string | null;
  descriptionEn: string | null;
  descriptionZh: string | null;
  status: EventStatus;      // public endpoints only ever return PUBLISHED
  sourceKey: string | null; // set when generated from a holiday rule, e.g. "lunar:visakha-bochea:2026"
  createdAt: string;
  updatedAt: string;
  publishedAt: string | null;
}

interface CalendarDay {
  date: string;
  dayOfWeek: number;        // 0=Sunday … 6=Saturday
  lunar: LunarDate;
  events: EventSummary[];   // published events covering this date
}

interface User {
  id: string; email: string; displayName: string; role: UserRole; isActive: boolean;
  lastLoginAt: string | null; createdAt: string;
}
```

## Public endpoints (no auth, cacheable)

| Method | Path | Notes |
|--------|------|-------|
| GET | `/health` | `{ status: "ok", database: "up" }` |
| GET | `/calendar/days/:date` | `CalendarDay` |
| GET | `/calendar/months/:year/:month` | `{ year, month, days: CalendarDay[] }` (every day of the month) |
| GET | `/calendar/new-year/:year` | `{ gregorianYear, mohaSongkran, time: "22:17", lerngSak, numberOfDays }` |
| GET | `/events?from=&to=&category=` | `Event[]` (PUBLISHED, overlapping `[from,to]`, max range 400 days, max 500 rows, sorted by `startDate`) |
| GET | `/events/:id` | `Event` (PUBLISHED only, otherwise 404) |

Year range for calendar endpoints: 1900–2100.

## Auth

| Method | Path | Body | Response |
|--------|------|------|----------|
| POST | `/auth/login` | `{ email, password }` | `{ accessToken, refreshToken, expiresIn, user }` (rate limited: 5/min/IP) |
| POST | `/auth/refresh` | `{ refreshToken }` | same as login. **Rotating**: the old refresh token is revoked; re-using a revoked token revokes the whole family. |
| POST | `/auth/logout` | `{ refreshToken }` | `{ loggedOut: true }` |
| GET | `/auth/me` | — | `User` |

Send `Authorization: Bearer <accessToken>`. `expiresIn` is seconds (default 900).
Do not attempt refresh for `/auth/login` or `/auth/refresh` failures.

## Admin endpoints (Bearer token)

| Method | Path | Roles | Notes |
|--------|------|-------|-------|
| GET | `/admin/events?from&to&status&category&q&page&limit` | ADMIN, EDITOR | paginated `Event[]`; `q` searches Khmer, English and Chinese titles; `limit` ≤ 100 |
| GET | `/admin/events/:id` | ADMIN, EDITOR | `Event` |
| POST | `/admin/events` | ADMIN, EDITOR | body below → `Event` (201) |
| PATCH | `/admin/events/:id` | ADMIN, EDITOR | partial body → `Event` |
| DELETE | `/admin/events/:id` | ADMIN | `{ deleted: true }` |
| POST | `/admin/events/generate` | ADMIN, EDITOR | `{ year }` → `{ created: Event[], skipped: string[] }` creates DRAFT events from built-in holiday rules (lunar + fixed-date); idempotent by `sourceKey` |
| GET | `/admin/users` | ADMIN | paginated `User[]` |
| POST | `/admin/users` | ADMIN | `{ email, displayName, password (min 12), role }` → `User` |
| PATCH | `/admin/users/:id` | ADMIN | `{ displayName?, role?, isActive?, password? }` → `User` |

Event write body:

```json
{
  "titleKm": "ពិធីបុណ្យវិសាខបូជា",
  "titleEn": "Visak Bochea Day",
  "titleZh": "卫塞节",
  "descriptionKm": null,
  "descriptionEn": null,
  "descriptionZh": null,
  "category": "BUDDHIST_HOLY_DAY",
  "startDate": "2026-05-01",
  "endDate": "2026-05-01",
  "isDayOff": true,
  "status": "DRAFT"
}
```

## Languages

Event text is stored in Khmer (`*Km`, required), English (`*En`, required) and Simplified Chinese (`*Zh`, optional,
added 2026-11-15 as an additive change). Clients pick the field for the user's language and fall back to English when
the Chinese field is null. Blank `titleZh`/`descriptionZh` values are stored as `null`.

## Compatibility

Additive changes (new fields, new endpoints) are non-breaking; clients must ignore unknown fields.
Breaking changes require `/api/v2`.
