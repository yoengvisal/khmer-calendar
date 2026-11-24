import {
  type CivilDate,
  formatIsoDate,
} from '../modules/lunar/domain/civil-date.js';

/** Postgres DATE columns come back as JS Dates at UTC midnight. Convert at the persistence boundary only. */
export function civilDateToDb(date: CivilDate | string): Date {
  const iso = typeof date === 'string' ? date : formatIsoDate(date);
  return new Date(`${iso}T00:00:00.000Z`);
}

export function dbDateToIso(date: Date): string {
  return date.toISOString().slice(0, 10);
}
