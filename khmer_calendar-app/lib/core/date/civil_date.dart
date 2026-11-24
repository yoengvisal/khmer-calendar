/// Timezone-free calendar date (pure Dart, no Flutter imports).
///
/// The calendar domain works on civil dates only, so results never depend on
/// the device's timezone. Mirrors `khmer-calendar-api/.../civil-date.ts`.
library;

final RegExp _isoDate = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

bool isGregorianLeapYear(int year) =>
    (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;

int daysInGregorianMonth(int year, int month) {
  const days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  return month == 2 && isGregorianLeapYear(year) ? 29 : days[month - 1];
}

bool isValidCivilDate(int year, int month, int day) =>
    year >= 1 &&
    year <= 9999 &&
    month >= 1 &&
    month <= 12 &&
    day >= 1 &&
    day <= daysInGregorianMonth(year, month);

/// Floor division with JavaScript `Math.floor(a / b)` semantics.
int _floorDiv(int a, int b) => (a / b).floor();

final class CivilDate implements Comparable<CivilDate> {
  /// Creates a date. Throws [ArgumentError] for impossible dates.
  CivilDate(this.year, this.month, this.day) {
    if (!isValidCivilDate(year, month, day)) {
      throw ArgumentError('Invalid civil date: $year-$month-$day');
    }
  }

  const CivilDate._unchecked(this.year, this.month, this.day);

  /// Takes the *local* calendar fields of [dateTime] (no timezone conversion).
  factory CivilDate.fromDateTime(DateTime dateTime) =>
      CivilDate(dateTime.year, dateTime.month, dateTime.day);

  /// Julian Day Number (integer) for a proleptic Gregorian civil date.
  factory CivilDate.fromJulianDay(int jdn) {
    final a = jdn + 32044;
    final b = _floorDiv(4 * a + 3, 146097);
    final c = a - _floorDiv(146097 * b, 4);
    final d = _floorDiv(4 * c + 3, 1461);
    final e = c - _floorDiv(1461 * d, 4);
    final m = _floorDiv(5 * e + 2, 153);
    return CivilDate._unchecked(
      100 * b + d - 4800 + _floorDiv(m, 10),
      m + 3 - 12 * _floorDiv(m, 10),
      e - _floorDiv(153 * m + 2, 5) + 1,
    );
  }

  /// Parses strict `YYYY-MM-DD`. Returns null for malformed or impossible dates.
  static CivilDate? tryParse(String value) {
    final match = _isoDate.firstMatch(value);
    if (match == null) return null;
    final year = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final day = int.parse(match.group(3)!);
    return isValidCivilDate(year, month, day)
        ? CivilDate._unchecked(year, month, day)
        : null;
  }

  /// Like [tryParse] but throws [FormatException].
  static CivilDate parse(String value) =>
      tryParse(value) ?? (throw FormatException('Invalid ISO date', value));

  final int year;

  /// 1-12
  final int month;

  /// 1-31
  final int day;

  int get julianDay {
    final a = _floorDiv(14 - month, 12);
    final y = year + 4800 - a;
    final m = month + 12 * a - 3;
    return day +
        _floorDiv(153 * m + 2, 5) +
        365 * y +
        _floorDiv(y, 4) -
        _floorDiv(y, 100) +
        _floorDiv(y, 400) -
        32045;
  }

  /// 0 = Sunday ... 6 = Saturday
  int get dayOfWeek => (julianDay + 1) % 7;

  CivilDate addDays(int days) => CivilDate.fromJulianDay(julianDay + days);

  int daysUntil(CivilDate other) => other.julianDay - julianDay;

  bool isBefore(CivilDate other) => compareTo(other) < 0;
  bool isAfter(CivilDate other) => compareTo(other) > 0;

  String toIso() =>
      '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';

  @override
  int compareTo(CivilDate other) => julianDay - other.julianDay;

  @override
  bool operator ==(Object other) =>
      other is CivilDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => toIso();
}
