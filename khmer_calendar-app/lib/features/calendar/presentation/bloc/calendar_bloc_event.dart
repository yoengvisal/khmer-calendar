part of 'calendar_bloc.dart';

sealed class CalendarBlocEvent extends Equatable {
  const CalendarBlocEvent();

  @override
  List<Object?> get props => [];
}

/// Load the current month.
final class CalendarStarted extends CalendarBlocEvent {
  const CalendarStarted();
}

/// Move by [delta] months (−1 = previous, +1 = next).
final class CalendarMonthShifted extends CalendarBlocEvent {
  const CalendarMonthShifted(this.delta);

  final int delta;

  @override
  List<Object?> get props => [delta];
}

/// Jump back to the month containing today.
final class CalendarTodayRequested extends CalendarBlocEvent {
  const CalendarTodayRequested();
}

/// Reload the visible month (e.g. after events failed to load).
final class CalendarRefreshRequested extends CalendarBlocEvent {
  const CalendarRefreshRequested();
}

/// Jump to a specific month (month picker, search results).
final class CalendarMonthSelected extends CalendarBlocEvent {
  const CalendarMonthSelected(this.month);

  final YearMonth month;

  @override
  List<Object?> get props => [month];
}
