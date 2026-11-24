import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:khmer_calendar/core/date/civil_date.dart';
import 'package:khmer_calendar/features/calendar/domain/lunar/khmer_lunar_calendar.dart';
import 'package:khmer_calendar/features/calendar/domain/lunar/khmer_lunar_constants.dart';

/// `flutter test` runs with the package root as the working directory.
final File goldenFile = File('../shared/fixtures/khmer-lunar-golden.json');

CivilDate d(String iso) => CivilDate.parse(iso);

void main() {
  final cal = KhmerLunarCalendar();

  group('golden-file parity with the TypeScript engine', () {
    late Map<String, dynamic> golden;

    setUpAll(() {
      expect(
        goldenFile.existsSync(),
        isTrue,
        reason: 'Missing ${goldenFile.absolute.path}',
      );
      golden =
          jsonDecode(goldenFile.readAsStringSync()) as Map<String, dynamic>;
    });

    test('field layout is the one this test understands', () {
      expect(golden['dayFields'], [
        'date',
        'lunarDay',
        'moonPhase',
        'monthIndex',
        'beYear',
        'jsYear',
        'animalYear',
        'sak',
        'dayOfWeek',
        'isHolyDay',
      ]);
      expect(golden['newYearFields'], [
        'gregorianYear',
        'mohaSongkran',
        'hour',
        'minute',
        'lerngSak',
        'numberOfDays',
      ]);
    });

    test('every day vector matches', () {
      final days = golden['days'] as List<dynamic>;
      expect(days, hasLength(8789));
      final mismatches = <String>[];
      for (final raw in days) {
        final row = raw as List<dynamic>;
        final lunar = cal.toLunar(d(row[0] as String));
        final actual = [
          row[0],
          lunar.day,
          lunar.moonPhase.index,
          lunar.month.index,
          lunar.beYear,
          lunar.jsYear,
          lunar.animalYear,
          lunar.sak,
          lunar.dayOfWeek,
          lunar.isHolyDay ? 1 : 0,
        ];
        final expected = [for (final v in row) v is bool ? (v ? 1 : 0) : v];
        if (actual.toString() != expected.toString()) {
          mismatches.add('expected $expected, got $actual');
        }
      }
      expect(mismatches, isEmpty, reason: mismatches.take(10).join('\n'));
    });

    test('every new-year vector matches', () {
      final newYears = golden['newYears'] as List<dynamic>;
      expect(newYears, hasLength(201));
      final mismatches = <String>[];
      for (final raw in newYears) {
        final row = raw as List<dynamic>;
        final info = cal.newYear(row[0] as int);
        final actual = [
          info.gregorianYear,
          info.mohaSongkran.toIso(),
          info.hour,
          info.minute,
          info.lerngSak.toIso(),
          info.numberOfDays,
        ];
        if (actual.toString() != row.toString()) {
          mismatches.add('expected $row, got $actual');
        }
      }
      expect(mismatches, isEmpty, reason: mismatches.take(10).join('\n'));
    });
  });

  group('real-world anchors (Royal Government public-holiday decrees)', () {
    const anchors = <(String, int, MoonPhase, LunarMonth, String)>[
      ('2024-02-24', 15, MoonPhase.waxing, LunarMonth.meak, 'Meak Bochea 2024'),
      ('2025-02-12', 15, MoonPhase.waxing, LunarMonth.meak, 'Meak Bochea 2025'),
      ('2024-05-22', 15, MoonPhase.waxing, LunarMonth.pisakh, 'Visakha 2024'),
      ('2025-05-11', 15, MoonPhase.waxing, LunarMonth.pisakh, 'Visakha 2025'),
      ('2024-05-26', 4, MoonPhase.waning, LunarMonth.pisakh, 'Ploughing 2024'),
      ('2025-05-15', 4, MoonPhase.waning, LunarMonth.pisakh, 'Ploughing 2025'),
      ('2024-10-02', 15, MoonPhase.waning, LunarMonth.phatrabot, 'Pchum 2024'),
      ('2025-09-22', 15, MoonPhase.waning, LunarMonth.phatrabot, 'Pchum 2025'),
      ('2024-11-15', 15, MoonPhase.waxing, LunarMonth.kadeuk, 'Water 2024'),
      ('2025-11-05', 15, MoonPhase.waxing, LunarMonth.kadeuk, 'Water 2025'),
    ];
    for (final (iso, day, phase, month, label) in anchors) {
      test('$iso is $day ${phase.name} ${month.name} ($label)', () {
        final lunar = cal.toLunar(d(iso));
        expect((lunar.day, lunar.moonPhase, lunar.month), (day, phase, month));
      });
    }

    const newYears = <(int, String)>[
      (2020, '2020-04-13'),
      (2021, '2021-04-14'),
      (2022, '2022-04-14'),
      (2023, '2023-04-14'),
      (2024, '2024-04-13'),
      (2025, '2025-04-14'),
    ];
    for (final (year, iso) in newYears) {
      test('Khmer New Year $year starts $iso', () {
        expect(cal.newYear(year).mohaSongkran.toIso(), iso);
      });
    }

    test('switches animal year on Moha Songkran, era on Lerng Sak and BE on '
        '1 Roch Pisakh (2024)', () {
      final before = cal.toLunar(d('2024-04-12'));
      expect((before.animalYear, before.sak, before.beYear), (3, 5, 2567));
      final songkran = cal.toLunar(d('2024-04-13'));
      expect(songkran.animalYear, 4); // Dragon
      expect(songkran.sak, 5);
      final lerngSak = cal.toLunar(d('2024-04-16'));
      expect(
        (lerngSak.animalYear, lerngSak.sak, lerngSak.beYear),
        (4, 6, 2567),
      );
      expect(cal.toLunar(d('2024-05-22')).beYear, 2567);
      final afterVisakha = cal.toLunar(d('2024-05-23'));
      expect(
        (afterVisakha.animalYear, afterVisakha.sak, afterVisakha.beYear),
        (4, 6, 2568),
      );
    });

    test('marks holy days (ថ្ងៃសីល)', () {
      expect(cal.toLunar(d('2025-05-11')).isHolyDay, isTrue); // 15 Kert
      expect(cal.toLunar(d('2025-05-12')).isHolyDay, isFalse); // 1 Roch
    });
  });

  test('is continuous: lunar day advances by one or wraps to 1 Kert', () {
    final start = d('1990-01-01');
    var prev = cal.toLunar(start);
    for (var offset = 1; offset < 365 * 60; offset++) {
      final cur = cal.toLunar(start.addDays(offset));
      final prevN = prev.moonPhase.index * 15 + prev.day - 1;
      final curN = cur.moonPhase.index * 15 + cur.day - 1;
      if (curN != prevN + 1) {
        expect(curN, 0, reason: 'at ${start.addDays(offset)}');
        expect(prevN == 28 || prevN == 29, isTrue);
      }
      prev = cur;
    }
  });

  test('findInGregorianYear finds Visakha Bochea 2025', () {
    expect(
      cal.findInGregorianYear(2025, LunarMonth.pisakh, 15, MoonPhase.waxing),
      [d('2025-05-11')],
    );
  });
}
