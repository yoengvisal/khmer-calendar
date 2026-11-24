import { AxiosError, AxiosHeaders, type AxiosResponse, type InternalAxiosRequestConfig } from 'axios'
import { describe, expect, it } from 'vitest'
import { ApiError, errorMessage, getFieldErrors, toApiError } from './errors'

function config(requestId = 'client-req-1234'): InternalAxiosRequestConfig {
  return { url: '/admin/events', method: 'get', headers: new AxiosHeaders({ 'x-request-id': requestId }) }
}

function response(status: number, data: unknown, headers: Record<string, string> = {}): AxiosResponse {
  return { status, statusText: '', data, headers: new AxiosHeaders(headers), config: config(), request: {} }
}

function httpError(status: number, data: unknown, headers?: Record<string, string>): AxiosError {
  return new AxiosError('Request failed', AxiosError.ERR_BAD_REQUEST, config(), {}, response(status, data, headers))
}

describe('toApiError', () => {
  it('maps the server error envelope', () => {
    const details = [{ field: 'startDate', messages: ['must be a date'] }]
    const err = toApiError(
      httpError(400, { success: false, error: { code: 'VALIDATION_ERROR', message: 'The request is invalid', details, requestId: 'srv-req-1' } }),
    )
    expect(err).toBeInstanceOf(ApiError)
    expect(err).toMatchObject({ status: 400, code: 'VALIDATION_ERROR', message: 'The request is invalid', details, requestId: 'srv-req-1' })
  })

  it('falls back to the x-request-id response header, then to the one we sent', () => {
    const body = { success: false, error: { code: 'NOT_FOUND', message: 'Nope' } }
    expect(toApiError(httpError(404, body, { 'x-request-id': 'hdr-req-1' })).requestId).toBe('hdr-req-1')
    expect(toApiError(httpError(404, body)).requestId).toBe('client-req-1234')
  })

  it('maps non-envelope responses (e.g. proxy HTML 502) by status', () => {
    const err = toApiError(httpError(502, '<html>Bad gateway</html>'))
    expect(err).toMatchObject({ status: 502, code: 'INTERNAL_ERROR', requestId: 'client-req-1234' })
    expect(toApiError(httpError(429, '')).code).toBe('RATE_LIMITED')
    expect(toApiError(httpError(403, null)).code).toBe('FORBIDDEN')
  })

  it('maps network errors (no response) to status 0 NETWORK_ERROR', () => {
    const err = toApiError(new AxiosError('Network Error', AxiosError.ERR_NETWORK, config()))
    expect(err).toMatchObject({ status: 0, code: 'NETWORK_ERROR', requestId: 'client-req-1234' })
    expect(err.message).toMatch(/cannot reach the server/i)
  })

  it('maps timeouts to TIMEOUT', () => {
    expect(toApiError(new AxiosError('timeout of 20000ms exceeded', AxiosError.ECONNABORTED, config())).code).toBe('TIMEOUT')
    expect(toApiError(new AxiosError('timeout', AxiosError.ETIMEDOUT, config())).code).toBe('TIMEOUT')
  })

  it('maps cancellations to CANCELLED', () => {
    expect(toApiError(new AxiosError('canceled', AxiosError.ERR_CANCELED, config())).code).toBe('CANCELLED')
  })

  it('wraps arbitrary throwables as UNKNOWN_ERROR and is idempotent', () => {
    const err = toApiError(new TypeError('boom'))
    expect(err).toMatchObject({ status: 0, code: 'UNKNOWN_ERROR', message: 'boom', requestId: null })
    expect(toApiError(err)).toBe(err)
    expect(toApiError('weird').code).toBe('UNKNOWN_ERROR')
  })
})

describe('getFieldErrors', () => {
  it('groups VALIDATION_ERROR details by field and ignores malformed entries', () => {
    const err = new ApiError({
      status: 400,
      code: 'VALIDATION_ERROR',
      message: 'invalid',
      details: [
        { field: 'endDate', messages: ['must not be before startDate'] },
        { field: 'endDate', messages: ['must be a date'] },
        { messages: ['no field'] },
        'garbage',
        { field: 'titleEn', messages: 'not-an-array' },
      ],
    })
    expect(getFieldErrors(err)).toEqual({ endDate: ['must not be before startDate', 'must be a date'], titleEn: [] })
  })

  it('returns {} for other errors', () => {
    expect(getFieldErrors(new ApiError({ status: 409, code: 'CONFLICT', message: 'dup', details: [{ field: 'email', messages: ['x'] }] }))).toEqual({})
    expect(getFieldErrors(new Error('x'))).toEqual({})
  })
})

describe('errorMessage', () => {
  it('prefers ApiError.message and falls back', () => {
    expect(errorMessage(new ApiError({ status: 500, code: 'INTERNAL_ERROR', message: 'Server sad' }))).toBe('Server sad')
    expect(errorMessage(undefined, 'fallback')).toBe('fallback')
  })
})
