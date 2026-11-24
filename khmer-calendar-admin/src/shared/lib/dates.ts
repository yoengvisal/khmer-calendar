/** Civil-date helpers. All API dates are `YYYY-MM-DD` with no timezone; we never go through UTC offsets. */

const ISO_DATE = /^(\d{4})-(\d{2})-(\d{2})$/

export function pad2(n: number): string {
  return String(n).padStart(2, '0')
}

export function toIsoDate(year: number, month: number, day: number): string {
  return `${String(year).padStart(4, '0')}-${pad2(month)}-${pad2(day)}`
}

export function todayIso(now: Date = new Date()): string {
  return toIsoDate(now.getFullYear(), now.getMonth() + 1, now.getDate())
}

export function parseIsoDate(value: string): { year: number; month: number; day: number } | null {
  const match = ISO_DATE.exec(value)
  if (!match) return null
  const year = Number(match[1])
  const month = Number(match[2])
  const day = Number(match[3])
  if (month < 1 || month > 12 || day < 1 || day > daysInMonth(year, month)) return null
  return { year, month, day }
}

export function isValidIsoDate(value: string): boolean {
  return parseIsoDate(value) !== null
}

export function daysInMonth(year: number, month: number): number {
  return new Date(Date.UTC(year, month, 0)).getUTCDate()
}

export function addDays(iso: string, days: number): string {
  const parts = parseIsoDate(iso)
  if (!parts) throw new Error(`Invalid date: ${iso}`)
  const d = new Date(Date.UTC(parts.year, parts.month - 1, parts.day + days))
  return toIsoDate(d.getUTCFullYear(), d.getUTCMonth() + 1, d.getUTCDate())
}

/** `{from, to}` for a whole year or a single month (1-12). */
export function rangeFor(year: number, month?: number | null): { from: string; to: string } {
  if (month) return { from: toIsoDate(year, month, 1), to: toIsoDate(year, month, daysInMonth(year, month)) }
  return { from: toIsoDate(year, 1, 1), to: toIsoDate(year, 12, 31) }
}

const dayFmt = new Intl.DateTimeFormat('en-GB', { day: 'numeric', month: 'short', year: 'numeric', timeZone: 'UTC' })
const monthFmt = new Intl.DateTimeFormat('en-GB', { month: 'long', year: 'numeric', timeZone: 'UTC' })

function utcDate(iso: string): Date | null {
  const p = parseIsoDate(iso)
  return p ? new Date(Date.UTC(p.year, p.month - 1, p.day)) : null
}

/** "1 May 2026" */
export function formatDate(iso: string): string {
  const d = utcDate(iso)
  return d ? dayFmt.format(d) : iso
}

/** "1 May 2026" or "14 Apr 2026 – 16 Apr 2026" */
export function formatDateRange(start: string, end: string): string {
  return start === end ? formatDate(start) : `${formatDate(start)} – ${formatDate(end)}`
}

/** "May 2026" */
export function formatMonth(year: number, month: number): string {
  return monthFmt.format(new Date(Date.UTC(year, month - 1, 1)))
}

const timestampFmt = new Intl.DateTimeFormat('en-GB', { dateStyle: 'medium', timeStyle: 'short' })

export function formatTimestamp(iso: string | null): string {
  if (!iso) return '—'
  const d = new Date(iso)
  return Number.isNaN(d.getTime()) ? iso : timestampFmt.format(d)
}

export const MONTH_NAMES = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
] as const
