/** Generates an id matching the server's accepted pattern `^[A-Za-z0-9-]{8,64}$`. */
export function createRequestId(): string {
  if (typeof crypto !== 'undefined' && typeof crypto.randomUUID === 'function') {
    return crypto.randomUUID()
  }
  // Fallback for non-secure contexts (randomUUID requires https or localhost).
  const rand = () => Math.random().toString(36).slice(2, 10).padEnd(8, '0')
  return `${Date.now().toString(36)}-${rand()}-${rand()}`
}

export const REQUEST_ID_HEADER = 'x-request-id'
