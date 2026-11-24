# Khmer Calendar API

NestJS 12 modular monolith + PostgreSQL (Prisma 7). Serves the Khmer lunar calendar, holidays/events, and the admin API.
The contract is in [`../docs/api-contract.md`](../docs/api-contract.md). Swagger is at `/api/docs` when `SWAGGER_ENABLED=true`.

## Quick start

```bash
nvm use                       # Node 24 (engines: >=22), npm 11
npm ci                        # also runs `prisma generate`
cp .env.example .env          # fill DATABASE_URL, JWT_ACCESS_SECRET (openssl rand -base64 48), SEED_ADMIN_PASSWORD
# Postgres: local install, or `docker compose up -d` from the repo root
npm run db:migrate:dev        # apply migrations to the dev DB
npm run db:seed               # admin user + published holidays for this year and next (refuses in production)
npm run start:dev             # http://localhost:3000/api/v1/health
```

## Scripts

| Script | Purpose |
|--------|---------|
| `start:dev` / `build` / `start:prod` | run with watch / compile / run compiled |
| `lint`, `typecheck`, `format:check` | static checks (CI runs all) |
| `test` | unit tests (lunar engine, holiday rules) |
| `db:migrate:test` then `test:e2e` | e2e tests against `.env.test` database (truncates it; refuses non-`test` DB names) |
| `db:migrate:dev` | create/apply migrations locally (`--create-only` to review SQL first) |
| `db:migrate:deploy` | apply reviewed migrations in staging/production (a separate release step) |
| `fixtures:golden` | regenerate `../shared/fixtures/khmer-lunar-golden.json` after an **intentional** algorithm change |

## Layout

```
src/
  main.ts, setup-app.ts       bootstrap; setup-app is shared with e2e tests
  app.module.ts               global guards (throttle → JWT → roles), interceptors, filter
  config/                     env validation (fails fast) + typed AppConfig
  common/                     errors, filters, guards, interceptors, middleware, validation
  database/                   PrismaService, DATE <-> civil date mapping
  generated/prisma/           generated client (git-ignored)
  modules/
    lunar/domain/             pure Chhankitek engine (no framework imports) + Nest adapter
    calendar/                 day / month / new-year views (lunar + published events)
    events/                   public + admin controllers, service, repository, domain/holiday-rules
    users/                    admin user management, password hashing, refresh-token store
    auth/                     login, rotating refresh, logout, me
    health/                   readiness (DB ping, 503 when down)
prisma/                       schema, reviewed migrations, seed
```

Request flow: controller (HTTP + DTO validation) → service (use case) → repository (Prisma) → PostgreSQL.
Domain code (`lunar/domain`, `events/domain`) imports neither NestJS nor Prisma.

## Design notes

- **Security**: routes are private by default (`@Public()` opts out). Helmet, strict CORS allowlist, global
  `ValidationPipe` (`whitelist` + `forbidNonWhitelisted`), rate limits (login 5/min, refresh 30/min, global 300/min),
  bcrypt (cost 12) with a constant-time path for unknown emails, 15-minute HS256 access tokens, 30-day
  single-use refresh tokens stored as SHA-256 hashes with family revocation on reuse. Deactivating a user, changing their
  role or resetting their password revokes their sessions.
- **Errors**: one filter maps everything to `{ success:false, error:{ code, message, details, requestId } }`; 5xx details
  are only logged.
- **Logs**: structured JSON (`LOG_FORMAT=json`), one line per request with `requestId`, route, status and duration —
  never bodies, headers or query values.
- **Data**: migrations only (no schema sync); `CHECK (end_date >= start_date)`; case-insensitive unique email;
  indexes for the published-range query.
- **Scaling**: stateless app instances. Public endpoints send `Cache-Control` so a CDN can absorb read traffic; the lunar
  engine is pure and memoized per year. Before running more than one instance, move the throttler to shared storage (Redis).

## Lunar engine

`src/modules/lunar/domain/khmer-lunar-calendar.ts` is a port of the MIT-licensed
[@thyrith/momentkh](https://github.com/ThyrithSor/momentkh) v3 algorithm, adapted to civil dates with day-level semantics
(animal year changes on the Moha Songkran date, era on Lerng Sak, BE on 1 Roch Pisakh). It is verified against officially
announced holiday dates (2020–2025) and continuity checks. The Flutter app has a Dart port verified against the same
golden fixtures.

## Hardening backlog

- Redis-backed throttler storage + response cache before horizontal scaling.
- Scheduled cleanup of expired refresh tokens (`RefreshTokensRepository.deleteExpired`).
- Audit log for admin changes.
- Move the admin refresh token to an httpOnly cookie.
