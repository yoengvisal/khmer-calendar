part of 'holidays_bloc.dart';

sealed class HolidaysState extends Equatable {
  const HolidaysState({required this.year});

  /// The selected Gregorian year.
  final int year;

  @override
  List<Object?> get props => [year];
}

final class HolidaysInitial extends HolidaysState {
  const HolidaysInitial({required super.year});
}

final class HolidaysLoading extends HolidaysState {
  const HolidaysLoading({required super.year});
}

final class HolidaysSuccess extends HolidaysState {
  const HolidaysSuccess({
    required super.year,
    required this.events,
    required this.today,
    this.isStale = false,
    this.savedAt,
  });

  /// Sorted by start date; never empty (see [HolidaysEmpty]).
  final List<CalendarEvent> events;

  /// Used to dim events that are already over.
  final CivilDate today;

  /// True when served from the on-device cache because the network failed.
  final bool isStale;
  final DateTime? savedAt;

  /// Events grouped by the month (1-12) of their start date within [year];
  /// events starting in an earlier year are grouped under January.
  Map<int, List<CalendarEvent>> get byMonth {
    final groups = <int, List<CalendarEvent>>{};
    for (final event in events) {
      final month = event.startDate.year < year ? 1 : event.startDate.month;
      (groups[month] ??= []).add(event);
    }
    return groups;
  }

  @override
  List<Object?> get props => [year, events, today, isStale, savedAt];
}

final class HolidaysEmpty extends HolidaysState {
  const HolidaysEmpty({required super.year, this.isStale = false});

  final bool isStale;

  @override
  List<Object?> get props => [year, isStale];
}

final class HolidaysFailure extends HolidaysState {
  const HolidaysFailure({required super.year, required this.failure});

  final AppFailure failure;

  @override
  List<Object?> get props => [year, failure];
}
