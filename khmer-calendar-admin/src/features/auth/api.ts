import { unwrap } from '@/core/api/client'
import { http } from '@/core/api/http'
import type { ApiSuccess } from '@/core/api/types'
import type { AuthResponse, LoginRequest, User } from './types'

export async function login(body: LoginRequest): Promise<AuthResponse> {
  return unwrap(await http.post<ApiSuccess<AuthResponse>>('/auth/login', body, { skipAuth: true }))
}

export async function logout(refreshToken: string): Promise<void> {
  await http.post<ApiSuccess<{ loggedOut: true }>>('/auth/logout', { refreshToken })
}

export async function fetchMe(): Promise<User> {
  return unwrap(await http.get<ApiSuccess<User>>('/auth/me'))
}
