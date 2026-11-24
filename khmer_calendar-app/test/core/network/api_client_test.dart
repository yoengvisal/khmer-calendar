import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khmer_calendar/app/config/app_config.dart';
import 'package:khmer_calendar/core/async/cancel_signal.dart';
import 'package:khmer_calendar/core/date/civil_date.dart';
import 'package:khmer_calendar/core/errors/app_failure.dart';
import 'package:khmer_calendar/core/logging/app_logger.dart';
import 'package:khmer_calendar/core/network/api_client.dart';
import 'package:khmer_calendar/core/network/dio_client.dart';
import 'package:khmer_calendar/features/events/data/datasources/events_remote_data_source.dart';

/// Scripted HTTP adapter: records requests, returns canned responses.
class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.respond);

  Future<ResponseBody> Function(RequestOptions options) respond;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    requests.add(options);
    return respond(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody jsonBody(Object body, int status) => ResponseBody.fromString(
  jsonEncode(body),
  status,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

void main() {
  const config = AppConfig(
    flavor: Flavor.staging,
    apiBaseUrl: 'https://staging-api.example.com/api/v1',
  );
  late Dio dio;
  late FakeAdapter adapter;
  late ApiEventsRemoteDataSource source;

  setUp(() {
    dio = createDio(config);
    adapter = FakeAdapter(
      (_) async => jsonBody({
        'success': true,
        'data': [
          {
            'id': 'e1',
            'titleKm': 'ក',
            'titleEn': 'A',
            'descriptionKm': null,
            'descriptionEn': null,
            'category': 'PUBLIC_HOLIDAY',
            'startDate': '2025-04-14',
            'endDate': '2025-04-16',
            'isDayOff': true,
            'status': 'PUBLISHED',
            'someFutureField': 42,
          },
        ],
      }, 200),
    );
    dio.httpClientAdapter = adapter;
    source = ApiEventsRemoteDataSource(ApiClient(dio));
  });

  Future<AppFailure> failureOf(Future<Object?> future) async {
    try {
      await future;
    } on AppException catch (e) {
      return e.failure;
    }
    fail('expected AppException');
  }

  test('Dio is configured from AppConfig', () {
    expect(dio.options.connectTimeout, const Duration(seconds: 15));
    expect(dio.options.receiveTimeout, const Duration(seconds: 20));
    expect(dio.options.sendTimeout, const Duration(seconds: 20));
    expect(
      dio.options.headers['accept'] ?? dio.options.headers['Accept'],
      'application/json',
    );
  });

  test('GET /events builds the URL, adds x-request-id, unwraps data', () async {
    final events = await source.fetchEvents(
      from: CivilDate(2025, 1, 1),
      to: CivilDate(2025, 12, 31),
    );

    final request = adapter.requests.single;
    expect(
      request.uri.toString(),
      'https://staging-api.example.com/api/v1/events?from=2025-01-01&to=2025-12-31',
    );
    expect(
      request.headers['x-request-id'],
      matches(RegExp(r'^[A-Za-z0-9-]{8,64}$')),
    );
    expect(events.single.id, 'e1');
    expect(events.single.endDate, '2025-04-16');
  });

  test('maps envelope error codes to typed failures', () async {
    adapter.respond = (_) async => jsonBody({
      'success': false,
      'error': {
        'code': 'VALIDATION_ERROR',
        'message': 'raw server text',
        'details': [
          {
            'field': 'from',
            'messages': ['bad'],
          },
        ],
        'requestId': 'req-12345678',
      },
    }, 400);
    expect(
      await failureOf(
        source.fetchEvents(
          from: CivilDate(2025, 1, 1),
          to: CivilDate(2025, 1, 2),
        ),
      ),
      const ValidationFailure(fields: ['from'], requestId: 'req-12345678'),
    );

    adapter.respond = (_) async => jsonBody({
      'success': false,
      'error': {'code': 'INTERNAL_ERROR', 'message': 'boom', 'requestId': 'r1'},
    }, 500);
    expect(
      await failureOf(
        source.fetchEvents(
          from: CivilDate(2025, 1, 1),
          to: CivilDate(2025, 1, 2),
        ),
      ),
      const ServerFailure(
        statusCode: 500,
        code: 'INTERNAL_ERROR',
        requestId: 'r1',
      ),
    );

    adapter.respond = (_) async => jsonBody({
      'success': false,
      'error': {'code': 'NOT_FOUND', 'message': 'nope'},
    }, 404);
    expect(
      await failureOf(
        source.fetchEvents(
          from: CivilDate(2025, 1, 1),
          to: CivilDate(2025, 1, 2),
        ),
      ),
      const NotFoundFailure(),
    );
  });

  test('maps connection errors, timeouts and cancellation', () async {
    adapter.respond = (o) async => throw DioException.connectionError(
      requestOptions: o,
      reason: 'offline',
    );
    expect(
      await failureOf(
        source.fetchEvents(
          from: CivilDate(2025, 1, 1),
          to: CivilDate(2025, 1, 2),
        ),
      ),
      const NetworkFailure(),
    );

    adapter.respond = (o) async => throw DioException.receiveTimeout(
      timeout: const Duration(seconds: 20),
      requestOptions: o,
    );
    expect(
      await failureOf(
        source.fetchEvents(
          from: CivilDate(2025, 1, 1),
          to: CivilDate(2025, 1, 2),
        ),
      ),
      const TimeoutFailure(),
    );

    final signal = CancelSignal()..cancel();
    expect(
      await failureOf(
        source.fetchEvents(
          from: CivilDate(2025, 1, 1),
          to: CivilDate(2025, 1, 2),
          cancelSignal: signal,
        ),
      ),
      const CancelledFailure(),
    );
  });

  test('malformed payloads become UnknownFailure', () async {
    adapter.respond = (_) async => jsonBody({'success': true, 'data': {}}, 200);
    expect(
      await failureOf(
        source.fetchEvents(
          from: CivilDate(2025, 1, 1),
          to: CivilDate(2025, 1, 2),
        ),
      ),
      isA<UnknownFailure>(),
    );
  });

  test('redaction hides sensitive fields', () {
    expect(
      redact({
        'Authorization': 'Bearer abc',
        'nested': {'refreshToken': 'x', 'ok': 1},
        'list': [
          {'password': 'p'},
        ],
      }),
      {
        'Authorization': redacted,
        'nested': {'refreshToken': redacted, 'ok': 1},
        'list': [
          {'password': redacted},
        ],
      },
    );
  });
}
