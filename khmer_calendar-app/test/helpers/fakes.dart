import 'dart:async';

import 'package:khmer_calendar/core/async/cancel_signal.dart';
import 'package:khmer_calendar/core/date/civil_date.dart';
import 'package:khmer_calendar/core/errors/app_failure.dart';
import 'package:khmer_calendar/core/errors/result.dart';
import 'package:khmer_calendar/features/events/data/datasources/events_local_data_source.dart';
import 'package:khmer_calendar/features/events/data/datasources/events_remote_data_source.dart';
import 'package:khmer_calendar/features/events/data/models/event_dto.dart';
import 'package:khmer_calendar/features/events/domain/entities/calendar_event.dart';
import 'package:khmer_calendar/features/events/domain/entities/year_events.dart';
import 'package:khmer_calendar/features/events/domain/repositories/events_repository.dart';
import 'package:khmer_calendar/features/weather/data/datasources/weather_remote_data_source.dart';

EventDto eventDto({
  String id = 'e1',
  String start = '2025-04-14',
  String? end,
  bool isDayOff = true,
  String category = 'PUBLIC_HOLIDAY',
}) => EventDto(
  id: id,
  titleKm: 'ព្រឹត្តិការណ៍ $id',
  titleEn: 'Event $id',
  category: category,
  startDate: start,
  endDate: end ?? start,
  isDayOff: isDayOff,
);

CalendarEvent calendarEvent({
  String id = 'e1',
  String start = '2025-04-14',
  String? end,
  bool isDayOff = true,
  EventCategory category = EventCategory.publicHoliday,
}) => CalendarEvent(
  id: id,
  titleKm: 'ព្រឹត្តិការណ៍ $id',
  titleEn: 'Event $id',
  category: category,
  startDate: CivilDate.parse(start),
  endDate: CivilDate.parse(end ?? start),
  isDayOff: isDayOff,
);

/// Remote data source whose behaviour is set per test.
class FakeEventsRemoteDataSource implements EventsRemoteDataSource {
  FakeEventsRemoteDataSource({this.events = const [], this.failure});

  List<EventDto> events;
  AppFailure? failure;
  final List<(CivilDate, CivilDate)> calls = [];

  @override
  Future<List<EventDto>> fetchEvents({
    required CivilDate from,
    required CivilDate to,
    CancelSignal? cancelSignal,
  }) async {
    calls.add((from, to));
    final f = failure;
    if (f != null) throw AppException(f);
    return events;
  }
}

/// In-memory cache.
class FakeEventsLocalDataSource implements EventsLocalDataSource {
  final Map<int, CachedYearEvents> store = {};

  @override
  Future<CachedYearEvents?> read(int year) async => store[year];

  @override
  Future<void> write(int year, List<EventDto> events, DateTime savedAt) async =>
      store[year] = (events: events, savedAt: savedAt);
}

/// Repository returning a scripted result (optionally after [gate] completes).
class FakeEventsRepository implements EventsRepository {
  FakeEventsRepository(this.result);

  Result<YearEvents, AppFailure> Function(int year) result;
  Completer<void>? gate;
  final List<int> requestedYears = [];

  @override
  Future<Result<YearEvents, AppFailure>> getEventsForYear(
    int year, {
    bool forceRefresh = false,
    CancelSignal? cancelSignal,
  }) async {
    requestedYears.add(year);
    if (gate != null) await gate!.future;
    return result(year);
  }
}

/// Minimal Open-Meteo payload (Phnom Penh, partly cloudy, 31°C).
Map<String, dynamic> openMeteoJson({double temp = 31.4, int code = 2}) => {
  'current': {'temperature_2m': temp, 'weather_code': code, 'is_day': 1},
  'daily': {
    'time': ['2025-05-11', '2025-05-12'],
    'weather_code': [code, 61],
    'temperature_2m_max': [33.2, 32.0],
    'temperature_2m_min': [24.1, 25.0],
    'precipitation_probability_max': [20, 80],
  },
};

class FakeWeatherRemoteDataSource implements WeatherRemoteDataSource {
  FakeWeatherRemoteDataSource({Map<String, dynamic>? json, this.failure})
    : json = json ?? openMeteoJson();

  Map<String, dynamic> json;
  AppFailure? failure;
  int calls = 0;

  @override
  Future<Map<String, dynamic>> fetchForecast() async {
    calls++;
    if (failure != null) throw AppException(failure!);
    return json;
  }
}
