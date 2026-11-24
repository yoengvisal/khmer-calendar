import 'dart:convert';

import '../../../../core/date/clock.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/storage/key_value_store.dart';
import '../../domain/entities/weather_report.dart';
import '../../domain/repositories/weather_repository.dart';
import '../datasources/weather_remote_data_source.dart';
import '../models/weather_dto.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  WeatherRepositoryImpl({
    required this._remote,
    required this._store,
    this._clock = const Clock(),
  });

  static const String cacheKey = 'weather.phnom_penh';
  static const Duration freshFor = Duration(minutes: 30);

  final WeatherRemoteDataSource _remote;
  final KeyValueStore _store;
  final Clock _clock;
  WeatherReport? _memory;

  @override
  Future<Result<WeatherReport, AppFailure>> getWeather({
    bool forceRefresh = false,
  }) async {
    final memo = _memory;
    if (!forceRefresh &&
        memo != null &&
        _clock.now().difference(memo.fetchedAt) < freshFor) {
      return Ok(memo);
    }
    try {
      final json = await _remote.fetchForecast();
      final now = _clock.now();
      final report = WeatherDto.fromOpenMeteo(json, now);
      _memory = report;
      await _store.setString(
        cacheKey,
        jsonEncode({'fetchedAt': now.toIso8601String(), 'data': json}),
      );
      return Ok(report);
    } on AppException catch (e) {
      return _fromCache(e.failure);
    } on Object catch (e) {
      return _fromCache(UnknownFailure(e));
    }
  }

  Result<WeatherReport, AppFailure> _fromCache(AppFailure failure) {
    final raw = _store.getString(cacheKey);
    if (raw == null) return Err(failure);
    try {
      final saved = jsonDecode(raw) as Map<String, dynamic>;
      final report = WeatherDto.fromOpenMeteo(
        saved['data'] as Map<String, dynamic>,
        DateTime.parse(saved['fetchedAt'] as String),
      );
      return Ok(report.asStale());
    } on Object {
      return Err(failure);
    }
  }
}
