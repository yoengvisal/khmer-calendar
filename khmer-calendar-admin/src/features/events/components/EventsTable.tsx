import { Link } from 'react-router'
import { formatDateRange } from '@/shared/lib/dates'
import { Button, Table, type Column } from '@/shared/ui'
import type { CalendarEvent } from '../types'
import { CategoryBadge, DayOffBadge, StatusBadge } from './EventBadges'

export interface EventsTableProps {
  events: readonly CalendarEvent[]
  canDelete: boolean
  busy?: boolean
  /** id of the event whose status is being changed, to show a spinner on that row. */
  pendingStatusId?: string | null
  onToggleStatus: (event: CalendarEvent) => void
  onDelete: (event: CalendarEvent) => void
}

export function EventsTable({ events, canDelete, busy, pendingStatusId, onToggleStatus, onDelete }: EventsTableProps) {
  const columns: Column<CalendarEvent>[] = [
    {
      key: 'title',
      header: 'Title',
      render: (e) => (
        <div className="cell-stack">
          <Link to={`/events/${e.id}/edit`} className="cell-stack__primary km" lang="km">
            {e.titleKm}
          </Link>
          <span className="cell-stack__secondary">
            <span>{e.titleEn}</span>
            {e.titleZh && (
              <>
                {' · '}
                <span lang="zh-Hans">{e.titleZh}</span>
              </>
            )}
          </span>
        </div>
      ),
    },
    { key: 'dates', header: 'Date', render: (e) => formatDateRange(e.startDate, e.endDate) },
    { key: 'category', header: 'Category', render: (e) => <CategoryBadge category={e.category} /> },
    { key: 'status', header: 'Status', render: (e) => <StatusBadge status={e.status} /> },
    { key: 'dayOff', header: 'Day off', render: (e) => <DayOffBadge isDayOff={e.isDayOff} /> },
    {
      key: 'actions',
      header: <span className="visually-hidden">Actions</span>,
      className: 'col-actions',
      render: (e) => {
        const isPublished = e.status === 'PUBLISHED'
        return (
          <div className="row-actions">
            <Link className="btn btn--ghost btn--sm" to={`/events/${e.id}/edit`} aria-label={`Edit ${e.titleEn}`}>
              Edit
            </Link>
            <Button
              size="sm"
              variant={isPublished ? 'secondary' : 'primary'}
              onClick={() => onToggleStatus(e)}
              loading={pendingStatusId === e.id}
              aria-label={`${isPublished ? 'Unpublish' : 'Publish'} ${e.titleEn}`}
            >
              {isPublished ? 'Unpublish' : 'Publish'}
            </Button>
            {canDelete && (
              <Button size="sm" variant="ghost" onClick={() => onDelete(e)} aria-label={`Delete ${e.titleEn}`}>
                Delete
              </Button>
            )}
          </div>
        )
      },
    },
  ]
  return <Table caption="Events" columns={columns} rows={events} rowKey={(e) => e.id} busy={busy} />
}
