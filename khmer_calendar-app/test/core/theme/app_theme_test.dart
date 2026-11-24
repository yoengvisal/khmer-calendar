import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khmer_calendar/core/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every theme has light and dark palettes with readable accents', () {
    for (final id in AppThemeId.values) {
      for (final b in Brightness.values) {
        final theme = AppTheme.build(id, b);
        final p = theme.extension<AppPalette>()!;
        expect(theme.brightness, b);
        // Today chip text on accent must be readable (WCAG AA for large text).
        expect(
          _contrast(p.accent, p.onAccent),
          greaterThan(3),
          reason: '$id $b',
        );
        expect(
          _contrast(Color.alphaBlend(p.card, p.background), p.text),
          greaterThan(7),
          reason: '$id $b',
        );
      }
    }
  });

  test('every scene asset exists', () async {
    for (final id in AppThemeId.values) {
      for (final b in Brightness.values) {
        final svg = await rootBundle.loadString(AppPalette.of(id, b).scene);
        expect(svg, startsWith('<svg'));
      }
    }
  });

  test('theme codes round-trip and default to Khmer Light', () {
    for (final id in AppThemeId.values) {
      expect(AppThemeId.fromCode(id.code), id);
    }
    expect(AppThemeId.fromCode('unknown'), AppThemeId.khmerLight);
  });
}

double _contrast(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  return (la > lb ? la + .05 : lb + .05) / (la > lb ? lb + .05 : la + .05);
}
