import { useState, type FormEvent } from 'react'
import { ApiError } from '@/core/api/errors'
import { Button, Input } from '@/shared/ui'
import { useLogin } from '../hooks'

function loginErrorMessage(error: unknown): string {
  if (error instanceof ApiError) {
    switch (error.code) {
      case 'INVALID_CREDENTIALS':
        return 'Incorrect email or password.'
      case 'RATE_LIMITED':
        return 'Too many sign-in attempts. Please wait a minute and try again.'
      case 'VALIDATION_ERROR':
        return 'Please enter a valid email address and password.'
      default:
        return error.message
    }
  }
  return 'Sign-in failed. Please try again.'
}

export function LoginForm({ onSuccess }: { onSuccess: () => void }) {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [touched, setTouched] = useState(false)
  const login = useLogin()

  const emailError = touched && !/^\S+@\S+\.\S+$/.test(email.trim()) ? 'Enter a valid email address.' : null
  const passwordError = touched && password.length === 0 ? 'Enter your password.' : null

  function handleSubmit(e: FormEvent) {
    e.preventDefault()
    setTouched(true)
    if (!/^\S+@\S+\.\S+$/.test(email.trim()) || password.length === 0) return
    login.mutate({ email: email.trim(), password }, { onSuccess })
  }

  return (
    <form className="stack" onSubmit={handleSubmit} noValidate>
      {login.isError && (
        <p className="form-error" role="alert">
          {loginErrorMessage(login.error)}
        </p>
      )}
      <Input
        label="Email"
        type="email"
        name="email"
        autoComplete="username"
        inputMode="email"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
        error={emailError}
        required
        autoFocus
      />
      <Input
        label="Password"
        type="password"
        name="password"
        autoComplete="current-password"
        value={password}
        onChange={(e) => setPassword(e.target.value)}
        error={passwordError}
        required
      />
      <Button type="submit" variant="primary" loading={login.isPending}>
        Sign in
      </Button>
    </form>
  )
}
