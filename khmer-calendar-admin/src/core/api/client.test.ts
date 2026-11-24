import { describe, expect, it, vi } from 'vitest'
import type { AuthResponse } from '@/core/auth/types'
import { createMockAdapter, fail, ok, pathOf, type MockHandler } from '@/test/mockAdapter'
import { makeAuth } from '@/test/fixtures'
import { createApiClient } from './client'
import { ApiError } from './errors'

const REQUEST_ID_PATTERN = /^[A-Za-z0-9-]{8,64}$/

function setup(handler: MockHandler, initial = { access: 'old-access', refresh: 'old-refresh' }) {
  const tokens = { access: initial.access as string | null, refresh: initial.refresh as string | null }
  const adapter = createMockAdapter(handler)
  const onTokensRefreshed = vi.fn((auth: AuthResponse) => {
    tokens.access = auth.accessToken
    tokens.refresh = auth.refreshToken
  })
  const onRefreshFailed = vi.fn(() => {
    tokens.access = null
    tokens.refresh = null
  })
  const client = createApiClient({
    baseURL: '/api/v1',
    adapter,
    tokens: { getAccessToken: () => tokens.access, getRefreshToken: () => tokens.refresh },
    onTokensRefreshed,
    onRefreshFailed,
  })
  const refreshCalls = () => adapter.calls.filter((c) => pathOf(c) === '/auth/refresh')
  return { client, adapter, tokens, onTokensRefreshed, onRefreshFailed, refreshCalls }
}

/** Server where "old-access" is expired and "new-access" is valid. */
function expiringServer(refreshReply = ok(makeAuth({ accessToken: 'new-access', refreshToken: 'new-refresh' }))): MockHandler {
  return (config) => {
    const path = pathOf(config)
    if (path === '/auth/refresh') return { ...refreshReply, delayMs: 10 }
    const auth = config.headers.get('Authorization')
    if (auth === 'Bearer new-access') return ok({ path })
    return fail(401, 'TOKEN_EXPIRED', 'Access token expired')
  }
}

describe('createApiClient — request decoration', () => {
  it('attaches the bearer token and a fresh x-request-id to every request', async () => {
    const { client, adapter } = setup(() => ok({}))
    await client.http.get('/admin/events')
    await client.http.get('/admin/events')

    const [first, second] = adapter.calls
    expect(first?.headers.get('Authorization')).toBe('Bearer old-access')
    const id1 = first?.headers.get('x-request-id')
    const id2 = second?.headers.get('x-request-id')
    expect(id1).toMatch(REQUEST_ID_PATTERN)
    expect(id2).toMatch(REQUEST_ID_PATTERN)
    expect(id1).not.toBe(id2)
  })

  it('does not attach the bearer token when skipAuth is set', async () => {
    const { client, adapter } = setup(() => ok({}))
    await client.http.get('/calendar/months/2026/5', { skipAuth: true })
    expect(adapter.calls[0]?.headers.get('Authorization')).toBeFalsy()
  })
})

describe('createApiClient — token refresh coordination', () => {
  it('3 concurrent TOKEN_EXPIRED 401s trigger exactly one refresh, then each request is retried once', async () => {
    const { client, adapter, refreshCalls, onTokensRefreshed, tokens } = setup(expiringServer())

    const results = await Promise.all([
      client.http.get('/admin/events'),
      client.http.get('/admin/users'),
      client.http.get('/auth/me'),
    ])

    expect(results.map((r) => (r.data as { data: { path: string } }).data.path)).toEqual(['/admin/events', '/admin/users', '/auth/me'])
    expect(refreshCalls()).toHaveLength(1)
    expect(refreshCalls()[0]?.data).toBe(JSON.stringify({ refreshToken: 'old-refresh' }))
    expect(refreshCalls()[0]?.headers.get('Authorization')).toBeFalsy()
    expect(onTokensRefreshed).toHaveBeenCalledTimes(1)
    expect(tokens).toEqual({ access: 'new-access', refresh: 'new-refresh' })

    // 3 original attempts + 1 refresh + 3 retries
    expect(adapter.calls).toHaveLength(7)
    const retries = adapter.calls.filter((c) => c.headers.get('Authorization') === 'Bearer new-access')
    expect(retries.map(pathOf).sort()).toEqual(['/admin/events', '/admin/users', '/auth/me'])
  })

  it('a later refresh can happen once the first one has settled (single-flight is per refresh, not forever)', async () => {
    const { client, refreshCalls } = setup(expiringServer())
    await client.refreshAccessToken()
    await client.refreshAccessToken()
    expect(refreshCalls()).toHaveLength(2)
  })

  it('concurrent explicit refreshes (e.g. StrictMode double restore) share one request', async () => {
    const { client, refreshCalls } = setup(expiringServer())
    const [a, b] = await Promise.all([client.refreshAccessToken(), client.refreshAccessToken()])
    expect(a).toBe('new-access')
    expect(b).toBe('new-access')
    expect(refreshCalls()).toHaveLength(1)
  })

  it('when refresh fails with INVALID_REFRESH_TOKEN: session is cleared once and every waiting request rejects', async () => {
    const { client, adapter, refreshCalls, onRefreshFailed, onTokensRefreshed } = setup(
      expiringServer(fail(401, 'INVALID_REFRESH_TOKEN', 'Refresh token revoked')),
    )

    const outcomes = await Promise.allSettled([
      client.http.get('/admin/events'),
      client.http.get('/admin/users'),
      client.http.get('/auth/me'),
    ])

    expect(refreshCalls()).toHaveLength(1)
    expect(onRefreshFailed).toHaveBeenCalledTimes(1)
    expect(onTokensRefreshed).not.toHaveBeenCalled()
    for (const outcome of outcomes) {
      expect(outcome.status).toBe('rejected')
      const reason = (outcome as PromiseRejectedResult).reason as ApiError
      expect(reason).toBeInstanceOf(ApiError)
      expect(reason.code).toBe('INVALID_REFRESH_TOKEN')
    }
    // No retries were attempted: 3 originals + 1 refresh.
    expect(adapter.calls).toHaveLength(4)
  })

  it('does not clear the session when refresh fails for a transient reason (network / 5xx)', async () => {
    const { client, onRefreshFailed } = setup(expiringServer(fail(503, 'INTERNAL_ERROR', 'Service unavailable')))
    await expect(client.http.get('/admin/events')).rejects.toMatchObject({ code: 'INTERNAL_ERROR', status: 503 })
    expect(onRefreshFailed).not.toHaveBeenCalled()
  })

  it('never refreshes on 403 FORBIDDEN', async () => {
    const { client, refreshCalls } = setup(() => fail(403, 'FORBIDDEN', 'Admins only'))
    await expect(client.http.delete('/admin/events/1')).rejects.toMatchObject({ status: 403, code: 'FORBIDDEN' })
    expect(refreshCalls()).toHaveLength(0)
  })

  it('never refreshes on 401s that are not TOKEN_EXPIRED', async () => {
    const { client, refreshCalls } = setup(() => fail(401, 'UNAUTHORIZED'))
    await expect(client.http.get('/admin/events')).rejects.toMatchObject({ code: 'UNAUTHORIZED' })
    expect(refreshCalls()).toHaveLength(0)
  })

  it('never refreshes for /auth/login or /auth/refresh failures', async () => {
    const { client, refreshCalls } = setup((config) =>
      pathOf(config) === '/auth/login' ? fail(401, 'TOKEN_EXPIRED') : fail(401, 'TOKEN_EXPIRED'),
    )
    await expect(client.http.post('/auth/login', { email: 'a@b.c', password: 'x' })).rejects.toMatchObject({ code: 'TOKEN_EXPIRED' })
    // A direct refresh call that 401s must not recurse into another refresh.
    await expect(client.http.post('/auth/refresh', { refreshToken: 'x' })).rejects.toMatchObject({ code: 'TOKEN_EXPIRED' })
    expect(refreshCalls()).toHaveLength(1) // only the explicit call above
  })

  it('retries a request only once even if the retry is rejected with TOKEN_EXPIRED again', async () => {
    const { client, adapter, refreshCalls } = setup((config) =>
      pathOf(config) === '/auth/refresh' ? ok(makeAuth({ accessToken: 'new-access', refreshToken: 'new-refresh' })) : fail(401, 'TOKEN_EXPIRED'),
    )
    await expect(client.http.get('/admin/events')).rejects.toMatchObject({ code: 'TOKEN_EXPIRED' })
    expect(refreshCalls()).toHaveLength(1)
    expect(adapter.calls.filter((c) => pathOf(c) === '/admin/events')).toHaveLength(2)
  })

  it('reuses a token refreshed by someone else while the request was in flight (no second rotation)', async () => {
    let release: () => void = () => {}
    const gate = new Promise<void>((r) => (release = r))
    const { client, tokens, refreshCalls, adapter } = setup(async (config) => {
      const path = pathOf(config)
      if (path === '/slow') {
        if (config.headers.get('Authorization') === 'Bearer old-access') {
          await gate
          return fail(401, 'TOKEN_EXPIRED')
        }
        return ok({ path })
      }
      return ok({})
    })

    const slow = client.http.get('/slow')
    // Meanwhile another part of the app refreshed the tokens.
    tokens.access = 'rotated-access'
    release()
    await slow

    expect(refreshCalls()).toHaveLength(0)
    expect(adapter.calls.at(-1)?.headers.get('Authorization')).toBe('Bearer rotated-access')
  })
})
