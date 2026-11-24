import { Injectable } from '@nestjs/common';
import type { CivilDate } from './domain/civil-date.js';
import {
  KhmerLunarCalendar,
  type KhmerLunarDate,
  type KhmerNewYearInfo,
} from './domain/khmer-lunar-calendar.js';
import type { LunarMonth, MoonPhase } from './domain/khmer-lunar.constants.js';

export const MIN_SUPPORTED_YEAR = 1900;
export const MAX_SUPPORTED_YEAR = 2100;

/**
 * Nest-facing adapter over the pure domain calculator. A single instance is shared
 * so the per-year memo caches stay warm (they are bounded by the supported year range).
 */
@Injectable()
export class LunarCalendarService {
  private readonly calendar = new KhmerLunarCalendar();

  toLunar(date: CivilDate): KhmerLunarDate {
    return this.calendar.toLunar(date);
  }

  newYear(gregorianYear: number): KhmerNewYearInfo {
    return this.calendar.newYear(gregorianYear);
  }

  findInGregorianYear(
    year: number,
    month: LunarMonth,
    day: number,
    phase: MoonPhase,
  ): CivilDate[] {
    return this.calendar.findInGregorianYear(year, month, day, phase);
  }
}
