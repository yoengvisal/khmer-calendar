import { isValidIsoDate } from '@/shared/lib/dates'
import { EVENT_CATEGORIES, EVENT_STATUSES, type CalendarEvent, type EventCategory, type EventStatus, type EventWriteBody } from './types'

/** Form state: everything the inputs hold, as strings/booleans. */
export interface EventFormValues {
  titleKm: string
  titleEn: string
  titleZh: string
  descriptionKm: string
  descriptionEn: string
  descriptionZh: string
  category: EventCategory | ''
  startDate: string
  endDate: string
  isDayOff: boolean
  status: EventStatus
}

export type EventFormField = keyof EventFormValues
export type EventFormErrors = Partial<Record<EventFormField, string>>

export const TITLE_MAX = 200
export const DESCRIPTION_MAX = 2000

export const emptyEventForm = (startDate = ''): EventFormValues => ({
  titleKm: '',
  titleEn: '',
  titleZh: '',
  descriptionKm: '',
  descriptionEn: '',
  descriptionZh: '',
  category: '',
  startDate,
  endDate: startDate,
  isDayOff: false,
  status: 'DRAFT',
})

export function eventToFormValues(event: CalendarEvent): EventFormValues {
  return {
    titleKm: event.titleKm,
    titleEn: event.titleEn,
    titleZh: event.titleZh ?? '',
    descriptionKm: event.descriptionKm ?? '',
    descriptionEn: event.descriptionEn ?? '',
    descriptionZh: event.descriptionZh ?? '',
    category: event.category,
    startDate: event.startDate,
    endDate: event.endDate,
    isDayOff: event.isDayOff,
    status: event.status,
  }
}

export function validateEventForm(values: EventFormValues): EventFormErrors {
  const errors: EventFormErrors = {}

  if (!values.titleKm.trim()) errors.titleKm = 'Khmer title is required.'
  else if (values.titleKm.trim().length > TITLE_MAX) errors.titleKm = `Keep it under ${TITLE_MAX} characters.`

  if (!values.titleEn.trim()) errors.titleEn = 'English title is required.'
  else if (values.titleEn.trim().length > TITLE_MAX) errors.titleEn = `Keep it under ${TITLE_MAX} characters.`

  if (values.titleZh.trim().length > TITLE_MAX) errors.titleZh = `Keep it under ${TITLE_MAX} characters.`

  if (values.descriptionKm.length > DESCRIPTION_MAX) errors.descriptionKm = `Keep it under ${DESCRIPTION_MAX} characters.`
  if (values.descriptionEn.length > DESCRIPTION_MAX) errors.descriptionEn = `Keep it under ${DESCRIPTION_MAX} characters.`
  if (values.descriptionZh.length > DESCRIPTION_MAX) errors.descriptionZh = `Keep it under ${DESCRIPTION_MAX} characters.`

  if (!values.category) errors.category = 'Choose a category.'
  else if (!EVENT_CATEGORIES.includes(values.category)) errors.category = 'Unknown category.'

  if (!EVENT_STATUSES.includes(values.status)) errors.status = 'Unknown status.'

  if (!values.startDate) errors.startDate = 'Start date is required.'
  else if (!isValidIsoDate(values.startDate)) errors.startDate = 'Enter a valid date (YYYY-MM-DD).'

  if (!values.endDate) errors.endDate = 'End date is required.'
  else if (!isValidIsoDate(values.endDate)) errors.endDate = 'Enter a valid date (YYYY-MM-DD).'
  else if (!errors.startDate && values.endDate < values.startDate) errors.endDate = 'End date cannot be before the start date.'

  return errors
}

export function hasErrors(errors: EventFormErrors): boolean {
  return Object.keys(errors).length > 0
}

/** Converts validated form values into the API body (empty optional fields become null). */
export function toEventWriteBody(values: EventFormValues): EventWriteBody {
  if (!values.category) throw new Error('toEventWriteBody called with invalid values')
  const optional = (s: string) => (s.trim() ? s.trim() : null)
  return {
    titleKm: values.titleKm.trim(),
    titleEn: values.titleEn.trim(),
    titleZh: optional(values.titleZh),
    descriptionKm: optional(values.descriptionKm),
    descriptionEn: optional(values.descriptionEn),
    descriptionZh: optional(values.descriptionZh),
    category: values.category,
    startDate: values.startDate,
    endDate: values.endDate,
    isDayOff: values.isDayOff,
    status: values.status,
  }
}
