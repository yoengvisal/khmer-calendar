import { createBrowserRouter, type RouteObject } from 'react-router'
import { LoginPage } from '@/features/auth/pages/LoginPage'
import { CalendarPage } from '@/features/calendar/pages/CalendarPage'
import { DashboardPage } from '@/features/dashboard/pages/DashboardPage'
import { EventCreatePage } from '@/features/events/pages/EventCreatePage'
import { EventEditPage } from '@/features/events/pages/EventEditPage'
import { EventsPage } from '@/features/events/pages/EventsPage'
import { UsersPage } from '@/features/users/pages/UsersPage'
import { RequireAuth, RequireRole } from './guards'
import { AppLayout } from './layout/AppLayout'
import { NotFoundPage } from './pages/NotFoundPage'
import { RouteErrorPage } from './pages/RouteErrorPage'

export const routes: RouteObject[] = [
  { path: '/login', element: <LoginPage />, errorElement: <RouteErrorPage /> },
  {
    element: <RequireAuth />,
    errorElement: <RouteErrorPage />,
    children: [
      {
        element: <AppLayout />,
        children: [
          { index: true, element: <DashboardPage /> },
          { path: 'events', element: <EventsPage /> },
          { path: 'events/new', element: <EventCreatePage /> },
          { path: 'events/:id/edit', element: <EventEditPage /> },
          { path: 'calendar', element: <CalendarPage /> },
          {
            element: <RequireRole roles={['ADMIN']} />,
            children: [{ path: 'users', element: <UsersPage /> }],
          },
          { path: '*', element: <NotFoundPage /> },
        ],
      },
    ],
  },
]

export function createAppRouter() {
  return createBrowserRouter(routes)
}
