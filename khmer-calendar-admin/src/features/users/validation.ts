import { PASSWORD_MIN_LENGTH } from './types'

export function validateEmail(email: string): string | null {
  if (!email.trim()) return 'Email is required.'
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.trim()) ? null : 'Enter a valid email address.'
}

export function validateDisplayName(name: string): string | null {
  if (!name.trim()) return 'Display name is required.'
  return name.trim().length > 100 ? 'Keep it under 100 characters.' : null
}

export function validatePassword(password: string): string | null {
  if (!password) return 'Password is required.'
  return password.length < PASSWORD_MIN_LENGTH ? `Password must be at least ${PASSWORD_MIN_LENGTH} characters.` : null
}
