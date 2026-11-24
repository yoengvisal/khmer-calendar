import { useQueryClient } from '@tanstack/react-query'
import { useEffect, useRef, type ReactNode } from 'react'
import { restoreSession } from './authService'
import { session } from './session'

/**
 * Restores the session once on mount and drops all cached server data whenever the
 * session ends (logout or refresh failure), so nothing leaks between users.
 */
export function AuthProvider({ children }: { children: ReactNode }) {
  const queryClient = useQueryClient()
  const lastStatus = useRef(session.getSnapshot().status)

  useEffect(() => {
    void restoreSession()
  }, [])

  useEffect(
    () =>
      session.subscribe(() => {
        const { status } = session.getSnapshot()
        if (status === 'anonymous' && lastStatus.current === 'authenticated') queryClient.clear()
        lastStatus.current = status
      }),
    [queryClient],
  )

  return <>{children}</>
}
