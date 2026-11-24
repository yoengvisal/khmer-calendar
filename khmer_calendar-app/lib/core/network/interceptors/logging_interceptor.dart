import 'package:dio/dio.dart';

import '../../logging/app_logger.dart';

/// Dev-only request/response logging with sensitive fields redacted.
/// Registered only when `AppConfig.enableNetworkLogging` is true.
class SanitizedLoggingInterceptor extends Interceptor {
  SanitizedLoggingInterceptor(this._logger);

  final AppLogger _logger;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.debug(
      '→ ${options.method} ${options.uri} '
      'headers=${redact(options.headers)}'
      '${options.data == null ? '' : ' body=${redact(options.data)}'}',
    );
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _logger.debug(
      '← ${response.statusCode} ${response.requestOptions.method} '
      '${response.requestOptions.uri} '
      'x-request-id=${response.headers.value('x-request-id')}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.debug(
      '✕ ${err.type.name} ${err.requestOptions.method} '
      '${err.requestOptions.uri} status=${err.response?.statusCode} '
      'error=${redact(err.response?.data)}',
    );
    handler.next(err);
  }
}
