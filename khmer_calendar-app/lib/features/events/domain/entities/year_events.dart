import 'package:equatable/equatable.dart';

import 'calendar_event.dart';

/// Events of one Gregorian year, plus where they came from.
final class YearEvents extends Equatable {
  const YearEvents({
    required this.year,
    required this.events,
    this.isFromCache = false,
    this.savedAt,
  });

  final int year;

  /// Sorted by start date.
  final List<CalendarEvent> events;

  /// True when the network failed and these are previously saved events.
  final bool isFromCache;

  /// When the cached copy was saved (set when [isFromCache]).
  final DateTime? savedAt;

  @override
  List<Object?> get props => [year, events, isFromCache, savedAt];
}
