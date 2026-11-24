import { keepPreviousData, useQuery } from '@tanstack/react-query'
import * as api from './api'

export const calendarKeys = {
  all: ['calendar'] as const,
  month: (year: number, month: number) => [...calendarKeys.all, 'month', year, month] as const,
}

export function useCalendarMonth(year: number, month: number) {
  return useQuery({
    queryKey: calendarKeys.month(year, month),
    queryFn: () => api.getCalendarMonth(year, month),
    placeholderData: keepPreviousData,
    staleTime: 60_000,
  })
}
