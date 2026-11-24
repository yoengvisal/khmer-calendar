import { keepPreviousData, useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import * as api from './api'
import type { AdminEventListParams, CalendarEvent, EventStatus, EventWriteBody } from './types'

/** All event-derived queries (incl. dashboard + calendar) live under these prefixes so writes can invalidate them. */
export const eventKeys = {
  all: ['events'] as const,
  lists: () => [...eventKeys.all, 'list'] as const,
  list: (params: AdminEventListParams) => [...eventKeys.lists(), params] as const,
  detail: (id: string) => [...eventKeys.all, 'detail', id] as const,
}

const CALENDAR_PREFIX = ['calendar'] as const

export function useEventList(params: AdminEventListParams) {
  return useQuery({
    queryKey: eventKeys.list(params),
    queryFn: () => api.listEvents(params),
    placeholderData: keepPreviousData,
  })
}

export function useEvent(id: string | undefined) {
  return useQuery({
    queryKey: eventKeys.detail(id ?? ''),
    queryFn: () => api.getEvent(id as string),
    enabled: Boolean(id),
  })
}

export function useInvalidateEvents() {
  const queryClient = useQueryClient()
  return (updated?: CalendarEvent) => {
    if (updated) queryClient.setQueryData(eventKeys.detail(updated.id), updated)
    void queryClient.invalidateQueries({ queryKey: eventKeys.all })
    void queryClient.invalidateQueries({ queryKey: CALENDAR_PREFIX })
  }
}

export function useCreateEvent() {
  const invalidate = useInvalidateEvents()
  return useMutation({
    mutationFn: (body: EventWriteBody) => api.createEvent(body),
    onSuccess: (event) => invalidate(event),
  })
}

export function useUpdateEvent() {
  const invalidate = useInvalidateEvents()
  return useMutation({
    mutationFn: ({ id, body }: { id: string; body: Partial<EventWriteBody> }) => api.updateEvent(id, body),
    onSuccess: (event) => invalidate(event),
  })
}

export function useSetEventStatus() {
  const invalidate = useInvalidateEvents()
  return useMutation({
    mutationFn: ({ id, status }: { id: string; status: EventStatus }) => api.updateEvent(id, { status }),
    onSuccess: (event) => invalidate(event),
  })
}

export function useDeleteEvent() {
  const queryClient = useQueryClient()
  const invalidate = useInvalidateEvents()
  return useMutation({
    mutationFn: (id: string) => api.deleteEvent(id),
    onSuccess: (_data, id) => {
      queryClient.removeQueries({ queryKey: eventKeys.detail(id) })
      invalidate()
    },
  })
}
