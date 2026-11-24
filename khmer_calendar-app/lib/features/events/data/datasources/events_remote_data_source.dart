import '../../../../core/async/cancel_signal.dart';
import '../../../../core/date/civil_date.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/network/api_client.dart';
import '../models/event_dto.dart';

abstract interface class EventsRemoteDataSource {
  /// `GET /events?from&to`. Throws [AppException].
  Future<List<EventDto>> fetchEvents({
    required CivilDate from,
    required CivilDate to,
    CancelSignal? cancelSignal,
  });
}

class ApiEventsRemoteDataSource implements EventsRemoteDataSource {
  ApiEventsRemoteDataSource(this._client);

  final ApiClient _client;

  @override
  Future<List<EventDto>> fetchEvents({
    required CivilDate from,
    required CivilDate to,
    CancelSignal? cancelSignal,
  }) async {
    final data = await _client.getData(
      'events',
      queryParameters: {'from': from.toIso(), 'to': to.toIso()},
      cancelSignal: cancelSignal,
    );
    if (data is! List) {
      throw const AppException(
        UnknownFailure(FormatException('Expected a list of events')),
      );
    }
    try {
      return [
        for (final item in data)
          EventDto.fromJson(Map<String, dynamic>.from(item as Map)),
      ];
    } on Object catch (e) {
      throw AppException(UnknownFailure(e));
    }
  }
}
