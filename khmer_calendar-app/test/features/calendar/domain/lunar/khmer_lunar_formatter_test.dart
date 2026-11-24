import 'package:flutter_test/flutter_test.dart';
import 'package:khmer_calendar/core/date/civil_date.dart';
import 'package:khmer_calendar/features/calendar/domain/lunar/khmer_lunar_calendar.dart';
import 'package:khmer_calendar/features/calendar/domain/lunar/khmer_lunar_constants.dart';
import 'package:khmer_calendar/features/calendar/domain/lunar/khmer_lunar_formatter.dart';

void main() {
  test('formatKm matches the API contract example', () {
    const lunar = KhmerLunarDate(
      day: 10,
      moonPhase: MoonPhase.waxing,
      month: LunarMonth.migasir,
      beYear: 2570,
      jsYear: 1388,
      animalYear: 6,
      sak: 8,
      dayOfWeek: 0,
      isHolyDay: false,
    );
    expect(
      KhmerLunarFormatter.formatKm(lunar),
      'ថ្ងៃអាទិត្យ ១០កើត ខែមិគសិរ ឆ្នាំមមី អដ្ឋស័ក ពុទ្ធសករាជ ២៥៧០',
    );
  });

  test('formats a real date (Visakha Bochea 2024)', () {
    final lunar = KhmerLunarCalendar().toLunar(CivilDate(2024, 5, 22));
    expect(
      KhmerLunarFormatter.formatKm(lunar),
      'ថ្ងៃពុធ ១៥កើត ខែពិសាខ ឆ្នាំរោង ឆស័ក ពុទ្ធសករាជ ២៥៦៧',
    );
    expect(
      KhmerLunarFormatter.formatEn(lunar),
      'Wednesday, 15 Kert, month of Pisakh, Year of the Dragon, Chha Sak, '
      'BE 2567',
    );
    expect(KhmerLunarFormatter.dayLabelKm(lunar), '១៥កើត');
    expect(KhmerLunarFormatter.dayLabelEn(lunar), '15 Kert');
  });
}
