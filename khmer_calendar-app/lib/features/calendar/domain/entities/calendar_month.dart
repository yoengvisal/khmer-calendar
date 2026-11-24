import 'package:equatable/equatable.dart';

import '../../../../core/errors/app_failure.dart';
import '../lunar/khmer_lunar_constants.dart';
import 'calendar_day.dart';

/// Whether the month's events could be attached.
enum EventsAvailability {
  /// Fresh from the API.
  live,

  /// API failed; events come from the on-device cache.
  cached,

  /// API failed and nothing is cached; lunar data is still complete.
  unavailable,
}

final class CalendarMonth extends Equatable {
  const CalendarMonth({
    required this.year,
    required this.month,
    required this.days,
    this.eventsAvailability = EventsAvailability.live,
    this.eventsFailure,
  });

  final int year;

  /// 1-12
  final int month;

  /// Every day of the month, in order.
  final List<CalendarDay> days;

  final EventsAvailability eventsAvailability;

  /// Set when [eventsAvailability] is not [EventsAvailability.live].
  final AppFailure? eventsFailure;

  /// Weekday of the 1st (0 = Sunday) = number of leading blank cells in a
  /// Sunday-first grid.
  int get leadingBlankDays => days.first.date.dayOfWeek;

  /// Distinct lunar months in order of appearance, e.g. [kadeuk, migasir].
  List<LunarMonth> get lunarMonths => _distinct(days.map((d) => d.lunar.month));

  /// Distinct animal years (0-11) in order of appearance.
  List<int> get animalYears => _distinct(days.map((d) => d.lunar.animalYear));

  /// Distinct saks (0-9) in order of appearance.
  List<int> get saks => _distinct(days.map((d) => d.lunar.sak));

  /// Distinct Buddhist Era years in order of appearance.
  List<int> get beYears => _distinct(days.map((d) => d.lunar.beYear));

  static List<T> _distinct<T>(Iterable<T> values) {
    final out = <T>[];
    for (final v in values) {
      if (!out.contains(v)) out.add(v);
    }
    return out;
  }

  @override
  List<Object?> get props => [
    year,
    month,
    days,
    eventsAvailability,
    eventsFailure,
  ];
}
