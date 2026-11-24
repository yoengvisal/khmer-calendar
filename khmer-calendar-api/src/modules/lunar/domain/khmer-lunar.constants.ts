export enum MoonPhase {
  Waxing = 0, // កើត
  Waning = 1, // រោច
}

/** Lunar month index. 12 and 13 only occur in leap-month (អធិកមាស) years. */
export enum LunarMonth {
  Migasir = 0,
  Boss = 1,
  Meak = 2,
  Phalkun = 3,
  Cheit = 4,
  Pisakh = 5,
  Jesth = 6,
  Asadh = 7,
  Srap = 8,
  Phatrabot = 9,
  Assoch = 10,
  Kadeuk = 11,
  Pathamasadh = 12,
  Tutiyasadh = 13,
}

export const LUNAR_MONTH_NAMES_KM = [
  'មិគសិរ',
  'បុស្ស',
  'មាឃ',
  'ផល្គុន',
  'ចេត្រ',
  'ពិសាខ',
  'ជេស្ឋ',
  'អាសាឍ',
  'ស្រាពណ៍',
  'ភទ្របទ',
  'អស្សុជ',
  'កត្ដិក',
  'បឋមាសាឍ',
  'ទុតិយាសាឍ',
] as const;

export const LUNAR_MONTH_NAMES_EN = [
  'Migasir',
  'Boss',
  'Meak',
  'Phalkun',
  'Cheit',
  'Pisakh',
  'Jesth',
  'Asadh',
  'Srap',
  'Phatrabot',
  'Assoch',
  'Kadeuk',
  'Pathamasadh',
  'Tutiyasadh',
] as const;

export const SOLAR_MONTH_NAMES_KM = [
  'មករា',
  'កុម្ភៈ',
  'មីនា',
  'មេសា',
  'ឧសភា',
  'មិថុនា',
  'កក្កដា',
  'សីហា',
  'កញ្ញា',
  'តុលា',
  'វិច្ឆិកា',
  'ធ្នូ',
] as const;

export const ANIMAL_YEAR_NAMES_KM = [
  'ជូត',
  'ឆ្លូវ',
  'ខាល',
  'ថោះ',
  'រោង',
  'ម្សាញ់',
  'មមី',
  'មមែ',
  'វក',
  'រកា',
  'ច',
  'កុរ',
] as const;

export const ANIMAL_YEAR_NAMES_EN = [
  'Rat',
  'Ox',
  'Tiger',
  'Rabbit',
  'Dragon',
  'Snake',
  'Horse',
  'Goat',
  'Monkey',
  'Rooster',
  'Dog',
  'Pig',
] as const;

export const SAK_NAMES_KM = [
  'សំរឹទ្ធិស័ក',
  'ឯកស័ក',
  'ទោស័ក',
  'ត្រីស័ក',
  'ចត្វាស័ក',
  'បញ្ចស័ក',
  'ឆស័ក',
  'សប្តស័ក',
  'អដ្ឋស័ក',
  'នព្វស័ក',
] as const;

export const WEEKDAY_NAMES_KM = [
  'អាទិត្យ',
  'ចន្ទ',
  'អង្គារ',
  'ពុធ',
  'ព្រហស្បតិ៍',
  'សុក្រ',
  'សៅរ៍',
] as const;

export const MOON_PHASE_NAMES_KM = ['កើត', 'រោច'] as const;

const KHMER_DIGITS = ['០', '១', '២', '៣', '៤', '៥', '៦', '៧', '៨', '៩'];

export function toKhmerNumeral(value: number | string): string {
  return String(value).replace(/\d/g, (d) => KHMER_DIGITS[Number(d)]);
}
