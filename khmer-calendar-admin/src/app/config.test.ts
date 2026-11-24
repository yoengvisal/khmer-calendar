import { describe, expect, it } from 'vitest'
import { ConfigError, parseConfig } from './config'

describe('parseConfig', () => {
  it('accepts a relative dev base URL and strips trailing slashes', () => {
    expect(parseConfig({ VITE_API_BASE_URL: '/api/v1/', VITE_APP_ENV: 'dev' })).toEqual({ apiBaseUrl: '/api/v1', appEnv: 'dev', isProduction: false })
  })

  it('accepts an absolute https URL in production', () => {
    expect(parseConfig({ VITE_API_BASE_URL: 'https://api.example.com/api/v1', VITE_APP_ENV: 'production' }).isProduction).toBe(true)
  })

  it('fails fast with a clear message when misconfigured', () => {
    expect(() => parseConfig({ VITE_APP_ENV: 'dev' })).toThrow(/VITE_API_BASE_URL is not set/)
    expect(() => parseConfig({ VITE_API_BASE_URL: 'api.example.com', VITE_APP_ENV: 'dev' })).toThrow(ConfigError)
    expect(() => parseConfig({ VITE_API_BASE_URL: '/api/v1', VITE_APP_ENV: 'prod' })).toThrow(/VITE_APP_ENV must be one of dev, staging, production/)
    expect(() => parseConfig({ VITE_API_BASE_URL: 'http://api.example.com/api/v1', VITE_APP_ENV: 'production' })).toThrow(/https/)
  })
})
