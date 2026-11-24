import { useId, useState, type FormEvent } from 'react'
import { ApiError, errorMessage, getFieldErrors } from '@/core/api/errors'
import { Button, Checkbox, Dialog, Input, Select, useToast } from '@/shared/ui'
import { useCreateUser, useUpdateUser } from '../hooks'
import { PASSWORD_MIN_LENGTH, USER_ROLES, type User, type UserRole } from '../types'
import { validateDisplayName, validateEmail, validatePassword } from '../validation'

const roleOptions = USER_ROLES.map((r) => ({ value: r, label: r === 'ADMIN' ? 'Admin — full access' : 'Editor — manage events' }))

type Errors = Partial<Record<'email' | 'displayName' | 'password' | 'role' | 'isActive', string | string[]>>

export interface UserFormDialogProps {
  open: boolean
  /** null = create a new user. */
  user: User | null
  currentUserId: string
  onClose: () => void
}

export function UserFormDialog({ open, user, currentUserId, onClose }: UserFormDialogProps) {
  const formId = useId()
  const create = useCreateUser()
  const update = useUpdateUser()
  const pending = create.isPending || update.isPending
  return (
    <Dialog
      open={open}
      onClose={onClose}
      dismissible={!pending}
      title={user ? 'Edit user' : 'New user'}
      description={user ? user.email : 'The user signs in with this email and password.'}
      footer={
        <>
          <Button variant="ghost" onClick={onClose} disabled={pending}>
            Cancel
          </Button>
          <Button type="submit" form={formId} variant="primary" loading={pending}>
            {user ? 'Save changes' : 'Create user'}
          </Button>
        </>
      }
    >
      <UserForm formId={formId} user={user} isSelf={user?.id === currentUserId} onDone={onClose} create={create} update={update} />
    </Dialog>
  )
}

interface UserFormProps {
  formId: string
  user: User | null
  isSelf: boolean
  onDone: () => void
  create: ReturnType<typeof useCreateUser>
  update: ReturnType<typeof useUpdateUser>
}

function UserForm({ formId, user, isSelf, onDone, create, update }: UserFormProps) {
  const toast = useToast()
  const [email, setEmail] = useState('')
  const [displayName, setDisplayName] = useState(user?.displayName ?? '')
  const [password, setPassword] = useState('')
  const [role, setRole] = useState<UserRole>(user?.role ?? 'EDITOR')
  const [isActive, setIsActive] = useState(user?.isActive ?? true)
  const [errors, setErrors] = useState<Errors>({})
  const [formError, setFormError] = useState<string | null>(null)

  function validate(): Errors {
    const next: Errors = {}
    const nameErr = validateDisplayName(displayName)
    if (nameErr) next.displayName = nameErr
    if (!user) {
      const emailErr = validateEmail(email)
      if (emailErr) next.email = emailErr
      const pwErr = validatePassword(password)
      if (pwErr) next.password = pwErr
    }
    return next
  }

  function handleServerError(err: unknown) {
    const fields = getFieldErrors(err)
    const mapped: Errors = {}
    for (const key of ['email', 'displayName', 'password', 'role', 'isActive'] as const) {
      if (fields[key]) mapped[key] = fields[key]
    }
    if (err instanceof ApiError && err.code === 'CONFLICT') mapped.email = 'A user with this email already exists.'
    setErrors(mapped)
    setFormError(Object.keys(mapped).length > 0 ? 'Please fix the highlighted fields.' : errorMessage(err))
  }

  function handleSubmit(e: FormEvent) {
    e.preventDefault()
    setFormError(null)
    const next = validate()
    setErrors(next)
    if (Object.keys(next).length > 0) return

    if (user) {
      const body = {
        displayName: displayName.trim(),
        ...(isSelf ? {} : { role, isActive }),
      }
      update.mutate(
        { id: user.id, body },
        {
          onSuccess: (saved) => {
            toast.success('User updated', saved.email)
            onDone()
          },
          onError: handleServerError,
        },
      )
    } else {
      create.mutate(
        { email: email.trim(), displayName: displayName.trim(), password, role },
        {
          onSuccess: (saved) => {
            toast.success('User created', saved.email)
            onDone()
          },
          onError: handleServerError,
        },
      )
    }
  }

  return (
    <form id={formId} className="stack" onSubmit={handleSubmit} noValidate>
      {formError && (
        <p className="form-error" role="alert">
          {formError}
        </p>
      )}
      {!user && (
        <Input
          label="Email"
          type="email"
          name="email"
          autoComplete="off"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          error={errors.email}
          required
          autoFocus
        />
      )}
      <Input
        label="Display name"
        name="displayName"
        value={displayName}
        onChange={(e) => setDisplayName(e.target.value)}
        error={errors.displayName}
        required
        autoFocus={Boolean(user)}
      />
      {!user && (
        <Input
          label="Password"
          type="password"
          name="password"
          autoComplete="new-password"
          value={password}
          minLength={PASSWORD_MIN_LENGTH}
          onChange={(e) => setPassword(e.target.value)}
          error={errors.password}
          hint={`At least ${PASSWORD_MIN_LENGTH} characters.`}
          required
        />
      )}
      <Select
        label="Role"
        name="role"
        options={roleOptions}
        value={role}
        onChange={(e) => setRole(e.target.value as UserRole)}
        error={errors.role}
        disabled={isSelf}
        hint={isSelf ? 'You cannot change your own role.' : undefined}
      />
      {user && (
        <Checkbox
          label="Active"
          hint={isSelf ? 'You cannot deactivate your own account.' : 'Inactive users cannot sign in.'}
          checked={isActive}
          disabled={isSelf}
          onChange={(e) => setIsActive(e.target.checked)}
        />
      )}
    </form>
  )
}
