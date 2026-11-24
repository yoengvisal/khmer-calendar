import { rangeFor } from '@/shared/lib/dates'
import { EVENTS_PAGE_SIZE } from './constants'
import { EVENT_CATEGORIES, EVENT_STATUSES, type AdminEventListParams, type EventCategory, type EventStatus } from './types'

/** Filter state for the events list, persisted in the URL query string. */
export interface EventFilters {
  year: number
  month: number | null
  status: EventStatus | null
  category: EventCategory | null
  q: string
  page: number
}

function intIn(value: string | null, min: number, max: number): number | null {
  if (value === null || !/^\d+$/.test(value)) return null
  const n = Number(value)
  return n >= min && n <= max ? n : null
}

export function parseEventFilters(params: URLSearchParams, now = new Date()): EventFilters {
  const status = params.get('status')
  const category = params.get('category')
  return {
    year: intIn(params.get('year'), 1900, 2100) ?? now.getFullYear(),
    month: intIn(params.get('month'), 1, 12),
    status: EVENT_STATUSES.includes(status as EventStatus) ? (status as EventStatus) : null,
    category: EVENT_CATEGORIES.includes(category as EventCategory) ? (category as EventCategory) : null,
    q: params.get('q')?.trim() ?? '',
    page: intIn(params.get('page'), 1, 100_000) ?? 1,
  }
}

export function filtersToSearchParams(filters: EventFilters): URLSearchParams {
  const out = new URLSearchParams()
  out.set('year', String(filters.year))
  if (filters.month) out.set('month', String(filters.month))
  if (filters.status) out.set('status', filters.status)
  if (filters.category) out.set('category', filters.category)
  if (filters.q) out.set('q', filters.q)
  if (filters.page > 1) out.set('page', String(filters.page))
  return out
}

export function filtersToQuery(filters: EventFilters): AdminEventListParams {
  const { from, to } = rangeFor(filters.year, filters.month)
  return {
    from,
    to,
    status: filters.status ?? undefined,
    category: filters.category ?? undefined,
    q: filters.q || undefined,
    page: filters.page,
    limit: EVENTS_PAGE_SIZE,
  }
}
