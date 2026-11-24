import type { CalendarDay } from './types'

export interface LunarSummary {
  monthsKm: string[]
  monthsEn: string[]
  animalYearsKm: string[]
  animalYearsEn: string[]
  saks: string[]
  beYears: number[]
}

function unique<T>(values: T[]): T[] {
  return [...new Set(values)]
}

/** A Gregorian month usually spans two lunar months, and April can cross the Khmer new year. */
export function summarizeLunar(days: readonly CalendarDay[]): LunarSummary {
  return {
    monthsKm: unique(days.map((d) => d.lunar.monthNameKm)),
    monthsEn: unique(days.map((d) => d.lunar.monthNameEn)),
    animalYearsKm: unique(days.map((d) => d.lunar.animalYearNameKm)),
    animalYearsEn: unique(days.map((d) => d.lunar.animalYearNameEn)),
    saks: unique(days.map((d) => d.lunar.sakNameKm)),
    beYears: unique(days.map((d) => d.lunar.beYear)),
  }
}
