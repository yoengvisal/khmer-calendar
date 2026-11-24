import { type INestApplication, VersioningType } from '@nestjs/common';
import type { NestExpressApplication } from '@nestjs/platform-express';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import helmet from 'helmet';
import { createValidationPipe } from './common/validation/validation.js';
import { AppConfig } from './config/app-config.service.js';

/** Shared by main.ts and e2e tests so both run the exact same HTTP pipeline. */
export function configureApp(app: INestApplication) {
  const config = app.get(AppConfig);
  const express = app as NestExpressApplication;

  if (config.trustProxy) express.set('trust proxy', 1);
  express.disable('x-powered-by');
  app.use(helmet());
  app.enableCors({
    origin: config.corsOrigins.length ? config.corsOrigins : false,
    methods: ['GET', 'POST', 'PATCH', 'DELETE'],
    allowedHeaders: ['Authorization', 'Content-Type', 'X-Request-Id'],
    exposedHeaders: ['X-Request-Id'],
    maxAge: 600,
  });
  app.setGlobalPrefix('api');
  app.enableVersioning({ type: VersioningType.URI, defaultVersion: '1' });
  app.useGlobalPipes(createValidationPipe());
  app.enableShutdownHooks();

  if (config.swaggerEnabled) {
    const doc = SwaggerModule.createDocument(
      app,
      new DocumentBuilder()
        .setTitle('Khmer Calendar API')
        .setDescription(
          'Khmer lunar calendar, holidays and admin API. See docs/api-contract.md.',
        )
        .setVersion('1.0')
        .addBearerAuth()
        .build(),
    );
    SwaggerModule.setup('api/docs', app, doc);
  }
  return app;
}
