export type UserRole = 'ADMIN' | 'EDITOR'

export const USER_ROLES: readonly UserRole[] = ['ADMIN', 'EDITOR']

export interface User {
  id: string
  email: string
  displayName: string
  role: UserRole
  isActive: boolean
  lastLoginAt: string | null
  createdAt: string
}

/** Response of POST /auth/login and POST /auth/refresh. */
export interface AuthResponse {
  accessToken: string
  refreshToken: string
  /** Access-token lifetime in seconds. */
  expiresIn: number
  user: User
}
