import 'package:flutter_test/flutter_test.dart';
import 'package:khmer_calendar/core/date/civil_date.dart';
import 'package:khmer_calendar/core/date/clock.dart';
import 'package:khmer_calendar/core/errors/app_failure.dart';
import 'package:khmer_calendar/core/errors/result.dart';
import 'package:khmer_calendar/core/storage/key_value_store.dart';
import 'package:khmer_calendar/features/weather/data/models/weather_dto.dart';
import 'package:khmer_calendar/features/weather/data/repositories/weather_repository_impl.dart';
import 'package:khmer_calendar/features/weather/domain/entities/weather_report.dart';

import '../../helpers/fakes.dart';

void main() {
  final clock = Clock.fixed(DateTime(2025, 5, 11, 9));

  test('maps WMO codes to simplified kinds', () {
    expect(WeatherDto.kindFromWmo(0), WeatherKind.clear);
    expect(WeatherDto.kindFromWmo(2), WeatherKind.partlyCloudy);
    expect(WeatherDto.kindFromWmo(3), WeatherKind.cloudy);
    expect(WeatherDto.kindFromWmo(63), WeatherKind.rain);
    expect(WeatherDto.kindFromWmo(81), WeatherKind.rain);
    expect(WeatherDto.kindFromWmo(95), WeatherKind.thunderstorm);
  });

  test('parses current conditions and the daily forecast', () {
    final report = WeatherDto.fromOpenMeteo(openMeteoJson(), clock.now());
    expect(report.temperature, 31.4);
    expect(report.kind, WeatherKind.partlyCloudy);
    expect(report.today.date, CivilDate(2025, 5, 11));
    expect(report.today.max, 33.2);
    expect(report.daily[1].kind, WeatherKind.rain);
    expect(report.daily[1].rainChance, 80);
  });

  test('network failure falls back to the cached report (stale)', () async {
    final store = InMemoryKeyValueStore();
    final remote = FakeWeatherRemoteDataSource();
    final repo = WeatherRepositoryImpl(
      remote: remote,
      store: store,
      clock: clock,
    );
    expect(
      (await repo.getWeather()).fold((r) => r.isStale, (_) => null),
      isFalse,
    );

    remote.failure = const NetworkFailure();
    final offline = WeatherRepositoryImpl(
      remote: remote,
      store: store,
      clock: clock,
    );
    final result = await offline.getWeather();
    expect(result.fold((r) => (r.isStale, r.temperature), (_) => null), (
      true,
      31.4,
    ));
  });

  test('failure without a cache is reported', () async {
    final repo = WeatherRepositoryImpl(
      remote: FakeWeatherRemoteDataSource(failure: const TimeoutFailure()),
      store: InMemoryKeyValueStore(),
      clock: clock,
    );
    expect(await repo.getWeather(), isA<Err<WeatherReport, AppFailure>>());
  });

  test('memoizes for a short time, refresh bypasses', () async {
    final remote = FakeWeatherRemoteDataSource();
    final repo = WeatherRepositoryImpl(
      remote: remote,
      store: InMemoryKeyValueStore(),
      clock: clock,
    );
    await repo.getWeather();
    await repo.getWeather();
    expect(remote.calls, 1);
    await repo.getWeather(forceRefresh: true);
    expect(remote.calls, 2);
  });
}
