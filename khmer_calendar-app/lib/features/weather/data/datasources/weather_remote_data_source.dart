import 'package:dio/dio.dart';

import '../../../../core/network/interceptors/error_interceptor.dart';

/// Phnom Penh. Fixed coordinates: the app never asks for the user's location.
const double phnomPenhLatitude = 11.5564;
const double phnomPenhLongitude = 104.9282;

abstract interface class WeatherRemoteDataSource {
  /// Raw Open-Meteo forecast JSON. Throws `AppException` on failure.
  Future<Map<String, dynamic>> fetchForecast();
}

/// Open-Meteo (https://open-meteo.com): free, no API key, CC BY 4.0
/// (attribution is shown on the Weather page).
class OpenMeteoDataSource implements WeatherRemoteDataSource {
  OpenMeteoDataSource([Dio? dio]) : _dio = dio ?? createWeatherDio();

  final Dio _dio;

  static Dio createWeatherDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.open-meteo.com/v1/',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        responseType: ResponseType.json,
      ),
    );
    dio.interceptors.add(ErrorNormalizationInterceptor());
    return dio;
  }

  @override
  Future<Map<String, dynamic>> fetchForecast() async {
    final response = await _dio.get<Map<String, dynamic>>(
      'forecast',
      queryParameters: {
        'latitude': phnomPenhLatitude,
        'longitude': phnomPenhLongitude,
        'current': 'temperature_2m,weather_code,is_day',
        'daily':
            'weather_code,temperature_2m_max,temperature_2m_min,'
            'precipitation_probability_max',
        'timezone': 'Asia/Phnom_Penh',
        'forecast_days': 7,
      },
    );
    return response.data ?? const {};
  }
}
