import { describe, expect, it } from 'vitest'
import { emptyEventForm, hasErrors, toEventWriteBody, validateEventForm, type EventFormValues } from './validation'

const valid: EventFormValues = {
  ...emptyEventForm('2026-04-14'),
  titleKm: 'ពិធីបុណ្យចូលឆ្នាំថ្មី',
  titleEn: 'Khmer New Year',
  category: 'PUBLIC_HOLIDAY',
  endDate: '2026-04-16',
  isDayOff: true,
}

describe('validateEventForm', () => {
  it('accepts a valid multi-day event', () => {
    expect(validateEventForm(valid)).toEqual({})
  })

  it('accepts a one-day event (endDate === startDate)', () => {
    expect(validateEventForm({ ...valid, endDate: valid.startDate })).toEqual({})
  })

  it('rejects endDate before startDate', () => {
    const errors = validateEventForm({ ...valid, startDate: '2026-04-14', endDate: '2026-04-13' })
    expect(errors.endDate).toMatch(/before the start date/i)
    expect(hasErrors(errors)).toBe(true)
  })

  it('requires both titles, category and dates', () => {
    const errors = validateEventForm(emptyEventForm())
    expect(Object.keys(errors).sort()).toEqual(['category', 'endDate', 'startDate', 'titleEn', 'titleKm'])
  })

  it('treats whitespace-only titles as empty', () => {
    expect(validateEventForm({ ...valid, titleKm: '   ' }).titleKm).toBeDefined()
  })

  it('rejects impossible dates', () => {
    expect(validateEventForm({ ...valid, startDate: '2026-02-30', endDate: '2026-03-01' }).startDate).toBeDefined()
  })

  it('defaults endDate to startDate for a new form', () => {
    expect(emptyEventForm('2026-05-01').endDate).toBe('2026-05-01')
  })
})

describe('toEventWriteBody', () => {
  it('trims titles and turns empty descriptions into null', () => {
    const body = toEventWriteBody({ ...valid, titleEn: '  Khmer New Year ', descriptionEn: '  ', descriptionKm: 'ពិធី' })
    expect(body).toEqual({
      titleKm: 'ពិធីបុណ្យចូលឆ្នាំថ្មី',
      titleEn: 'Khmer New Year',
      titleZh: null,
      descriptionKm: 'ពិធី',
      descriptionEn: null,
      descriptionZh: null,
      category: 'PUBLIC_HOLIDAY',
      startDate: '2026-04-14',
      endDate: '2026-04-16',
      isDayOff: true,
      status: 'DRAFT',
    })
  })
})

describe('Chinese fields', () => {
  it('are optional, trimmed, and blank becomes null', () => {
    expect(hasErrors(validateEventForm({ ...valid, titleZh: '' }))).toBe(false)
    const body = toEventWriteBody({ ...valid, titleZh: '  柬埔寨新年 ', descriptionZh: '   ' })
    expect(body.titleZh).toBe('柬埔寨新年')
    expect(body.descriptionZh).toBeNull()
  })

  it('limits the Chinese title length', () => {
    expect(validateEventForm({ ...valid, titleZh: '节'.repeat(201) }).titleZh).toBeTruthy()
  })
})
