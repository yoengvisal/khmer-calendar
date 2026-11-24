import { Navigate, useLocation, useNavigate } from 'react-router'
import { config } from '@/app/config'
import { useAuth } from '@/core/auth/useAuth'
import { Badge, BrandLogo } from '@/shared/ui'
import { LoginForm } from '../components/LoginForm'
import './login.css'

interface FromState {
  from?: { pathname?: string; search?: string }
}

export function LoginPage() {
  const { isAuthenticated, endReason } = useAuth()
  const navigate = useNavigate()
  const location = useLocation()
  const from = (location.state as FromState | null)?.from
  const target = from?.pathname && from.pathname !== '/login' ? `${from.pathname}${from.search ?? ''}` : '/'

  if (isAuthenticated) return <Navigate to={target} replace />

  return (
    <main className="login">
      <div className="login__card card">
        <div className="login__brand">
          <BrandLogo size={48} className="login__logo" />
          <div>
            <h1 className="login__title">Khmer Calendar Admin</h1>
            <p className="km login__subtitle" lang="km">
              ប្រតិទិនខ្មែរ
            </p>
          </div>
          {!config.isProduction && <Badge tone="warning">{config.appEnv}</Badge>}
        </div>
        {endReason === 'expired' && (
          <p className="notice notice--warning" role="status">
            Your session has expired. Please sign in again.
          </p>
        )}
        <LoginForm onSuccess={() => navigate(target, { replace: true })} />
      </div>
    </main>
  )
}
