import '../../../../core/async/cancel_signal.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/result.dart';
import '../entities/year_events.dart';

abstract interface class EventsRepository {
  /// Published events overlapping [year]. Network first; on failure returns
  /// the last saved copy (`isFromCache: true`) when one exists.
  ///
  /// Successful network results are memoized for the session unless
  /// [forceRefresh] is true.
  Future<Result<YearEvents, AppFailure>> getEventsForYear(
    int year, {
    bool forceRefresh = false,
    CancelSignal? cancelSignal,
  });
}
