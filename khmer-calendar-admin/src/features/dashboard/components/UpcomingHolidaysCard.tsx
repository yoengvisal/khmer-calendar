import { Link } from 'react-router'
import { CategoryBadge } from '@/features/events/components/EventBadges'
import { formatDateRange } from '@/shared/lib/dates'
import { Badge, ErrorState, Spinner } from '@/shared/ui'
import { useUpcomingPublished } from '../hooks'
import type { UpcomingWindow } from '../types'

export function UpcomingHolidaysCard({ range }: { range: UpcomingWindow }) {
  const query = useUpcomingPublished(range)
  return (
    <section className="card dash-card dash-card--wide" aria-labelledby="upcoming-title">
      <div className="card__header">
        <h2 id="upcoming-title">Published in the next 30 days</h2>
        <Link to={`/calendar`} className="btn btn--ghost btn--sm">
          Open calendar
        </Link>
      </div>
      {query.isPending ? (
        <Spinner label="Loading upcoming events…" />
      ) : query.isError ? (
        <ErrorState error={query.error} onRetry={() => void query.refetch()} />
      ) : query.data.length === 0 ? (
        <p className="muted">No published events between {formatDateRange(range.from, range.to)}.</p>
      ) : (
        <ul className="upcoming">
          {query.data.map((e) => (
            <li key={e.id} className="upcoming__item">
              <div className="upcoming__date">{formatDateRange(e.startDate, e.endDate)}</div>
              <div className="upcoming__titles">
                <Link to={`/events/${e.id}/edit`} className="km upcoming__km" lang="km">
                  {e.titleKm}
                </Link>
                <span className="muted">{e.titleEn}</span>
              </div>
              <div className="upcoming__badges">
                <CategoryBadge category={e.category} />
                {e.isDayOff && <Badge tone="danger">Day off</Badge>}
              </div>
            </li>
          ))}
        </ul>
      )}
    </section>
  )
}
