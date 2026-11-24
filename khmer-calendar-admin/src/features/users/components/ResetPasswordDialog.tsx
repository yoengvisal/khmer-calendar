import { useId, useState, type FormEvent } from 'react'
import { errorMessage, getFieldErrors } from '@/core/api/errors'
import { Button, Dialog, Input, useToast } from '@/shared/ui'
import { useUpdateUser } from '../hooks'
import { PASSWORD_MIN_LENGTH, type User } from '../types'
import { validatePassword } from '../validation'

export function ResetPasswordDialog({ user, onClose }: { user: User | null; onClose: () => void }) {
  const formId = useId()
  const update = useUpdateUser()
  return (
    <Dialog
      open={user !== null}
      onClose={onClose}
      dismissible={!update.isPending}
      size="sm"
      title="Reset password"
      description={user ? `Set a new password for ${user.email}. Share it with them through a secure channel.` : undefined}
      footer={
        <>
          <Button variant="ghost" onClick={onClose} disabled={update.isPending}>
            Cancel
          </Button>
          <Button type="submit" form={formId} variant="primary" loading={update.isPending}>
            Set password
          </Button>
        </>
      }
    >
      {user && <ResetPasswordForm formId={formId} user={user} update={update} onDone={onClose} />}
    </Dialog>
  )
}

function ResetPasswordForm({
  formId,
  user,
  update,
  onDone,
}: {
  formId: string
  user: User
  update: ReturnType<typeof useUpdateUser>
  onDone: () => void
}) {
  const toast = useToast()
  const [password, setPassword] = useState('')
  const [confirm, setConfirm] = useState('')
  const [errors, setErrors] = useState<{ password?: string | string[]; confirm?: string }>({})
  const [formError, setFormError] = useState<string | null>(null)

  function handleSubmit(e: FormEvent) {
    e.preventDefault()
    setFormError(null)
    const next: typeof errors = {}
    const pwErr = validatePassword(password)
    if (pwErr) next.password = pwErr
    if (!pwErr && confirm !== password) next.confirm = 'Passwords do not match.'
    setErrors(next)
    if (Object.keys(next).length > 0) return
    update.mutate(
      { id: user.id, body: { password } },
      {
        onSuccess: () => {
          toast.success('Password updated', user.email)
          onDone()
        },
        onError: (err) => {
          const fields = getFieldErrors(err)
          if (fields.password) setErrors({ password: fields.password })
          setFormError(errorMessage(err))
        },
      },
    )
  }

  return (
    <form id={formId} className="stack" onSubmit={handleSubmit} noValidate>
      {formError && (
        <p className="form-error" role="alert">
          {formError}
        </p>
      )}
      <Input
        label="New password"
        type="password"
        autoComplete="new-password"
        value={password}
        onChange={(e) => setPassword(e.target.value)}
        error={errors.password}
        hint={`At least ${PASSWORD_MIN_LENGTH} characters.`}
        required
        autoFocus
      />
      <Input
        label="Confirm password"
        type="password"
        autoComplete="new-password"
        value={confirm}
        onChange={(e) => setConfirm(e.target.value)}
        error={errors.confirm}
        required
      />
    </form>
  )
}
