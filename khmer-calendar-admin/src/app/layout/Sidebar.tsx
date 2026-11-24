import { NavLink } from 'react-router'
import { useAuth } from '@/core/auth/useAuth'
import type { UserRole } from '@/core/auth/types'
import { cx } from '@/shared/lib/cx'
import { BrandLogo } from '@/shared/ui'

interface NavItem {
  to: string
  label: string
  icon: string
  roles?: UserRole[]
  end?: boolean
}

const NAV: NavItem[] = [
  { to: '/', label: 'Dashboard', icon: '◧', end: true },
  { to: '/events', label: 'Events', icon: '☰' },
  { to: '/calendar', label: 'Calendar', icon: '▦' },
  { to: '/users', label: 'Users', icon: '◉', roles: ['ADMIN'] },
]

export function Sidebar({ open, onNavigate }: { open: boolean; onNavigate: () => void }) {
  const { hasRole } = useAuth()
  return (
    <aside id="app-sidebar" className={cx('sidebar', open && 'sidebar--open')} aria-label="Main navigation">
      <div className="sidebar__brand">
        <BrandLogo size={36} className="sidebar__logo" />
        <span>
          <span className="sidebar__name">Khmer Calendar</span>
          <span className="sidebar__sub">Admin</span>
        </span>
      </div>
      <nav>
        <ul className="sidebar__nav">
          {NAV.filter((item) => !item.roles || hasRole(...item.roles)).map((item) => (
            <li key={item.to}>
              <NavLink to={item.to} end={item.end} className={({ isActive }) => cx('sidebar__link', isActive && 'sidebar__link--active')} onClick={onNavigate}>
                <span className="sidebar__icon" aria-hidden="true">
                  {item.icon}
                </span>
                {item.label}
              </NavLink>
            </li>
          ))}
        </ul>
      </nav>
    </aside>
  )
}
