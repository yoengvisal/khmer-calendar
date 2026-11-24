import 'package:equatable/equatable.dart';

import '../../../../core/date/civil_date.dart';

/// Simplified sky conditions (mapped from WMO weather codes).
enum WeatherKind {
  clear,
  partlyCloudy,
  cloudy,
  fog,
  drizzle,
  rain,
  thunderstorm,
}

final class DailyForecast extends Equatable {
  const DailyForecast({
    required this.date,
    required this.kind,
    required this.max,
    required this.min,
    this.rainChance,
  });

  final CivilDate date;
  final WeatherKind kind;
  final double max;
  final double min;

  /// 0-100 %, when provided.
  final int? rainChance;

  @override
  List<Object?> get props => [date, kind, max, min, rainChance];
}

/// Current conditions + a short daily forecast for one place.
final class WeatherReport extends Equatable {
  const WeatherReport({
    required this.temperature,
    required this.kind,
    required this.isDay,
    required this.daily,
    required this.fetchedAt,
    this.isStale = false,
  });

  final double temperature;
  final WeatherKind kind;
  final bool isDay;

  /// Today first; never empty.
  final List<DailyForecast> daily;
  final DateTime fetchedAt;

  /// True when served from the on-device cache after a network failure.
  final bool isStale;

  DailyForecast get today => daily.first;

  WeatherReport asStale() => WeatherReport(
    temperature: temperature,
    kind: kind,
    isDay: isDay,
    daily: daily,
    fetchedAt: fetchedAt,
    isStale: true,
  );

  @override
  List<Object?> get props => [
    temperature,
    kind,
    isDay,
    daily,
    fetchedAt,
    isStale,
  ];
}
