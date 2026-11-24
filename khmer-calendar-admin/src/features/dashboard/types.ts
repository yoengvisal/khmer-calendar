import type { CalendarEvent } from '@/features/events/types'

export interface GenerateEventsResult {
  /** Newly created events; always DRAFT. */
  created: CalendarEvent[]
  /** sourceKeys of rules whose event already existed (generation is idempotent). */
  skipped: string[]
}

export interface UpcomingWindow {
  from: string
  to: string
}
