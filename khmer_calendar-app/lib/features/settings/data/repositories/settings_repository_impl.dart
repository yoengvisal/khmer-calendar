import '../../../../core/storage/key_value_store.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._store);

  static const String languageKey = 'settings.language';
  static const String themeKey = 'settings.theme';
  static const String themeIdKey = 'settings.themeId';
  static const String lunarDaysKey = 'settings.showLunarDays';

  final KeyValueStore _store;

  @override
  AppSettings load() => AppSettings(
    language: AppLanguage.fromCode(_store.getString(languageKey)),
    themePreference: ThemePreference.values.firstWhere(
      (t) => t.name == _store.getString(themeKey),
      orElse: () => ThemePreference.light,
    ),
    themeId: AppThemeId.fromCode(_store.getString(themeIdKey)),
    showLunarDays: _store.getString(lunarDaysKey) == 'true',
  );

  @override
  Future<void> save(AppSettings settings) async {
    await _store.setString(languageKey, settings.language.code);
    await _store.setString(themeKey, settings.themePreference.name);
    await _store.setString(themeIdKey, settings.themeId.code);
    await _store.setString(lunarDaysKey, '${settings.showLunarDays}');
  }
}
