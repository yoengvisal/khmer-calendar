import { config } from 'dotenv';
import { defineConfig, env } from 'prisma/config';

// Local convenience only; in deployed environments DATABASE_URL comes from the secret manager.
config({
  path: process.env.NODE_ENV === 'test' ? '.env.test' : '.env',
  quiet: true,
});

export default defineConfig({
  schema: 'prisma/schema.prisma',
  migrations: {
    path: 'prisma/migrations',
    seed: 'tsx prisma/seed.ts',
  },
  datasource: {
    url: env('DATABASE_URL'),
  },
});
