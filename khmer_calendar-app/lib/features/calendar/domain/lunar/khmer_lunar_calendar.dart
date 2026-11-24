/// Khmer lunar calendar (ចន្ទគតិ / Chhankitek) calculator — pure Dart.
///
/// Behaviour-identical port of
/// `khmer-calendar-api/src/modules/lunar/domain/khmer-lunar-calendar.ts`
/// (itself a port of @thyrith/momentkh v3, MIT, (c) Thyrith Sor):
///  - Works on civil dates only (no DateTime / timezone dependency).
///  - Day-level semantics: the animal year changes on the Moha Songkran
///    *date*, the era (ស័ក) on the Lerng Sak date, the Buddhist Era on
///    1 Roch Pisakh.
///  - Pure functions + per-year memoization.
///
/// Integer arithmetic deliberately reproduces JavaScript semantics
/// (`Math.floor(a / b)` and the sign-of-dividend `%` operator) so that results
/// are identical even for negative intermediates. Both engines are verified
/// against `shared/fixtures/khmer-lunar-golden.json`.
library;

import '../../../../core/date/civil_date.dart';
import 'khmer_lunar_constants.dart';

/// `Math.floor(a / b)`
int _fdiv(int a, int b) => (a / b).floor();

/// JavaScript `a % b` (result has the sign of the dividend).
int _rem(int a, int b) => a.remainder(b);

/// Mathematical modulo (always non-negative for positive [m]).
int _mod(int n, int m) => ((n % m) + m) % m;

final class KhmerLunarDate {
  const KhmerLunarDate({
    required this.day,
    required this.moonPhase,
    required this.month,
    required this.beYear,
    required this.jsYear,
    required this.animalYear,
    required this.sak,
    required this.dayOfWeek,
    required this.isHolyDay,
  });

  /// 1-15
  final int day;
  final MoonPhase moonPhase;
  final LunarMonth month;

  /// Buddhist Era year (ពុទ្ធសករាជ) — changes on 1 Roch Pisakh.
  final int beYear;

  /// Jolak Sakaraj year (ចុល្លសករាជ).
  final int jsYear;

  /// 0 = Rat ... 11 = Pig
  final int animalYear;

  /// 0-9
  final int sak;

  /// 0 = Sunday ... 6 = Saturday
  final int dayOfWeek;

  /// ថ្ងៃសីល: 8 Kert, 15 Kert, 8 Roch and the last day of the lunar month.
  final bool isHolyDay;

  @override
  bool operator ==(Object other) =>
      other is KhmerLunarDate &&
      other.day == day &&
      other.moonPhase == moonPhase &&
      other.month == month &&
      other.beYear == beYear &&
      other.jsYear == jsYear &&
      other.animalYear == animalYear &&
      other.sak == sak &&
      other.dayOfWeek == dayOfWeek &&
      other.isHolyDay == isHolyDay;

  @override
  int get hashCode => Object.hash(
    day,
    moonPhase,
    month,
    beYear,
    jsYear,
    animalYear,
    sak,
    dayOfWeek,
    isHolyDay,
  );

  @override
  String toString() =>
      'KhmerLunarDate($day ${moonPhase.name} ${month.name}, BE $beYear, '
      'JS $jsYear, animal $animalYear, sak $sak, holy $isHolyDay)';
}

final class KhmerNewYearInfo {
  const KhmerNewYearInfo({
    required this.gregorianYear,
    required this.mohaSongkran,
    required this.hour,
    required this.minute,
    required this.lerngSak,
    required this.numberOfDays,
  });

  final int gregorianYear;

  /// Moha Songkran (first day of Khmer New Year).
  final CivilDate mohaSongkran;
  final int hour;
  final int minute;

  /// Lerng Sak (last day of the celebration; era changes on this day).
  final CivilDate lerngSak;

  /// 3 or 4 days
  final int numberOfDays;
}

/// (dayNumber 0-29 where 0 = 1 Kert and 15 = 1 Roch, month)
typedef _LunarDayAndMonth = ({int dayNumber, LunarMonth month});
typedef _SunInfo = ({int angsar, int libda});

/// Known corrections for years where the computed Songkran differs from the
/// officially announced moment (carried over from the reference).
final Map<int, (CivilDate, int, int)> _newYearOverrides = {
  1879: (CivilDate(1879, 4, 12), 11, 36),
  1897: (CivilDate(1897, 4, 13), 2, 0),
  2011: (CivilDate(2011, 4, 14), 13, 12),
  2012: (CivilDate(2012, 4, 14), 19, 11),
  2013: (CivilDate(2013, 4, 14), 2, 12),
  2014: (CivilDate(2014, 4, 14), 8, 7),
  2015: (CivilDate(2015, 4, 14), 14, 2),
  2024: (CivilDate(2024, 4, 13), 22, 17),
};

/// 1 Kert, Boss
final int _epochJdn = CivilDate(1900, 1, 1).julianDay;

class KhmerLunarCalendar {
  final Map<int, int> _leapTypeCache = {};
  final Map<int, int> _pisakhaCache = {};
  final Map<int, KhmerNewYearInfo> _newYearCache = {};

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  KhmerLunarDate toLunar(CivilDate date) {
    final jdn = date.julianDay;
    final lunar = _lunarDayAndMonth(date);

    final transitionJdn = _beYearTransitionJdn(date.year);
    final beYear = jdn >= transitionJdn ? date.year + 544 : date.year + 543;
    var jsYear = beYear - 1182;
    var animalYear = _mod(beYear + 4, 12);

    final newYear = this.newYear(date.year);
    if (jdn >= newYear.mohaSongkran.julianDay && jdn < transitionJdn) {
      animalYear = (animalYear + 1) % 12;
    }
    if (jdn >= newYear.lerngSak.julianDay && jdn < transitionJdn) {
      jsYear += 1;
    }

    final isLastDayOfMonth = _lunarDayAndMonth(date.addDays(1)).dayNumber == 0;
    final dayNumber = lunar.dayNumber;

    return KhmerLunarDate(
      day: _rem(dayNumber, 15) + 1,
      moonPhase: dayNumber < 15 ? MoonPhase.waxing : MoonPhase.waning,
      month: lunar.month,
      beYear: beYear,
      jsYear: jsYear,
      animalYear: animalYear,
      sak: _mod(jsYear, 10),
      dayOfWeek: date.dayOfWeek,
      isHolyDay:
          dayNumber == 7 ||
          dayNumber == 14 ||
          dayNumber == 22 ||
          isLastDayOfMonth,
    );
  }

  KhmerNewYearInfo newYear(int gregorianYear) {
    final cached = _newYearCache[gregorianYear];
    if (cached != null) return cached;

    final jsYear = gregorianYear - 638;
    final sotins = _newYearSotins(jsYear);
    var hour = 0;
    var minute = 0;
    for (final sotin in sotins) {
      if (sotin.angsar == 0) {
        final minutes = 24 * 60 - sotin.libda * 24;
        hour = _rem(_fdiv(minutes, 60), 24);
        minute = _rem(minutes, 60);
        break;
      }
    }

    var bodithey = _boditheyJs(jsYear);
    if (_isAdhikameasJs(jsYear - 1) && _isChantrathimeasJs(jsYear - 1)) {
      bodithey = _rem(bodithey + 1, 30);
    }
    final lerngSakDay = bodithey >= 6 ? bodithey - 1 : bodithey;
    final lerngSakMonth = bodithey >= 6 ? LunarMonth.cheit : LunarMonth.pisakh;
    final numberOfDays = sotins[0].angsar == 0 ? 4 : 3;

    final epoch = CivilDate(gregorianYear, 4, 17);
    final khEpoch = _lunarDayAndMonth(epoch);
    final diffFromEpoch =
        (khEpoch.month.index - 4) * 29 +
        khEpoch.dayNumber -
        ((lerngSakMonth.index - 4) * 29 + lerngSakDay);
    var newYearJdn = epoch.julianDay - (diffFromEpoch + numberOfDays - 1);

    final override = _newYearOverrides[gregorianYear];
    if (override != null) {
      newYearJdn = override.$1.julianDay;
      hour = override.$2;
      minute = override.$3;
    }

    final info = KhmerNewYearInfo(
      gregorianYear: gregorianYear,
      mohaSongkran: CivilDate.fromJulianDay(newYearJdn),
      hour: hour,
      minute: minute,
      lerngSak: CivilDate.fromJulianDay(newYearJdn + numberOfDays - 1),
      numberOfDays: numberOfDays,
    );
    _newYearCache[gregorianYear] = info;
    return info;
  }

  /// Every date in the Gregorian year whose lunar day/month matches.
  List<CivilDate> findInGregorianYear(
    int gregorianYear,
    LunarMonth month,
    int day,
    MoonPhase moonPhase,
  ) {
    final targetDayNumber = (moonPhase == MoonPhase.waxing ? 0 : 15) + day - 1;
    final result = <CivilDate>[];
    final start = CivilDate(gregorianYear, 1, 1).julianDay;
    final end = CivilDate(gregorianYear, 12, 31).julianDay;
    for (var jdn = start; jdn <= end; jdn++) {
      final date = CivilDate.fromJulianDay(jdn);
      final lunar = _lunarDayAndMonth(date);
      if (lunar.month == month && lunar.dayNumber == targetDayNumber) {
        result.add(date);
      }
    }
    return result;
  }

  // ---------------------------------------------------------------------------
  // Lunar day & month
  // ---------------------------------------------------------------------------

  _LunarDayAndMonth _lunarDayAndMonth(CivilDate date) {
    var epochJdn = _epochJdn;
    var diffDays = date.julianDay - epochJdn;
    var month = LunarMonth.boss;

    if (diffDays > 0) {
      for (;;) {
        final epoch = CivilDate.fromJulianDay(epochJdn);
        final daysInNextYear = _daysInKhmerYear(
          _maybeBeYear(epoch.year + 1, epoch.month),
        );
        if (diffDays > daysInNextYear) {
          diffDays -= daysInNextYear;
          epochJdn += daysInNextYear;
        } else {
          break;
        }
      }
    } else if (diffDays < 0) {
      while (diffDays < 0) {
        final epoch = CivilDate.fromJulianDay(epochJdn);
        final daysInYear = _daysInKhmerYear(
          _maybeBeYear(epoch.year, epoch.month),
        );
        diffDays += daysInYear;
        epochJdn -= daysInYear;
      }
    }

    while (diffDays > 0) {
      final epoch = CivilDate.fromJulianDay(epochJdn);
      final be = _maybeBeYear(epoch.year, epoch.month);
      final daysInMonth = _daysInKhmerMonth(month, be);
      if (diffDays > daysInMonth) {
        diffDays -= daysInMonth;
        epochJdn += daysInMonth;
        month = _nextMonthOf(month, be);
      } else {
        break;
      }
    }

    var dayNumber = diffDays;
    final finalBe = _maybeBeYear(date.year, date.month);
    final totalDaysInMonth = _daysInKhmerMonth(month, finalBe);
    if (dayNumber >= totalDaysInMonth) {
      dayNumber = _rem(dayNumber, totalDaysInMonth);
      month = _nextMonthOf(month, finalBe);
    }
    return (dayNumber: dayNumber, month: month);
  }

  /// JDN of 1 Roch Pisakh in the Gregorian year — the day the BE increments.
  int _beYearTransitionJdn(int gregorianYear) {
    final cached = _pisakhaCache[gregorianYear];
    if (cached != null) return cached;

    var found = CivilDate(gregorianYear, 4, 15).julianDay; // fallback
    final start = CivilDate(gregorianYear, 4, 1).julianDay;
    final end = CivilDate(gregorianYear, 6, 30).julianDay;
    for (var jdn = start; jdn <= end; jdn++) {
      final lunar = _lunarDayAndMonth(CivilDate.fromJulianDay(jdn));
      if (lunar.month == LunarMonth.pisakh && lunar.dayNumber == 15) {
        found = jdn;
        break;
      }
    }
    _pisakhaCache[gregorianYear] = found;
    return found;
  }

  // ---------------------------------------------------------------------------
  // Leap rules (BE-year based)
  // ---------------------------------------------------------------------------

  int _daysInKhmerMonth(LunarMonth month, int beYear) {
    final leapType = _leapType(beYear);
    if (month == LunarMonth.jesth && leapType == 2) return 30;
    if (month == LunarMonth.pathamasadh || month == LunarMonth.tutiyasadh) {
      return leapType == 1 ? 30 : 0;
    }
    return month.index % 2 == 0 ? 29 : 30;
  }

  int _daysInKhmerYear(int beYear) {
    final leapType = _leapType(beYear);
    if (leapType == 1) return 384;
    if (leapType == 2) return 355;
    return 354;
  }

  LunarMonth _nextMonthOf(LunarMonth month, int beYear) {
    if (month == LunarMonth.jesth && _leapType(beYear) == 1) {
      return LunarMonth.pathamasadh;
    }
    if (month == LunarMonth.kadeuk) return LunarMonth.migasir;
    if (month == LunarMonth.pathamasadh) return LunarMonth.tutiyasadh;
    if (month == LunarMonth.tutiyasadh) return LunarMonth.srap;
    return LunarMonth.values[month.index + 1];
  }

  /// 0 = regular, 1 = leap month (អធិកមាស), 2 = leap day (ចន្ទ្រាធិមាស)
  int _leapType(int beYear) {
    final cached = _leapTypeCache[beYear];
    if (cached != null) return cached;

    var result = 0;
    if (_isKhmerLeapMonth(beYear)) {
      result = 1;
    } else if (_isKhmerLeapDay(beYear)) {
      result = 2;
    } else if (_isKhmerLeapMonth(beYear - 1)) {
      var previousYear = beYear - 1;
      for (;;) {
        if (_isKhmerLeapDay(previousYear)) {
          result = 2;
          break;
        }
        previousYear -= 1;
        if (!_isKhmerLeapMonth(previousYear)) {
          result = 0;
          break;
        }
      }
    }
    _leapTypeCache[beYear] = result;
    return result;
  }

  // ---------------------------------------------------------------------------
  // Songkran (JS-year based)
  // ---------------------------------------------------------------------------

  List<_SunInfo> _newYearSotins(int jsYear) {
    final sotins = _kromthupulJs(jsYear - 1) <= 207
        ? const [363, 364, 365, 366]
        : const [362, 363, 364, 365];
    return [for (final sotin in sotins) _sunInfo(jsYear, sotin)];
  }

  int _boditheyJs(int jsYear) {
    final aharkun = _aharkunJs(jsYear);
    return _rem(aharkun + _fdiv(11 * aharkun + 650, 692), 30);
  }

  bool _isAdhikameasJs(int jsYear) {
    final bodithey = _boditheyJs(jsYear);
    final next = _boditheyJs(jsYear + 1);
    if (bodithey == 24 && next == 6) return true;
    if (bodithey == 25 && next == 5) return false;
    return bodithey > 24 || bodithey < 6;
  }

  bool _isChantrathimeasJs(int jsYear) {
    final avoman = _avomanJs(jsYear);
    final avomanNext = _avomanJs(jsYear + 1);
    final avomanPrev = _avomanJs(jsYear - 1);
    final isSolarLeap = _kromthupulJs(jsYear) <= 207;
    if (avoman == 0 && avomanPrev == 137) return true;
    if (isSolarLeap) return avoman < 127;
    if (avoman == 137 && avomanNext == 0) return false;
    return avoman < 138;
  }
}

// -----------------------------------------------------------------------------
// Pure helpers
// -----------------------------------------------------------------------------

/// Approximate BE year used while walking months (matches the reference).
int _maybeBeYear(int year, int month) => month <= 4 ? year + 543 : year + 544;

int _aharkun(int beYear) => _fdiv(beYear * 292207 + 499, 800) + 4;

int _avoman(int beYear) => _rem(_aharkun(beYear) * 11 + 25, 692);

int _bodithey(int beYear) {
  final a = _aharkun(beYear);
  return _rem(_fdiv(a * 11 + 25, 692) + a + 29, 30);
}

bool _isKhmerSolarLeap(int beYear) =>
    800 - _rem(beYear * 292207 + 499, 800) <= 207;

bool _isKhmerLeapDay(int beYear) {
  final av = _avoman(beYear);
  if (av == 0 && _avoman(beYear - 1) == 137) return true;
  if (_isKhmerSolarLeap(beYear)) return av < 127;
  if (av == 137 && _avoman(beYear + 1) == 0) return false;
  return av < 138;
}

bool _isKhmerLeapMonth(int beYear) {
  final b = _bodithey(beYear);
  final next = _bodithey(beYear + 1);
  if (b == 25 && next == 5) return false;
  return (b == 24 && next == 6) || b >= 25 || b < 6;
}

int _aharkunJs(int jsYear) => _fdiv(jsYear * 292207 + 373, 800) + 1;

int _avomanJs(int jsYear) => _rem(_aharkunJs(jsYear) * 11 + 650, 692);

int _kromthupulJs(int jsYear) => 800 - _rem(292207 * jsYear + 373, 800);

_SunInfo _sunInfo(int jsYear, int sotin) {
  final r2 = 800 * sotin + _kromthupulJs(jsYear - 1);
  final reasey = _fdiv(r2, 24350);
  final r3 = _rem(r2, 24350);
  final angsar = _fdiv(r3, 811);
  final libda = _fdiv(_rem(r3, 811), 14) - 3;
  final sunAverageAsLibda = 30 * 60 * reasey + 60 * angsar + libda;

  const s1 = 30 * 60 * 2 + 60 * 20;
  var leftOver = sunAverageAsLibda - s1;
  if (sunAverageAsLibda < s1) leftOver += 30 * 60 * 12;
  final kaen = _fdiv(leftOver, 30 * 60);

  final int rs;
  if (kaen <= 2) {
    rs = leftOver;
  } else if (kaen <= 5) {
    rs = 30 * 60 * 6 - leftOver;
  } else if (kaen <= 8) {
    rs = leftOver - 30 * 60 * 6;
  } else {
    rs = 30 * 60 * 11 + 60 * 29 + 60 - leftOver;
  }

  final lastReasey = _fdiv(rs, 30 * 60);
  final lastAngsar = _fdiv(_rem(rs, 30 * 60), 60);
  final lastLibda = _rem(rs, 60);

  final int khan;
  final int pouichalip;
  if (lastAngsar >= 15) {
    khan = 2 * lastReasey + 1;
    pouichalip = 60 * (lastAngsar - 15) + lastLibda;
  } else {
    khan = 2 * lastReasey;
    pouichalip = 60 * lastAngsar + lastLibda;
  }

  const chhayaTable = [
    (35, 0),
    (32, 35),
    (27, 67),
    (22, 94),
    (13, 116),
    (5, 129),
  ];
  // JS indexes a negative khan as `undefined`, which would throw on
  // destructuring; khan is always >= 0 because rs >= 0.
  final (multiplicity, chhaya) = khan <= 5 ? chhayaTable[khan] : (0, 134);
  final pholAsLibda = _fdiv(pouichalip * multiplicity, 900) + chhaya;
  final inauguration = kaen <= 5
      ? sunAverageAsLibda - pholAsLibda
      : sunAverageAsLibda + pholAsLibda;

  return (
    angsar: _fdiv(_rem(inauguration, 30 * 60), 60),
    libda: _rem(inauguration, 60),
  );
}
