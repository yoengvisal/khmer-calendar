import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/result.dart';
import '../entities/weather_report.dart';

abstract interface class WeatherRepository {
  /// Weather for Phnom Penh. Network first (memoized for a short time); on
  /// failure returns the last saved report marked `isStale`, if any.
  Future<Result<WeatherReport, AppFailure>> getWeather({
    bool forceRefresh = false,
  });
}
