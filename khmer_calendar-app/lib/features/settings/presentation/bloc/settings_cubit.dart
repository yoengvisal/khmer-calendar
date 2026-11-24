import 'package:bloc/bloc.dart';

import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

/// App-wide language + theme preference, persisted via [SettingsRepository].
class SettingsCubit extends Cubit<AppSettings> {
  SettingsCubit(this._repository) : super(_repository.load());

  final SettingsRepository _repository;

  Future<void> setLanguage(AppLanguage language) =>
      _update(state.copyWith(language: language));

  Future<void> setThemePreference(ThemePreference preference) =>
      _update(state.copyWith(themePreference: preference));

  Future<void> setThemeId(AppThemeId themeId) =>
      _update(state.copyWith(themeId: themeId));

  Future<void> setShowLunarDays(bool value) =>
      _update(state.copyWith(showLunarDays: value));

  Future<void> _update(AppSettings next) async {
    if (next == state) return;
    emit(next);
    await _repository.save(next);
  }
}
