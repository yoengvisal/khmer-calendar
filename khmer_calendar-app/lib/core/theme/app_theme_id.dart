/// Selectable visual themes (pure Dart; persisted by settings).
library;

enum AppThemeId {
  khmerLight('khmer_light'),
  khmerNight('khmer_night'),
  lotus('lotus'),
  green('green'),
  sunset('sunset'),
  royal('royal');

  const AppThemeId(this.code);

  /// Stable storage code; never change once released.
  final String code;

  static AppThemeId fromCode(String? code) => values.firstWhere(
    (t) => t.code == code,
    orElse: () => AppThemeId.khmerLight,
  );
}
