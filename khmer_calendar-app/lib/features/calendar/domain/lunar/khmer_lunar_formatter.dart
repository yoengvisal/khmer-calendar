/// Pure-Dart formatting of [KhmerLunarDate]s (mirrors the API's `formattedKm`).
library;

import '../../../../core/l10n/khmer_digits.dart';
import '../../../../core/l10n/ui_language.dart';
import 'khmer_lunar_calendar.dart';
import 'khmer_lunar_constants.dart';

abstract final class KhmerLunarFormatter {
  /// e.g. "ថ្ងៃអាទិត្យ ១០កើត ខែមិគសិរ ឆ្នាំមមី អដ្ឋស័ក ពុទ្ធសករាជ ២៥៧០"
  static String formatKm(KhmerLunarDate lunar) =>
      'ថ្ងៃ${weekdayNamesKm[lunar.dayOfWeek]} '
      '${dayLabelKm(lunar)} '
      'ខែ${lunarMonthNamesKm[lunar.month.index]} '
      'ឆ្នាំ${animalYearNamesKm[lunar.animalYear]} '
      '${sakNamesKm[lunar.sak]} '
      'ពុទ្ធសករាជ ${toKhmerNumeral(lunar.beYear)}';

  /// e.g. "Sunday, 10 Kert, month of Migasir, Year of the Horse, Attha Sak, BE 2570"
  static String formatEn(KhmerLunarDate lunar) =>
      '${weekdayNamesEn[lunar.dayOfWeek]}, '
      '${dayLabelEn(lunar)}, '
      'month of ${lunarMonthNamesEn[lunar.month.index]}, '
      'Year of the ${animalYearNamesEn[lunar.animalYear]}, '
      '${sakNamesEn[lunar.sak]}, '
      'BE ${lunar.beYear}';

  /// e.g. "星期日 · 柬历一月初十 · 马年 · 佛历2570"
  static String formatZh(KhmerLunarDate lunar) =>
      '${weekdayNamesZh[lunar.dayOfWeek]} · '
      '${monthLabelZh(lunar.month.index)}${dayLabelZh(lunar)} · '
      '${animalYearNamesZh[lunar.animalYear]}年 · '
      '佛历${lunar.beYear}';

  /// Full description in [lang]; Khmer for `km`.
  static String format(KhmerLunarDate lunar, UiLanguage lang) => switch (lang) {
    UiLanguage.km => formatKm(lunar),
    UiLanguage.en => formatEn(lunar),
    UiLanguage.zh => formatZh(lunar),
  };

  /// Compact day label for calendar cells: "៥កើត" / "5 Kert" / "初五".
  static String dayLabel(KhmerLunarDate lunar, UiLanguage lang) =>
      switch (lang) {
        UiLanguage.km => dayLabelKm(lunar),
        UiLanguage.en => dayLabelEn(lunar),
        UiLanguage.zh => dayLabelZh(lunar),
      };

  /// e.g. "៥កើត"
  static String dayLabelKm(KhmerLunarDate lunar) =>
      '${toKhmerNumeral(lunar.day)}${moonPhaseNamesKm[lunar.moonPhase.index]}';

  /// e.g. "5 Kert"
  static String dayLabelEn(KhmerLunarDate lunar) =>
      '${lunar.day} ${moonPhaseNamesEn[lunar.moonPhase.index]}';

  /// e.g. "初五" (1-15 Kert = 初一…十五, 1-15 Roch = 十六…三十)
  static String dayLabelZh(KhmerLunarDate lunar) =>
      lunarDayNamesZh[lunar.moonPhase.index * 15 + lunar.day - 1];

  /// e.g. "柬历一月"
  static String monthLabelZh(int monthIndex) =>
      '柬历${lunarMonthNamesZh[monthIndex]}';
}
