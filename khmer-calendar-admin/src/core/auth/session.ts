import type { AuthResponse, User } from './types'

/**
 * Session store (framework-agnostic, subscribe/getSnapshot for `useSyncExternalStore`).
 *
 * - Access token: memory only (lost on reload; restored via refresh).
 * - Refresh token: localStorage. Planned hardening: move it to an httpOnly, SameSite cookie set by the API.
 */

export type SessionStatus =
  /** Initial state while we try to restore a session from the stored refresh token. */
  | 'restoring'
  | 'authenticated'
  | 'anonymous'
  /** Restore failed for a non-auth reason (API unreachable). The refresh token is kept. */
  | 'unavailable'

export type EndReason = 'logout' | 'expired' | null

export interface SessionSnapshot {
  status: SessionStatus
  user: User | null
  /** Why the last session ended; used by the login page to explain the redirect. */
  endReason: EndReason
}

export interface SessionStore {
  getSnapshot(): SessionSnapshot
  subscribe(listener: () => void): () => void
  getAccessToken(): string | null
  getRefreshToken(): string | null
  hasRefreshToken(): boolean
  setSession(auth: AuthResponse): void
  setUser(user: User): void
  setStatus(status: Extract<SessionStatus, 'restoring' | 'unavailable' | 'anonymous'>): void
  clear(reason: EndReason): void
}

export const REFRESH_TOKEN_KEY = 'khmer-calendar-admin.refreshToken'

function safeStorage(storage: Storage | undefined) {
  return {
    get(): string | null {
      try {
        return storage?.getItem(REFRESH_TOKEN_KEY) ?? null
      } catch {
        return null
      }
    },
    set(value: string) {
      try {
        storage?.setItem(REFRESH_TOKEN_KEY, value)
      } catch {
        /* storage unavailable (private mode / quota) — session will not survive reload */
      }
    },
    remove() {
      try {
        storage?.removeItem(REFRESH_TOKEN_KEY)
      } catch {
        /* ignore */
      }
    },
  }
}

export function createSessionStore(storage: Storage | undefined): SessionStore {
  const store = safeStorage(storage)
  const listeners = new Set<() => void>()
  let accessToken: string | null = null
  let snapshot: SessionSnapshot = {
    status: store.get() ? 'restoring' : 'anonymous',
    user: null,
    endReason: null,
  }

  function emit(next: SessionSnapshot) {
    snapshot = next
    for (const listener of listeners) listener()
  }

  return {
    getSnapshot: () => snapshot,
    subscribe(listener) {
      listeners.add(listener)
      return () => listeners.delete(listener)
    },
    getAccessToken: () => accessToken,
    // Read through to storage each time so a rotation done in another tab is picked up.
    getRefreshToken: () => store.get(),
    hasRefreshToken: () => store.get() !== null,
    setSession(auth) {
      accessToken = auth.accessToken
      store.set(auth.refreshToken)
      emit({ status: 'authenticated', user: auth.user, endReason: null })
    },
    setUser(user) {
      if (snapshot.status !== 'authenticated') return
      emit({ ...snapshot, user })
    },
    setStatus(status) {
      emit({ ...snapshot, status })
    },
    clear(reason) {
      accessToken = null
      store.remove()
      emit({ status: 'anonymous', user: null, endReason: reason })
    },
  }
}

export const session: SessionStore = createSessionStore(typeof window === 'undefined' ? undefined : window.localStorage)
