import 'package:flutter_test/flutter_test.dart';
import 'package:khmer_calendar/core/date/civil_date.dart';

void main() {
  test('parses and formats strict ISO dates', () {
    expect(CivilDate.parse('2024-02-29').toIso(), '2024-02-29');
    expect(CivilDate.tryParse('2023-02-29'), isNull);
    expect(CivilDate.tryParse('2024-2-1'), isNull);
  });

  test('julian day round-trips and weekday is Sunday-based', () {
    final date = CivilDate(2026, 11, 15);
    expect(CivilDate.fromJulianDay(date.julianDay), date);
    expect(date.dayOfWeek, 0); // Sunday
    expect(CivilDate(2000, 1, 1).julianDay, 2451545);
  });

  test('addDays crosses month and year boundaries', () {
    expect(CivilDate(2024, 12, 31).addDays(1), CivilDate(2025, 1, 1));
    expect(CivilDate(2024, 3, 1).addDays(-1), CivilDate(2024, 2, 29));
  });
}
