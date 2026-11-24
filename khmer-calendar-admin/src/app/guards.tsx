import type { ReactNode } from 'react'
import { Navigate, Outlet, useLocation } from 'react-router'
import { restoreSession } from '@/core/auth/authService'
import type { UserRole } from '@/core/auth/types'
import { useAuth } from '@/core/auth/useAuth'
import { Button, PageSpinner } from '@/shared/ui'
import { ForbiddenPage } from './pages/ForbiddenPage'

/** Renders child routes only for an authenticated session; otherwise redirects to /login (remembering where we were). */
export function RequireAuth() {
  const { status, isAuthenticated } = useAuth()
  const location = useLocation()

  if (status === 'restoring') return <PageSpinner label="Restoring your session…" />
  if (status === 'unavailable') {
    return (
      <main className="page" style={{ padding: 'var(--space-8) var(--space-4)' }}>
        <div className="state state--error" role="alert">
          <p className="state__title">Cannot reach the server</p>
          <p className="state__description">We could not restore your session. Check your connection and try again.</p>
          <div className="state__action">
            <Button variant="primary" onClick={() => void restoreSession()}>
              Try again
            </Button>
          </div>
        </div>
      </main>
    )
  }
  if (!isAuthenticated) return <Navigate to="/login" replace state={{ from: location }} />
  return <Outlet />
}

/** Role guard for a subtree. The API enforces roles too; this is UX, not security. */
export function RequireRole({ roles, children }: { roles: UserRole[]; children?: ReactNode }) {
  const { hasRole } = useAuth()
  if (!hasRole(...roles)) return <ForbiddenPage />
  return children ? <>{children}</> : <Outlet />
}
