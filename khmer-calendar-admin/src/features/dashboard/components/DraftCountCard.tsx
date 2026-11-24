import { Link } from 'react-router'
import { ErrorState, Spinner } from '@/shared/ui'
import { useDraftCount } from '../hooks'

export function DraftCountCard() {
  const query = useDraftCount()
  return (
    <section className="card dash-card" aria-labelledby="drafts-title">
      <h2 id="drafts-title">Draft events</h2>
      {query.isPending ? (
        <Spinner label="Counting drafts…" />
      ) : query.isError ? (
        <ErrorState error={query.error} onRetry={() => void query.refetch()} />
      ) : (
        <>
          <p className="dash-stat">{query.data}</p>
          <p className="muted">{query.data === 1 ? 'event is' : 'events are'} waiting for review and are not visible publicly.</p>
          {query.data > 0 && (
            <Link to="/events?status=DRAFT" className="btn btn--secondary btn--sm dash-card__cta">
              Review drafts
            </Link>
          )}
        </>
      )}
    </section>
  )
}
