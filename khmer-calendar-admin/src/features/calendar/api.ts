import { unwrap } from '@/core/api/client'
import { http } from '@/core/api/http'
import type { ApiSuccess } from '@/core/api/types'
import type { CalendarMonth } from './types'

/** Public, cacheable endpoint — no bearer token needed. */
export async function getCalendarMonth(year: number, month: number): Promise<CalendarMonth> {
  return unwrap(await http.get<ApiSuccess<CalendarMonth>>(`/calendar/months/${year}/${month}`, { skipAuth: true }))
}
