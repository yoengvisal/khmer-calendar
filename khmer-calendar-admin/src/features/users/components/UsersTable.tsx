import { formatTimestamp } from '@/shared/lib/dates'
import { Badge, Button, Table, type Column } from '@/shared/ui'
import type { User } from '../types'

export interface UsersTableProps {
  users: readonly User[]
  currentUserId: string
  busy?: boolean
  onEdit: (user: User) => void
  onResetPassword: (user: User) => void
}

export function UsersTable({ users, currentUserId, busy, onEdit, onResetPassword }: UsersTableProps) {
  const columns: Column<User>[] = [
    {
      key: 'name',
      header: 'User',
      render: (u) => (
        <div className="cell-stack">
          <span className="cell-stack__primary">
            {u.displayName}
            {u.id === currentUserId && <span className="subtle"> (you)</span>}
          </span>
          <span className="cell-stack__secondary">{u.email}</span>
        </div>
      ),
    },
    { key: 'role', header: 'Role', render: (u) => <Badge tone={u.role === 'ADMIN' ? 'accent' : 'info'}>{u.role === 'ADMIN' ? 'Admin' : 'Editor'}</Badge> },
    { key: 'status', header: 'Status', render: (u) => <Badge tone={u.isActive ? 'success' : 'neutral'}>{u.isActive ? 'Active' : 'Inactive'}</Badge> },
    { key: 'lastLogin', header: 'Last sign-in', hideOnMobile: true, render: (u) => formatTimestamp(u.lastLoginAt) },
    { key: 'created', header: 'Created', hideOnMobile: true, render: (u) => formatTimestamp(u.createdAt) },
    {
      key: 'actions',
      header: <span className="visually-hidden">Actions</span>,
      className: 'col-actions',
      render: (u) => (
        <div className="row-actions">
          <Button size="sm" variant="ghost" onClick={() => onEdit(u)} aria-label={`Edit ${u.email}`}>
            Edit
          </Button>
          <Button size="sm" variant="ghost" onClick={() => onResetPassword(u)} aria-label={`Reset password for ${u.email}`}>
            Reset password
          </Button>
        </div>
      ),
    },
  ]
  return <Table caption="Users" columns={columns} rows={users} rowKey={(u) => u.id} busy={busy} />
}
