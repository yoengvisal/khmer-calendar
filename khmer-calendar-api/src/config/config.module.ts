import { Global, Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AppConfig } from './app-config.service.js';
import { validateEnv } from './env.validation.js';

@Global()
@Module({
  imports: [
    ConfigModule.forRoot({
      validate: validateEnv,
      envFilePath: process.env.NODE_ENV === 'test' ? ['.env.test'] : ['.env'],
      ignoreEnvFile: process.env.NODE_ENV === 'production',
      cache: true,
    }),
  ],
  providers: [AppConfig],
  exports: [AppConfig],
})
export class AppConfigModule {}
