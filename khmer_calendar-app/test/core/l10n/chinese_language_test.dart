import 'package:flutter_test/flutter_test.dart';
import 'package:khmer_calendar/core/date/civil_date.dart';
import 'package:khmer_calendar/core/l10n/l10n.dart';
import 'package:khmer_calendar/features/calendar/domain/lunar/khmer_lunar_calendar.dart';
import 'package:khmer_calendar/features/calendar/domain/lunar/khmer_lunar_formatter.dart';
import 'package:khmer_calendar/features/events/data/models/event_dto.dart';
import 'package:khmer_calendar/features/events/domain/entities/calendar_event.dart';
import 'package:khmer_calendar/features/events/presentation/widgets/event_style.dart';
import 'package:khmer_calendar/features/settings/domain/entities/app_settings.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/pump_app.dart';

void main() {
  final calendar = KhmerLunarCalendar();

  group('Chinese lunar labels', () {
    test('lunar days map to 初一…十五 (Kert) and 十六…三十 (Roch)', () {
      // Visakha Bochea 2025 = 15 Kert, next day 1 Roch; Pchum Ben 2025 = 15 Roch.
      expect(
        KhmerLunarFormatter.dayLabelZh(
          calendar.toLunar(CivilDate(2025, 5, 11)),
        ),
        '十五',
      );
      expect(
        KhmerLunarFormatter.dayLabelZh(
          calendar.toLunar(CivilDate(2025, 5, 12)),
        ),
        '十六',
      );
      expect(
        KhmerLunarFormatter.dayLabelZh(
          calendar.toLunar(CivilDate(2025, 9, 22)),
        ),
        '三十',
      );
      expect(
        KhmerLunarFormatter.dayLabelZh(
          calendar.toLunar(CivilDate(2025, 5, 13)),
        ),
        '十七',
      );
    });

    test('formatZh describes a full day', () {
      // 2026-11-15 is 6 Kert of Kadeuk (12th month), Year of the Horse, BE 2570.
      expect(
        KhmerLunarFormatter.formatZh(calendar.toLunar(CivilDate(2026, 11, 15))),
        '星期日 · 柬历十二月初六 · 马年 · 佛历2570',
      );
    });
  });

  group('Chinese date formatting', () {
    test('single dates', () {
      expect(
        formatCivilDate(
          CivilDate(2026, 11, 15),
          UiLanguage.zh,
          withWeekday: true,
        ),
        '2026年11月15日 星期日',
      );
      expect(formatMonthYear(2026, 4, UiLanguage.zh), '2026年4月');
    });

    test('ranges', () {
      expect(
        formatDateRange(
          CivilDate(2026, 4, 14),
          CivilDate(2026, 4, 16),
          UiLanguage.zh,
        ),
        '2026年4月14日 - 16日',
      );
      expect(
        formatDateRange(
          CivilDate(2026, 4, 30),
          CivilDate(2026, 5, 2),
          UiLanguage.zh,
        ),
        '2026年4月30日 - 5月2日',
      );
      expect(
        formatDateRange(
          CivilDate(2026, 12, 31),
          CivilDate(2027, 1, 1),
          UiLanguage.zh,
        ),
        '2026年12月31日 - 2027年1月1日',
      );
    });

    test('weekday labels', () {
      expect(weekdayShortLabels(UiLanguage.zh).first, '日');
    });
  });

  group('settings', () {
    test('zh is a persisted language code', () {
      expect(AppLanguage.fromCode('zh'), AppLanguage.chinese);
      expect(AppLanguage.chinese.code, 'zh');
    });
  });

  group('event titles', () {
    Map<String, dynamic> json({Object? titleZh = _absent}) => {
      'id': 'e1',
      'titleKm': 'ពិធីបុណ្យអុំទូក',
      'titleEn': 'Water Festival',
      if (titleZh != _absent) 'titleZh': titleZh,
      'category': 'CULTURAL',
      'startDate': '2026-11-23',
      'endDate': '2026-11-25',
      'isDayOff': true,
    };

    test('titleZh is parsed, and optional for older payloads', () {
      expect(EventDto.fromJson(json(titleZh: '送水节')).toEntity().titleZh, '送水节');
      expect(EventDto.fromJson(json()).toEntity().titleZh, isNull);
      expect(EventDto.fromJson(json(titleZh: null)).toEntity().titleZh, isNull);
    });

    Future<String> titleIn(
      WidgetTester tester,
      Locale locale,
      CalendarEvent e,
    ) async {
      late String title;
      await pumpLocalized(
        tester,
        Builder(
          builder: (context) {
            title = e.localizedTitle(context);
            return const SizedBox();
          },
        ),
        locale: locale,
      );
      return title;
    }

    testWidgets('picks the UI language and falls back to English', (
      tester,
    ) async {
      final translated = EventDto.fromJson(json(titleZh: '送水节')).toEntity();
      final untranslated = EventDto.fromJson(json()).toEntity();
      expect(await titleIn(tester, const Locale('zh'), translated), '送水节');
      expect(
        await titleIn(tester, const Locale('zh'), untranslated),
        'Water Festival',
      );
      expect(
        await titleIn(tester, const Locale('km'), translated),
        'ពិធីបុណ្យអុំទូក',
      );
      expect(
        await titleIn(tester, const Locale('en'), translated),
        'Water Festival',
      );
    });
  });
}

const Object _absent = Object();
