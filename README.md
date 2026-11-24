# Khmer Calendar

Monorepo for the Khmer Calendar product (ប្រតិទិនខ្មែរ):

| Project | Stack | Purpose |
|---------|-------|---------|
| [`khmer_calendar_app/`](khmer_calendar_app/) | Flutter 3.50.0 (FVM, project-scoped), BLoC, Dio, Clean Architecture, flavors dev/staging/production | Mobile app (Android/iOS). Lunar dates are computed on-device (works offline); holidays come from the API and are cached. |
| [`khmer-calendar-api/`](khmer-calendar-api/) | NestJS 12 modular monolith, PostgreSQL 16, Prisma 7 | Public calendar/events API + authenticated admin API. |
| [`khmer-calendar-admin/`](khmer-calendar-admin/) | React 19, Vite, TanStack Query, React Router | Web dashboard for editors/admins to manage holidays and users. |
| [`docs/api-contract.md`](docs/api-contract.md) | — | The v1 HTTP contract all three projects build against. |
| [`branding/`](branding/README.md) | — | Logo "Kbach Kor" (ក្បាច់ក): meaning (EN/KM), files, colours, usage rules, `sync_assets.sh`. |
| [`docs/operations.md`](docs/operations.md) | — | Environments, migrations, backups/restore, release checklists, known gaps. |
| [`shared/fixtures/`](shared/fixtures/) | — | Golden vectors that keep the TypeScript and Dart lunar engines identical. |

```
 Flutter app ──(public GET /events)──┐
                                     ├──► NestJS API ──► PostgreSQL
 Admin web ──(JWT, admin endpoints)──┘
```

## Getting started

Prerequisites: Node 24 (`>=22`), npm 11, PostgreSQL 16 (local or `docker compose up -d`), FVM, Xcode/Android SDK.

```bash
# 1. API (http://localhost:3000/api/v1, docs at /api/docs)
cd khmer-calendar-api && npm ci && cp .env.example .env   # edit .env
npm run db:migrate:dev && npm run db:seed && npm run start:dev

# 2. Admin (http://localhost:5173, proxies /api to :3000)
cd khmer-calendar-admin && npm ci && npm run dev

# 3. Mobile — Flutter is pinned by the repo-root .fvmrc (3.50.0); it never touches your global Flutter
fvm install                      # from the repo root, once
cd khmer_calendar_app && fvm flutter pub get
fvm flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=config/dev.json
```

### Flutter SDK (FVM, scoped to this folder)

`/Users/mac/Khmer-Calendar/.fvmrc` pins Flutter **3.50.0** for everything under this folder. FVM resolves it upward, so
`fvm flutter …` inside `khmer_calendar_app/` uses 3.50.0, and `.vscode/settings.json` points VS Code's Dart extension at
`.fvm/versions/3.50.0`. Always use `fvm flutter` / `fvm dart`. Never run `fvm global` or global `flutter config`;
other projects on the machine keep their own SDK.

Each project's README has the full command list, environment matrix and architecture notes.

## Principles

- Feature-first modules; domain code is framework-free (no Flutter/Dio/NestJS/Prisma imports).
- The Khmer lunar (Chhankitek) engine exists in TypeScript (API) and Dart (app). Both are tested against
  officially announced holiday dates and the shared golden fixtures. Change both together, then regenerate the
  fixtures with `npm run fixtures:golden` in the API.
- Holidays are data, not code: `POST /admin/events/generate` drafts a year's lunar + fixed-date holidays,
  and an editor checks them against the government's announcement before publishing.
- Modular monolith first; migrations are reviewed SQL; secrets live only in local `.env` files or the deployment
  secret manager.
