import '../entities/app_settings.dart';

abstract interface class SettingsRepository {
  /// Synchronous so the first frame already uses the saved language/theme.
  AppSettings load();

  Future<void> save(AppSettings settings);
}
