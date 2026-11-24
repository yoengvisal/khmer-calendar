export type { User, UserRole } from '@/core/auth/types'
export { USER_ROLES } from '@/core/auth/types'
import type { UserRole } from '@/core/auth/types'

export const PASSWORD_MIN_LENGTH = 12

export interface CreateUserBody {
  email: string
  displayName: string
  password: string
  role: UserRole
}

export interface UpdateUserBody {
  displayName?: string
  role?: UserRole
  isActive?: boolean
  password?: string
}

export interface UserListParams {
  page: number
  limit: number
}
