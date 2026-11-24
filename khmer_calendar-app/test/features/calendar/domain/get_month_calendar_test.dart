import 'package:flutter_test/flutter_test.dart';
import 'package:khmer_calendar/core/date/civil_date.dart';
import 'package:khmer_calendar/core/errors/app_failure.dart';
import 'package:khmer_calendar/core/errors/result.dart';
import 'package:khmer_calendar/features/calendar/domain/entities/calendar_month.dart';
import 'package:khmer_calendar/features/calendar/domain/lunar/khmer_lunar_calendar.dart';
import 'package:khmer_calendar/features/calendar/domain/lunar/khmer_lunar_constants.dart';
import 'package:khmer_calendar/features/calendar/domain/usecases/get_month_calendar.dart';
import 'package:khmer_calendar/features/events/domain/entities/year_events.dart';

import '../../../helpers/fakes.dart';

void main() {
  final lunar = KhmerLunarCalendar();
  late FakeEventsRepository events;
  late GetMonthCalendar useCase;

  setUp(() {
    events = FakeEventsRepository(
      (year) => Ok(
        YearEvents(
          year: year,
          events: [
            // Khmer New Year 2025: 3-day event.
            calendarEvent(id: 'kny', start: '2025-04-14', end: '2025-04-16'),
            // Crosses into May.
            calendarEvent(
              id: 'span',
              start: '2025-04-29',
              end: '2025-05-02',
              isDayOff: false,
            ),
            calendarEvent(id: 'visak', start: '2025-05-11'),
          ],
        ),
      ),
    );
    useCase = GetMonthCalendar(lunarCalendar: lunar, eventsRepository: events);
  });

  test('combines locally computed lunar data with events', () async {
    final month = await useCase(2025, 5);

    expect(month.days, hasLength(31));
    expect(month.eventsAvailability, EventsAvailability.live);
    expect(events.requestedYears, [2025]);
    for (final day in month.days) {
      expect(day.lunar, lunar.toLunar(day.date));
    }
    final visak = month.days[10];
    expect(visak.date, CivilDate(2025, 5, 11));
    expect((visak.lunar.day, visak.lunar.month), (15, LunarMonth.pisakh));
    expect(visak.isHolyDay, isTrue);
    expect(visak.events.single.id, 'visak');
    expect(visak.isDayOff, isTrue);
  });

  test('multi-day events cover every day in their range', () async {
    final april = await useCase(2025, 4);

    final covered = [
      for (final day in april.days)
        if (day.events.any((e) => e.id == 'kny')) day.date.day,
    ];
    expect(covered, [14, 15, 16]);

    final may = await useCase(2025, 5);
    final spanDays = [
      for (final day in may.days)
        if (day.events.any((e) => e.id == 'span')) day.date.day,
    ];
    expect(spanDays, [1, 2]);
    expect(april.days[29].events.map((e) => e.id), ['span']); // 30 April
  });

  test('Sunday-first leading blanks and header summary', () async {
    final month = await useCase(2025, 5);
    expect(month.leadingBlankDays, 4); // 1 May 2025 is a Thursday
    expect(month.lunarMonths, [LunarMonth.pisakh, LunarMonth.jesth]);
    expect(month.beYears, [2568, 2569]);
  });

  test('events failure still yields complete lunar data', () async {
    events.result = (_) => const Err(NetworkFailure());

    final month = await useCase(2025, 2);

    expect(month.days, hasLength(28));
    expect(month.eventsAvailability, EventsAvailability.unavailable);
    expect(month.eventsFailure, const NetworkFailure());
    expect(month.days.every((d) => d.events.isEmpty), isTrue);
    expect(month.days[11].lunar.day, 15); // Meak Bochea 2025-02-12
  });

  test('cached events are flagged', () async {
    events.result = (year) =>
        Ok(YearEvents(year: year, events: const [], isFromCache: true));
    final month = await useCase(2025, 1);
    expect(month.eventsAvailability, EventsAvailability.cached);
  });
}
