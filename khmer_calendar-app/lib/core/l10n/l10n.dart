import 'package:material_ui/material_ui.dart';

import '../../l10n/generated/app_localizations.dart';
import '../date/civil_date.dart';
import '../date/date_names.dart';
import '../errors/app_failure.dart';
import 'khmer_digits.dart';
import 'ui_language.dart';

export '../../l10n/generated/app_localizations.dart';
export 'ui_language.dart';

const List<Locale> supportedAppLocales = [
  Locale('km'),
  Locale('en'),
  Locale('zh'),
];

/// All delegates the app needs. Uses `material_ui`'s Material/Cupertino
/// delegates (the generated `AppLocalizations.localizationsDelegates` still
/// references the deprecated `package:flutter/material.dart` ones).
const List<LocalizationsDelegate<dynamic>> appLocalizationsDelegates = [
  AppLocalizations.delegate,
  ...GlobalMaterialLocalizations.delegates,
];

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  UiLanguage get uiLanguage =>
      UiLanguage.fromCode(Localizations.localeOf(this).languageCode);

  bool get isKhmer => uiLanguage == UiLanguage.km;

  /// Digits in the current script (Khmer numerals for `km`).
  String digits(Object value) =>
      isKhmer ? toKhmerNumeral(value) : value.toString();
}

const List<String> _weekdayShortKm = ['អា', 'ច', 'អ', 'ពុ', 'ព្រ', 'សុ', 'ស'];
const List<String> _weekdayShortEn = [
  'Sun',
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat',
];
const List<String> _weekdayShortZh = ['日', '一', '二', '三', '四', '五', '六'];

/// Sunday-first short weekday labels.
List<String> weekdayShortLabels(UiLanguage lang) => switch (lang) {
  UiLanguage.km => _weekdayShortKm,
  UiLanguage.en => _weekdayShortEn,
  UiLanguage.zh => _weekdayShortZh,
};

/// Maps a failure to a localized, user-safe message (never raw server text).
String failureMessage(AppLocalizations l10n, AppFailure failure) =>
    switch (failure) {
      NetworkFailure() => l10n.errorNetwork,
      TimeoutFailure() => l10n.errorTimeout,
      ServerFailure() => l10n.errorServer,
      NotFoundFailure() => l10n.errorNotFound,
      ValidationFailure() => l10n.errorValidation,
      CancelledFailure() || UnknownFailure() => l10n.errorUnknown,
    };

/// "មករា ២០២៦" / "January 2026" / "2026年1月"
String formatMonthYear(int year, int month, UiLanguage lang) => switch (lang) {
  UiLanguage.km => '${solarMonthNamesKm[month - 1]} ${toKhmerNumeral(year)}',
  UiLanguage.en => '${solarMonthNamesEn[month - 1]} $year',
  UiLanguage.zh => '$year年$month月',
};

/// "ថ្ងៃអាទិត្យ ១៥ វិច្ឆិកា ២០២៦" / "Sunday, 15 November 2026" /
/// "2026年11月15日 星期日"
String formatCivilDate(
  CivilDate date,
  UiLanguage lang, {
  bool withWeekday = false,
  bool withYear = true,
}) {
  switch (lang) {
    case UiLanguage.km:
      return [
        if (withWeekday) 'ថ្ងៃ${weekdayNamesKm[date.dayOfWeek]}',
        toKhmerNumeral(date.day),
        solarMonthNamesKm[date.month - 1],
        if (withYear) toKhmerNumeral(date.year),
      ].join(' ');
    case UiLanguage.zh:
      final core =
          '${withYear ? '${date.year}年' : ''}${date.month}月${date.day}日';
      return withWeekday ? '$core ${weekdayNamesZh[date.dayOfWeek]}' : core;
    case UiLanguage.en:
      final core = [
        date.day,
        solarMonthNamesEn[date.month - 1],
        if (withYear) date.year,
      ].join(' ');
      return withWeekday ? '${weekdayNamesEn[date.dayOfWeek]}, $core' : core;
  }
}

/// Inclusive range: "១៤ - ១៦ មេសា ២០២៦" / "14 - 16 April 2026" /
/// "2026年4月14日 - 16日".
String formatDateRange(CivilDate start, CivilDate end, UiLanguage lang) {
  if (start == end) return formatCivilDate(start, lang);
  final sameYear = start.year == end.year;
  if (sameYear && start.month == end.month) {
    return switch (lang) {
      UiLanguage.km =>
        '${toKhmerNumeral(start.day)} - ${formatCivilDate(end, lang)}',
      UiLanguage.en => '${start.day} - ${formatCivilDate(end, lang)}',
      UiLanguage.zh => '${formatCivilDate(start, lang)} - ${end.day}日',
    };
  }
  if (lang == UiLanguage.zh) {
    return '${formatCivilDate(start, lang)} - '
        '${formatCivilDate(end, lang, withYear: !sameYear)}';
  }
  return '${formatCivilDate(start, lang, withYear: !sameYear)} - '
      '${formatCivilDate(end, lang)}';
}
