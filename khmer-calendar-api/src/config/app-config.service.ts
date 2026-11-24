import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import type { EnvironmentVariables } from './env.validation.js';

/** Typed, read-only access to validated configuration. Inject this instead of reading process.env. */
@Injectable()
export class AppConfig {
  constructor(
    private readonly config: ConfigService<EnvironmentVariables, true>,
  ) {}

  private get<K extends keyof EnvironmentVariables>(
    key: K,
  ): EnvironmentVariables[K] {
    return this.config.get(key, { infer: true });
  }

  get nodeEnv() {
    return this.get('NODE_ENV');
  }
  get isProduction() {
    return this.nodeEnv === 'production';
  }
  get port() {
    return this.get('PORT');
  }
  get databaseUrl() {
    return this.get('DATABASE_URL');
  }
  get jwtAccessSecret() {
    return this.get('JWT_ACCESS_SECRET');
  }
  get jwtAccessTtlSeconds() {
    return this.get('JWT_ACCESS_TTL_SECONDS');
  }
  get refreshTokenTtlDays() {
    return this.get('REFRESH_TOKEN_TTL_DAYS');
  }
  get corsOrigins(): string[] {
    return this.get('CORS_ORIGINS')
      .split(',')
      .map((o) => o.trim())
      .filter(Boolean);
  }
  get swaggerEnabled() {
    return this.get('SWAGGER_ENABLED');
  }
  get logFormat() {
    return this.get('LOG_FORMAT');
  }
  get trustProxy() {
    return this.get('TRUST_PROXY');
  }
}
