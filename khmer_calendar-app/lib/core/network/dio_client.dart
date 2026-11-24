import 'package:dio/dio.dart';

import '../../app/config/app_config.dart';
import '../logging/app_logger.dart';
import 'interceptors/correlation_id_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/logging_interceptor.dart';

/// Builds the single, centrally configured [Dio] instance.
///
/// No retry interceptor is installed: the app only issues idempotent GETs and
/// failures fall back to cached data, so retries are left to the user
/// (pull-to-refresh / retry button).
Dio createDio(AppConfig config, {AppLogger logger = const AppLogger()}) {
  final dio = Dio(
    BaseOptions(
      // Trailing slash + relative paths ("events") => /api/v1/events.
      baseUrl: '${config.apiBaseUrl}/',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      headers: {Headers.acceptHeader: Headers.jsonContentType},
      responseType: ResponseType.json,
    ),
  );
  dio.interceptors.addAll([
    CorrelationIdInterceptor(),
    if (config.enableNetworkLogging) SanitizedLoggingInterceptor(logger),
    ErrorNormalizationInterceptor(),
  ]);
  return dio;
}
