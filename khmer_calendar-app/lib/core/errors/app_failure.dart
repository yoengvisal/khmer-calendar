/// Typed, user-safe failures. Never carries raw server messages or stack
/// traces for display; [UnknownFailure.cause] is for logging only.
library;

sealed class AppFailure {
  const AppFailure();
}

/// No connectivity / connection refused / DNS failure.
final class NetworkFailure extends AppFailure {
  const NetworkFailure();

  @override
  bool operator ==(Object other) => other is NetworkFailure;
  @override
  int get hashCode => (NetworkFailure).hashCode;
  @override
  String toString() => 'NetworkFailure()';
}

/// Connect / send / receive timeout.
final class TimeoutFailure extends AppFailure {
  const TimeoutFailure();

  @override
  bool operator ==(Object other) => other is TimeoutFailure;
  @override
  int get hashCode => (TimeoutFailure).hashCode;
  @override
  String toString() => 'TimeoutFailure()';
}

/// Non-2xx response that is not a validation / not-found error.
final class ServerFailure extends AppFailure {
  const ServerFailure({this.statusCode, this.code, this.requestId});

  final int? statusCode;

  /// Envelope `error.code`, e.g. `INTERNAL_ERROR`, `RATE_LIMITED`.
  final String? code;
  final String? requestId;

  @override
  bool operator ==(Object other) =>
      other is ServerFailure &&
      other.statusCode == statusCode &&
      other.code == code &&
      other.requestId == requestId;
  @override
  int get hashCode => Object.hash(statusCode, code, requestId);
  @override
  String toString() => 'ServerFailure($statusCode, $code, $requestId)';
}

/// HTTP 400 / `VALIDATION_ERROR`; [fields] are the offending field names.
final class ValidationFailure extends AppFailure {
  const ValidationFailure({this.fields = const [], this.requestId});

  final List<String> fields;
  final String? requestId;

  @override
  bool operator ==(Object other) =>
      other is ValidationFailure &&
      other.requestId == requestId &&
      other.fields.join(',') == fields.join(',');
  @override
  int get hashCode => Object.hash(fields.join(','), requestId);
  @override
  String toString() => 'ValidationFailure($fields, $requestId)';
}

final class NotFoundFailure extends AppFailure {
  const NotFoundFailure();

  @override
  bool operator ==(Object other) => other is NotFoundFailure;
  @override
  int get hashCode => (NotFoundFailure).hashCode;
  @override
  String toString() => 'NotFoundFailure()';
}

/// The request was cancelled because its screen went away. Not shown to users.
final class CancelledFailure extends AppFailure {
  const CancelledFailure();

  @override
  bool operator ==(Object other) => other is CancelledFailure;
  @override
  int get hashCode => (CancelledFailure).hashCode;
  @override
  String toString() => 'CancelledFailure()';
}

final class UnknownFailure extends AppFailure {
  const UnknownFailure([this.cause]);

  /// For logs only — never render this.
  final Object? cause;

  @override
  bool operator ==(Object other) => other is UnknownFailure;
  @override
  int get hashCode => (UnknownFailure).hashCode;
  @override
  String toString() => 'UnknownFailure($cause)';
}

/// Exception used to carry an [AppFailure] across the data layer.
final class AppException implements Exception {
  const AppException(this.failure);

  final AppFailure failure;

  @override
  String toString() => 'AppException($failure)';
}
