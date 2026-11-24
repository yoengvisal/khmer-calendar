import 'package:dio/dio.dart';

import '../request_id.dart';

/// Adds an `x-request-id` header to every request (unless already set) so
/// client logs can be correlated with server logs.
class CorrelationIdInterceptor extends Interceptor {
  CorrelationIdInterceptor({String Function()? idGenerator})
    : _idGenerator = idGenerator ?? generateRequestId;

  static const String headerName = 'x-request-id';

  final String Function() _idGenerator;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers.putIfAbsent(headerName, _idGenerator);
    handler.next(options);
  }
}
