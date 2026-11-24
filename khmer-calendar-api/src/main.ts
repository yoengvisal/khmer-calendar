import { ConsoleLogger } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module.js';
import { AppConfig } from './config/app-config.service.js';
import { configureApp } from './setup-app.js';

async function bootstrap() {
  const json = (process.env.LOG_FORMAT ?? 'json') === 'json';
  const app = await NestFactory.create(AppModule, {
    logger: new ConsoleLogger({
      json,
      colors: !json,
      prefix: 'KhmerCalendarAPI',
    }),
  });
  configureApp(app);
  const config = app.get(AppConfig);
  await app.listen(config.port);
}
await bootstrap();
