import { isRouteErrorResponse, useRouteError } from 'react-router'
import { ErrorState } from '@/shared/ui'

/** Last-resort boundary for render errors inside routes. */
export function RouteErrorPage() {
  const error = useRouteError()
  const message = isRouteErrorResponse(error) ? `${error.status} ${error.statusText}` : error
  return (
    <main className="page" style={{ padding: 'var(--space-8) var(--space-4)' }}>
      <ErrorState error={message instanceof Error ? message : new Error(String(message))} title="Something went wrong" onRetry={() => window.location.reload()} />
    </main>
  )
}
