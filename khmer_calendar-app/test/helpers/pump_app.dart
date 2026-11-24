import 'package:flutter_test/flutter_test.dart';
import 'package:khmer_calendar/core/l10n/l10n.dart';
import 'package:khmer_calendar/core/theme/app_theme.dart';
import 'package:material_ui/material_ui.dart';

/// Pumps [child] inside a localized, themed MaterialApp.
Future<void> pumpLocalized(
  WidgetTester tester,
  Widget child, {
  Locale locale = const Locale('en'),
}) => tester.pumpWidget(
  MaterialApp(
    locale: locale,
    supportedLocales: supportedAppLocales,
    localizationsDelegates: appLocalizationsDelegates,
    theme: AppTheme.light(),
    home: child,
  ),
);
