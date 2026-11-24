import 'dart:io';

import 'package:dio/dio.dart';

import '../errors/app_failure.dart';

/// Single place that turns transport errors into [AppFailure]s.
AppFailure mapDioException(DioException err) {
  if (err.error is AppFailure) return err.error! as AppFailure;

  switch (err.type) {
    case DioExceptionType.cancel:
      return const CancelledFailure();
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return const TimeoutFailure();
    case DioExceptionType.connectionError:
    case DioExceptionType.badCertificate:
      return const NetworkFailure();
    case DioExceptionType.badResponse:
      return _mapResponse(err.response);
    case DioExceptionType.unknown:
      if (err.error is SocketException || err.error is HttpException) {
        return const NetworkFailure();
      }
      return UnknownFailure(err.error ?? err.type);
  }
}

AppFailure _mapResponse(Response<dynamic>? response) {
  final status = response?.statusCode;
  final envelopeError = _envelopeError(response?.data);
  final code = envelopeError?['code'] is String
      ? envelopeError!['code'] as String
      : null;
  final requestId = envelopeError?['requestId'] is String
      ? envelopeError!['requestId'] as String
      : response?.headers.value('x-request-id');

  if (code == 'VALIDATION_ERROR' || status == 400) {
    final details = envelopeError?['details'];
    final fields = <String>[
      if (details is List)
        for (final d in details)
          if (d is Map && d['field'] is String) d['field'] as String,
    ];
    return ValidationFailure(fields: fields, requestId: requestId);
  }
  if (code == 'NOT_FOUND' || status == 404) return const NotFoundFailure();
  return ServerFailure(statusCode: status, code: code, requestId: requestId);
}

Map<String, dynamic>? _envelopeError(Object? data) {
  if (data is Map && data['error'] is Map) {
    return Map<String, dynamic>.from(data['error'] as Map);
  }
  return null;
}
