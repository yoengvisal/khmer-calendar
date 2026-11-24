import { unwrap, unwrapPage } from '@/core/api/client'
import { http } from '@/core/api/http'
import type { ApiSuccess, Paginated } from '@/core/api/types'
import type { CreateUserBody, UpdateUserBody, User, UserListParams } from './types'

export async function listUsers(params: UserListParams): Promise<Paginated<User>> {
  return unwrapPage(await http.get<ApiSuccess<User[]>>('/admin/users', { params }))
}

export async function createUser(body: CreateUserBody): Promise<User> {
  return unwrap(await http.post<ApiSuccess<User>>('/admin/users', body))
}

export async function updateUser(id: string, body: UpdateUserBody): Promise<User> {
  return unwrap(await http.patch<ApiSuccess<User>>(`/admin/users/${encodeURIComponent(id)}`, body))
}
