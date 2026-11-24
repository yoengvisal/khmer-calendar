import { useSyncExternalStore } from 'react'
import { session, type SessionSnapshot } from './session'
import type { User, UserRole } from './types'

export interface AuthState extends SessionSnapshot {
  isAuthenticated: boolean
  hasRole(...roles: UserRole[]): boolean
}

export function useAuth(): AuthState {
  const snapshot = useSyncExternalStore(session.subscribe, session.getSnapshot, session.getSnapshot)
  return {
    ...snapshot,
    isAuthenticated: snapshot.status === 'authenticated' && snapshot.user !== null,
    hasRole: (...roles: UserRole[]) => snapshot.user !== null && roles.includes(snapshot.user.role),
  }
}

/** For components rendered only inside protected routes. */
export function useCurrentUser(): User {
  const { user } = useAuth()
  if (!user) throw new Error('useCurrentUser must be used inside an authenticated route')
  return user
}
