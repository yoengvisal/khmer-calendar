import axios, { type AxiosAdapter, type AxiosInstance, type AxiosResponse, type InternalAxiosRequestConfig } from 'axios'
import type { AuthResponse } from '@/core/auth/types'
import { ApiError, toApiError } from './errors'
import { createRequestId, REQUEST_ID_HEADER } from './requestId'
import type { ApiSuccess, Paginated } from './types'

declare module 'axios' {
  interface AxiosRequestConfig {
    /** Do not attach the bearer token and never attempt a refresh for this request. */
    skipAuth?: boolean
    /** Internal: set once a request has been retried after a refresh. */
    _retriedAfterRefresh?: boolean
    /** Internal: access token that was attached when the request was sent. */
    _sentAccessToken?: string | null
  }
}

/** Endpoints whose 401s must never trigger a refresh (contract: "Do not attempt refresh for /auth/login or /auth/refresh"). */
const NO_REFRESH_PATHS = ['/auth/login', '/auth/refresh']

export interface TokenSource {
  getAccessToken(): string | null
  getRefreshToken(): string | null
}

export interface ApiClientOptions {
  baseURL: string
  tokens: TokenSource
  /** Called after a successful refresh so the session can store the rotated tokens. */
  onTokensRefreshed(response: AuthResponse): void
  /** Called when the refresh token is rejected; the session must be cleared (user goes to /login). */
  onRefreshFailed(error: ApiError): void
  timeoutMs?: number
  /** Test seam: replaces the HTTP transport. */
  adapter?: AxiosAdapter
}

export interface ApiClient {
  http: AxiosInstance
  /**
   * Refreshes the access token. Single-flight: concurrent callers share one `POST /auth/refresh`.
   * Resolves with the new access token; rejects with an `ApiError`.
   */
  refreshAccessToken(): Promise<string>
}

function pathOf(url: string | undefined): string {
  if (!url) return ''
  const withoutQuery = url.split('?')[0] ?? ''
  try {
    return new URL(withoutQuery, 'http://placeholder').pathname
  } catch {
    return withoutQuery
  }
}

function isNoRefreshUrl(url: string | undefined): boolean {
  const path = pathOf(url)
  return NO_REFRESH_PATHS.some((p) => path === p || path.endsWith(p))
}

/** Errors that mean the refresh token itself is no good (as opposed to network / server trouble). */
function isSessionRejected(error: ApiError): boolean {
  return error.status === 401 || error.status === 400 || error.code === 'INVALID_REFRESH_TOKEN'
}

export function createApiClient(options: ApiClientOptions): ApiClient {
  const http = axios.create({
    baseURL: options.baseURL,
    timeout: options.timeoutMs ?? 20_000,
    headers: { Accept: 'application/json' },
    ...(options.adapter ? { adapter: options.adapter } : {}),
  })

  let refreshInFlight: Promise<string> | null = null

  function refreshAccessToken(): Promise<string> {
    if (refreshInFlight) return refreshInFlight

    const run = async (): Promise<string> => {
      const refreshToken = options.tokens.getRefreshToken()
      if (!refreshToken) {
        throw new ApiError({ status: 401, code: 'INVALID_REFRESH_TOKEN', message: 'No refresh token available.' })
      }
      const response = await http.post<ApiSuccess<AuthResponse>>('/auth/refresh', { refreshToken }, { skipAuth: true })
      const auth = response.data.data
      options.onTokensRefreshed(auth)
      return auth.accessToken
    }

    refreshInFlight = run()
      .catch((error: unknown) => {
        const apiError = toApiError(error)
        if (isSessionRejected(apiError)) options.onRefreshFailed(apiError)
        throw apiError
      })
      .finally(() => {
        refreshInFlight = null
      })
    return refreshInFlight
  }

  http.interceptors.request.use((config: InternalAxiosRequestConfig) => {
    config.headers.set(REQUEST_ID_HEADER, createRequestId())
    if (config.skipAuth) {
      config.headers.delete('Authorization')
      return config
    }
    const token = options.tokens.getAccessToken()
    config._sentAccessToken = token
    if (token) config.headers.set('Authorization', `Bearer ${token}`)
    else config.headers.delete('Authorization')
    return config
  })

  http.interceptors.response.use(
    (response: AxiosResponse) => response,
    async (error: unknown) => {
      const apiError = toApiError(error)
      const original = axios.isAxiosError(error) ? error.config : undefined

      const canRefresh =
        original !== undefined &&
        apiError.status === 401 &&
        apiError.code === 'TOKEN_EXPIRED' &&
        !original.skipAuth &&
        !original._retriedAfterRefresh &&
        !isNoRefreshUrl(original.url)

      if (!canRefresh) throw apiError

      original._retriedAfterRefresh = true
      const current = options.tokens.getAccessToken()
      // A refresh may already have completed while this request was in flight: reuse its token
      // instead of rotating the refresh token a second time.
      if (!current || current === original._sentAccessToken) {
        await refreshAccessToken() // rejects with ApiError -> propagates to the caller
      }
      // The request interceptor attaches the (new) current access token.
      return http.request(original)
    },
  )

  return { http, refreshAccessToken }
}

/** Unwraps `{ success, data }`. */
export function unwrap<T>(response: AxiosResponse<ApiSuccess<T>>): T {
  return response.data.data
}

/** Unwraps a paginated `{ success, data: T[], meta }`. */
export function unwrapPage<T>(response: AxiosResponse<ApiSuccess<T[]>>): Paginated<T> {
  const { data, meta } = response.data
  return {
    items: data,
    meta: meta ?? { page: 1, limit: data.length, total: data.length, totalPages: 1 },
  }
}
