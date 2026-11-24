import axios from 'axios'
import { REQUEST_ID_HEADER } from './requestId'
import type { ApiErrorCode, ApiFailure, FieldErrorDetail } from './types'

export interface ApiErrorInit {
  status: number
  code: ApiErrorCode | (string & {})
  message: string
  details?: unknown
  requestId?: string | null
  cause?: unknown
}

/**
 * The only error type that leaves the API layer. `status` is 0 when no HTTP response was received
 * (network failure, timeout, cancellation).
 */
export class ApiError extends Error {
  readonly status: number
  readonly code: ApiErrorCode | (string & {})
  readonly details: unknown
  readonly requestId: string | null

  constructor(init: ApiErrorInit) {
    super(init.message, init.cause === undefined ? undefined : { cause: init.cause })
    this.name = 'ApiError'
    this.status = init.status
    this.code = init.code
    this.details = init.details ?? null
    this.requestId = init.requestId ?? null
  }
}

export function isApiError(value: unknown): value is ApiError {
  return value instanceof ApiError
}

function isFailureEnvelope(body: unknown): body is ApiFailure {
  if (typeof body !== 'object' || body === null) return false
  const candidate = body as { success?: unknown; error?: unknown }
  if (candidate.success !== false || typeof candidate.error !== 'object' || candidate.error === null) return false
  const err = candidate.error as { code?: unknown; message?: unknown }
  return typeof err.code === 'string' && typeof err.message === 'string'
}

function codeForStatus(status: number): ApiErrorCode {
  if (status === 400 || status === 422) return 'VALIDATION_ERROR'
  if (status === 401) return 'UNAUTHORIZED'
  if (status === 403) return 'FORBIDDEN'
  if (status === 404) return 'NOT_FOUND'
  if (status === 409) return 'CONFLICT'
  if (status === 429) return 'RATE_LIMITED'
  if (status >= 500) return 'INTERNAL_ERROR'
  return 'UNKNOWN_ERROR'
}

const DEFAULT_MESSAGES: Partial<Record<ApiErrorCode, string>> = {
  NETWORK_ERROR: 'Cannot reach the server. Check your connection and try again.',
  TIMEOUT: 'The server took too long to respond. Please try again.',
  CANCELLED: 'The request was cancelled.',
  INTERNAL_ERROR: 'Something went wrong on the server. Please try again.',
  RATE_LIMITED: 'Too many requests. Please wait a moment and try again.',
  FORBIDDEN: 'You do not have permission to do this.',
  NOT_FOUND: 'The requested resource was not found.',
  UNAUTHORIZED: 'Your session is not valid. Please sign in again.',
}

function headerValue(headers: unknown, name: string): string | null {
  if (!headers || typeof headers !== 'object') return null
  const h = headers as { get?: (n: string) => unknown } & Record<string, unknown>
  const value = typeof h.get === 'function' ? h.get(name) : (h[name] ?? h[name.toLowerCase()])
  return typeof value === 'string' && value.length > 0 ? value : null
}

/** Converts anything thrown by axios (or our own code) into an `ApiError`. Idempotent. */
export function toApiError(error: unknown): ApiError {
  if (error instanceof ApiError) return error

  if (axios.isAxiosError(error)) {
    const sentRequestId = headerValue(error.config?.headers, REQUEST_ID_HEADER)
    const response = error.response

    if (response) {
      const responseRequestId = headerValue(response.headers, REQUEST_ID_HEADER)
      const body: unknown = response.data
      if (isFailureEnvelope(body)) {
        return new ApiError({
          status: response.status,
          code: body.error.code,
          message: body.error.message,
          details: body.error.details ?? null,
          requestId: body.error.requestId ?? responseRequestId ?? sentRequestId,
          cause: error,
        })
      }
      const code = codeForStatus(response.status)
      return new ApiError({
        status: response.status,
        code,
        message: DEFAULT_MESSAGES[code] ?? `Unexpected response from the server (HTTP ${response.status}).`,
        requestId: responseRequestId ?? sentRequestId,
        cause: error,
      })
    }

    let code: ApiErrorCode = 'NETWORK_ERROR'
    if (error.code === 'ECONNABORTED' || error.code === 'ETIMEDOUT') code = 'TIMEOUT'
    else if (error.code === 'ERR_CANCELED' || axios.isCancel(error)) code = 'CANCELLED'
    return new ApiError({
      status: 0,
      code,
      message: DEFAULT_MESSAGES[code] ?? 'Network error.',
      requestId: sentRequestId,
      cause: error,
    })
  }

  return new ApiError({
    status: 0,
    code: 'UNKNOWN_ERROR',
    message: error instanceof Error && error.message ? error.message : 'An unexpected error occurred.',
    cause: error,
  })
}

/** Extracts per-field messages from a VALIDATION_ERROR. Returns `{}` for anything else. */
export function getFieldErrors(error: unknown): Record<string, string[]> {
  if (!(error instanceof ApiError) || error.code !== 'VALIDATION_ERROR' || !Array.isArray(error.details)) return {}
  const result: Record<string, string[]> = {}
  for (const entry of error.details as unknown[]) {
    if (typeof entry !== 'object' || entry === null) continue
    const { field, messages } = entry as Partial<FieldErrorDetail>
    if (typeof field !== 'string') continue
    const list = Array.isArray(messages) ? messages.filter((m): m is string => typeof m === 'string') : []
    result[field] = [...(result[field] ?? []), ...list]
  }
  return result
}

/** Human-readable message for UI display. */
export function errorMessage(error: unknown, fallback = 'Something went wrong.'): string {
  if (error instanceof ApiError) return error.message || fallback
  if (error instanceof Error && error.message) return error.message
  return fallback
}
