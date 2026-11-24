/// Khmer lunar calendar constants. Mirrors `khmer-lunar.constants.ts`.
library;

export '../../../../core/date/date_names.dart';

enum MoonPhase {
  /// កើត (index 0)
  waxing,

  /// រោច (index 1)
  waning,
}

/// Lunar month. [index] matches the API's `monthIndex` (0-13).
/// 12 and 13 only occur in leap-month (អធិកមាស) years.
enum LunarMonth {
  migasir,
  boss,
  meak,
  phalkun,
  cheit,
  pisakh,
  jesth,
  asadh,
  srap,
  phatrabot,
  assoch,
  kadeuk,
  pathamasadh,
  tutiyasadh,
}

const List<String> lunarMonthNamesKm = [
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
];

const List<String> lunarMonthNamesEn = [
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
];

const List<String> animalYearNamesKm = [
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
];

const List<String> animalYearNamesEn = [
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
];

const List<String> sakNamesKm = [
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
];

const List<String> sakNamesEn = [
  'Samridhi Sak',
  'Ek Sak',
  'To Sak',
  'Trei Sak',
  'Chattva Sak',
  'Pancha Sak',
  'Chha Sak',
  'Sapta Sak',
  'Attha Sak',
  'Nup Sak',
];

const List<String> moonPhaseNamesKm = ['កើត', 'រោច'];
const List<String> moonPhaseNamesEn = ['Kert', 'Roch'];

/// Simplified Chinese month labels. The Khmer lunar year counts Migasir as the
/// first month and Asadh as the eighth; in a leap-month year the two Asadh
/// months become 前八月 / 后八月. Shown with the 柬历 ("Khmer calendar") prefix.
const List<String> lunarMonthNamesZh = [
  '一月',
  '二月',
  '三月',
  '四月',
  '五月',
  '六月',
  '七月',
  '八月',
  '九月',
  '十月',
  '十一月',
  '十二月',
  '前八月',
  '后八月',
];

const List<String> animalYearNamesZh = [
  '鼠',
  '牛',
  '虎',
  '兔',
  '龙',
  '蛇',
  '马',
  '羊',
  '猴',
  '鸡',
  '狗',
  '猪',
];

/// Lunar day names 1-30 as used in Chinese lunar calendars: 1 Kert = 初一,
/// 15 Kert = 十五, 1 Roch = 十六 … 15 Roch = 三十.
const List<String> lunarDayNamesZh = [
  '初一',
  '初二',
  '初三',
  '初四',
  '初五',
  '初六',
  '初七',
  '初八',
  '初九',
  '初十',
  '十一',
  '十二',
  '十三',
  '十四',
  '十五',
  '十六',
  '十七',
  '十八',
  '十九',
  '二十',
  '廿一',
  '廿二',
  '廿三',
  '廿四',
  '廿五',
  '廿六',
  '廿七',
  '廿八',
  '廿九',
  '三十',
];
