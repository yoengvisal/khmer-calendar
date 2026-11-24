import { useMutation, useQuery } from '@tanstack/react-query'
import { eventKeys, useInvalidateEvents } from '@/features/events/hooks'
import * as api from './api'
import type { UpcomingWindow } from './types'

export const dashboardKeys = {
  upcoming: (range: UpcomingWindow) => [...eventKeys.all, 'dashboard', 'upcoming', range] as const,
  draftCount: () => [...eventKeys.all, 'dashboard', 'draft-count'] as const,
}

export function useUpcomingPublished(range: UpcomingWindow) {
  return useQuery({ queryKey: dashboardKeys.upcoming(range), queryFn: () => api.fetchUpcomingPublished(range) })
}

export function useDraftCount() {
  return useQuery({ queryKey: dashboardKeys.draftCount(), queryFn: api.fetchDraftCount })
}

export function useGenerateHolidays() {
  const invalidate = useInvalidateEvents()
  return useMutation({
    mutationFn: (year: number) => api.generateHolidays(year),
    onSuccess: () => invalidate(),
  })
}
