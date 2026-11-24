/**
 * Timezone-free calendar date. The calendar domain works on civil dates only,
 * so results never depend on the server's or the device's timezone.
 */
export interface CivilDate {
  readonly year: number;
  readonly month: number; // 1-12
  readonly day: number; // 1-31
}

const ISO_DATE = /^(\d{4})-(\d{2})-(\d{2})$/;

export function isGregorianLeapYear(year: number): boolean {
  return (year % 4 === 0 && year % 100 !== 0) || year % 400 === 0;
}

export function daysInGregorianMonth(year: number, month: number): number {
  const days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  return month === 2 && isGregorianLeapYear(year) ? 29 : days[month - 1];
}

export function isValidCivilDate(
  year: number,
  month: number,
  day: number,
): boolean {
  return (
    Number.isInteger(year) &&
    Number.isInteger(month) &&
    Number.isInteger(day) &&
    year >= 1 &&
    year <= 9999 &&
    month >= 1 &&
    month <= 12 &&
    day >= 1 &&
    day <= daysInGregorianMonth(year, month)
  );
}

/** Parses strict `YYYY-MM-DD`. Returns null for malformed or impossible dates. */
export function parseIsoDate(value: string): CivilDate | null {
  const match = ISO_DATE.exec(value);
  if (!match) return null;
  const [year, month, day] = [
    Number(match[1]),
    Number(match[2]),
    Number(match[3]),
  ];
  return isValidCivilDate(year, month, day) ? { year, month, day } : null;
}

export function formatIsoDate(date: CivilDate): string {
  const pad = (n: number, w = 2) => String(n).padStart(w, '0');
  return `${pad(date.year, 4)}-${pad(date.month)}-${pad(date.day)}`;
}

/** Julian Day Number (integer) for a proleptic Gregorian civil date. */
export function toJulianDay(date: CivilDate): number {
  const a = Math.floor((14 - date.month) / 12);
  const y = date.year + 4800 - a;
  const m = date.month + 12 * a - 3;
  return (
    date.day +
    Math.floor((153 * m + 2) / 5) +
    365 * y +
    Math.floor(y / 4) -
    Math.floor(y / 100) +
    Math.floor(y / 400) -
    32045
  );
}

export function fromJulianDay(jdn: number): CivilDate {
  const a = jdn + 32044;
  const b = Math.floor((4 * a + 3) / 146097);
  const c = a - Math.floor((146097 * b) / 4);
  const d = Math.floor((4 * c + 3) / 1461);
  const e = c - Math.floor((1461 * d) / 4);
  const m = Math.floor((5 * e + 2) / 153);
  return {
    day: e - Math.floor((153 * m + 2) / 5) + 1,
    month: m + 3 - 12 * Math.floor(m / 10),
    year: 100 * b + d - 4800 + Math.floor(m / 10),
  };
}

export function addDays(date: CivilDate, days: number): CivilDate {
  return fromJulianDay(toJulianDay(date) + days);
}

/** 0 = Sunday ... 6 = Saturday */
export function dayOfWeek(date: CivilDate): number {
  return (toJulianDay(date) + 1) % 7;
}

export function compareDates(a: CivilDate, b: CivilDate): number {
  return toJulianDay(a) - toJulianDay(b);
}

export function daysBetween(from: CivilDate, to: CivilDate): number {
  return toJulianDay(to) - toJulianDay(from);
}
