# Khmer Calendar — Admin dashboard

Web admin for the Khmer calendar product: manage holidays / holy days / observances, preview the lunar
calendar month grid, generate holidays from the built-in rules, and manage admin users.

Built strictly against the v1 API contract in [`../docs/api-contract.md`](../docs/api-contract.md).

- React 19 + TypeScript (strict) + Vite
- React Router v7 (data router), TanStack Query v5, axios
- Hand-written CSS with design tokens (light + dark via `prefers-color-scheme`), no component library
- Vitest + Testing Library (jsdom)

## Setup

```bash
nvm use            # .nvmrc -> Node 24 (engines: node >= 22)
npm install        # npm is the package manager (packageManager: npm@11.12.1)
npm run dev        # http://localhost:5173
```

In dev, the app calls `/api/v1/...` on its own origin and the Vite dev server proxies `/api` to
`http://localhost:3000` (the NestJS API in `../khmer-calendar-api`). To point the proxy elsewhere:

```bash
API_PROXY_TARGET=http://localhost:4000 npm run dev
```

(`API_PROXY_TARGET` is read by `vite.config.ts` on the Node side only; it is never bundled.)

## Environments / modes

`src/app/config.ts` reads `import.meta.env` **once**, validates it, and throws a `ConfigError` with a clear
message if anything is missing or malformed. `main.tsx` renders that message on screen instead of a blank page.

| Mode (`vite --mode`) | Used by                 | `VITE_API_BASE_URL`                       | `VITE_APP_ENV` | Env badge in top bar |
| -------------------- | ----------------------- | ----------------------------------------- | -------------- | -------------------- |
| `development`        | `npm run dev`           | `/api/v1` (proxied to `localhost:3000`)   | `dev`          | `DEV`                |
| `staging`            | `npm run build:staging` | `https://staging-api.example.com/api/v1`  | `staging`      | `STAGING`            |
| `production`         | `npm run build`         | `https://api.example.com/api/v1`          | `production`   | hidden               |
| `test`               | `npm test` (Vitest)     | `/api/v1`                                 | `dev`          | —                    |

Validation rules: base URL must be a path starting with `/` or an absolute `http(s)` URL (https required in
production); `VITE_APP_ENV` must be `dev | staging | production`.

Everything prefixed `VITE_` is inlined into the public bundle — **never put secrets in env files**. The
`example.com` hosts are placeholders; override per deployment with `.env.<mode>.local` (git-ignored) or CI
environment variables. Production builds emit *hidden* source maps (generated, not referenced) for upload to an
error tracker.

## Scripts

| Script                  | What it does                                                        |
| ----------------------- | ------------------------------------------------------------------- |
| `npm run dev`           | Vite dev server with `/api` proxy                                   |
| `npm run build`         | `tsc -b` + production build into `dist/`                            |
| `npm run build:staging` | `tsc -b` + `vite build --mode staging`                              |
| `npm run preview`       | Serve the last build locally                                        |
| `npm run lint`          | oxlint (scaffold default), warnings fail the run                    |
| `npm run typecheck`     | `tsc -b` (all tsconfig projects have `noEmit`)                      |
| `npm test`              | `vitest run` (jsdom)                                                |
| `npm run test:watch`    | Vitest in watch mode                                                |

## Architecture

Feature-first, with strict layering: **app → features → core / shared**. Components never import axios;
they use hooks (`hooks.ts`, TanStack Query), which call typed functions (`api.ts`), which use the single
axios instance in `core/api/http.ts`.

```
src/
  main.tsx                 global CSS + fonts, lazy-loads the app so config errors render on screen
  app/
    config.ts              env parsing/validation (the only reader of import.meta.env)
    App.tsx, providers.tsx QueryClient -> AuthProvider -> ToastProvider -> RouterProvider
    router.tsx, guards.tsx routes; RequireAuth (redirect to /login) + RequireRole (ADMIN-only subtree)
    layout/                AppLayout, Sidebar (role-filtered nav, off-canvas on mobile), Topbar (env badge, user, sign out)
    pages/                 NotFound, Forbidden, RouteError
    styles/                tokens.css (design tokens, light/dark), global.css (base + utilities)
  core/
    api/                   client.ts (axios factory + interceptors + refresh), http.ts (app instance),
                           errors.ts (ApiError + normalisation), requestId.ts, types.ts (envelope)
    auth/                  session.ts (store), authService.ts (restore), AuthProvider.tsx, useAuth.ts, types.ts
  features/
    auth/                  login page/form, login/logout hooks
    dashboard/             upcoming published events, draft count, "generate holidays for year"
    events/                list (URL-synced filters + pagination), create/edit form, publish/unpublish, delete
    calendar/              month grid preview (lunar day, holy day, event chips) from /calendar/months
    users/                 ADMIN-only list, create, edit (role/active/name), reset password
  shared/
    ui/                    Button, Input/Checkbox, Select, Textarea, Field, Dialog, ConfirmDialog, Badge,
                           Table, Pagination, Toast, EmptyState, ErrorState, Spinner (+ ui.css)
    lib/                   civil-date helpers, Khmer numerals / lunar-day formatting, cx
  test/                    setup, fixtures, axios mock adapter, render helper
```

Each feature has `api.ts`, `hooks.ts`, `types.ts`, `components/`, `pages/`. Cross-feature imports are limited
to types and presentational pieces (dashboard and calendar reuse event badges/types; dashboard reuses the
event query-key prefix so writes refresh it).

### Data & caching

- Query keys: `['events', …]` (lists, details, dashboard widgets), `['calendar', 'month', y, m]`, `['users', …]`.
  Event mutations invalidate `events` and `calendar`.
- Queries only retry transient failures (network / timeout / 5xx), never 4xx. Mutations never retry.
- Events filters (`year`, `month`, `status`, `category`, `q`, `page`) live in the URL, so views are linkable and
  survive reloads. Year + optional month are converted to `from`/`to`.
- The calendar preview uses the public `GET /calendar/months/:year/:month` (sent without a bearer token), so it
  shows **published** events only — same as end users see. Clicking an event chip opens its edit page.
- The whole query cache is cleared when a session ends, so data never leaks between users.

### Errors

Every failure leaving the API layer is an `ApiError { status, code, message, details, requestId }`:

- Server envelope `{ success: false, error: {…} }` is mapped as-is.
- Non-envelope responses (e.g. proxy HTML 502) map by status (`429 → RATE_LIMITED`, `5xx → INTERNAL_ERROR`, …).
- No response: `NETWORK_ERROR`, `TIMEOUT` (`ECONNABORTED`/`ETIMEDOUT`), `CANCELLED`, with `status: 0`.
- `requestId` comes from the body, else the `x-request-id` response header, else the id we sent.
  `ErrorState` shows it so users can quote it to support.
- `VALIDATION_ERROR` `details` (`[{ field, messages[] }]`) are mapped onto form fields (event form, user forms);
  unknown fields are listed in the form-level error. `CONFLICT` on user create maps to the email field.

## Auth & token refresh design

- **Access token**: memory only (`core/auth/session.ts`). Lost on reload by design.
- **Refresh token**: `localStorage` (`khmer-calendar-admin.refreshToken`), read through on every refresh so a
  rotation made in another tab is picked up.
- **Restore on load**: `AuthProvider` calls `restoreSession()`, which performs a refresh. While it runs the
  route guard shows a spinner. Auth rejection → anonymous (login page explains the session expired). Network /
  5xx → "Cannot reach the server" with Retry, and the refresh token is kept.
- **Request interceptor**: attaches `Authorization: Bearer <access>` (unless `skipAuth`) and a fresh
  `x-request-id` (UUID, matches `^[A-Za-z0-9-]{8,64}$`) on every attempt.
- **Response interceptor** (`core/api/client.ts`):
  1. Normalise to `ApiError`.
  2. Refresh **only** when `status === 401 && code === 'TOKEN_EXPIRED'`, the request is not `/auth/login` or
     `/auth/refresh`, not `skipAuth`, and has not already been retried. Never on 403 or other 401 codes.
  3. **Single flight**: the first failing request starts `POST /auth/refresh`; all concurrent failures await the
     same promise, then each original request is retried **once** with the new token. The refresh endpoint
     rotates tokens, so a second parallel refresh with the same token would trip reuse detection and revoke the
     whole family — the single-flight is what prevents that (also for StrictMode's double `restoreSession`).
  4. If a request was sent with an access token that has since been replaced (another request already
     refreshed), it is retried with the current token without refreshing again.
  5. Refresh rejected (`INVALID_REFRESH_TOKEN` / 401 / 400) → `session.clear('expired')` once; all waiting
     requests reject; `RequireAuth` redirects to `/login` (remembering the page to return to). Transient refresh
     failures (network / 5xx) do **not** clear the session.
- **Logout**: best-effort `POST /auth/logout` with the refresh token, then local session clear.
- **Roles**: `RequireRole(['ADMIN'])` guards `/users`; the Users nav item and event Delete action are hidden for
  EDITORs. This is UX only — the API enforces roles (`403 FORBIDDEN` is surfaced, never refreshed).

Covered by `src/core/api/client.test.ts` (3 concurrent 401s → exactly 1 refresh and 3 retries; refresh failure
→ session cleared once, all rejected, no retries; 403 / non-expiry 401 / auth endpoints → no refresh; retry
only once; stale-token reuse; transient refresh failure keeps the session) and
`src/core/auth/sessionExpiry.test.tsx` (real app wiring: rotated tokens stored; rejected refresh → session
cleared → guard redirects to `/login`).

## Accessibility & UI

- Labels wired to every control (`Field` sets `id`, `aria-invalid`, `aria-describedby` for hints/errors);
  first invalid field is focused on submit.
- Visible focus rings (`:focus-visible`), skip link, keyboard-operable everything.
- Dialogs use native `<dialog>` + `showModal()` (focus containment, Escape, inert background, focus restore),
  labelled via `aria-labelledby`; non-dismissible while a mutation is pending.
- Toasts in an `aria-live` region; errors use `role="alert"`.
- Responsive to phone width: off-canvas sidebar, tables become stacked cards ≤ 640px, calendar chips collapse
  to coloured bars on very narrow screens. Respects `prefers-reduced-motion`.
- Khmer text uses Noto Sans Khmer (`@fontsource/noto-sans-khmer`, Khmer subset only via `unicode-range`, so
  Latin UI text keeps the system font), marked `lang="km"` with a taller line height. UI chrome is English.

## Dependencies

Runtime: `react`, `react-dom` (scaffold), `react-router` (v7), `@tanstack/react-query`, `axios`,
`@fontsource/noto-sans-khmer` — exactly the requested set; nothing else was added.

Dev: `vitest`, `@testing-library/react`, `@testing-library/user-event`, `jsdom` (requested), plus:

- `@testing-library/dom` — required peer dependency of `@testing-library/react` 16.
- `@testing-library/jest-dom` — DOM matchers (`toBeInTheDocument`, `toHaveAccessibleDescription`) for readable
  accessibility-focused assertions.

`oxlint` and TypeScript 7 come from the current `create-vite` `react-ts` template and were kept.

## Testing notes

- Tests live next to the code (`*.test.ts[x]`). The events page test mocks `features/events/api` and renders the
  real hooks + React Query + router; the refresh tests drive the real axios instance through a mock adapter
  (`src/test/mockAdapter.ts`), no network.
- Node ≥ 25 exposes a stub global `localStorage` that shadows jsdom's; `src/test/setup.ts` installs an in-memory
  Storage when that happens. Node may print a harmless `--localstorage-file` warning during `npm test`.

## Hardening TODOs

- [ ] Move the refresh token to an **httpOnly, Secure, SameSite=Strict cookie** set by the API (scoped to
      `/api/v1/auth`), removing it from JS-readable storage; add CSRF protection for the refresh/logout endpoints.
- [ ] Coordinate refresh across browser tabs (Web Locks API or `BroadcastChannel`) so two tabs never rotate the
      same refresh token concurrently (would trigger family revocation and log both out).
- [ ] Proactive refresh shortly before `expiresIn` elapses, to avoid the 401 round-trip.
- [ ] Content-Security-Policy, `X-Frame-Options`/`frame-ancestors`, `Referrer-Policy` headers at the hosting layer.
- [ ] Error tracking (e.g. Sentry) with the hidden source maps and `requestId` correlation.
- [ ] Idle-timeout / "sign out everywhere"; MFA for ADMIN accounts (API work).
- [ ] Replace the `example.com` hosts with real staging/production URLs via CI env vars.
- [ ] E2E tests (Playwright) against the real API once it is runnable in CI.
