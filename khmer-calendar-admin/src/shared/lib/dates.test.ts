import { describe, expect, it } from 'vitest'
import { addDays, daysInMonth, formatDateRange, isValidIsoDate, rangeFor, todayIso } from './dates'
import { formatLunarDay, toKhmerNumerals } from './khmer'

describe('dates', () => {
  it('builds year and month ranges (leap years included)', () => {
    expect(rangeFor(2026)).toEqual({ from: '2026-01-01', to: '2026-12-31' })
    expect(rangeFor(2028, 2)).toEqual({ from: '2028-02-01', to: '2028-02-29' })
    expect(daysInMonth(2026, 2)).toBe(28)
  })

  it('adds days across month/year boundaries without timezone drift', () => {
    expect(addDays('2026-12-20', 30)).toBe('2027-01-19')
    expect(addDays('2026-03-01', -1)).toBe('2026-02-28')
  })

  it('validates civil dates', () => {
    expect(isValidIsoDate('2026-02-29')).toBe(false)
    expect(isValidIsoDate('2026-1-01')).toBe(false)
    expect(isValidIsoDate('2026-04-14')).toBe(true)
  })

  it('formats ranges and today', () => {
    expect(formatDateRange('2026-04-14', '2026-04-16')).toBe('14 Apr 2026 – 16 Apr 2026')
    expect(formatDateRange('2026-05-01', '2026-05-01')).toBe('1 May 2026')
    expect(todayIso(new Date(2026, 10, 5, 23, 59))).toBe('2026-11-05')
  })
})

describe('khmer', () => {
  it('formats Khmer numerals and lunar days', () => {
    expect(toKhmerNumerals(2570)).toBe('២៥៧០')
    expect(formatLunarDay(5, 'WAXING')).toBe('៥កើត')
    expect(formatLunarDay(14, 'WANING')).toBe('១៤រោច')
  })
})
