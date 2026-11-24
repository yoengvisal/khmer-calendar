import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../core/l10n/l10n.dart';
import '../core/theme/app_theme.dart';
import '../features/settings/domain/entities/app_settings.dart';
import '../features/settings/presentation/bloc/settings_cubit.dart';
import 'config/app_config.dart';

class KhmerCalendarApp extends StatelessWidget {
  const KhmerCalendarApp({
    required this.config,
    required this.router,
    required this.createSettingsCubit,
    super.key,
  });

  final AppConfig config;
  final GoRouter router;
  final SettingsCubit Function() createSettingsCubit;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<AppConfig>.value(
      value: config,
      child: BlocProvider<SettingsCubit>(
        create: (_) => createSettingsCubit(),
        child: BlocBuilder<SettingsCubit, AppSettings>(
          builder: (context, settings) => MaterialApp.router(
            onGenerateTitle: (context) => context.l10n.appTitle,
            debugShowCheckedModeBanner: false,
            routerConfig: router,
            theme: AppTheme.light(settings.themeId),
            darkTheme: AppTheme.dark(settings.themeId),
            themeMode: switch (settings.themePreference) {
              ThemePreference.system => ThemeMode.system,
              ThemePreference.light => ThemeMode.light,
              ThemePreference.dark => ThemeMode.dark,
            },
            locale: Locale(settings.language.code),
            supportedLocales: supportedAppLocales,
            localizationsDelegates: appLocalizationsDelegates,
            builder: (context, child) =>
                EnvironmentBanner(flavor: config.flavor, child: child!),
          ),
        ),
      ),
    );
  }
}

/// Corner ribbon on non-production builds so environments are never confused.
class EnvironmentBanner extends StatelessWidget {
  const EnvironmentBanner({
    required this.flavor,
    required this.child,
    super.key,
  });

  final Flavor flavor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (flavor.isProduction) return child;
    return Banner(
      message: flavor == Flavor.dev ? 'DEV' : 'STG',
      location: BannerLocation.topEnd,
      color: flavor == Flavor.dev
          ? const Color(0xFF2E7D32)
          : const Color(0xFFEF6C00),
      child: child,
    );
  }
}
