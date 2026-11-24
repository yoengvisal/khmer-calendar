const KHMER_DIGITS = ['០', '១', '២', '៣', '៤', '៥', '៦', '៧', '៨', '៩'] as const

/** 2570 -> "២៥៧០" */
export function toKhmerNumerals(value: number | string): string {
  return String(value).replace(/[0-9]/g, (d) => KHMER_DIGITS[Number(d)] ?? d)
}

export type MoonPhase = 'WAXING' | 'WANING'

/** (5, 'WAXING') -> "៥កើត" ; (3, 'WANING') -> "៣រោច" */
export function formatLunarDay(day: number, phase: MoonPhase): string {
  return `${toKhmerNumerals(day)}${phase === 'WAXING' ? 'កើត' : 'រោច'}`
}
