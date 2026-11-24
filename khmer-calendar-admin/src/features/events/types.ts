export type EventCategory = 'PUBLIC_HOLIDAY' | 'BUDDHIST_HOLY_DAY' | 'CULTURAL' | 'OBSERVANCE'
export type EventStatus = 'DRAFT' | 'PUBLISHED' | 'ARCHIVED'

export const EVENT_CATEGORIES: readonly EventCategory[] = ['PUBLIC_HOLIDAY', 'BUDDHIST_HOLY_DAY', 'CULTURAL', 'OBSERVANCE']
export const EVENT_STATUSES: readonly EventStatus[] = ['DRAFT', 'PUBLISHED', 'ARCHIVED']

export interface EventSummary {
  id: string
  titleKm: string
  titleEn: string
  /** Simplified Chinese; null when not translated (apps fall back to English). */
  titleZh: string | null
  category: EventCategory
  /** Inclusive, YYYY-MM-DD. */
  startDate: string
  /** Inclusive, YYYY-MM-DD, >= startDate. */
  endDate: string
  isDayOff: boolean
}

/** The contract's `Event` type (renamed to avoid clashing with the DOM `Event`). */
export interface CalendarEvent extends EventSummary {
  descriptionKm: string | null
  descriptionEn: string | null
  descriptionZh: string | null
  status: EventStatus
  sourceKey: string | null
  createdAt: string
  updatedAt: string
  publishedAt: string | null
}

/** Body for POST /admin/events and (partially) PATCH /admin/events/:id. */
export interface EventWriteBody {
  titleKm: string
  titleEn: string
  titleZh: string | null
  descriptionKm: string | null
  descriptionEn: string | null
  descriptionZh: string | null
  category: EventCategory
  startDate: string
  endDate: string
  isDayOff: boolean
  status: EventStatus
}

export interface AdminEventListParams {
  from?: string
  to?: string
  status?: EventStatus
  category?: EventCategory
  q?: string
  page?: number
  limit?: number
}
