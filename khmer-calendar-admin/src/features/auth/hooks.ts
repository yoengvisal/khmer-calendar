import { useMutation } from '@tanstack/react-query'
import { session } from '@/core/auth/session'
import * as api from './api'
import type { LoginRequest } from './types'

export function useLogin() {
  return useMutation({
    mutationFn: (body: LoginRequest) => api.login(body),
    onSuccess: (auth) => session.setSession(auth),
  })
}

export function useLogout() {
  return useMutation({
    mutationFn: async () => {
      const refreshToken = session.getRefreshToken()
      try {
        // Best effort: revoke server-side. The local session is cleared regardless.
        if (refreshToken) await api.logout(refreshToken)
      } finally {
        session.clear('logout')
      }
    },
  })
}
