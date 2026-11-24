import { config } from '@/app/config'
import { session } from '@/core/auth/session'
import { createApiClient } from './client'

/**
 * The application's single HTTP client. Feature `api.ts` modules import `http` from here;
 * components never do.
 */
export const apiClient = createApiClient({
  baseURL: config.apiBaseUrl,
  tokens: {
    getAccessToken: () => session.getAccessToken(),
    getRefreshToken: () => session.getRefreshToken(),
  },
  onTokensRefreshed: (auth) => session.setSession(auth),
  // Clearing the session flips status to "anonymous"; the route guard then redirects to /login.
  onRefreshFailed: () => session.clear('expired'),
})

export const http = apiClient.http
