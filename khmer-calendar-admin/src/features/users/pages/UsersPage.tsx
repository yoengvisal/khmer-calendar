import { useState } from 'react'
import { useCurrentUser } from '@/core/auth/useAuth'
import { Button, EmptyState, ErrorState, PageSpinner, Pagination } from '@/shared/ui'
import { ResetPasswordDialog } from '../components/ResetPasswordDialog'
import { UserFormDialog } from '../components/UserFormDialog'
import { UsersTable } from '../components/UsersTable'
import { useUserList } from '../hooks'
import type { User } from '../types'

const PAGE_SIZE = 20

export function UsersPage() {
  const me = useCurrentUser()
  const [page, setPage] = useState(1)
  const query = useUserList({ page, limit: PAGE_SIZE })
  const [editing, setEditing] = useState<{ user: User | null } | null>(null)
  const [resetting, setResetting] = useState<User | null>(null)

  return (
    <div className="page">
      <header className="page__header">
        <div>
          <h1>Users</h1>
          <p className="page__subtitle">Admins manage users and can delete events. Editors manage events only.</p>
        </div>
        <Button variant="primary" onClick={() => setEditing({ user: null })}>
          + New user
        </Button>
      </header>

      {query.isPending ? (
        <PageSpinner label="Loading users…" />
      ) : query.isError ? (
        <ErrorState error={query.error} onRetry={() => void query.refetch()} />
      ) : query.data.items.length === 0 ? (
        <EmptyState title="No users yet" />
      ) : (
        <>
          <UsersTable
            users={query.data.items}
            currentUserId={me.id}
            busy={query.isPlaceholderData}
            onEdit={(user) => setEditing({ user })}
            onResetPassword={setResetting}
          />
          <Pagination
            page={query.data.meta.page}
            totalPages={query.data.meta.totalPages}
            total={query.data.meta.total}
            limit={query.data.meta.limit}
            onPageChange={setPage}
          />
        </>
      )}

      <UserFormDialog open={editing !== null} user={editing?.user ?? null} currentUserId={me.id} onClose={() => setEditing(null)} />
      <ResetPasswordDialog user={resetting} onClose={() => setResetting(null)} />
    </div>
  )
}
