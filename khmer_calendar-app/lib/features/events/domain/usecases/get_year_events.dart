import '../../../../core/async/cancel_signal.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/result.dart';
import '../entities/year_events.dart';
import '../repositories/events_repository.dart';

class GetYearEvents {
  const GetYearEvents(this._repository);

  final EventsRepository _repository;

  Future<Result<YearEvents, AppFailure>> call(
    int year, {
    bool forceRefresh = false,
    CancelSignal? cancelSignal,
  }) => _repository.getEventsForYear(
    year,
    forceRefresh: forceRefresh,
    cancelSignal: cancelSignal,
  );
}
