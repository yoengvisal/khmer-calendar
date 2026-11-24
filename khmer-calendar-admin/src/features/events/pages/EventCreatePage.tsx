import { Link, useNavigate, useSearchParams } from 'react-router'
import { isValidIsoDate } from '@/shared/lib/dates'
import { useToast } from '@/shared/ui'
import { EventForm } from '../components/EventForm'
import { useCreateEvent } from '../hooks'
import { emptyEventForm } from '../validation'

export function EventCreatePage() {
  const navigate = useNavigate()
  const [params] = useSearchParams()
  const toast = useToast()
  const create = useCreateEvent()
  const date = params.get('date')
  const initial = emptyEventForm(date && isValidIsoDate(date) ? date : '')

  return (
    <div className="page page--narrow">
      <header className="page__header">
        <div>
          <Link to="/events" className="back-link">
            ‹ Events
          </Link>
          <h1>New event</h1>
        </div>
      </header>
      <EventForm
        initialValues={initial}
        submitLabel="Create event"
        onCancel={() => navigate(-1)}
        onSubmit={async (body) => {
          const event = await create.mutateAsync(body)
          toast.success('Event created', event.titleEn)
          navigate('/events')
        }}
      />
    </div>
  )
}
