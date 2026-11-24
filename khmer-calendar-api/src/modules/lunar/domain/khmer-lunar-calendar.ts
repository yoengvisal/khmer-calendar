/**
 * Khmer lunar calendar (ចន្ទគតិ / Chhankitek) calculator.
 *
 * Port of the algorithm in @thyrith/momentkh v3 (MIT, (c) Thyrith Sor), which in
 * turn follows the traditional Chhankitek rules. Differences from the reference:
 *  - Works on civil dates only (no JS Date / timezone dependency).
 *  - Day-level semantics: the animal year changes on the Moha Songkran *date*,
 *    the era (ស័ក) on the Lerng Sak date, the Buddhist Era on 1 Roch Pisakh.
 *  - Pure functions + per-year memoization so it is cheap to call repeatedly.
 *
 * The Dart port in the mobile app must stay behaviourally identical; both are
 * verified against shared/fixtures/khmer-lunar-golden.json.
 */
import {
  type CivilDate,
  addDays,
  dayOfWeek as weekday,
  fromJulianDay,
  toJulianDay,
} from './civil-date.js';
import { LunarMonth, MoonPhase } from './khmer-lunar.constants.js';

export interface KhmerLunarDate {
  /** 1-15 */
  readonly day: number;
  readonly moonPhase: MoonPhase;
  readonly monthIndex: LunarMonth;
  /** Buddhist Era year (ពុទ្ធសករាជ) — changes on 1 Roch Pisakh. */
  readonly beYear: number;
  /** Jolak Sakaraj year (ចុល្លសករាជ). */
  readonly jsYear: number;
  /** 0 = Rat ... 11 = Pig */
  readonly animalYear: number;
  /** 0-9 */
  readonly sak: number;
  /** 0 = Sunday ... 6 = Saturday */
  readonly dayOfWeek: number;
  /** ថ្ងៃសីល: 8 Kert, 15 Kert, 8 Roch and the last day of the lunar month. */
  readonly isHolyDay: boolean;
}

export interface KhmerNewYearInfo {
  readonly gregorianYear: number;
  /** Moha Songkran (first day of Khmer New Year). */
  readonly mohaSongkran: CivilDate;
  readonly hour: number;
  readonly minute: number;
  /** Lerng Sak (last day of the celebration; era changes on this day). */
  readonly lerngSak: CivilDate;
  /** 3 or 4 days */
  readonly numberOfDays: number;
}

interface LunarDayAndMonth {
  /** 0-29 (0 = 1 Kert, 15 = 1 Roch) */
  dayNumber: number;
  monthIndex: LunarMonth;
}

interface SunInfo {
  angsar: number;
  libda: number;
}

/**
 * Known corrections for years where the computed Songkran differs from the
 * officially announced moment (carried over from the reference implementation).
 */
const NEW_YEAR_OVERRIDES: Readonly<
  Record<number, readonly [CivilDate, number, number]>
> = {
  1879: [{ year: 1879, month: 4, day: 12 }, 11, 36],
  1897: [{ year: 1897, month: 4, day: 13 }, 2, 0],
  2011: [{ year: 2011, month: 4, day: 14 }, 13, 12],
  2012: [{ year: 2012, month: 4, day: 14 }, 19, 11],
  2013: [{ year: 2013, month: 4, day: 14 }, 2, 12],
  2014: [{ year: 2014, month: 4, day: 14 }, 8, 7],
  2015: [{ year: 2015, month: 4, day: 14 }, 14, 2],
  2024: [{ year: 2024, month: 4, day: 13 }, 22, 17],
};

const EPOCH_JDN = toJulianDay({ year: 1900, month: 1, day: 1 }); // 1 Kert, Boss
const mod = (n: number, m: number) => ((n % m) + m) % m;

export class KhmerLunarCalendar {
  private readonly leapTypeCache = new Map<number, number>();
  private readonly pisakhaCache = new Map<number, number>();
  private readonly newYearCache = new Map<number, KhmerNewYearInfo>();

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  toLunar(date: CivilDate): KhmerLunarDate {
    const jdn = toJulianDay(date);
    const { dayNumber, monthIndex } = this.lunarDayAndMonth(date);

    const transitionJdn = this.beYearTransitionJdn(date.year);
    const beYear = jdn >= transitionJdn ? date.year + 544 : date.year + 543;
    let jsYear = beYear - 1182;
    let animalYear = mod(beYear + 4, 12);

    const newYear = this.newYear(date.year);
    if (jdn >= toJulianDay(newYear.mohaSongkran) && jdn < transitionJdn) {
      animalYear = (animalYear + 1) % 12;
    }
    if (jdn >= toJulianDay(newYear.lerngSak) && jdn < transitionJdn) {
      jsYear += 1;
    }

    const isLastDayOfMonth =
      this.lunarDayAndMonth(addDays(date, 1)).dayNumber === 0;

    return {
      day: (dayNumber % 15) + 1,
      moonPhase: dayNumber < 15 ? MoonPhase.Waxing : MoonPhase.Waning,
      monthIndex,
      beYear,
      jsYear,
      animalYear,
      sak: mod(jsYear, 10),
      dayOfWeek: weekday(date),
      isHolyDay:
        dayNumber === 7 ||
        dayNumber === 14 ||
        dayNumber === 22 ||
        isLastDayOfMonth,
    };
  }

  newYear(gregorianYear: number): KhmerNewYearInfo {
    const cached = this.newYearCache.get(gregorianYear);
    if (cached) return cached;

    const jsYear = gregorianYear - 638;
    const sotins = this.newYearSotins(jsYear);
    let hour = 0;
    let minute = 0;
    for (const sotin of sotins) {
      if (sotin.angsar === 0) {
        const minutes = 24 * 60 - sotin.libda * 24;
        hour = Math.floor(minutes / 60) % 24;
        minute = minutes % 60;
        break;
      }
    }

    let bodithey = this.boditheyJs(jsYear);
    if (
      this.isAdhikameasJs(jsYear - 1) &&
      this.isChantrathimeasJs(jsYear - 1)
    ) {
      bodithey = (bodithey + 1) % 30;
    }
    const lerngSakDay = bodithey >= 6 ? bodithey - 1 : bodithey;
    const lerngSakMonth = bodithey >= 6 ? LunarMonth.Cheit : LunarMonth.Pisakh;
    const numberOfDays = sotins[0].angsar === 0 ? 4 : 3;

    const epoch: CivilDate = { year: gregorianYear, month: 4, day: 17 };
    const khEpoch = this.lunarDayAndMonth(epoch);
    const diffFromEpoch =
      (khEpoch.monthIndex - 4) * 29 +
      khEpoch.dayNumber -
      ((lerngSakMonth - 4) * 29 + lerngSakDay);
    let newYearJdn = toJulianDay(epoch) - (diffFromEpoch + numberOfDays - 1);

    const override = NEW_YEAR_OVERRIDES[gregorianYear];
    if (override) {
      newYearJdn = toJulianDay(override[0]);
      hour = override[1];
      minute = override[2];
    }

    const info: KhmerNewYearInfo = {
      gregorianYear,
      mohaSongkran: fromJulianDay(newYearJdn),
      hour,
      minute,
      lerngSak: fromJulianDay(newYearJdn + numberOfDays - 1),
      numberOfDays,
    };
    this.newYearCache.set(gregorianYear, info);
    return info;
  }

  /** Every date in the Gregorian year whose lunar day/month matches. */
  findInGregorianYear(
    gregorianYear: number,
    monthIndex: LunarMonth,
    day: number,
    moonPhase: MoonPhase,
  ): CivilDate[] {
    const targetDayNumber = (moonPhase === MoonPhase.Waxing ? 0 : 15) + day - 1;
    const result: CivilDate[] = [];
    const start = toJulianDay({ year: gregorianYear, month: 1, day: 1 });
    const end = toJulianDay({ year: gregorianYear, month: 12, day: 31 });
    for (let jdn = start; jdn <= end; jdn++) {
      const date = fromJulianDay(jdn);
      const lunar = this.lunarDayAndMonth(date);
      if (
        lunar.monthIndex === monthIndex &&
        lunar.dayNumber === targetDayNumber
      ) {
        result.push(date);
      }
    }
    return result;
  }

  // ---------------------------------------------------------------------------
  // Lunar day & month
  // ---------------------------------------------------------------------------

  private lunarDayAndMonth(date: CivilDate): LunarDayAndMonth {
    let epochJdn = EPOCH_JDN;
    let diffDays = toJulianDay(date) - epochJdn;
    let monthIndex: LunarMonth = LunarMonth.Boss;

    if (diffDays > 0) {
      for (;;) {
        const epoch = fromJulianDay(epochJdn);
        const daysInNextYear = this.daysInKhmerYear(
          maybeBeYear(epoch.year + 1, epoch.month),
        );
        if (diffDays > daysInNextYear) {
          diffDays -= daysInNextYear;
          epochJdn += daysInNextYear;
        } else {
          break;
        }
      }
    } else if (diffDays < 0) {
      while (diffDays < 0) {
        const epoch = fromJulianDay(epochJdn);
        const daysInYear = this.daysInKhmerYear(
          maybeBeYear(epoch.year, epoch.month),
        );
        diffDays += daysInYear;
        epochJdn -= daysInYear;
      }
    }

    while (diffDays > 0) {
      const epoch = fromJulianDay(epochJdn);
      const be = maybeBeYear(epoch.year, epoch.month);
      const daysInMonth = this.daysInKhmerMonth(monthIndex, be);
      if (diffDays > daysInMonth) {
        diffDays -= daysInMonth;
        epochJdn += daysInMonth;
        monthIndex = this.nextMonthOf(monthIndex, be);
      } else {
        break;
      }
    }

    let dayNumber = diffDays;
    const finalBe = maybeBeYear(date.year, date.month);
    const totalDaysInMonth = this.daysInKhmerMonth(monthIndex, finalBe);
    if (dayNumber >= totalDaysInMonth) {
      dayNumber %= totalDaysInMonth;
      monthIndex = this.nextMonthOf(monthIndex, finalBe);
    }
    return { dayNumber, monthIndex };
  }

  /** JDN of 1 Roch Pisakh in the Gregorian year — the day the BE year increments. */
  private beYearTransitionJdn(gregorianYear: number): number {
    const cached = this.pisakhaCache.get(gregorianYear);
    if (cached !== undefined) return cached;

    let found = toJulianDay({ year: gregorianYear, month: 4, day: 15 }); // fallback
    const start = toJulianDay({ year: gregorianYear, month: 4, day: 1 });
    const end = toJulianDay({ year: gregorianYear, month: 6, day: 30 });
    for (let jdn = start; jdn <= end; jdn++) {
      const lunar = this.lunarDayAndMonth(fromJulianDay(jdn));
      if (lunar.monthIndex === LunarMonth.Pisakh && lunar.dayNumber === 15) {
        found = jdn;
        break;
      }
    }
    this.pisakhaCache.set(gregorianYear, found);
    return found;
  }

  // ---------------------------------------------------------------------------
  // Leap rules (BE-year based)
  // ---------------------------------------------------------------------------

  private daysInKhmerMonth(monthIndex: LunarMonth, beYear: number): number {
    const leapType = this.leapType(beYear);
    if (monthIndex === LunarMonth.Jesth && leapType === 2) return 30;
    if (
      monthIndex === LunarMonth.Pathamasadh ||
      monthIndex === LunarMonth.Tutiyasadh
    ) {
      return leapType === 1 ? 30 : 0;
    }
    return monthIndex % 2 === 0 ? 29 : 30;
  }

  private daysInKhmerYear(beYear: number): number {
    const leapType = this.leapType(beYear);
    if (leapType === 1) return 384;
    if (leapType === 2) return 355;
    return 354;
  }

  private nextMonthOf(monthIndex: LunarMonth, beYear: number): LunarMonth {
    if (monthIndex === LunarMonth.Jesth && this.leapType(beYear) === 1)
      return LunarMonth.Pathamasadh;
    if (monthIndex === LunarMonth.Kadeuk) return LunarMonth.Migasir;
    if (monthIndex === LunarMonth.Pathamasadh) return LunarMonth.Tutiyasadh;
    if (monthIndex === LunarMonth.Tutiyasadh) return LunarMonth.Srap;
    return (monthIndex + 1) as LunarMonth;
  }

  /** 0 = regular, 1 = leap month (អធិកមាស), 2 = leap day (ចន្ទ្រាធិមាស) */
  private leapType(beYear: number): number {
    const cached = this.leapTypeCache.get(beYear);
    if (cached !== undefined) return cached;

    let result = 0;
    if (isKhmerLeapMonth(beYear)) {
      result = 1;
    } else if (isKhmerLeapDay(beYear)) {
      result = 2;
    } else if (isKhmerLeapMonth(beYear - 1)) {
      let previousYear = beYear - 1;
      for (;;) {
        if (isKhmerLeapDay(previousYear)) {
          result = 2;
          break;
        }
        previousYear -= 1;
        if (!isKhmerLeapMonth(previousYear)) {
          result = 0;
          break;
        }
      }
    }
    this.leapTypeCache.set(beYear, result);
    return result;
  }

  // ---------------------------------------------------------------------------
  // Songkran (JS-year based)
  // ---------------------------------------------------------------------------

  private newYearSotins(jsYear: number): SunInfo[] {
    const sotins =
      kromthupulJs(jsYear - 1) <= 207
        ? [363, 364, 365, 366]
        : [362, 363, 364, 365];
    return sotins.map((sotin) => sunInfo(jsYear, sotin));
  }

  private boditheyJs(jsYear: number): number {
    const aharkun = aharkunJs(jsYear);
    return (aharkun + Math.floor((11 * aharkun + 650) / 692)) % 30;
  }

  private isAdhikameasJs(jsYear: number): boolean {
    const bodithey = this.boditheyJs(jsYear);
    const next = this.boditheyJs(jsYear + 1);
    if (bodithey === 24 && next === 6) return true;
    if (bodithey === 25 && next === 5) return false;
    return bodithey > 24 || bodithey < 6;
  }

  private isChantrathimeasJs(jsYear: number): boolean {
    const avoman = avomanJs(jsYear);
    const avomanNext = avomanJs(jsYear + 1);
    const avomanPrev = avomanJs(jsYear - 1);
    const isSolarLeap = kromthupulJs(jsYear) <= 207;
    if (avoman === 0 && avomanPrev === 137) return true;
    if (isSolarLeap) return avoman < 127;
    if (avoman === 137 && avomanNext === 0) return false;
    return avoman < 138;
  }
}

// -----------------------------------------------------------------------------
// Pure helpers
// -----------------------------------------------------------------------------

/** Approximate BE year used while walking months (matches the reference). */
function maybeBeYear(year: number, month: number): number {
  return month <= 4 ? year + 543 : year + 544;
}

function aharkun(beYear: number): number {
  return Math.floor((beYear * 292207 + 499) / 800) + 4;
}

function avoman(beYear: number): number {
  return (aharkun(beYear) * 11 + 25) % 692;
}

function bodithey(beYear: number): number {
  const a = aharkun(beYear);
  return (Math.floor((a * 11 + 25) / 692) + a + 29) % 30;
}

function isKhmerSolarLeap(beYear: number): boolean {
  return 800 - ((beYear * 292207 + 499) % 800) <= 207;
}

function isKhmerLeapDay(beYear: number): boolean {
  const av = avoman(beYear);
  if (av === 0 && avoman(beYear - 1) === 137) return true;
  if (isKhmerSolarLeap(beYear)) return av < 127;
  if (av === 137 && avoman(beYear + 1) === 0) return false;
  return av < 138;
}

function isKhmerLeapMonth(beYear: number): boolean {
  const b = bodithey(beYear);
  const next = bodithey(beYear + 1);
  if (b === 25 && next === 5) return false;
  return (b === 24 && next === 6) || b >= 25 || b < 6;
}

function aharkunJs(jsYear: number): number {
  return Math.floor((jsYear * 292207 + 373) / 800) + 1;
}

function avomanJs(jsYear: number): number {
  return (aharkunJs(jsYear) * 11 + 650) % 692;
}

function kromthupulJs(jsYear: number): number {
  return 800 - ((292207 * jsYear + 373) % 800);
}

function sunInfo(jsYear: number, sotin: number): SunInfo {
  const r2 = 800 * sotin + kromthupulJs(jsYear - 1);
  const reasey = Math.floor(r2 / 24350);
  const r3 = r2 % 24350;
  const angsar = Math.floor(r3 / 811);
  const libda = Math.floor((r3 % 811) / 14) - 3;
  const sunAverageAsLibda = 30 * 60 * reasey + 60 * angsar + libda;

  const s1 = 30 * 60 * 2 + 60 * 20;
  let leftOver = sunAverageAsLibda - s1;
  if (sunAverageAsLibda < s1) leftOver += 30 * 60 * 12;
  const kaen = Math.floor(leftOver / (30 * 60));

  let rs: number;
  if (kaen <= 2) rs = leftOver;
  else if (kaen <= 5) rs = 30 * 60 * 6 - leftOver;
  else if (kaen <= 8) rs = leftOver - 30 * 60 * 6;
  else rs = 30 * 60 * 11 + 60 * 29 + 60 - leftOver;

  const last = {
    reasey: Math.floor(rs / (30 * 60)),
    angsar: Math.floor((rs % (30 * 60)) / 60),
    libda: rs % 60,
  };
  let khan: number;
  let pouichalip: number;
  if (last.angsar >= 15) {
    khan = 2 * last.reasey + 1;
    pouichalip = 60 * (last.angsar - 15) + last.libda;
  } else {
    khan = 2 * last.reasey;
    pouichalip = 60 * last.angsar + last.libda;
  }

  const chhayaTable = [
    [35, 0],
    [32, 35],
    [27, 67],
    [22, 94],
    [13, 116],
    [5, 129],
  ] as const;
  const [multiplicity, chhaya] = khan <= 5 ? chhayaTable[khan] : [0, 134];
  const pholAsLibda = Math.floor((pouichalip * multiplicity) / 900) + chhaya;
  const inauguration =
    kaen <= 5
      ? sunAverageAsLibda - pholAsLibda
      : sunAverageAsLibda + pholAsLibda;

  return {
    angsar: Math.floor((inauguration % (30 * 60)) / 60),
    libda: inauguration % 60,
  };
}
