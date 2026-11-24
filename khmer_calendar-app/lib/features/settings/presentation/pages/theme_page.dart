import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/app_settings.dart';
import '../bloc/settings_cubit.dart';

String themeName(AppThemeId id, AppLocalizations l10n) => switch (id) {
  AppThemeId.khmerLight => l10n.themeKhmerLight,
  AppThemeId.khmerNight => l10n.themeKhmerNight,
  AppThemeId.lotus => l10n.themeLotus,
  AppThemeId.green => l10n.themeGreen,
  AppThemeId.sunset => l10n.themeSunset,
  AppThemeId.royal => l10n.themeRoyal,
  AppThemeId.ocean => l10n.themeOcean,
  AppThemeId.pastel => l10n.themePastel,
  AppThemeId.aurora => l10n.themeAurora,
  AppThemeId.kitty => l10n.themeKitty,
  AppThemeId.puppy => l10n.themePuppy,
  AppThemeId.buddha => l10n.themeBuddha,
};

/// Light / Dark / System and the illustrated theme picker.
class ThemePage extends StatelessWidget {
  const ThemePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final p = context.palette;
    final settings = context.watch<SettingsCubit>().state;
    final cubit = context.read<SettingsCubit>();

    Widget mode(
      ThemePreference value,
      IconData icon,
      Color iconColor,
      String title, {
      String? subtitle,
    }) {
      final selected = settings.themePreference == value;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Material(
          color: p.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: selected ? p.accent : p.line),
          ),
          child: ListTile(
            key: Key('theme-mode-${value.name}'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            leading: Icon(icon, color: iconColor, size: 28),
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: subtitle == null
                ? null
                : Text(subtitle, style: TextStyle(color: p.muted)),
            trailing: Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected ? p.accent : p.muted,
            ),
            onTap: () => cubit.setThemePreference(value),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.theme), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          mode(
            ThemePreference.light,
            Icons.wb_sunny_rounded,
            const Color(0xFFF5B800),
            '${l10n.themeLight} ${l10n.themeDefaultSuffix}',
          ),
          mode(
            ThemePreference.dark,
            Icons.dark_mode_rounded,
            p.text,
            l10n.themeDark,
          ),
          mode(
            ThemePreference.system,
            Icons.smartphone_rounded,
            p.text,
            l10n.themeSystem,
            subtitle: l10n.followDevice,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 18, 4, 12),
            child: Text(
              l10n.moreThemes,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: .86,
            children: [
              for (final id in AppThemeId.values)
                _ThemeTile(
                  id: id,
                  name: themeName(id, l10n),
                  isDefault: id == AppThemeId.khmerLight,
                  defaultLabel: l10n.themeDefaultSuffix,
                  selected: settings.themeId == id,
                  onTap: () => cubit.setThemeId(id),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  const _ThemeTile({
    required this.id,
    required this.name,
    required this.isDefault,
    required this.defaultLabel,
    required this.selected,
    required this.onTap,
  });

  final AppThemeId id;
  final String name;
  final bool isDefault;
  final String defaultLabel;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final theme = Theme.of(context);
    return Semantics(
      selected: selected,
      button: true,
      label: name,
      child: InkWell(
        key: Key('theme-tile-${id.code}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 1.4,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected ? p.accent : p.line,
                    width: selected ? 3 : 1,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    SvgPicture.asset(
                      AppPalette.thumbnail(id),
                      fit: BoxFit.cover,
                      excludeFromSemantics: true,
                    ),
                    PositionedDirectional(
                      top: 5,
                      end: 5,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selected ? p.accent : Colors.white24,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: selected
                            ? Icon(
                                Icons.check_rounded,
                                size: 13,
                                color: p.onAccent,
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            if (isDefault)
              Text(
                defaultLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: p.muted,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
