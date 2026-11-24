import { Link, useNavigate, useParams } from 'react-router'
import { formatTimestamp } from '@/shared/lib/dates'
import { ErrorState, PageSpinner, useToast } from '@/shared/ui'
import { StatusBadge } from '../components/EventBadges'
import { EventForm } from '../components/EventForm'
import { useEvent, useUpdateEvent } from '../hooks'
import { eventToFormValues } from '../validation'

export function EventEditPage() {
  const { id } = useParams<{ id: string }>()
  const navigate = useNavigate()
  const toast = useToast()
  const query = useEvent(id)
  const update = useUpdateEvent()

  return (
    <div className="page page--narrow">
      <header className="page__header">
        <div>
          <Link to="/events" className="back-link">
            ‹ Events
          </Link>
          <h1>Edit event</h1>
          {query.data && (
            <p className="page__subtitle row">
              <StatusBadge status={query.data.status} />
              <span>Updated {formatTimestamp(query.data.updatedAt)}</span>
              {query.data.sourceKey && <code className="subtle">{query.data.sourceKey}</code>}
            </p>
          )}
        </div>
      </header>
      {query.isPending ? (
        <PageSpinner label="Loading event…" />
      ) : query.isError ? (
        <ErrorState error={query.error} title="Could not load this event" onRetry={() => void query.refetch()} />
      ) : (
        <EventForm
          // Remount when a different event loads so the form re-initialises (not on background refetches).
          key={query.data.id}
          initialValues={eventToFormValues(query.data)}
          submitLabel="Save changes"
          onCancel={() => navigate(-1)}
          onSubmit={async (body) => {
            const event = await update.mutateAsync({ id: query.data.id, body })
            toast.success('Event saved', event.titleEn)
            navigate('/events')
          }}
        />
      )}
    </div>
  )
}
