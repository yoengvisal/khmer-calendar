import { QueryClient } from '@tanstack/react-query'
import { ApiError } from '@/core/api/errors'

/** Do not retry client errors (4xx) — only transient failures (network, timeout, 5xx). */
function shouldRetry(failureCount: number, error: unknown): boolean {
  if (failureCount >= 2) return false
  if (error instanceof ApiError) return error.status === 0 || error.status >= 500
  return true
}

export function createQueryClient(): QueryClient {
  return new QueryClient({
    defaultOptions: {
      queries: {
        staleTime: 30_000,
        retry: shouldRetry,
        refetchOnWindowFocus: true,
      },
      mutations: {
        retry: false,
      },
    },
  })
}
