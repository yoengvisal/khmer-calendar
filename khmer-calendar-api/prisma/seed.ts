/**
 * Development/staging seed. Idempotent. Refuses to run in production.
 *  - Creates (or leaves alone) an ADMIN user from SEED_ADMIN_EMAIL / SEED_ADMIN_PASSWORD.
 *  - Drafts holidays for the current and next year from the built-in rules and publishes
 *    them so the mobile app has data. Real deployments should review drafts in the admin UI.
 */
import { config } from 'dotenv';
config({ quiet: true });
import { PrismaPg } from '@prisma/adapter-pg';
import bcrypt from 'bcryptjs';
import { PrismaClient } from '../src/generated/prisma/client.js';
import { civilDateToDb } from '../src/database/date-mapping.js';
import { generateHolidayCandidates } from '../src/modules/events/domain/holiday-rules.js';
import { KhmerLunarCalendar } from '../src/modules/lunar/domain/khmer-lunar-calendar.js';

async function main() {
  if (process.env.NODE_ENV === 'production')
    throw new Error('Refusing to seed a production database');
  const prisma = new PrismaClient({
    adapter: new PrismaPg({ connectionString: process.env.DATABASE_URL! }),
  });
  try {
    const email = process.env.SEED_ADMIN_EMAIL?.trim().toLowerCase();
    const password = process.env.SEED_ADMIN_PASSWORD;
    let adminId: string | undefined;
    if (email && password) {
      if (password.length < 12)
        throw new Error('SEED_ADMIN_PASSWORD must be at least 12 characters');
      const existing = await prisma.user.findFirst({
        where: { email: { equals: email, mode: 'insensitive' } },
      });
      const admin =
        existing ??
        (await prisma.user.create({
          data: {
            email,
            displayName: 'Administrator',
            role: 'ADMIN',
            passwordHash: await bcrypt.hash(password, 12),
          },
        }));
      adminId = admin.id;
      console.log(
        existing ? `admin ${email} already exists` : `created admin ${email}`,
      );
    } else {
      console.log(
        'SEED_ADMIN_EMAIL/SEED_ADMIN_PASSWORD not set — skipping admin user',
      );
    }

    const calendar = new KhmerLunarCalendar();
    const thisYear = new Date().getFullYear();
    for (const year of [thisYear, thisYear + 1]) {
      const candidates = generateHolidayCandidates(year, calendar);
      const result = await prisma.event.createMany({
        skipDuplicates: true,
        data: candidates.map((c) => ({
          titleKm: c.titleKm,
          titleEn: c.titleEn,
          titleZh: c.titleZh,
          category: c.category,
          isDayOff: c.isDayOff,
          sourceKey: c.sourceKey,
          startDate: civilDateToDb(c.startDate),
          endDate: civilDateToDb(c.endDate),
          status: 'PUBLISHED',
          publishedAt: new Date(),
          createdById: adminId,
          updatedById: adminId,
        })),
      });
      // Backfill Chinese titles on rule-generated events created before titleZh existed.
      let backfilled = 0;
      for (const c of candidates) {
        const { count } = await prisma.event.updateMany({
          where: { sourceKey: c.sourceKey, titleZh: null },
          data: { titleZh: c.titleZh },
        });
        backfilled += count;
      }
      console.log(
        `${year}: inserted ${result.count} of ${candidates.length} holiday events, added Chinese titles to ${backfilled}`,
      );
    }
  } finally {
    await prisma.$disconnect();
  }
}

main().catch((err: unknown) => {
  console.error(err instanceof Error ? err.message : err);
  process.exit(1);
});
