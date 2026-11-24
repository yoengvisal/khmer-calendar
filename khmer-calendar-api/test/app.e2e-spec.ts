/**
 * End-to-end tests against a real PostgreSQL test database (DATABASE_URL from .env.test).
 * Prepare once with: npm run db:migrate:test
 */
import { Test } from '@nestjs/testing';
import type { INestApplication } from '@nestjs/common';
import request from 'supertest';
import type { App } from 'supertest/types.js';
import { AppModule } from '../src/app.module.js';
import { PrismaService } from '../src/database/prisma.service.js';
import { PasswordHasher } from '../src/modules/users/password-hasher.js';
import { configureApp } from '../src/setup-app.js';

const ADMIN = { email: 'admin@test.local', password: 'admin-password-123' };
const EDITOR = { email: 'editor@test.local', password: 'editor-password-123' };

describe('Khmer Calendar API (e2e)', () => {
  let app: INestApplication<App>;
  let http: ReturnType<typeof request>;
  let adminToken: string;
  let adminRefresh: string;
  let editorToken: string;

  beforeAll(async () => {
    const moduleRef = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();
    app = configureApp(
      moduleRef.createNestApplication(),
    ) as INestApplication<App>;
    await app.init();
    http = request(app.getHttpServer());

    const prisma = app.get(PrismaService);
    if (
      !(
        await prisma.$queryRaw<
          { db: string }[]
        >`SELECT current_database() AS db`
      )[0].db.includes('test')
    ) {
      throw new Error('Refusing to run e2e tests against a non-test database');
    }
    await prisma.$executeRawUnsafe(
      'TRUNCATE TABLE refresh_tokens, events, users CASCADE',
    );
    const hasher = app.get(PasswordHasher);
    await prisma.user.createMany({
      data: [
        {
          email: ADMIN.email,
          displayName: 'Admin',
          role: 'ADMIN',
          passwordHash: await hasher.hash(ADMIN.password),
        },
        {
          email: EDITOR.email,
          displayName: 'Editor',
          role: 'EDITOR',
          passwordHash: await hasher.hash(EDITOR.password),
        },
      ],
    });
  });

  afterAll(async () => {
    await app.close();
  });

  describe('public', () => {
    it('GET /health reports database up', async () => {
      const res = await http.get('/api/v1/health').expect(200);
      expect(res.body).toEqual({
        success: true,
        data: { status: 'ok', database: 'up' },
      });
      expect(res.headers['x-request-id']).toBeTruthy();
    });

    it('propagates a well-formed client request id', async () => {
      const res = await http
        .get('/api/v1/health')
        .set('x-request-id', 'client-req-12345')
        .expect(200);
      expect(res.headers['x-request-id']).toBe('client-req-12345');
    });

    it('GET /calendar/days/:date returns lunar data', async () => {
      const res = await http
        .get('/api/v1/calendar/days/2025-05-11')
        .expect(200);
      expect(res.body.data.lunar).toMatchObject({
        day: 15,
        moonPhase: 'WAXING',
        monthNameEn: 'Pisakh',
        isHolyDay: true,
      });
      expect(res.headers['cache-control']).toContain('max-age=300');
    });

    it('GET /calendar/months/:year/:month returns every day', async () => {
      const res = await http.get('/api/v1/calendar/months/2024/2').expect(200);
      expect(res.body.data.days).toHaveLength(29);
    });

    it('rejects impossible dates with the validation envelope', async () => {
      const res = await http
        .get('/api/v1/calendar/days/2025-02-30')
        .expect(400);
      expect(res.body.success).toBe(false);
      expect(res.body.error.code).toBe('VALIDATION_ERROR');
      expect(res.body.error.details[0].field).toBe('date');
      expect(res.body.error.requestId).toBeTruthy();
    });

    it('rejects out-of-range years and over-long event ranges', async () => {
      await http.get('/api/v1/calendar/months/1899/1').expect(400);
      const res = await http
        .get('/api/v1/events?from=2026-01-01&to=2027-06-01')
        .expect(400);
      expect(res.body.error.code).toBe('VALIDATION_ERROR');
    });

    it('unknown routes return the error envelope', async () => {
      const res = await http.get('/api/v1/nope').expect(404);
      expect(res.body.error.code).toBe('NOT_FOUND');
    });
  });

  describe('auth', () => {
    it('rejects bad credentials without revealing which part was wrong', async () => {
      const res = await http
        .post('/api/v1/auth/login')
        .send({ email: ADMIN.email, password: 'wrong-password' })
        .expect(401);
      expect(res.body.error.code).toBe('INVALID_CREDENTIALS');
    });

    it('logs in admin and editor', async () => {
      const a = await http.post('/api/v1/auth/login').send(ADMIN).expect(200);
      expect(a.body.data.user).toMatchObject({
        email: ADMIN.email,
        role: 'ADMIN',
      });
      expect(a.body.data.user.passwordHash).toBeUndefined();
      adminToken = a.body.data.accessToken;
      adminRefresh = a.body.data.refreshToken;
      const e = await http.post('/api/v1/auth/login').send(EDITOR).expect(200);
      editorToken = e.body.data.accessToken;
    });

    it('requires a token for admin routes', async () => {
      const res = await http.get('/api/v1/admin/events').expect(401);
      expect(res.body.error.code).toBe('UNAUTHORIZED');
    });

    it('GET /auth/me returns the current user', async () => {
      const res = await http
        .get('/api/v1/auth/me')
        .auth(adminToken, { type: 'bearer' })
        .expect(200);
      expect(res.body.data.email).toBe(ADMIN.email);
    });

    it('rotates refresh tokens and revokes the family on reuse', async () => {
      const first = await http
        .post('/api/v1/auth/refresh')
        .send({ refreshToken: adminRefresh })
        .expect(200);
      const rotated = first.body.data.refreshToken as string;
      expect(rotated).not.toBe(adminRefresh);

      // Re-using the old token is treated as theft…
      const reuse = await http
        .post('/api/v1/auth/refresh')
        .send({ refreshToken: adminRefresh })
        .expect(401);
      expect(reuse.body.error.code).toBe('INVALID_REFRESH_TOKEN');
      // …so the rotated token from the same family is revoked too.
      await http
        .post('/api/v1/auth/refresh')
        .send({ refreshToken: rotated })
        .expect(401);
      // Access tokens stay valid until they expire.
      adminToken = first.body.data.accessToken;
    });
  });

  describe('admin events', () => {
    let eventId: string;

    it('validates the event body (end before start, unknown fields)', async () => {
      const res = await http
        .post('/api/v1/admin/events')
        .auth(editorToken, { type: 'bearer' })
        .send({
          titleKm: 'ក',
          titleEn: 'A',
          category: 'CULTURAL',
          startDate: '2026-06-02',
          endDate: '2026-06-01',
        })
        .expect(400);
      expect(res.body.error.details[0].field).toBe('endDate');
      await http
        .post('/api/v1/admin/events')
        .auth(editorToken, { type: 'bearer' })
        .send({
          titleKm: 'ក',
          titleEn: 'A',
          category: 'CULTURAL',
          startDate: '2026-06-01',
          endDate: '2026-06-01',
          hack: true,
        })
        .expect(400);
    });

    it('editor creates a draft that is not public', async () => {
      const res = await http
        .post('/api/v1/admin/events')
        .auth(editorToken, { type: 'bearer' })
        .send({
          titleKm: 'ពិធីសាកល្បង',
          titleEn: 'Test Festival',
          titleZh: '  测试节  ',
          category: 'CULTURAL',
          startDate: '2026-06-01',
          endDate: '2026-06-03',
        })
        .expect(201);
      eventId = res.body.data.id;
      expect(res.body.data).toMatchObject({
        titleZh: '测试节',
        descriptionZh: null,
        status: 'DRAFT',
        publishedAt: null,
        isDayOff: false,
      });
      await http.get(`/api/v1/events/${eventId}`).expect(404);
    });

    it('publishing makes it visible on every covered calendar day', async () => {
      const res = await http
        .patch(`/api/v1/admin/events/${eventId}`)
        .auth(editorToken, { type: 'bearer' })
        .send({ status: 'PUBLISHED' })
        .expect(200);
      expect(res.body.data.publishedAt).toBeTruthy();
      await http.get(`/api/v1/events/${eventId}`).expect(200);
      const month = await http
        .get('/api/v1/calendar/months/2026/6')
        .expect(200);
      const covered = month.body.data.days.filter(
        (d: { events: { id: string }[] }) =>
          d.events.some((e) => e.id === eventId),
      );
      expect(covered.map((d: { date: string }) => d.date)).toEqual([
        '2026-06-01',
        '2026-06-02',
        '2026-06-03',
      ]);
    });

    it('lists with pagination meta and search', async () => {
      const res = await http
        .get('/api/v1/admin/events?q=test&limit=5')
        .auth(editorToken, { type: 'bearer' })
        .expect(200);
      expect(res.body.meta).toMatchObject({
        page: 1,
        limit: 5,
        total: 1,
        totalPages: 1,
      });
    });

    it('editors cannot delete; admins can', async () => {
      const forbidden = await http
        .delete(`/api/v1/admin/events/${eventId}`)
        .auth(editorToken, { type: 'bearer' })
        .expect(403);
      expect(forbidden.body.error.code).toBe('FORBIDDEN');
      await http
        .delete(`/api/v1/admin/events/${eventId}`)
        .auth(adminToken, { type: 'bearer' })
        .expect(200);
      await http
        .get(`/api/v1/admin/events/${eventId}`)
        .auth(adminToken, { type: 'bearer' })
        .expect(404);
    });

    it('generates holiday drafts idempotently', async () => {
      const first = await http
        .post('/api/v1/admin/events/generate')
        .auth(editorToken, { type: 'bearer' })
        .send({ year: 2025 })
        .expect(200);
      expect(first.body.data.created.length).toBe(16);
      const pchum = first.body.data.created.find(
        (e: { sourceKey: string }) => e.sourceKey === 'lunar:pchum-ben:2025',
      );
      expect(pchum).toMatchObject({
        titleZh: '亡人节',
        startDate: '2025-09-21',
        endDate: '2025-09-23',
        status: 'DRAFT',
      });
      const second = await http
        .post('/api/v1/admin/events/generate')
        .auth(editorToken, { type: 'bearer' })
        .send({ year: 2025 })
        .expect(200);
      expect(second.body.data.created).toHaveLength(0);
      expect(second.body.data.skipped).toHaveLength(16);
    });
  });

  describe('admin users', () => {
    it('only admins manage users; duplicate emails conflict', async () => {
      await http
        .get('/api/v1/admin/users')
        .auth(editorToken, { type: 'bearer' })
        .expect(403);
      const body = {
        email: 'new.editor@test.local',
        displayName: 'New',
        password: 'long-enough-password',
        role: 'EDITOR',
      };
      await http
        .post('/api/v1/admin/users')
        .auth(adminToken, { type: 'bearer' })
        .send(body)
        .expect(201);
      const dup = await http
        .post('/api/v1/admin/users')
        .auth(adminToken, { type: 'bearer' })
        .send({ ...body, email: 'NEW.editor@test.local' })
        .expect(409);
      expect(dup.body.error.code).toBe('CONFLICT');
    });
  });
});
