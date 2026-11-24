import { apiClient } from '@/core/api/http'
import { session } from './session'

/**
 * Restores a session on page load using the stored refresh token.
 * Safe to call more than once (React StrictMode): the refresh call is single-flight and
 * subsequent calls are no-ops once the status has settled.
 */
export async function restoreSession(): Promise<void> {
  const { status } = session.getSnapshot()
  if (status === 'authenticated') return
  if (!session.hasRefreshToken()) {
    if (status !== 'anonymous') session.setStatus('anonymous')
    return
  }
  if (status !== 'restoring') session.setStatus('restoring')
  try {
    await apiClient.refreshAccessToken() // success -> session.setSession via onTokensRefreshed
  } catch {
    // Auth rejection already cleared the session (onRefreshFailed). Anything else (network/5xx)
    // keeps the refresh token so the user can retry.
    if (session.getSnapshot().status === 'restoring') session.setStatus('unavailable')
  }
}
