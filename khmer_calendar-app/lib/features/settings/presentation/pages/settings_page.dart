import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/config/app_config.dart';
import '../../../../app/config/app_version.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/brand_logo.dart';
import '../../../../core/widgets/royal.dart';
import '../../domain/entities/app_settings.dart';
import '../bloc/settings_cubit.dart';
import 'theme_page.dart';

/// Language + theme preferences and app info. Reads [SettingsCubit] and the
/// [AppConfig] provided (via RepositoryProvider) at the app root.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final config = context.read<AppConfig>();
    final settings = context.watch<SettingsCubit>().state;
    final cubit = context.read<SettingsCubit>();

    final decor = context.decor;
    Widget section(String title) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 8),
      child: Text(
        title,
        style: theme.textTheme.labelLarge?.copyWith(
          color: decor.muted,
          letterSpacing: 0.6,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(titleSpacing: 20, title: Text(l10n.settingsTitle)),
      body: ListView(
        children: [
          section(l10n.language),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<AppLanguage>(
              key: const Key('language-selector'),
              segments: [
                ButtonSegment(
                  value: AppLanguage.khmer,
                  label: Text(l10n.languageKhmer),
                ),
                ButtonSegment(
                  value: AppLanguage.english,
                  label: Text(l10n.languageEnglish),
                ),
                ButtonSegment(
                  value: AppLanguage.chinese,
                  label: Text(l10n.languageChinese),
                ),
              ],
              selected: {settings.language},
              onSelectionChanged: (s) => cubit.setLanguage(s.first),
            ),
          ),
          section(l10n.theme),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: ListTile(
                key: const Key('theme-selector'),
                leading: Icon(Icons.palette_rounded, color: decor.accent),
                title: Text(themeName(settings.themeId, l10n)),
                subtitle: Text(switch (settings.themePreference) {
                  ThemePreference.light => l10n.themeLight,
                  ThemePreference.dark => l10n.themeDark,
                  ThemePreference.system => l10n.themeSystem,
                }),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => BlocProvider.value(
                      value: cubit,
                      child: const ThemePage(),
                    ),
                  ),
                ),
              ),
            ),
          ),
          section(l10n.display),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: SwitchListTile(
                key: const Key('lunar-days-switch'),
                title: Text(l10n.showLunarDays),
                value: settings.showLunarDays,
                onChanged: cubit.setShowLunarDays,
              ),
            ),
          ),
          section(l10n.about),
          RoyalCard(
            key: const Key('brand-header'),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const BrandLogo(size: 52),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.appTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontFamilyFallback: AppFonts.fallback,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${l10n.appVersion} $appVersion',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: decor.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (!config.flavor.isProduction)
            RoyalCard(
              key: const Key('environment-tile'),
              margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Row(
                children: [
                  Icon(Icons.dns_rounded, color: decor.muted),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.environment),
                        Text(
                          '${config.flavor.envName} · ${config.apiBaseUrl}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: decor.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
