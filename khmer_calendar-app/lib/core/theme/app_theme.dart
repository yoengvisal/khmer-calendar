import 'package:material_ui/material_ui.dart';

import 'app_theme_id.dart';

export 'app_theme_id.dart';

/// Brand palette (see branding/README.md).
abstract final class AppColors {
  static const Color navy = Color(0xFF0E2A6B);
  static const Color navyDeep = Color(0xFF0B1E57);
  static const Color gold = Color(0xFFF2C766);
  static const Color goldLight = Color(0xFFF7DA86);
  static const Color goldDeep = Color(0xFFD59A2E);
  static const Color red = Color(0xFFC8102E);
}

/// Typography: each script gets the most legible font for it.
///
/// - Latin text and digits: the platform UI font (Roboto / San Francisco).
/// - Khmer: Kantumruy Pro (bundled), picked per glyph via [fallback].
/// - Chinese: the system CJK font.
abstract final class AppFonts {
  static const List<String> fallback = ['KantumruyPro'];
}

/// Per-theme colours for one brightness, plus its header illustration.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.card,
    required this.line,
    required this.text,
    required this.muted,
    required this.accent,
    required this.onAccent,
    required this.saturday,
    required this.sunday,
    required this.nav,
    required this.glass,
    required this.headerText,
    required this.scene,
  });

  final Color background;
  final Color card;
  final Color line;
  final Color text;
  final Color muted;
  final Color accent;
  final Color onAccent;
  final Color saturday;
  final Color sunday;
  final Color nav;

  /// Translucent fill for round buttons over the header illustration.
  final Color glass;

  /// App name over the illustration.
  final Color headerText;

  /// SVG asset drawn behind the header (assets/scenes).
  final String scene;

  static AppPalette of(AppThemeId id, Brightness brightness) {
    final dark = brightness == Brightness.dark;
    return (dark ? _dark : _light)[id]!;
  }

  static String _scene(AppThemeId id, {required bool night}) =>
      'assets/scenes/${switch (id) {
        AppThemeId.khmerLight => 'khmerLight',
        AppThemeId.khmerNight => 'khmerNight',
        AppThemeId.lotus => 'lotus',
        AppThemeId.green => 'green',
        AppThemeId.sunset => 'sunset',
        AppThemeId.royal => 'royal',
      }}_${night ? 'night' : 'day'}.svg';

  /// Thumbnail used in the theme picker.
  static String thumbnail(AppThemeId id) =>
      _scene(id, night: id == AppThemeId.khmerNight || id == AppThemeId.royal);

  static final Map<AppThemeId, AppPalette> _light = {
    AppThemeId.khmerLight: AppPalette(
      background: const Color(0xFFEEF2FB),
      card: const Color(0xF2FFFFFF),
      line: const Color(0x0F0F172A),
      text: const Color(0xFF0F172A),
      muted: const Color(0xFF6E7689),
      accent: const Color(0xFF1D5CF2),
      onAccent: Colors.white,
      saturday: const Color(0xFF1D5CF2),
      sunday: const Color(0xFFE11D2E),
      nav: const Color(0xF5FFFFFF),
      glass: const Color(0xC0FFFFFF),
      headerText: const Color(0xFF0F172A),
      scene: _scene(AppThemeId.khmerLight, night: false),
    ),
    AppThemeId.khmerNight: AppPalette(
      background: const Color(0xFFEDEFFA),
      card: const Color(0xF2FFFFFF),
      line: const Color(0x0F0F172A),
      text: const Color(0xFF141938),
      muted: const Color(0xFF6F7497),
      accent: const Color(0xFF4338CA),
      onAccent: Colors.white,
      saturday: const Color(0xFF4338CA),
      sunday: const Color(0xFFE11D48),
      nav: const Color(0xF5FFFFFF),
      glass: const Color(0x99FFFFFF),
      headerText: Colors.white,
      scene: _scene(AppThemeId.khmerNight, night: false),
    ),
    AppThemeId.lotus: AppPalette(
      background: const Color(0xFFFFF2F7),
      card: const Color(0xF2FFFFFF),
      line: const Color(0x1AE0457B),
      text: const Color(0xFF3A1024),
      muted: const Color(0xFF8E6176),
      accent: const Color(0xFFD63A70),
      onAccent: Colors.white,
      saturday: const Color(0xFF8B45C2),
      sunday: const Color(0xFFD63A70),
      nav: const Color(0xF5FFFFFF),
      glass: const Color(0xB3FFFFFF),
      headerText: const Color(0xFF3A1024),
      scene: _scene(AppThemeId.lotus, night: false),
    ),
    AppThemeId.green: AppPalette(
      background: const Color(0xFFEEF8F0),
      card: const Color(0xF2FFFFFF),
      line: const Color(0x1A22A05A),
      text: const Color(0xFF0F2A1A),
      muted: const Color(0xFF5E7D6A),
      accent: const Color(0xFF178A49),
      onAccent: Colors.white,
      saturday: const Color(0xFF1E6F96),
      sunday: const Color(0xFFD9362B),
      nav: const Color(0xF5FFFFFF),
      glass: const Color(0xB3FFFFFF),
      headerText: const Color(0xFF0F2A1A),
      scene: _scene(AppThemeId.green, night: false),
    ),
    AppThemeId.sunset: AppPalette(
      background: const Color(0xFFFFF4EC),
      card: const Color(0xF2FFFFFF),
      line: const Color(0x1FF07C50),
      text: const Color(0xFF341A2E),
      muted: const Color(0xFF8A6574),
      accent: const Color(0xFFE2562B),
      onAccent: Colors.white,
      saturday: const Color(0xFF6D3FC0),
      sunday: const Color(0xFFD6245F),
      nav: const Color(0xF5FFFFFF),
      glass: const Color(0x99FFFFFF),
      headerText: Colors.white,
      scene: _scene(AppThemeId.sunset, night: false),
    ),
    AppThemeId.royal: AppPalette(
      background: const Color(0xFFF4F1E8),
      card: const Color(0xF2FFFFFF),
      line: const Color(0x140E2A6B),
      text: const Color(0xFF0E1F4D),
      muted: const Color(0xFF656E90),
      accent: AppColors.navy,
      onAccent: AppColors.goldLight,
      saturday: AppColors.navy,
      sunday: AppColors.red,
      nav: const Color(0xF5FFFFFF),
      glass: const Color(0xB3FFFFFF),
      headerText: const Color(0xFF0E1F4D),
      scene: _scene(AppThemeId.royal, night: false),
    ),
  };

  static final Map<AppThemeId, AppPalette> _dark = {
    AppThemeId.khmerLight: AppPalette(
      background: const Color(0xFF0E1529),
      card: const Color(0xE01B2540),
      line: const Color(0x12FFFFFF),
      text: const Color(0xFFF2F5FB),
      muted: const Color(0xFF8C96B2),
      accent: const Color(0xFF2F6BFF),
      onAccent: Colors.white,
      saturday: const Color(0xFF6E9BFF),
      sunday: const Color(0xFFFF5A5A),
      nav: const Color(0xEB161F38),
      glass: const Color(0x1FFFFFFF),
      headerText: Colors.white,
      scene: _scene(AppThemeId.khmerLight, night: true),
    ),
    AppThemeId.khmerNight: AppPalette(
      background: const Color(0xFF070D22),
      card: const Color(0xE6131B3A),
      line: const Color(0x1FF7DA86),
      text: const Color(0xFFF4EEDD),
      muted: const Color(0xFF9AA3C6),
      accent: const Color(0xFFE5B64A),
      onAccent: const Color(0xFF0B1230),
      saturday: const Color(0xFF8FB3FF),
      sunday: const Color(0xFFFF6B7F),
      nav: const Color(0xF00A112C),
      glass: const Color(0x1AFFFFFF),
      headerText: Colors.white,
      scene: _scene(AppThemeId.khmerNight, night: true),
    ),
    AppThemeId.lotus: AppPalette(
      background: const Color(0xFF1C0B1E),
      card: const Color(0xE6301430),
      line: const Color(0x1FFF8FB8),
      text: const Color(0xFFFBEAF2),
      muted: const Color(0xFFC399AE),
      accent: const Color(0xFFFF6FA3),
      onAccent: const Color(0xFF2A0F2E),
      saturday: const Color(0xFFC59BFF),
      sunday: const Color(0xFFFF6FA3),
      nav: const Color(0xF0280E28),
      glass: const Color(0x1FFFFFFF),
      headerText: Colors.white,
      scene: _scene(AppThemeId.lotus, night: true),
    ),
    AppThemeId.green: AppPalette(
      background: const Color(0xFF08160E),
      card: const Color(0xE6122A1C),
      line: const Color(0x1F6CCB7E),
      text: const Color(0xFFE8F6EC),
      muted: const Color(0xFF8DB39A),
      accent: const Color(0xFF3CC274),
      onAccent: const Color(0xFF06210F),
      saturday: const Color(0xFF6FC3E0),
      sunday: const Color(0xFFFF6B5E),
      nav: const Color(0xF00A1E12),
      glass: const Color(0x1AFFFFFF),
      headerText: Colors.white,
      scene: _scene(AppThemeId.green, night: true),
    ),
    AppThemeId.sunset: AppPalette(
      background: const Color(0xFF140C1F),
      card: const Color(0xE62C1834),
      line: const Color(0x1FFFB36B),
      text: const Color(0xFFFBEDE6),
      muted: const Color(0xFFBC9AA8),
      accent: const Color(0xFFFF8A4C),
      onAccent: const Color(0xFF26100A),
      saturday: const Color(0xFFB39BFF),
      sunday: const Color(0xFFFF6B8B),
      nav: const Color(0xF0201028),
      glass: const Color(0x1AFFFFFF),
      headerText: Colors.white,
      scene: _scene(AppThemeId.sunset, night: true),
    ),
    AppThemeId.royal: AppPalette(
      background: const Color(0xFF061232),
      card: const Color(0xE00B1E57),
      line: const Color(0x24F7DA86),
      text: const Color(0xFFF4EEDD),
      muted: const Color(0xFFA9B4D6),
      accent: AppColors.gold,
      onAccent: AppColors.navyDeep,
      saturday: const Color(0xFF8FB3FF),
      sunday: const Color(0xFFFF7A8A),
      nav: const Color(0xF0061232),
      glass: const Color(0x1AFFFFFF),
      headerText: AppColors.goldLight,
      scene: _scene(AppThemeId.royal, night: true),
    ),
  };

  @override
  AppPalette copyWith() => this;

  @override
  AppPalette lerp(AppPalette? other, double t) =>
      other == null || t < .5 ? this : other;
}

/// Semantic calendar colours (same meaning in every theme).
@immutable
class CalendarColors extends ThemeExtension<CalendarColors> {
  const CalendarColors({
    required this.holiday,
    required this.holyDay,
    required this.myEvent,
    required this.otherEvent,
    required this.todayFill,
    required this.onTodayFill,
  });

  /// Public holidays / days off (red dot).
  final Color holiday;

  /// Buddhist holy days, ថ្ងៃសីល (yellow dot).
  final Color holyDay;

  /// The user's own events (blue dot).
  final Color myEvent;

  /// Other published events (green dot).
  final Color otherEvent;

  final Color todayFill;
  final Color onTodayFill;

  /// Published events that aren't days off.
  Color get event => otherEvent;

  static CalendarColors forPalette(AppPalette p, Brightness brightness) {
    final dark = brightness == Brightness.dark;
    return CalendarColors(
      holiday: dark ? const Color(0xFFFF5C5C) : const Color(0xFFEF4444),
      holyDay: const Color(0xFFF5B800),
      myEvent: dark ? const Color(0xFF5B9BFF) : const Color(0xFF3B82F6),
      otherEvent: dark ? const Color(0xFF3CCB6A) : const Color(0xFF22A447),
      todayFill: p.accent,
      onTodayFill: p.onAccent,
    );
  }

  @override
  CalendarColors copyWith() => this;

  @override
  CalendarColors lerp(CalendarColors? other, double t) =>
      other == null || t < .5 ? this : other;
}

/// Decoration tokens shared by older widgets (cards, chips, sheets),
/// derived from the active [AppPalette].
@immutable
class RoyalDecor extends ThemeExtension<RoyalDecor> {
  const RoyalDecor({
    required this.background,
    required this.card,
    required this.line,
    required this.muted,
    required this.accent,
    required this.headingGradient,
    required this.todayGradient,
    required this.starfield,
  });

  factory RoyalDecor.fromPalette(AppPalette p) => RoyalDecor(
    background: LinearGradient(colors: [p.background, p.background]),
    card: p.card,
    line: p.line,
    muted: p.muted,
    accent: p.accent,
    headingGradient: LinearGradient(colors: [p.text, p.text]),
    todayGradient: LinearGradient(colors: [p.accent, p.accent]),
    starfield: false,
  );

  final Gradient background;
  final Color card;
  final Color line;
  final Color muted;
  final Color accent;
  final Gradient headingGradient;
  final Gradient todayGradient;
  final bool starfield;

  @override
  RoyalDecor copyWith() => this;

  @override
  RoyalDecor lerp(RoyalDecor? other, double t) =>
      other == null || t < .5 ? this : other;
}

abstract final class AppTheme {
  static ThemeData light([AppThemeId id = AppThemeId.khmerLight]) =>
      build(id, Brightness.light);
  static ThemeData dark([AppThemeId id = AppThemeId.khmerLight]) =>
      build(id, Brightness.dark);

  static ThemeData build(AppThemeId id, Brightness brightness) {
    final p = AppPalette.of(id, brightness);
    final isDark = brightness == Brightness.dark;
    final scheme =
        ColorScheme.fromSeed(
          seedColor: p.accent,
          brightness: brightness,
        ).copyWith(
          primary: p.accent,
          onPrimary: p.onAccent,
          surface: isDark
              ? Color.alphaBlend(p.card, p.background)
              : Colors.white,
          onSurface: p.text,
          onSurfaceVariant: p.muted,
          outline: p.line,
          outlineVariant: p.line,
          secondaryContainer: p.accent.withValues(alpha: isDark ? .22 : .10),
          onSecondaryContainer: isDark ? p.text : p.accent,
        );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamilyFallback: AppFonts.fallback,
    );
    final textTheme = base.textTheme
        .apply(bodyColor: p.text, displayColor: p.text)
        .copyWith(
          bodyLarge: base.textTheme.bodyLarge?.copyWith(
            height: 1.5,
            color: p.text,
          ),
          bodyMedium: base.textTheme.bodyMedium?.copyWith(
            fontSize: 15,
            height: 1.45,
            color: p.text,
          ),
          bodySmall: base.textTheme.bodySmall?.copyWith(
            fontSize: 13,
            height: 1.4,
            color: p.text,
          ),
          labelSmall: base.textTheme.labelSmall?.copyWith(
            fontSize: 12,
            color: p.text,
          ),
          titleLarge: base.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: p.text,
          ),
          headlineSmall: base.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: p.text,
          ),
        );
    final decor = RoyalDecor.fromPalette(p);

    return base.copyWith(
      textTheme: textTheme,
      scaffoldBackgroundColor: p.background,
      canvasColor: scheme.surface,
      dividerColor: p.line,
      extensions: [p, CalendarColors.forPalette(p, brightness), decor],
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: p.background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: p.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleLarge,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.nav,
        surfaceTintColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        height: 72,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 26,
            color: states.contains(WidgetState.selected) ? p.accent : p.text,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontFamilyFallback: AppFonts.fallback,
            fontSize: 13,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w400,
            color: states.contains(WidgetState.selected) ? p.accent : p.text,
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark
            ? Color.alphaBlend(p.card, p.background)
            : Colors.white,
        surfaceTintColor: Colors.transparent,
        dragHandleColor: p.muted,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      cardTheme: CardThemeData(
        color: p.card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: p.line),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          side: WidgetStatePropertyAll(BorderSide(color: p.line)),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) =>
                states.contains(WidgetState.selected) ? p.accent : p.card,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) =>
                states.contains(WidgetState.selected) ? p.onAccent : p.text,
          ),
          iconColor: WidgetStateProperty.resolveWith(
            (states) =>
                states.contains(WidgetState.selected) ? p.onAccent : p.muted,
          ),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(14)),
            ),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: p.card,
        selectedColor: p.accent,
        side: BorderSide(color: p.line),
        labelStyle: TextStyle(
          fontFamilyFallback: AppFonts.fallback,
          color: p.text,
        ),
        secondaryLabelStyle: TextStyle(
          fontFamilyFallback: AppFonts.fallback,
          color: p.onAccent,
        ),
        checkmarkColor: p.onAccent,
        shape: const StadiumBorder(),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: p.accent,
        foregroundColor: p.onAccent,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? p.onAccent : p.muted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? p.accent : p.line,
        ),
      ),
      listTileTheme: ListTileThemeData(iconColor: p.muted),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: p.accent),
    );
  }
}

extension CalendarColorsContext on BuildContext {
  CalendarColors get calendarColors =>
      Theme.of(this).extension<CalendarColors>() ??
      CalendarColors.forPalette(
        AppPalette.of(AppThemeId.khmerLight, Brightness.light),
        Brightness.light,
      );

  RoyalDecor get decor =>
      Theme.of(this).extension<RoyalDecor>() ??
      RoyalDecor.fromPalette(
        AppPalette.of(AppThemeId.khmerLight, Brightness.light),
      );

  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ??
      AppPalette.of(AppThemeId.khmerLight, Brightness.light);
}
