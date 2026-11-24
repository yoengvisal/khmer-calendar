import { AxiosError, AxiosHeaders, type AxiosAdapter, type AxiosResponse, type InternalAxiosRequestConfig } from 'axios'

export interface MockReply {
  status: number
  body?: unknown
  headers?: Record<string, string>
  /** Resolve after this many ms (lets concurrent requests overlap). */
  delayMs?: number
}

export type MockHandler = (config: InternalAxiosRequestConfig) => MockReply | Promise<MockReply>

/** Minimal axios adapter for tests: produces real AxiosErrors for non-2xx, like the XHR adapter does. */
export function createMockAdapter(handler: MockHandler): AxiosAdapter & { calls: InternalAxiosRequestConfig[] } {
  const calls: InternalAxiosRequestConfig[] = []
  const adapter = (async (config: InternalAxiosRequestConfig) => {
    // Snapshot headers: the same config object is reused by axios on retry.
    calls.push({ ...config, headers: new AxiosHeaders(config.headers) })
    const reply = await handler(config)
    if (reply.delayMs) await new Promise((r) => setTimeout(r, reply.delayMs))
    const response: AxiosResponse = {
      data: reply.body,
      status: reply.status,
      statusText: String(reply.status),
      headers: new AxiosHeaders(reply.headers ?? {}),
      config,
      request: {},
    }
    if (reply.status >= 200 && reply.status < 300) return response
    throw new AxiosError(
      `Request failed with status code ${reply.status}`,
      reply.status >= 500 ? AxiosError.ERR_BAD_RESPONSE : AxiosError.ERR_BAD_REQUEST,
      config,
      {},
      response,
    )
  }) as AxiosAdapter & { calls: InternalAxiosRequestConfig[] }
  adapter.calls = calls
  return adapter
}

export const ok = (data: unknown, meta?: unknown): MockReply => ({ status: 200, body: { success: true, data, ...(meta ? { meta } : {}) } })

export const fail = (status: number, code: string, message = code, details: unknown = []): MockReply => ({
  status,
  body: { success: false, error: { code, message, details, requestId: `srv-${code.toLowerCase()}` } },
})

/** Path relative to baseURL, without query. */
export function pathOf(config: InternalAxiosRequestConfig): string {
  return (config.url ?? '').split('?')[0] ?? ''
}
