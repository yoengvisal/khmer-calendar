import type { EventSummary } from '@/features/events/types'
import type { MoonPhase } from '@/shared/lib/khmer'

export type { MoonPhase }

export interface LunarDate {
  /** 1-15 */
  day: number
  moonPhase: MoonPhase
  /** 0-13 (12/13 = បឋមាសាឍ/ទុតិយាសាឍ in leap-month years) */
  monthIndex: number
  monthNameKm: string
  monthNameEn: string
  /** ពុទ្ធសករាជ */
  beYear: number
  /** ចុល្លសករាជ */
  jsYear: number
  /** 0=Rat … 11=Pig */
  animalYear: number
  animalYearNameKm: string
  animalYearNameEn: string
  /** 0-9 */
  sak: number
  sakNameKm: string
  /** ថ្ងៃសីល */
  isHolyDay: boolean
  formattedKm: string
}

export interface CalendarDay {
  date: string
  /** 0=Sunday … 6=Saturday */
  dayOfWeek: number
  lunar: LunarDate
  /** Published events covering this date. */
  events: EventSummary[]
}

export interface CalendarMonth {
  year: number
  month: number
  days: CalendarDay[]
}
