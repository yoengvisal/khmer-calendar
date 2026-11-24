import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { render } from '@testing-library/react'
import type { ReactElement } from 'react'
import { createMemoryRouter, RouterProvider, type RouteObject } from 'react-router'
import { session } from '@/core/auth/session'
import type { User } from '@/core/auth/types'
import { ToastProvider } from '@/shared/ui'
import { makeAuth } from './fixtures'

export function createTestQueryClient() {
  return new QueryClient({ defaultOptions: { queries: { retry: false, gcTime: Infinity }, mutations: { retry: false } } })
}

interface Options {
  path?: string
  route?: string
  user?: User | null
  extraRoutes?: RouteObject[]
}

/** Renders `ui` at `route` inside QueryClient + Toast + a memory router, with an optional signed-in user. */
export function renderWithProviders(ui: ReactElement, { path = '/', route = path, user, extraRoutes = [] }: Options = {}) {
  if (user) session.setSession(makeAuth({ user }))
  else session.clear(null)
  const queryClient = createTestQueryClient()
  const router = createMemoryRouter([{ path, element: ui }, ...extraRoutes], { initialEntries: [route] })
  const result = render(
    <QueryClientProvider client={queryClient}>
      <ToastProvider>
        <RouterProvider router={router} />
      </ToastProvider>
    </QueryClientProvider>,
  )
  return { ...result, router, queryClient }
}
