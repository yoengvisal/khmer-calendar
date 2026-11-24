import { unwrap, unwrapPage } from '@/core/api/client'
import { http } from '@/core/api/http'
import type { ApiSuccess, Paginated } from '@/core/api/types'
import type { AdminEventListParams, CalendarEvent, EventWriteBody } from './types'

function cleanParams(params: AdminEventListParams): Record<string, string | number> {
  const out: Record<string, string | number> = {}
  for (const [key, value] of Object.entries(params)) {
    if (value !== undefined && value !== null && value !== '') out[key] = value as string | number
  }
  return out
}

export async function listEvents(params: AdminEventListParams): Promise<Paginated<CalendarEvent>> {
  return unwrapPage(await http.get<ApiSuccess<CalendarEvent[]>>('/admin/events', { params: cleanParams(params) }))
}

export async function getEvent(id: string): Promise<CalendarEvent> {
  return unwrap(await http.get<ApiSuccess<CalendarEvent>>(`/admin/events/${encodeURIComponent(id)}`))
}

export async function createEvent(body: EventWriteBody): Promise<CalendarEvent> {
  return unwrap(await http.post<ApiSuccess<CalendarEvent>>('/admin/events', body))
}

export async function updateEvent(id: string, body: Partial<EventWriteBody>): Promise<CalendarEvent> {
  return unwrap(await http.patch<ApiSuccess<CalendarEvent>>(`/admin/events/${encodeURIComponent(id)}`, body))
}

export async function deleteEvent(id: string): Promise<void> {
  await http.delete<ApiSuccess<{ deleted: true }>>(`/admin/events/${encodeURIComponent(id)}`)
}
