import '../../../../core/async/cancel_signal.dart';
import '../../../../core/date/civil_date.dart';
import '../../../../core/date/clock.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/logging/app_logger.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/entities/year_events.dart';
import '../../domain/repositories/events_repository.dart';
import '../datasources/events_local_data_source.dart';
import '../datasources/events_remote_data_source.dart';
import '../models/event_dto.dart';

class EventsRepositoryImpl implements EventsRepository {
  EventsRepositoryImpl({
    required this._remote,
    required this._local,
    this._clock = const Clock(),
    this._logger = const AppLogger(),
  });

  final EventsRemoteDataSource _remote;
  final EventsLocalDataSource _local;
  final Clock _clock;
  final AppLogger _logger;

  /// Fresh network results for this session (keeps month swipes cheap).
  final Map<int, YearEvents> _memory = {};

  @override
  Future<Result<YearEvents, AppFailure>> getEventsForYear(
    int year, {
    bool forceRefresh = false,
    CancelSignal? cancelSignal,
  }) async {
    final memoized = _memory[year];
    if (!forceRefresh && memoized != null) return Ok(memoized);

    try {
      final dtos = await _remote.fetchEvents(
        from: CivilDate(year, 1, 1),
        to: CivilDate(year, 12, 31),
        cancelSignal: cancelSignal,
      );
      final result = YearEvents(year: year, events: _toSortedEntities(dtos));
      _memory[year] = result;
      try {
        await _local.write(year, dtos, _clock.now());
      } on Object catch (e) {
        _logger.warning('Could not cache events for $year', e);
      }
      return Ok(result);
    } on AppException catch (e) {
      return _fallbackToCache(year, e.failure);
    } on Object catch (e) {
      return _fallbackToCache(year, UnknownFailure(e));
    }
  }

  Future<Result<YearEvents, AppFailure>> _fallbackToCache(
    int year,
    AppFailure failure,
  ) async {
    // A cancelled request belongs to a screen that is gone; don't bother.
    if (failure is CancelledFailure) return Err(failure);
    _logger.info('Events $year: network failed ($failure), trying cache');
    final cached = await _local.read(year);
    if (cached == null) return Err(failure);
    return Ok(
      YearEvents(
        year: year,
        events: _toSortedEntities(cached.events),
        isFromCache: true,
        savedAt: cached.savedAt,
      ),
    );
  }

  List<CalendarEvent> _toSortedEntities(List<EventDto> dtos) =>
      [for (final dto in dtos) dto.toEntity()]..sort((a, b) {
        final byStart = a.startDate.compareTo(b.startDate);
        return byStart != 0 ? byStart : a.endDate.compareTo(b.endDate);
      });
}
