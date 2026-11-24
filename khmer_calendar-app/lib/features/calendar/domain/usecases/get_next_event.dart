import '../../../../core/date/civil_date.dart';
import '../../../events/domain/entities/calendar_event.dart';
import '../../../events/domain/repositories/events_repository.dart';

/// The next published event that hasn't ended yet (today's year, then next
/// year). Returns null when there is none or events can't be loaded; the
/// calendar must keep working without it.
class GetNextEvent {
  const GetNextEvent(this._repository);

  final EventsRepository _repository;

  Future<CalendarEvent?> call(CivilDate today) async {
    for (final year in [today.year, today.year + 1]) {
      final result = await _repository.getEventsForYear(year);
      final next = result.fold((yearEvents) {
        final upcoming =
            yearEvents.events.where((e) => !e.endDate.isBefore(today)).toList()
              ..sort((a, b) => a.startDate.compareTo(b.startDate));
        return upcoming.isEmpty ? null : upcoming.first;
      }, (_) => null);
      if (next != null) return next;
    }
    return null;
  }
}
