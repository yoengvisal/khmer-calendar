import type { BadgeTone } from '@/shared/ui'
import type { EventCategory, EventStatus } from './types'

export const CATEGORY_LABELS: Record<EventCategory, string> = {
  PUBLIC_HOLIDAY: 'Public holiday',
  BUDDHIST_HOLY_DAY: 'Buddhist holy day',
  CULTURAL: 'Cultural',
  OBSERVANCE: 'Observance',
}

export const CATEGORY_TONES: Record<EventCategory, BadgeTone> = {
  PUBLIC_HOLIDAY: 'danger',
  BUDDHIST_HOLY_DAY: 'warning',
  CULTURAL: 'accent',
  OBSERVANCE: 'info',
}

export const STATUS_LABELS: Record<EventStatus, string> = {
  DRAFT: 'Draft',
  PUBLISHED: 'Published',
  ARCHIVED: 'Archived',
}

export const STATUS_TONES: Record<EventStatus, BadgeTone> = {
  DRAFT: 'neutral',
  PUBLISHED: 'success',
  ARCHIVED: 'warning',
}

export const EVENTS_PAGE_SIZE = 20
