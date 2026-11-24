import { useState } from 'react'
import { Link, useSearchParams } from 'react-router'
import { errorMessage } from '@/core/api/errors'
import { useAuth } from '@/core/auth/useAuth'
import { ConfirmDialog, EmptyState, ErrorState, PageSpinner, Pagination, useToast } from '@/shared/ui'
import { EventFiltersBar } from '../components/EventFiltersBar'
import { EventsTable } from '../components/EventsTable'
import { filtersToQuery, filtersToSearchParams, parseEventFilters, type EventFilters } from '../filters'
import { useDeleteEvent, useEventList, useSetEventStatus } from '../hooks'
import type { CalendarEvent } from '../types'

export function EventsPage() {
  const [searchParams, setSearchParams] = useSearchParams()
  const filters = parseEventFilters(searchParams)
  const query = useEventList(filtersToQuery(filters))
  const { hasRole } = useAuth()
  const canDelete = hasRole('ADMIN')
  const toast = useToast()

  const setStatus = useSetEventStatus()
  const deleteEvent = useDeleteEvent()
  const [toDelete, setToDelete] = useState<CalendarEvent | null>(null)

  function updateFilters(patch: Partial<EventFilters>) {
    setSearchParams(filtersToSearchParams({ ...filters, page: 1, ...patch }), { replace: true })
  }

  function toggleStatus(event: CalendarEvent) {
    const status = event.status === 'PUBLISHED' ? 'DRAFT' : 'PUBLISHED'
    setStatus.mutate(
      { id: event.id, status },
      {
        onSuccess: () => toast.success(status === 'PUBLISHED' ? 'Event published' : 'Event unpublished', event.titleEn),
        onError: (err) => toast.error('Could not change status', errorMessage(err)),
      },
    )
  }

  function confirmDelete() {
    if (!toDelete) return
    const event = toDelete
    deleteEvent.mutate(event.id, {
      onSuccess: () => {
        setToDelete(null)
        toast.success('Event deleted', event.titleEn)
      },
    })
  }

  const data = query.data

  return (
    <div className="page">
      <header className="page__header">
        <div>
          <h1>Events</h1>
          <p className="page__subtitle">Holidays, holy days and observances shown in the calendar.</p>
        </div>
        <Link to="/events/new" className="btn btn--primary">
          + New event
        </Link>
      </header>

      <EventFiltersBar
        filters={filters}
        onChange={updateFilters}
        onReset={() => setSearchParams(filtersToSearchParams(parseEventFilters(new URLSearchParams())), { replace: true })}
      />

      {query.isPending ? (
        <PageSpinner label="Loading events…" />
      ) : query.isError ? (
        <ErrorState error={query.error} onRetry={() => void query.refetch()} />
      ) : data && data.items.length === 0 ? (
        <EmptyState
          title="No events match these filters"
          description="Try another year or month, clear the filters, or create a new event."
          action={
            <Link to="/events/new" className="btn btn--primary">
              New event
            </Link>
          }
        />
      ) : data ? (
        <>
          <EventsTable
            events={data.items}
            canDelete={canDelete}
            busy={query.isPlaceholderData}
            pendingStatusId={setStatus.isPending ? setStatus.variables?.id : null}
            onToggleStatus={toggleStatus}
            onDelete={(e) => {
              deleteEvent.reset()
              setToDelete(e)
            }}
          />
          <Pagination
            page={data.meta.page}
            totalPages={data.meta.totalPages}
            total={data.meta.total}
            limit={data.meta.limit}
            onPageChange={(page) => setSearchParams(filtersToSearchParams({ ...filters, page }))}
          />
        </>
      ) : null}

      <ConfirmDialog
        open={toDelete !== null}
        title="Delete event?"
        tone="danger"
        confirmLabel="Delete"
        loading={deleteEvent.isPending}
        error={deleteEvent.isError ? errorMessage(deleteEvent.error) : null}
        message={
          toDelete && (
            <p>
              <strong className="km" lang="km">
                {toDelete.titleKm}
              </strong>{' '}
              ({toDelete.titleEn}) will be permanently deleted. This cannot be undone.
            </p>
          )
        }
        onConfirm={confirmDelete}
        onCancel={() => setToDelete(null)}
      />
    </div>
  )
}
