import { parseIsoDate, formatIsoDate } from './civil-date.js';
import { KhmerLunarCalendar } from './khmer-lunar-calendar.js';
import { LunarMonth, MoonPhase } from './khmer-lunar.constants.js';

const cal = new KhmerLunarCalendar();
const d = (iso: string) => parseIsoDate(iso)!;

/** Dates published by the Royal Government of Cambodia (public-holiday decrees). */
const ANCHORS: Array<[string, number, MoonPhase, LunarMonth, string]> = [
  ['2024-02-24', 15, MoonPhase.Waxing, LunarMonth.Meak, 'Meak Bochea 2024'],
  ['2025-02-12', 15, MoonPhase.Waxing, LunarMonth.Meak, 'Meak Bochea 2025'],
  [
    '2024-05-22',
    15,
    MoonPhase.Waxing,
    LunarMonth.Pisakh,
    'Visakha Bochea 2024',
  ],
  [
    '2025-05-11',
    15,
    MoonPhase.Waxing,
    LunarMonth.Pisakh,
    'Visakha Bochea 2025',
  ],
  [
    '2024-05-26',
    4,
    MoonPhase.Waning,
    LunarMonth.Pisakh,
    'Royal Ploughing 2024',
  ],
  [
    '2025-05-15',
    4,
    MoonPhase.Waning,
    LunarMonth.Pisakh,
    'Royal Ploughing 2025',
  ],
  ['2024-10-02', 15, MoonPhase.Waning, LunarMonth.Phatrabot, 'Pchum Ben 2024'],
  ['2025-09-22', 15, MoonPhase.Waning, LunarMonth.Phatrabot, 'Pchum Ben 2025'],
  [
    '2024-11-15',
    15,
    MoonPhase.Waxing,
    LunarMonth.Kadeuk,
    'Water Festival 2024',
  ],
  [
    '2025-11-05',
    15,
    MoonPhase.Waxing,
    LunarMonth.Kadeuk,
    'Water Festival 2025',
  ],
];

describe('KhmerLunarCalendar', () => {
  it.each(ANCHORS)('%s is %i %s month %i (%s)', (iso, day, phase, month) => {
    const lunar = cal.toLunar(d(iso));
    expect([lunar.day, lunar.moonPhase, lunar.monthIndex]).toEqual([
      day,
      phase,
      month,
    ]);
  });

  it.each([
    [2020, '2020-04-13'],
    [2021, '2021-04-14'],
    [2022, '2022-04-14'],
    [2023, '2023-04-14'],
    [2024, '2024-04-13'],
    [2025, '2025-04-14'],
  ])('Khmer New Year %i starts %s', (year, iso) => {
    expect(formatIsoDate(cal.newYear(year).mohaSongkran)).toBe(iso);
  });

  it('switches animal year on Moha Songkran, era on Lerng Sak and BE on 1 Roch Pisakh (2024)', () => {
    const before = cal.toLunar(d('2024-04-12'));
    expect([before.animalYear, before.sak, before.beYear]).toEqual([
      3, 5, 2567,
    ]); // Rabbit, Pancha Sak
    const songkran = cal.toLunar(d('2024-04-13'));
    expect(songkran.animalYear).toBe(4); // Dragon
    expect(songkran.sak).toBe(5);
    const lerngSak = cal.toLunar(d('2024-04-16'));
    expect([lerngSak.animalYear, lerngSak.sak, lerngSak.beYear]).toEqual([
      4, 6, 2567,
    ]); // Chha Sak
    expect(cal.toLunar(d('2024-05-22')).beYear).toBe(2567); // Visakha Bochea, still old BE
    const afterVisakha = cal.toLunar(d('2024-05-23'));
    expect([
      afterVisakha.animalYear,
      afterVisakha.sak,
      afterVisakha.beYear,
    ]).toEqual([4, 6, 2568]);
  });

  it('marks holy days (ថ្ងៃសីល)', () => {
    expect(cal.toLunar(d('2025-05-11')).isHolyDay).toBe(true); // 15 Kert
    expect(cal.toLunar(d('2025-05-12')).isHolyDay).toBe(false); // 1 Roch
  });

  it('is continuous: lunar day always advances by one or wraps to 1 Kert', () => {
    let prev = cal.toLunar(d('1990-01-01'));
    for (let jdnOffset = 1; jdnOffset < 365 * 60; jdnOffset++) {
      const date = new Date(Date.UTC(1990, 0, 1 + jdnOffset));
      const cur = cal.toLunar({
        year: date.getUTCFullYear(),
        month: date.getUTCMonth() + 1,
        day: date.getUTCDate(),
      });
      const prevN = prev.moonPhase * 15 + prev.day - 1;
      const curN = cur.moonPhase * 15 + cur.day - 1;
      if (curN !== prevN + 1) {
        expect(curN).toBe(0);
        expect(prevN === 28 || prevN === 29).toBe(true);
      }
      prev = cur;
    }
  });
});
