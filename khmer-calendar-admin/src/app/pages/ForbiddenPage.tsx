import { Link } from 'react-router'
import { EmptyState } from '@/shared/ui'

export function ForbiddenPage() {
  return (
    <div className="page">
      <EmptyState
        title="You don't have access to this page"
        description="Ask an administrator if you need this permission."
        action={
          <Link to="/" className="btn btn--secondary">
            Go to dashboard
          </Link>
        }
      />
    </div>
  )
}
