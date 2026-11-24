import { keepPreviousData, useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { session } from '@/core/auth/session'
import * as api from './api'
import type { CreateUserBody, UpdateUserBody, UserListParams } from './types'

export const userKeys = {
  all: ['users'] as const,
  list: (params: UserListParams) => [...userKeys.all, 'list', params] as const,
}

export function useUserList(params: UserListParams) {
  return useQuery({ queryKey: userKeys.list(params), queryFn: () => api.listUsers(params), placeholderData: keepPreviousData })
}

export function useCreateUser() {
  const queryClient = useQueryClient()
  return useMutation({
    mutationFn: (body: CreateUserBody) => api.createUser(body),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: userKeys.all }),
  })
}

export function useUpdateUser() {
  const queryClient = useQueryClient()
  return useMutation({
    mutationFn: ({ id, body }: { id: string; body: UpdateUserBody }) => api.updateUser(id, body),
    onSuccess: (user) => {
      // Keep the top bar in sync if the admin edited their own display name.
      if (session.getSnapshot().user?.id === user.id) session.setUser(user)
      return queryClient.invalidateQueries({ queryKey: userKeys.all })
    },
  })
}
