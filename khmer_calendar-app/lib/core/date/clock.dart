import 'civil_date.dart';

/// Injectable source of "now" so date-dependent logic is testable.
class Clock {
  const Clock([DateTime Function()? now]) : _now = now;

  /// A clock frozen at [fixed].
  Clock.fixed(DateTime fixed) : _now = (() => fixed);

  final DateTime Function()? _now;

  DateTime now() => _now?.call() ?? DateTime.now();

  /// Today's date in the device's local calendar.
  CivilDate today() => CivilDate.fromDateTime(now());
}
