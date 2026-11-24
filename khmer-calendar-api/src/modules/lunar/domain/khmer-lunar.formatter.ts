import type { KhmerLunarDate } from './khmer-lunar-calendar.js';
import {
  ANIMAL_YEAR_NAMES_EN,
  ANIMAL_YEAR_NAMES_KM,
  LUNAR_MONTH_NAMES_EN,
  LUNAR_MONTH_NAMES_KM,
  MOON_PHASE_NAMES_KM,
  MoonPhase,
  SAK_NAMES_KM,
  toKhmerNumeral,
  WEEKDAY_NAMES_KM,
} from './khmer-lunar.constants.js';

/** e.g. "ថ្ងៃអាទិត្យ ១០កើត ខែមិគសិរ ឆ្នាំមមី អដ្ឋស័ក ពុទ្ធសករាជ ២៥៧០" */
export function formatLunarKm(l: KhmerLunarDate): string {
  return (
    `ថ្ងៃ${WEEKDAY_NAMES_KM[l.dayOfWeek]} ${toKhmerNumeral(l.day)}${MOON_PHASE_NAMES_KM[l.moonPhase]} ` +
    `ខែ${LUNAR_MONTH_NAMES_KM[l.monthIndex]} ឆ្នាំ${ANIMAL_YEAR_NAMES_KM[l.animalYear]} ${SAK_NAMES_KM[l.sak]} ` +
    `ពុទ្ធសករាជ ${toKhmerNumeral(l.beYear)}`
  );
}

export const lunarNames = {
  monthKm: (i: number) => LUNAR_MONTH_NAMES_KM[i],
  monthEn: (i: number) => LUNAR_MONTH_NAMES_EN[i],
  animalKm: (i: number) => ANIMAL_YEAR_NAMES_KM[i],
  animalEn: (i: number) => ANIMAL_YEAR_NAMES_EN[i],
  sakKm: (i: number) => SAK_NAMES_KM[i],
  phase: (p: MoonPhase) =>
    (p === MoonPhase.Waxing ? 'WAXING' : 'WANING') as 'WAXING' | 'WANING',
};
