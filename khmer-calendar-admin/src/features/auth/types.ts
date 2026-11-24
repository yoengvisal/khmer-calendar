export type { AuthResponse, User, UserRole } from '@/core/auth/types'

export interface LoginRequest {
  email: string
  password: string
}
