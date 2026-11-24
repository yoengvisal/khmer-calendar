/** Envelope + shared contract types from docs/api-contract.md (v1). */

export interface PageMeta {
  page: number
  limit: number
  total: number
  totalPages: number
}

export interface ApiSuccess<T> {
  success: true
  data: T
  meta?: PageMeta
}

export interface ApiErrorBody {
  code: string
  message: string
  details?: unknown
  requestId?: string
}

export interface ApiFailure {
  success: false
  error: ApiErrorBody
}

export interface Paginated<T> {
  items: T[]
  meta: PageMeta
}

/** Error codes defined by the server contract. */
export type ServerErrorCode =
  | 'VALIDATION_ERROR'
  | 'UNAUTHORIZED'
  | 'TOKEN_EXPIRED'
  | 'INVALID_CREDENTIALS'
  | 'INVALID_REFRESH_TOKEN'
  | 'FORBIDDEN'
  | 'NOT_FOUND'
  | 'CONFLICT'
  | 'RATE_LIMITED'
  | 'INTERNAL_ERROR'

/** Codes synthesised by the client when there is no usable server error body. */
export type ClientErrorCode = 'NETWORK_ERROR' | 'TIMEOUT' | 'CANCELLED' | 'UNKNOWN_ERROR'

export type ApiErrorCode = ServerErrorCode | ClientErrorCode

/** `details` entry for VALIDATION_ERROR. */
export interface FieldErrorDetail {
  field: string
  messages: string[]
}
