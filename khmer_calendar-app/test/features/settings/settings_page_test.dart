import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khmer_calendar/app/config/app_config.dart';
import 'package:khmer_calendar/app/config/app_version.dart';
import 'package:khmer_calendar/core/storage/key_value_store.dart';
import 'package:khmer_calendar/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:khmer_calendar/features/settings/domain/entities/app_settings.dart';
import 'package:khmer_calendar/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:khmer_calendar/features/settings/presentation/pages/settings_page.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/pump_app.dart';

void main() {
  Future<SettingsCubit> pump(WidgetTester tester, Flavor flavor) async {
    final cubit = SettingsCubit(
      SettingsRepositoryImpl(InMemoryKeyValueStore()),
    );
    await pumpLocalized(
      tester,
      RepositoryProvider.value(
        value: AppConfig(
          flavor: flavor,
          apiBaseUrl: 'https://api.example.com/api/v1',
        ),
        child: BlocProvider.value(value: cubit, child: const SettingsPage()),
      ),
    );
    return cubit;
  }

  testWidgets('shows version and environment on non-production', (
    tester,
  ) async {
    await pump(tester, Flavor.staging);
    expect(find.textContaining(appVersion), findsOneWidget);
    expect(find.byKey(const Key('environment-tile')), findsOneWidget);
  });

  testWidgets('hides environment on production', (tester) async {
    await pump(tester, Flavor.production);
    expect(find.byKey(const Key('environment-tile')), findsNothing);
  });

  testWidgets('changing language/theme updates the cubit', (tester) async {
    final cubit = await pump(tester, Flavor.dev);
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(cubit.state.language, AppLanguage.english);

    // Theme lives on its own page: Light / Dark / System + illustrated themes.
    await tester.tap(find.byKey(const Key('theme-selector')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('theme-mode-dark')));
    await tester.pump();
    expect(cubit.state.themePreference, ThemePreference.dark);

    await tester.scrollUntilVisible(
      find.byKey(const Key('theme-tile-lotus')),
      100,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.byKey(const Key('theme-tile-lotus')));
    await tester.pump();
    expect(cubit.state.themeId, AppThemeId.lotus);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('lunar-days-switch')),
      100,
    );
    await tester.tap(find.byKey(const Key('lunar-days-switch')));
    await tester.pump();
    expect(cubit.state.showLunarDays, isTrue);
  });

  testWidgets('offers Khmer, English and Chinese and can select Chinese', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640); // small phone
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final cubit = await pump(tester, Flavor.production);
    expect(find.text('ខ្មែរ'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('中文'), findsOneWidget);
    await tester.tap(find.text('中文'));
    await tester.pump();
    expect(cubit.state.language, AppLanguage.chinese);
  });
}
