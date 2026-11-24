import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khmer_calendar/core/date/civil_date.dart';
import 'package:khmer_calendar/core/date/clock.dart';
import 'package:khmer_calendar/core/errors/result.dart';
import 'package:khmer_calendar/features/calendar/domain/entities/year_month.dart';
import 'package:khmer_calendar/features/calendar/domain/lunar/khmer_lunar_calendar.dart';
import 'package:khmer_calendar/features/calendar/domain/usecases/get_month_calendar.dart';
import 'package:khmer_calendar/features/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:khmer_calendar/features/events/domain/entities/year_events.dart';

import '../../../../helpers/fakes.dart';

void main() {
  final clock = Clock.fixed(DateTime(2025, 12, 20));
  late FakeEventsRepository events;

  CalendarBloc buildBloc() => CalendarBloc(
    getMonthCalendar: GetMonthCalendar(
      lunarCalendar: KhmerLunarCalendar(),
      eventsRepository: events,
    ),
    clock: clock,
  );

  setUp(() {
    events = FakeEventsRepository(
      (year) => Ok(YearEvents(year: year, events: const [])),
    );
  });

  Matcher loading(int year, int month) => isA<CalendarState>()
      .having((s) => s.status, 'status', CalendarStatus.loading)
      .having((s) => s.visibleMonth, 'visibleMonth', YearMonth(year, month))
      .having((s) => s.month, 'month', isNull);

  Matcher success(int year, int month) => isA<CalendarState>()
      .having((s) => s.status, 'status', CalendarStatus.success)
      .having((s) => s.visibleMonth, 'visibleMonth', YearMonth(year, month))
      .having((s) => s.month?.month, 'month.month', month)
      .having((s) => s.month?.year, 'month.year', year);

  test('starts on the month containing today', () {
    final state = buildBloc().state;
    expect(state.visibleMonth, const YearMonth(2025, 12));
    expect(state.today, CivilDate(2025, 12, 20));
    expect(state.status, CalendarStatus.initial);
    expect(state.isShowingToday, isTrue);
  });

  blocTest<CalendarBloc, CalendarState>(
    'started: loading → success for the current month',
    build: buildBloc,
    act: (bloc) => bloc.add(const CalendarStarted()),
    expect: () => [loading(2025, 12), success(2025, 12)],
  );

  blocTest<CalendarBloc, CalendarState>(
    'next crosses the year boundary',
    build: buildBloc,
    act: (bloc) => bloc.add(const CalendarMonthShifted(1)),
    expect: () => [loading(2026, 1), success(2026, 1)],
    verify: (_) => expect(events.requestedYears, [2026]),
  );

  blocTest<CalendarBloc, CalendarState>(
    'previous goes back one month',
    build: buildBloc,
    act: (bloc) => bloc.add(const CalendarMonthShifted(-1)),
    expect: () => [loading(2025, 11), success(2025, 11)],
  );

  blocTest<CalendarBloc, CalendarState>(
    'today returns to the current month',
    build: buildBloc,
    seed: () => CalendarState(
      visibleMonth: const YearMonth(2024, 3),
      today: CivilDate(2025, 12, 20),
    ),
    act: (bloc) => bloc.add(const CalendarTodayRequested()),
    expect: () => [loading(2025, 12), success(2025, 12)],
  );

  blocTest<CalendarBloc, CalendarState>(
    'rapid navigation: only the latest month is shown',
    build: buildBloc,
    act: (bloc) {
      bloc
        ..add(const CalendarMonthShifted(1))
        ..add(const CalendarMonthShifted(1));
    },
    skip: 0,
    verify: (bloc) {
      expect(bloc.state.visibleMonth, const YearMonth(2026, 2));
      expect(bloc.state.status, CalendarStatus.success);
      expect(bloc.state.month?.month, 2);
    },
  );
}
