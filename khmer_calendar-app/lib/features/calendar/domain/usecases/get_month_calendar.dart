import '../../../../core/async/cancel_signal.dart';
import '../../../../core/date/civil_date.dart';
import '../../../../core/errors/result.dart';
import '../../../events/domain/entities/calendar_event.dart';
import '../../../events/domain/repositories/events_repository.dart';
import '../entities/calendar_day.dart';
import '../entities/calendar_month.dart';
import '../lunar/khmer_lunar_calendar.dart';

/// Builds a month: lunar data is computed locally (always available, works
/// offline); events come from [EventsRepository] and are attached to every
/// day they cover (multi-day events included).
class GetMonthCalendar {
  const GetMonthCalendar({
    required KhmerLunarCalendar lunarCalendar,
    required EventsRepository eventsRepository,
  }) : _lunar = lunarCalendar,
       _events = eventsRepository;

  final KhmerLunarCalendar _lunar;
  final EventsRepository _events;

  Future<CalendarMonth> call(
    int year,
    int month, {
    CancelSignal? cancelSignal,
  }) async {
    final result = await _events.getEventsForYear(
      year,
      cancelSignal: cancelSignal,
    );
    return switch (result) {
      Ok(:final value) => buildMonth(
        year,
        month,
        value.events,
        availability: value.isFromCache
            ? EventsAvailability.cached
            : EventsAvailability.live,
      ),
      Err(:final error) => CalendarMonth(
        year: year,
        month: month,
        days: buildMonth(year, month, const []).days,
        eventsAvailability: EventsAvailability.unavailable,
        eventsFailure: error,
      ),
    };
  }

  /// Synchronous, pure combination of lunar data + [events].
  CalendarMonth buildMonth(
    int year,
    int month,
    List<CalendarEvent> events, {
    EventsAvailability availability = EventsAvailability.live,
  }) {
    final first = CivilDate(year, month, 1);
    final last = CivilDate(year, month, daysInGregorianMonth(year, month));
    final inMonth = [
      for (final e in events)
        if (!e.endDate.isBefore(first) && !e.startDate.isAfter(last)) e,
    ];
    return CalendarMonth(
      year: year,
      month: month,
      eventsAvailability: availability,
      days: [
        for (var day = 1; day <= last.day; day++)
          _day(CivilDate(year, month, day), inMonth),
      ],
    );
  }

  CalendarDay _day(CivilDate date, List<CalendarEvent> events) => CalendarDay(
    date: date,
    lunar: _lunar.toLunar(date),
    events: [
      for (final e in events)
        if (e.covers(date)) e,
    ],
  );
}
