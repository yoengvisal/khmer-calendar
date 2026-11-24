import { plainToInstance, Transform } from 'class-transformer';
import {
  IsBoolean,
  IsIn,
  IsInt,
  IsString,
  Matches,
  Max,
  Min,
  MinLength,
  validateSync,
} from 'class-validator';

const toBool = ({ value }: { value: unknown }) =>
  value === true || value === 'true' || value === '1';

export class EnvironmentVariables {
  @IsIn(['development', 'test', 'staging', 'production'])
  NODE_ENV: 'development' | 'test' | 'staging' | 'production' = 'development';

  @Transform(({ value }) => Number(value))
  @IsInt()
  @Min(1)
  @Max(65535)
  PORT = 3000;

  @IsString()
  @Matches(/^postgres(ql)?:\/\//, {
    message: 'DATABASE_URL must be a postgres:// connection string',
  })
  DATABASE_URL: string;

  @IsString()
  @MinLength(32, {
    message: 'JWT_ACCESS_SECRET must be at least 32 characters',
  })
  JWT_ACCESS_SECRET: string;

  @Transform(({ value }) => Number(value))
  @IsInt()
  @Min(60)
  @Max(3600)
  JWT_ACCESS_TTL_SECONDS = 900;

  @Transform(({ value }) => Number(value))
  @IsInt()
  @Min(1)
  @Max(90)
  REFRESH_TOKEN_TTL_DAYS = 30;

  @IsString()
  CORS_ORIGINS = '';

  @Transform(toBool)
  @IsBoolean()
  SWAGGER_ENABLED = false;

  @IsIn(['json', 'pretty'])
  LOG_FORMAT: 'json' | 'pretty' = 'json';

  @Transform(toBool)
  @IsBoolean()
  TRUST_PROXY = false;
}

/** Fails fast at startup with every invalid variable listed (values are never printed). */
export function validateEnv(
  config: Record<string, unknown>,
): EnvironmentVariables {
  const env = plainToInstance(EnvironmentVariables, config, {
    exposeDefaultValues: true,
  });
  const errors = validateSync(env, {
    skipMissingProperties: false,
    whitelist: false,
  });
  if (errors.length > 0) {
    const lines = errors.map(
      (e) =>
        `  - ${e.property}: ${Object.values(e.constraints ?? {}).join('; ')}`,
    );
    throw new Error(`Invalid environment configuration:\n${lines.join('\n')}`);
  }
  if (env.NODE_ENV === 'production' && env.SWAGGER_ENABLED) {
    // Allowed, but make it a conscious choice.
    console.warn('SWAGGER_ENABLED=true in production');
  }
  return env;
}
