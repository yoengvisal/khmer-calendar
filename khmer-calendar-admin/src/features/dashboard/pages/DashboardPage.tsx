import { useMemo } from 'react'
import { useCurrentUser } from '@/core/auth/useAuth'
import { addDays, todayIso } from '@/shared/lib/dates'
import { DraftCountCard } from '../components/DraftCountCard'
import { GenerateHolidaysCard } from '../components/GenerateHolidaysCard'
import { UpcomingHolidaysCard } from '../components/UpcomingHolidaysCard'
import './dashboard.css'

export function DashboardPage() {
  const user = useCurrentUser()
  const today = todayIso()
  const range = useMemo(() => ({ from: today, to: addDays(today, 30) }), [today])

  return (
    <div className="page">
      <header className="page__header">
        <div>
          <h1>Dashboard</h1>
          <p className="page__subtitle">Welcome back, {user.displayName}.</p>
        </div>
      </header>
      <div className="dash-grid">
        <UpcomingHolidaysCard range={range} />
        <DraftCountCard />
        <GenerateHolidaysCard />
      </div>
    </div>
  )
}
