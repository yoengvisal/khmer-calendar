# Operations, release & recovery

Covers blueprint §9 (backups, restore, migration recovery), §11 (CI/CD, release discipline) and §14 (final checklist).

## Environments

| | dev | staging | production |
|---|---|---|---|
| API base URL | `http://localhost:3000/api/v1` | `https://staging-api.example.com/api/v1` | `https://api.example.com/api/v1` |
| Database | local `khmer_calendar_dev` | managed PostgreSQL 16 (own instance) | managed PostgreSQL 16 (own instance, PITR on) |
| Secrets | local `.env` (git-ignored) | deployment secret manager | deployment secret manager (separate credentials) |
| Swagger | on | on | off (`SWAGGER_ENABLED=false`) |
| Mobile flavor / app id | `dev` / `….dev` | `staging` / `….staging` | `production` / base id |
| Admin build | `npm run dev` | `npm run build:staging` | `npm run build` |

Replace the `example.com` hosts and the `com.example.khmercalendar` app id before the first store or staging release.

## Database migrations

1. Create locally: `npm run db:migrate:dev -- --name <change> --create-only`, then review the SQL (locks, data
   backfills, `NOT NULL` on large tables) and apply with `npm run db:migrate:dev`.
2. Merge only with a passing CI run (CI runs `prisma migrate deploy` + e2e against a fresh PostgreSQL).
3. Release order: **backup/snapshot → `npm run db:migrate:deploy` (separate step, not on container start) → deploy app**.
   Schema changes must be backwards-compatible with the previous app version (expand → migrate → contract) so that
   rolling back the app never needs a schema rollback.
4. Recovery from a failed migration: `prisma migrate status`; fix forward with a new migration, or mark the failed one
   with `prisma migrate resolve --rolled-back <name>` after manually reverting its partial changes. Restore from the
   pre-release snapshot only if data was damaged.

Never use `prisma db push` or schema synchronization against staging/production.

## Backups & restore

- Production: managed PostgreSQL with point-in-time recovery (≥ 7 days) + daily logical dump
  (`pg_dump --format=custom`) to separate storage, retained 30 days.
- **Restore test monthly** into a scratch instance: `pg_restore --clean --no-owner -d <scratch> dump.pgdump`, then run
  `GET /api/v1/health` and spot-check `GET /api/v1/events?from=…&to=…` against it. Record the date and the duration (that's your real RTO).
- Data retention: expired refresh tokens can be purged after 7 days (`RefreshTokensRepository.deleteExpired`; schedule it).

## API release checklist

- [ ] CI green: format, lint, typecheck, unit, e2e, build
- [ ] Migrations reviewed; backup/snapshot taken; `db:migrate:deploy` succeeded
- [ ] Env validated at boot (the app refuses to start on missing/weak `JWT_ACCESS_SECRET`, bad `DATABASE_URL`)
- [ ] `CORS_ORIGINS` = the exact admin origin(s); `TRUST_PROXY=true` only behind a trusted load balancer
- [ ] `/api/v1/health` returns 200 behind the load balancer; logs arrive as JSON with `requestId`
- [ ] Staging smoke test passed before production (separate from the production deploy)

## Mobile release checklist

- [ ] `fvm flutter analyze` / `fvm flutter test` green with the repo-root `.fvmrc` SDK (3.50.0)
- [ ] Build each flavor separately, verify app id, display name, environment label and API URL in Settings
- [ ] Release signing: Android upload keystore + `key.properties` and iOS distribution certificate/profiles live only in
      the CI secret store / developer keychain, never in git
- [ ] Release builds with `--obfuscate --split-debug-info=build/symbols/<flavor>`; upload the symbols and the Android
      `mapping.txt` to the crash reporter you adopt (not yet integrated, see below); keep the artifacts per build number
- [ ] Device QA on a small and a large Android phone and one iPhone, in Khmer and English, light and dark

## Admin release checklist

- [ ] lint, typecheck, test, `build` / `build:staging` green
- [ ] Served over HTTPS with a strict CSP; API origin matches `VITE_API_BASE_URL`

## Known gaps

| Item | Status |
|------|--------|
| Crash reporting (e.g. Sentry/Crashlytics) | Not integrated. Choose a provider, then wire symbol and mapping upload into the release job |
| Certificate pinning (mobile) | Not enabled. It needs a key-rotation and recovery plan before turning it on |
| Throttler storage | In-memory. Move to Redis before running more than one API instance |
| Admin refresh token | `localStorage`. Planned move to an httpOnly cookie |
| Audit log of admin changes | Not implemented (`createdById` and `updatedById` are recorded) |
