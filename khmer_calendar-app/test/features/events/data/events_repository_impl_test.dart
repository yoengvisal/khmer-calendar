import 'package:flutter_test/flutter_test.dart';
import 'package:khmer_calendar/core/date/civil_date.dart';
import 'package:khmer_calendar/core/date/clock.dart';
import 'package:khmer_calendar/core/errors/app_failure.dart';
import 'package:khmer_calendar/core/errors/result.dart';
import 'package:khmer_calendar/core/storage/key_value_store.dart';
import 'package:khmer_calendar/features/events/data/datasources/events_local_data_source.dart';
import 'package:khmer_calendar/features/events/data/repositories/events_repository_impl.dart';
import 'package:khmer_calendar/features/events/domain/entities/year_events.dart';

import '../../../helpers/fakes.dart';

void main() {
  final savedAt = DateTime.utc(2025, 3, 1, 8);
  late FakeEventsRemoteDataSource remote;
  late FakeEventsLocalDataSource local;
  late EventsRepositoryImpl repository;

  setUp(() {
    remote = FakeEventsRemoteDataSource();
    local = FakeEventsLocalDataSource();
    repository = EventsRepositoryImpl(
      remote: remote,
      local: local,
      clock: Clock.fixed(savedAt),
    );
  });

  test('success: returns sorted live events and caches them', () async {
    remote.events = [
      eventDto(id: 'b', start: '2025-05-11'),
      eventDto(id: 'a', start: '2025-04-14', end: '2025-04-16'),
    ];

    final result = await repository.getEventsForYear(2025);

    final value = (result as Ok<YearEvents, AppFailure>).value;
    expect(value.isFromCache, isFalse);
    expect(value.events.map((e) => e.id), ['a', 'b']);
    expect(remote.calls.single, (
      CivilDate(2025, 1, 1),
      CivilDate(2025, 12, 31),
    ));
    expect(local.store[2025]!.events, hasLength(2));
    expect(local.store[2025]!.savedAt, savedAt);
  });

  test('network failure: falls back to cached data', () async {
    await local.write(2025, [eventDto(id: 'cached')], savedAt);
    remote.failure = const NetworkFailure();

    final result = await repository.getEventsForYear(2025);

    final value = (result as Ok<YearEvents, AppFailure>).value;
    expect(value.isFromCache, isTrue);
    expect(value.savedAt, savedAt);
    expect(value.events.single.id, 'cached');
  });

  test('failure without cache: returns the typed failure', () async {
    remote.failure = const TimeoutFailure();

    final result = await repository.getEventsForYear(2025);

    expect(result, const Err<YearEvents, AppFailure>(TimeoutFailure()));
  });

  test('cancelled requests never fall back to cache', () async {
    await local.write(2025, [eventDto()], savedAt);
    remote.failure = const CancelledFailure();

    final result = await repository.getEventsForYear(2025);

    expect(result.errorOrNull, const CancelledFailure());
  });

  test('memoizes fresh results unless forceRefresh', () async {
    remote.events = [eventDto()];
    await repository.getEventsForYear(2025);
    await repository.getEventsForYear(2025);
    expect(remote.calls, hasLength(1));

    await repository.getEventsForYear(2025, forceRefresh: true);
    expect(remote.calls, hasLength(2));
  });

  group('PrefsEventsLocalDataSource', () {
    test('round-trips a year through the key-value store', () async {
      final store = InMemoryKeyValueStore();
      final source = PrefsEventsLocalDataSource(store);
      await source.write(2025, [eventDto(id: 'x', end: '2025-04-16')], savedAt);

      final cached = await source.read(2025);

      expect(cached!.savedAt, savedAt);
      expect(
        cached.events.single.toJson(),
        eventDto(id: 'x', end: '2025-04-16').toJson(),
      );
      expect(await source.read(2024), isNull);
    });

    test('drops a corrupt cache entry instead of throwing', () async {
      final store = InMemoryKeyValueStore({
        PrefsEventsLocalDataSource.keyFor(2025): '{not json',
      });
      final source = PrefsEventsLocalDataSource(store);

      expect(await source.read(2025), isNull);
      expect(store.values, isEmpty);
    });
  });
}
