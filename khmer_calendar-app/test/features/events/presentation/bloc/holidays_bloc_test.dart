import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khmer_calendar/core/date/civil_date.dart';
import 'package:khmer_calendar/core/date/clock.dart';
import 'package:khmer_calendar/core/errors/app_failure.dart';
import 'package:khmer_calendar/features/events/data/repositories/events_repository_impl.dart';
import 'package:khmer_calendar/features/events/domain/usecases/get_year_events.dart';
import 'package:khmer_calendar/features/events/presentation/bloc/holidays_bloc.dart';

import '../../../../helpers/fakes.dart';

void main() {
  final clock = Clock.fixed(DateTime(2025, 6, 1));
  final today = CivilDate(2025, 6, 1);
  final savedAt = DateTime.utc(2025, 5, 1);
  late FakeEventsRemoteDataSource remote;
  late FakeEventsLocalDataSource local;

  /// Real repository over fake data sources, so the bloc tests exercise the
  /// whole network → cache fallback path.
  HolidaysBloc buildBloc() => HolidaysBloc(
    getYearEvents: GetYearEvents(
      EventsRepositoryImpl(remote: remote, local: local, clock: clock),
    ),
    clock: clock,
  );

  setUp(() {
    remote = FakeEventsRemoteDataSource();
    local = FakeEventsLocalDataSource();
  });

  test('initial state is the current year', () {
    expect(buildBloc().state, const HolidaysInitial(year: 2025));
  });

  blocTest<HolidaysBloc, HolidaysState>(
    'success: loading → success with fresh events',
    setUp: () => remote.events = [
      eventDto(id: 'b', start: '2025-05-11'),
      eventDto(id: 'a', start: '2025-04-14'),
    ],
    build: buildBloc,
    act: (bloc) => bloc.add(const HolidaysStarted()),
    expect: () => [
      const HolidaysLoading(year: 2025),
      HolidaysSuccess(
        year: 2025,
        today: today,
        events: [
          calendarEvent(id: 'a', start: '2025-04-14'),
          calendarEvent(id: 'b', start: '2025-05-11'),
        ],
      ),
    ],
  );

  blocTest<HolidaysBloc, HolidaysState>(
    'network failure: loading → stale success from cache',
    setUp: () {
      remote.failure = const NetworkFailure();
      local.store[2025] = (events: [eventDto(id: 'saved')], savedAt: savedAt);
    },
    build: buildBloc,
    act: (bloc) => bloc.add(const HolidaysStarted()),
    expect: () => [
      const HolidaysLoading(year: 2025),
      HolidaysSuccess(
        year: 2025,
        today: today,
        events: [calendarEvent(id: 'saved')],
        isStale: true,
        savedAt: savedAt,
      ),
    ],
  );

  blocTest<HolidaysBloc, HolidaysState>(
    'failure without cache: loading → failure',
    setUp: () => remote.failure = const NetworkFailure(),
    build: buildBloc,
    act: (bloc) => bloc.add(const HolidaysStarted()),
    expect: () => const [
      HolidaysLoading(year: 2025),
      HolidaysFailure(year: 2025, failure: NetworkFailure()),
    ],
  );

  blocTest<HolidaysBloc, HolidaysState>(
    'no events: loading → empty',
    build: buildBloc,
    act: (bloc) => bloc.add(const HolidaysStarted()),
    expect: () => const [
      HolidaysLoading(year: 2025),
      HolidaysEmpty(year: 2025),
    ],
  );

  blocTest<HolidaysBloc, HolidaysState>(
    'year navigation requests the new year',
    build: buildBloc,
    act: (bloc) => bloc.add(const HolidaysYearShifted(1)),
    expect: () => const [
      HolidaysLoading(year: 2026),
      HolidaysEmpty(year: 2026),
    ],
    verify: (_) => expect(remote.calls.single.$1, CivilDate(2026, 1, 1)),
  );

  blocTest<HolidaysBloc, HolidaysState>(
    'refresh keeps content visible, bypasses memory and completes',
    setUp: () => remote.events = [eventDto(id: 'a')],
    build: buildBloc,
    act: (bloc) async {
      bloc.add(const HolidaysStarted());
      await Future<void>.delayed(Duration.zero);
      remote.events = [
        eventDto(id: 'a'),
        eventDto(id: 'n', start: '2025-12-01'),
      ];
      final completer = Completer<void>();
      bloc.add(HolidaysRefreshRequested(completer: completer));
      await completer.future;
    },
    expect: () => [
      const HolidaysLoading(year: 2025),
      isA<HolidaysSuccess>().having((s) => s.events.length, 'events', 1),
      isA<HolidaysSuccess>().having((s) => s.events.length, 'events', 2),
    ],
    verify: (_) => expect(remote.calls, hasLength(2)),
  );

  test('groups events by start month', () {
    final state = HolidaysSuccess(
      year: 2025,
      today: today,
      events: [
        calendarEvent(id: 'carry', start: '2024-12-31', end: '2025-01-01'),
        calendarEvent(id: 'a', start: '2025-04-14'),
        calendarEvent(id: 'b', start: '2025-04-30'),
      ],
    );
    expect(
      state.byMonth.map((k, v) => MapEntry(k, v.map((e) => e.id).toList())),
      {
        1: ['carry'],
        4: ['a', 'b'],
      },
    );
  });
}
