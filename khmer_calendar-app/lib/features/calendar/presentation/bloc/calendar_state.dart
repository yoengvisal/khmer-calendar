part of 'calendar_bloc.dart';

enum CalendarStatus { initial, loading, success }

final class CalendarState extends Equatable {
  const CalendarState({
    required this.visibleMonth,
    required this.today,
    this.status = CalendarStatus.initial,
    this.month,
    this.nextEvent,
  });

  /// The month the user is looking at.
  final YearMonth visibleMonth;

  final CivilDate today;

  final CalendarStatus status;

  /// Computed days (lunar + events) for [visibleMonth]; set on success.
  /// Event loading status lives in [CalendarMonth.eventsAvailability].
  final CalendarMonth? month;

  /// The next event that hasn't ended (for the "next holiday" card).
  final CalendarEvent? nextEvent;

  bool get isShowingToday => visibleMonth.contains(today);

  CalendarState copyWith({
    YearMonth? visibleMonth,
    CivilDate? today,
    CalendarStatus? status,
    CalendarMonth? Function()? month,
    CalendarEvent? Function()? nextEvent,
  }) => CalendarState(
    visibleMonth: visibleMonth ?? this.visibleMonth,
    today: today ?? this.today,
    status: status ?? this.status,
    month: month != null ? month() : this.month,
    nextEvent: nextEvent != null ? nextEvent() : this.nextEvent,
  );

  @override
  List<Object?> get props => [visibleMonth, today, status, month, nextEvent];
}
