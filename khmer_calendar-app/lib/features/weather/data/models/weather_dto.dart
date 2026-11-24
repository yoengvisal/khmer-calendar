import '../../../../core/date/civil_date.dart';
import '../../domain/entities/weather_report.dart';

/// Maps an Open-Meteo `/v1/forecast` JSON payload to [WeatherReport].
/// The same JSON is cached on device, so parsing is shared.
abstract final class WeatherDto {
  /// Throws [FormatException] on a malformed payload.
  static WeatherReport fromOpenMeteo(
    Map<String, dynamic> json,
    DateTime fetchedAt,
  ) {
    final current = json['current'];
    final daily = json['daily'];
    if (current is! Map || daily is! Map) {
      throw const FormatException('Missing current/daily weather');
    }
    final dates = (daily['time'] as List).cast<String>();
    final codes = (daily['weather_code'] as List).cast<num>();
    final max = (daily['temperature_2m_max'] as List).cast<num>();
    final min = (daily['temperature_2m_min'] as List).cast<num>();
    final rain = (daily['precipitation_probability_max'] as List?)
        ?.cast<num?>();
    if (dates.isEmpty) throw const FormatException('Empty forecast');

    return WeatherReport(
      temperature: (current['temperature_2m'] as num).toDouble(),
      kind: kindFromWmo((current['weather_code'] as num).toInt()),
      isDay: (current['is_day'] as num? ?? 1) == 1,
      fetchedAt: fetchedAt,
      daily: [
        for (var i = 0; i < dates.length; i++)
          DailyForecast(
            date: CivilDate.parse(dates[i]),
            kind: kindFromWmo(codes[i].toInt()),
            max: max[i].toDouble(),
            min: min[i].toDouble(),
            rainChance: rain?[i]?.round(),
          ),
      ],
    );
  }

  /// WMO weather interpretation codes → [WeatherKind].
  static WeatherKind kindFromWmo(int code) => switch (code) {
    0 => WeatherKind.clear,
    1 || 2 => WeatherKind.partlyCloudy,
    3 => WeatherKind.cloudy,
    45 || 48 => WeatherKind.fog,
    >= 51 && <= 57 => WeatherKind.drizzle,
    >= 61 && <= 67 || >= 80 && <= 82 => WeatherKind.rain,
    >= 95 => WeatherKind.thunderstorm,
    _ => WeatherKind.cloudy,
  };
}
