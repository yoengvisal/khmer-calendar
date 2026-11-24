import 'package:equatable/equatable.dart';

import '../../../../core/date/civil_date.dart';

/// A Gregorian month (year + 1-12 month).
final class YearMonth extends Equatable implements Comparable<YearMonth> {
  const YearMonth(this.year, this.month) : assert(month >= 1 && month <= 12);

  factory YearMonth.of(CivilDate date) => YearMonth(date.year, date.month);

  final int year;
  final int month;

  YearMonth addMonths(int delta) {
    final zeroBased = year * 12 + (month - 1) + delta;
    return YearMonth(zeroBased ~/ 12, zeroBased % 12 + 1);
  }

  YearMonth get next => addMonths(1);
  YearMonth get previous => addMonths(-1);

  bool contains(CivilDate date) => date.year == year && date.month == month;

  @override
  int compareTo(YearMonth other) =>
      (year * 12 + month) - (other.year * 12 + other.month);

  @override
  List<Object?> get props => [year, month];

  @override
  String toString() => '$year-${month.toString().padLeft(2, '0')}';
}
