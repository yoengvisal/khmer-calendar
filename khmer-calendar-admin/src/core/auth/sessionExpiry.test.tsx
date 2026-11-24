import { render, screen } from '@testing-library/react'
import { createMemoryRouter, RouterProvider } from 'react-router'
import { afterEach, describe, expect, it } from 'vitest'
import { RequireAuth } from '@/app/guards'
import { http } from '@/core/api/http'
import { makeAuth } from '@/test/fixtures'
import { createMockAdapter, fail, ok, pathOf } from '@/test/mockAdapter'
import { REFRESH_TOKEN_KEY, session } from './session'

/**
 * Integration of the real wiring in core/api/http.ts: the app's axios instance + session store + route guard.
 */
describe('session expiry wiring', () => {
  const originalAdapter = http.defaults.adapter
  afterEach(() => {
    http.defaults.adapter = originalAdapter
    session.clear(null)
  })

  it('stores rotated tokens after a successful refresh', async () => {
    http.defaults.adapter = createMockAdapter((config) => {
      if (pathOf(config) === '/auth/refresh') return ok(makeAuth({ accessToken: 'access-2', refreshToken: 'refresh-2' }))
      return config.headers.get('Authorization') === 'Bearer access-2' ? ok({ fine: true }) : fail(401, 'TOKEN_EXPIRED')
    })
    session.setSession(makeAuth({ accessToken: 'access-1', refreshToken: 'refresh-1' }))

    await http.get('/admin/events')

    expect(session.getAccessToken()).toBe('access-2')
    expect(window.localStorage.getItem(REFRESH_TOKEN_KEY)).toBe('refresh-2')
  })

  it('clears the session and redirects to /login when the refresh token is rejected', async () => {
    http.defaults.adapter = createMockAdapter((config) =>
      pathOf(config) === '/auth/refresh' ? fail(401, 'INVALID_REFRESH_TOKEN') : fail(401, 'TOKEN_EXPIRED'),
    )
    session.setSession(makeAuth())

    const router = createMemoryRouter(
      [
        { path: '/login', element: <p>Login page</p> },
        { element: <RequireAuth />, children: [{ path: '/', element: <p>Protected page</p> }] },
      ],
      { initialEntries: ['/'] },
    )
    render(<RouterProvider router={router} />)
    expect(screen.getByText('Protected page')).toBeInTheDocument()

    await expect(http.get('/admin/events')).rejects.toMatchObject({ code: 'INVALID_REFRESH_TOKEN' })

    expect(session.getSnapshot()).toMatchObject({ status: 'anonymous', user: null, endReason: 'expired' })
    expect(session.getAccessToken()).toBeNull()
    expect(window.localStorage.getItem(REFRESH_TOKEN_KEY)).toBeNull()
    expect(await screen.findByText('Login page')).toBeInTheDocument()
    expect(router.state.location.pathname).toBe('/login')
  })
})
