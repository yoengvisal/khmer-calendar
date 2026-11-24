import 'package:dio/dio.dart';

import '../failure_mapper.dart';

/// Normalizes every [DioException] so that `err.error` is an `AppFailure`.
/// Must be the last interceptor so it sees the final error.
class ErrorNormalizationInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(err.copyWith(error: mapDioException(err)));
  }
}
