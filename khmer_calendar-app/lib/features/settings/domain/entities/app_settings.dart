import 'package:equatable/equatable.dart';

import '../../../../core/theme/app_theme_id.dart';

export '../../../../core/theme/app_theme_id.dart';

enum AppLanguage {
  khmer('km'),
  english('en'),
  chinese('zh');

  const AppLanguage(this.code);

  /// BCP-47 language code.
  final String code;

  static AppLanguage fromCode(String? code) =>
      values.firstWhere((l) => l.code == code, orElse: () => AppLanguage.khmer);
}

enum ThemePreference { system, light, dark }

final class AppSettings extends Equatable {
  const AppSettings({
    this.language = AppLanguage.khmer,
    this.themePreference = ThemePreference.light,
    this.themeId = AppThemeId.khmerLight,
    this.showLunarDays = false,
  });

  final AppLanguage language;

  /// Light / dark / follow the device.
  final ThemePreference themePreference;

  /// Which illustrated theme (each has a light and a dark variant).
  final AppThemeId themeId;

  /// Show the lunar day (e.g. ៦កើត) under each date in the month grid.
  final bool showLunarDays;

  AppSettings copyWith({
    AppLanguage? language,
    ThemePreference? themePreference,
    AppThemeId? themeId,
    bool? showLunarDays,
  }) => AppSettings(
    language: language ?? this.language,
    themePreference: themePreference ?? this.themePreference,
    themeId: themeId ?? this.themeId,
    showLunarDays: showLunarDays ?? this.showLunarDays,
  );

  @override
  List<Object?> get props => [
    language,
    themePreference,
    themeId,
    showLunarDays,
  ];
}
