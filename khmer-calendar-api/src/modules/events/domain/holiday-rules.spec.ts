import { formatIsoDate } from '../../lunar/domain/civil-date.js';
import { KhmerLunarCalendar } from '../../lunar/domain/khmer-lunar-calendar.js';
import { generateHolidayCandidates } from './holiday-rules.js';

describe('generateHolidayCandidates', () => {
  const byKey = (year: number) =>
    new Map(
      generateHolidayCandidates(year, new KhmerLunarCalendar()).map((c) => [
        c.sourceKey,
        `${formatIsoDate(c.startDate)}..${formatIsoDate(c.endDate)}`,
      ]),
    );

  it('matches the officially announced 2025 lunar holidays', () => {
    const y = byKey(2025);
    expect(y.get('khmer-new-year:2025')).toBe('2025-04-14..2025-04-16');
    expect(y.get('lunar:visakha-bochea:2025')).toBe('2025-05-11..2025-05-11');
    expect(y.get('lunar:royal-ploughing:2025')).toBe('2025-05-15..2025-05-15');
    expect(y.get('lunar:pchum-ben:2025')).toBe('2025-09-21..2025-09-23');
    expect(y.get('lunar:water-festival:2025')).toBe('2025-11-04..2025-11-06');
  });

  it('produces unique source keys so generation is idempotent', () => {
    const keys = generateHolidayCandidates(2026, new KhmerLunarCalendar()).map(
      (c) => c.sourceKey,
    );
    expect(new Set(keys).size).toBe(keys.length);
  });

  it('gives every generated holiday Khmer, English and Chinese titles', () => {
    for (const c of generateHolidayCandidates(2026, new KhmerLunarCalendar())) {
      expect(c.titleKm && c.titleEn && c.titleZh).toBeTruthy();
    }
  });
});
