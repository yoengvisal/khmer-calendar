import { unwrap, unwrapPage } from '@/core/api/client'
import { http } from '@/core/api/http'
import type { ApiSuccess } from '@/core/api/types'
import type { CalendarEvent } from '@/features/events/types'
import type { GenerateEventsResult, UpcomingWindow } from './types'

/** Published events overlapping the window, sorted by start date (max 100 — plenty for 30 days). */
export async function fetchUpcomingPublished({ from, to }: UpcomingWindow): Promise<CalendarEvent[]> {
  const page = unwrapPage(
    await http.get<ApiSuccess<CalendarEvent[]>>('/admin/events', { params: { from, to, status: 'PUBLISHED', page: 1, limit: 100 } }),
  )
  return [...page.items].sort((a, b) => a.startDate.localeCompare(b.startDate))
}

/** Uses pagination meta to count without downloading rows. */
export async function fetchDraftCount(): Promise<number> {
  const page = unwrapPage(await http.get<ApiSuccess<CalendarEvent[]>>('/admin/events', { params: { status: 'DRAFT', page: 1, limit: 1 } }))
  return page.meta.total
}

export async function generateHolidays(year: number): Promise<GenerateEventsResult> {
  return unwrap(await http.post<ApiSuccess<GenerateEventsResult>>('/admin/events/generate', { year }))
}
