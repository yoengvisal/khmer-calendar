import { createContext } from 'react'

export type ToastTone = 'info' | 'success' | 'error'

export interface ToastInput {
  title: string
  description?: string
  tone?: ToastTone
  /** ms; 0 = sticky until dismissed. */
  duration?: number
}

export interface ToastApi {
  show(toast: ToastInput): void
  success(title: string, description?: string): void
  error(title: string, description?: string): void
}

export const ToastContext = createContext<ToastApi | null>(null)
