import 'package:dio/dio.dart';

import '../async/cancel_signal.dart';
import '../errors/app_failure.dart';
import 'failure_mapper.dart';

/// Thin wrapper over [Dio] that unwraps the API envelope
/// (`{ success, data }`) and throws [AppException] for every failure.
class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  /// GET [path] (relative, e.g. `events`) and return the envelope's `data`.
  Future<Object?> getData(
    String path, {
    Map<String, dynamic>? queryParameters,
    CancelSignal? cancelSignal,
  }) async {
    try {
      final response = await _dio.get<Object?>(
        path,
        queryParameters: queryParameters,
        cancelToken: toCancelToken(cancelSignal),
      );
      return _unwrap(response.data);
    } on DioException catch (err) {
      throw AppException(mapDioException(err));
    }
  }

  Object? _unwrap(Object? body) {
    if (body is Map && body['success'] == true && body.containsKey('data')) {
      return body['data'];
    }
    throw const AppException(
      UnknownFailure(FormatException('Unexpected response envelope')),
    );
  }
}

/// Adapts a framework-free [CancelSignal] to a Dio [CancelToken].
CancelToken? toCancelToken(CancelSignal? signal) {
  if (signal == null) return null;
  final token = CancelToken();
  if (signal.isCancelled) {
    token.cancel();
  } else {
    signal.whenCancelled.then((_) => token.cancel());
  }
  return token;
}
