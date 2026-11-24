/**
 * Built-in holiday rules used to *draft* a year's events. Generated events are created
 * as DRAFT so an editor can check them against the official Royal Government
 * announcement for that year (fixed-date public holidays change by sub-decree).
 * Pure domain code: no framework or ORM imports.
 */
import { type CivilDate, addDays } from '../../lunar/domain/civil-date.js';
import type { KhmerNewYearInfo } from '../../lunar/domain/khmer-lunar-calendar.js';
import {
  LunarMonth,
  MoonPhase,
} from '../../lunar/domain/khmer-lunar.constants.js';

export type HolidayCategory =
  'PUBLIC_HOLIDAY' | 'BUDDHIST_HOLY_DAY' | 'CULTURAL' | 'OBSERVANCE';

interface RuleBase {
  key: string;
  titleKm: string;
  titleEn: string;
  titleZh: string;
  category: HolidayCategory;
  isDayOff: boolean;
}

export type HolidayRule =
  | (RuleBase & {
      kind: 'fixed';
      month: number;
      day: number;
      durationDays: number;
    })
  | (RuleBase & {
      kind: 'lunar';
      lunarMonth: LunarMonth;
      lunarDay: number;
      phase: MoonPhase;
      durationDays: number;
    })
  | (RuleBase & { kind: 'khmer-new-year' });

export const HOLIDAY_RULES: readonly HolidayRule[] = [
  {
    kind: 'fixed',
    key: 'international-new-year',
    month: 1,
    day: 1,
    durationDays: 1,
    titleKm: 'ទិវាចូលឆ្នាំសកល',
    titleEn: 'International New Year Day',
    titleZh: '元旦',
    category: 'PUBLIC_HOLIDAY',
    isDayOff: true,
  },
  {
    kind: 'fixed',
    key: 'victory-over-genocide',
    month: 1,
    day: 7,
    durationDays: 1,
    titleKm: 'ទិវាជ័យជម្នះលើរបបប្រល័យពូជសាសន៍',
    titleEn: 'Victory over Genocide Day',
    titleZh: '战胜种族灭绝纪念日',
    category: 'PUBLIC_HOLIDAY',
    isDayOff: true,
  },
  {
    kind: 'fixed',
    key: 'womens-day',
    month: 3,
    day: 8,
    durationDays: 1,
    titleKm: 'ទិវាអន្តរជាតិនារី',
    titleEn: "International Women's Day",
    titleZh: '国际妇女节',
    category: 'PUBLIC_HOLIDAY',
    isDayOff: true,
  },
  {
    kind: 'khmer-new-year',
    key: 'khmer-new-year',
    titleKm: 'ពិធីបុណ្យចូលឆ្នាំថ្មីប្រពៃណីជាតិ',
    titleEn: 'Khmer New Year',
    titleZh: '柬埔寨新年',
    category: 'PUBLIC_HOLIDAY',
    isDayOff: true,
  },
  {
    kind: 'fixed',
    key: 'labour-day',
    month: 5,
    day: 1,
    durationDays: 1,
    titleKm: 'ទិវាពលកម្មអន្តរជាតិ',
    titleEn: 'International Labour Day',
    titleZh: '国际劳动节',
    category: 'PUBLIC_HOLIDAY',
    isDayOff: true,
  },
  {
    kind: 'fixed',
    key: 'king-birthday',
    month: 5,
    day: 14,
    durationDays: 1,
    titleKm: 'ព្រះរាជពិធីបុណ្យចម្រើនព្រះជន្ម ព្រះមហាក្សត្រ',
    titleEn: "King's Birthday",
    titleZh: '国王诞辰',
    category: 'PUBLIC_HOLIDAY',
    isDayOff: true,
  },
  {
    kind: 'fixed',
    key: 'queen-mother-birthday',
    month: 6,
    day: 18,
    durationDays: 1,
    titleKm: 'ព្រះរាជពិធីបុណ្យចម្រើនព្រះជន្ម ព្រះវររាជមាតា',
    titleEn: "Queen Mother's Birthday",
    titleZh: '太后诞辰',
    category: 'PUBLIC_HOLIDAY',
    isDayOff: true,
  },
  {
    kind: 'fixed',
    key: 'constitution-day',
    month: 9,
    day: 24,
    durationDays: 1,
    titleKm: 'ទិវាប្រកាសរដ្ឋធម្មនុញ្ញ',
    titleEn: 'Constitution Day',
    titleZh: '宪法日',
    category: 'PUBLIC_HOLIDAY',
    isDayOff: true,
  },
  {
    kind: 'fixed',
    key: 'king-father-commemoration',
    month: 10,
    day: 15,
    durationDays: 1,
    titleKm: 'ទិវាប្រារព្ធពិធីគោរពព្រះវិញ្ញាណក្ខន្ធ ព្រះបរមរតនកោដ្ឋ',
    titleEn: 'Commemoration Day of King Father',
    titleZh: '太皇纪念日',
    category: 'PUBLIC_HOLIDAY',
    isDayOff: true,
  },
  {
    kind: 'fixed',
    key: 'coronation-day',
    month: 10,
    day: 29,
    durationDays: 1,
    titleKm: 'ព្រះរាជពិធីគ្រងព្រះបរមរាជសម្បត្តិ',
    titleEn: 'Coronation Day',
    titleZh: '国王加冕日',
    category: 'PUBLIC_HOLIDAY',
    isDayOff: true,
  },
  {
    kind: 'fixed',
    key: 'independence-day',
    month: 11,
    day: 9,
    durationDays: 1,
    titleKm: 'ពិធីបុណ្យឯករាជ្យជាតិ',
    titleEn: 'Independence Day',
    titleZh: '独立日',
    category: 'PUBLIC_HOLIDAY',
    isDayOff: true,
  },
  {
    kind: 'lunar',
    key: 'meak-bochea',
    lunarMonth: LunarMonth.Meak,
    lunarDay: 15,
    phase: MoonPhase.Waxing,
    durationDays: 1,
    titleKm: 'ពិធីបុណ្យមាឃបូជា',
    titleEn: 'Meak Bochea Day',
    titleZh: '万佛节',
    category: 'BUDDHIST_HOLY_DAY',
    isDayOff: false,
  },
  {
    kind: 'lunar',
    key: 'visakha-bochea',
    lunarMonth: LunarMonth.Pisakh,
    lunarDay: 15,
    phase: MoonPhase.Waxing,
    durationDays: 1,
    titleKm: 'ពិធីបុណ្យវិសាខបូជា',
    titleEn: 'Visak Bochea Day',
    titleZh: '卫塞节',
    category: 'BUDDHIST_HOLY_DAY',
    isDayOff: true,
  },
  {
    kind: 'lunar',
    key: 'royal-ploughing',
    lunarMonth: LunarMonth.Pisakh,
    lunarDay: 4,
    phase: MoonPhase.Waning,
    durationDays: 1,
    titleKm: 'ព្រះរាជពិធីច្រត់ព្រះនង្គ័ល',
    titleEn: 'Royal Ploughing Ceremony',
    titleZh: '御耕节',
    category: 'CULTURAL',
    isDayOff: true,
  },
  {
    kind: 'lunar',
    key: 'pchum-ben',
    lunarMonth: LunarMonth.Phatrabot,
    lunarDay: 14,
    phase: MoonPhase.Waning,
    durationDays: 3,
    titleKm: 'ពិធីបុណ្យភ្ជុំបិណ្ឌ',
    titleEn: 'Pchum Ben Festival',
    titleZh: '亡人节',
    category: 'BUDDHIST_HOLY_DAY',
    isDayOff: true,
  },
  {
    kind: 'lunar',
    key: 'water-festival',
    lunarMonth: LunarMonth.Kadeuk,
    lunarDay: 14,
    phase: MoonPhase.Waxing,
    durationDays: 3,
    titleKm: 'ព្រះរាជពិធីបុណ្យអុំទូក បណ្តែតប្រទីប និងសំពះព្រះខែ អកអំបុក',
    titleEn: 'Water Festival',
    titleZh: '送水节',
    category: 'CULTURAL',
    isDayOff: true,
  },
];

export interface HolidayCandidate {
  sourceKey: string;
  titleKm: string;
  titleEn: string;
  titleZh: string;
  category: HolidayCategory;
  isDayOff: boolean;
  startDate: CivilDate;
  endDate: CivilDate;
}

/** Calendar capabilities the generator needs (implemented by the lunar engine). */
export interface HolidayCalendarPort {
  newYear(gregorianYear: number): KhmerNewYearInfo;
  findInGregorianYear(
    year: number,
    month: LunarMonth,
    day: number,
    phase: MoonPhase,
  ): CivilDate[];
}

export function generateHolidayCandidates(
  year: number,
  calendar: HolidayCalendarPort,
  rules: readonly HolidayRule[] = HOLIDAY_RULES,
): HolidayCandidate[] {
  const candidates: HolidayCandidate[] = [];
  for (const rule of rules) {
    const base = {
      titleKm: rule.titleKm,
      titleEn: rule.titleEn,
      titleZh: rule.titleZh,
      category: rule.category,
      isDayOff: rule.isDayOff,
    };
    switch (rule.kind) {
      case 'fixed': {
        const start = { year, month: rule.month, day: rule.day };
        candidates.push({
          ...base,
          sourceKey: `fixed:${rule.key}:${year}`,
          startDate: start,
          endDate: addDays(start, rule.durationDays - 1),
        });
        break;
      }
      case 'khmer-new-year': {
        const ny = calendar.newYear(year);
        candidates.push({
          ...base,
          sourceKey: `khmer-new-year:${year}`,
          startDate: ny.mohaSongkran,
          endDate: ny.lerngSak,
        });
        break;
      }
      case 'lunar': {
        const matches = calendar.findInGregorianYear(
          year,
          rule.lunarMonth,
          rule.lunarDay,
          rule.phase,
        );
        matches.forEach((start, i) => {
          const suffix = matches.length > 1 ? `-${i + 1}` : '';
          candidates.push({
            ...base,
            sourceKey: `lunar:${rule.key}:${year}${suffix}`,
            startDate: start,
            endDate: addDays(start, rule.durationDays - 1),
          });
        });
        break;
      }
    }
  }
  return candidates;
}
