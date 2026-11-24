import type { AuthResponse, User } from '@/core/auth/types'
import type { CalendarEvent } from '@/features/events/types'

export function makeUser(overrides: Partial<User> = {}): User {
  return {
    id: 'u-admin',
    email: 'admin@example.com',
    displayName: 'Sokha Admin',
    role: 'ADMIN',
    isActive: true,
    lastLoginAt: null,
    createdAt: '2026-01-01T00:00:00.000Z',
    ...overrides,
  }
}

export function makeAuth(overrides: Partial<AuthResponse> = {}): AuthResponse {
  return { accessToken: 'access-1', refreshToken: 'refresh-1', expiresIn: 900, user: makeUser(), ...overrides }
}

export function makeEvent(overrides: Partial<CalendarEvent> = {}): CalendarEvent {
  return {
    id: 'e-1',
    titleKm: 'ពិធីបុណ្យវិសាខបូជា',
    titleEn: 'Visak Bochea Day',
    titleZh: null,
    descriptionKm: null,
    descriptionEn: null,
    descriptionZh: null,
    category: 'BUDDHIST_HOLY_DAY',
    startDate: '2026-05-01',
    endDate: '2026-05-01',
    isDayOff: true,
    status: 'DRAFT',
    sourceKey: 'lunar:visakha-bochea:2026',
    createdAt: '2026-01-01T00:00:00.000Z',
    updatedAt: '2026-01-01T00:00:00.000Z',
    publishedAt: null,
    ...overrides,
  }
}
