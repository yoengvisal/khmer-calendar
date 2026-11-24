import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khmer_calendar/core/storage/key_value_store.dart';
import 'package:khmer_calendar/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:khmer_calendar/features/settings/domain/entities/app_settings.dart';
import 'package:khmer_calendar/features/settings/presentation/bloc/settings_cubit.dart';

void main() {
  late InMemoryKeyValueStore store;

  setUp(() => store = InMemoryKeyValueStore());

  test('defaults to Khmer + system theme', () {
    expect(
      SettingsCubit(SettingsRepositoryImpl(store)).state,
      const AppSettings(),
    );
  });

  blocTest<SettingsCubit, AppSettings>(
    'persists language and theme changes',
    build: () => SettingsCubit(SettingsRepositoryImpl(store)),
    act: (cubit) async {
      await cubit.setLanguage(AppLanguage.english);
      await cubit.setThemePreference(ThemePreference.dark);
      await cubit.setThemeId(AppThemeId.lotus);
    },
    expect: () => const [
      AppSettings(language: AppLanguage.english),
      AppSettings(
        language: AppLanguage.english,
        themePreference: ThemePreference.dark,
      ),
      AppSettings(
        language: AppLanguage.english,
        themePreference: ThemePreference.dark,
        themeId: AppThemeId.lotus,
      ),
    ],
    verify: (_) {
      final reloaded = SettingsRepositoryImpl(store).load();
      expect(reloaded.language, AppLanguage.english);
      expect(reloaded.themePreference, ThemePreference.dark);
      expect(reloaded.themeId, AppThemeId.lotus);
    },
  );

  test('ignores unknown persisted values', () {
    store.values
      ..[SettingsRepositoryImpl.languageKey] = 'fr'
      ..[SettingsRepositoryImpl.themeKey] = 'neon';
    expect(SettingsRepositoryImpl(store).load(), const AppSettings());
  });

  test('defaults to Khmer, Light mode and the Khmer Light theme', () {
    final settings = SettingsRepositoryImpl(store).load();
    expect(settings.language, AppLanguage.khmer);
    expect(settings.themePreference, ThemePreference.light);
    expect(settings.themeId, AppThemeId.khmerLight);
    expect(settings.showLunarDays, isFalse);
  });
}
