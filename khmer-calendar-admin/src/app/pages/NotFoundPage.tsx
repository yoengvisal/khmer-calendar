import { Link } from 'react-router'
import { EmptyState } from '@/shared/ui'

export function NotFoundPage() {
  return (
    <div className="page">
      <EmptyState
        title="Page not found"
        action={
          <Link to="/" className="btn btn--secondary">
            Go to dashboard
          </Link>
        }
      />
    </div>
  )
}
