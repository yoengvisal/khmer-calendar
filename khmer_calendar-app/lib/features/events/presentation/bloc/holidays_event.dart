part of 'holidays_bloc.dart';

sealed class HolidaysEvent extends Equatable {
  const HolidaysEvent();

  @override
  List<Object?> get props => [];
}

/// Load the current year.
final class HolidaysStarted extends HolidaysEvent {
  const HolidaysStarted();
}

/// Move the selected year by [delta] (−1 / +1).
final class HolidaysYearShifted extends HolidaysEvent {
  const HolidaysYearShifted(this.delta);

  final int delta;

  @override
  List<Object?> get props => [delta];
}

/// Pull-to-refresh / retry: bypasses the in-memory copy.
final class HolidaysRefreshRequested extends HolidaysEvent {
  const HolidaysRefreshRequested({this.completer});

  /// Completed when the refresh finishes (drives `RefreshIndicator`).
  /// Not part of equality.
  final Completer<void>? completer;
}
