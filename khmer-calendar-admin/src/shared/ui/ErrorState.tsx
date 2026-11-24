import { ApiError, errorMessage } from '@/core/api/errors'
import { Button } from './Button'

export function ErrorState({ error, title = 'Could not load data', onRetry }: { error: unknown; title?: string; onRetry?: () => void }) {
  const requestId = error instanceof ApiError ? error.requestId : null
  return (
    <div className="state state--error" role="alert">
      <p className="state__title">{title}</p>
      <p className="state__description">{errorMessage(error)}</p>
      {requestId && (
        <p className="state__meta">
          Request ID: <code>{requestId}</code>
        </p>
      )}
      {onRetry && (
        <div className="state__action">
          <Button onClick={onRetry}>Try again</Button>
        </div>
      )}
    </div>
  )
}
