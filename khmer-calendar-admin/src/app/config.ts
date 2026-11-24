/**
 * Runtime configuration. `import.meta.env` is read exactly once, here, and validated
 * before anything else runs. Everything else imports `config` instead of touching env vars.
 *
 * Note: every VITE_* value is inlined into the public bundle. Never put secrets in env files.
 */

export const APP_ENVS = ['dev', 'staging', 'production'] as const
export type AppEnv = (typeof APP_ENVS)[number]

export interface AppConfig {
  /** Base URL including the version prefix, without trailing slash, e.g. `/api/v1` or `https://api.example.com/api/v1`. */
  readonly apiBaseUrl: string
  readonly appEnv: AppEnv
  readonly isProduction: boolean
}

export class ConfigError extends Error {
  constructor(message: string) {
    super(`[config] ${message}`)
    this.name = 'ConfigError'
  }
}

interface RawEnv {
  readonly VITE_API_BASE_URL?: string
  readonly VITE_APP_ENV?: string
}

export function parseConfig(env: RawEnv): AppConfig {
  const rawBase = env.VITE_API_BASE_URL?.trim()
  if (!rawBase) {
    throw new ConfigError(
      'VITE_API_BASE_URL is not set. Define it in .env.<mode> (e.g. "/api/v1" for dev, "https://api.example.com/api/v1" for production).',
    )
  }
  const isRelative = rawBase.startsWith('/')
  if (!isRelative) {
    let url: URL
    try {
      url = new URL(rawBase)
    } catch {
      throw new ConfigError(`VITE_API_BASE_URL must be an absolute http(s) URL or a path starting with "/", got "${rawBase}".`)
    }
    if (url.protocol !== 'https:' && url.protocol !== 'http:') {
      throw new ConfigError(`VITE_API_BASE_URL must use http or https, got "${url.protocol}".`)
    }
  }

  const rawEnv = env.VITE_APP_ENV?.trim()
  if (!rawEnv || !(APP_ENVS as readonly string[]).includes(rawEnv)) {
    throw new ConfigError(`VITE_APP_ENV must be one of ${APP_ENVS.join(', ')}; got "${rawEnv ?? ''}".`)
  }
  const appEnv = rawEnv as AppEnv

  if (appEnv === 'production' && rawBase.startsWith('http://')) {
    throw new ConfigError('VITE_API_BASE_URL must use https in production.')
  }

  return Object.freeze({
    apiBaseUrl: rawBase.replace(/\/+$/, ''),
    appEnv,
    isProduction: appEnv === 'production',
  })
}

export const config: AppConfig = parseConfig(import.meta.env)
