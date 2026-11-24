import { config } from '@/app/config'
import { useCurrentUser } from '@/core/auth/useAuth'
import { useLogout } from '@/features/auth/hooks'
import { Badge, Button } from '@/shared/ui'

export function Topbar({ navOpen, onToggleNav }: { navOpen: boolean; onToggleNav: () => void }) {
  const user = useCurrentUser()
  const logout = useLogout()
  return (
    <header className="topbar">
      <button
        type="button"
        className="icon-btn topbar__menu"
        aria-label={navOpen ? 'Close navigation' : 'Open navigation'}
        aria-expanded={navOpen}
        aria-controls="app-sidebar"
        onClick={onToggleNav}
      >
        ☰
      </button>
      {!config.isProduction && (
        <Badge tone="warning" title={`API: ${config.apiBaseUrl}`}>
          {config.appEnv.toUpperCase()}
        </Badge>
      )}
      <div className="topbar__spacer" />
      <div className="topbar__user">
        <span className="topbar__name" title={user.email}>
          {user.displayName}
        </span>
        <Badge tone={user.role === 'ADMIN' ? 'accent' : 'info'}>{user.role === 'ADMIN' ? 'Admin' : 'Editor'}</Badge>
      </div>
      <Button size="sm" variant="ghost" onClick={() => logout.mutate()} loading={logout.isPending}>
        Sign out
      </Button>
    </header>
  )
}
