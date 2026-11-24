import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/date/civil_date.dart';
import '../../core/l10n/l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../features/calendar/presentation/bloc/calendar_bloc.dart';

/// Scaffold with the bottom navigation: Calendar / Events / [Today] / Weather
/// / Tools. The centre button shows today's date and jumps the calendar back
/// to the current month from any tab. It sits inside the bar, so it never
/// covers page content.
///
/// Expects a [CalendarBloc] above it.
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  /// Width of the bar's middle slot, which holds the Today button.
  static const double _centerSlot = 80;

  void _goBranch(int index) => navigationShell.goBranch(
    index,
    initialLocation: index == navigationShell.currentIndex,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = [
      _NavItem(
        icon: Icons.calendar_month_outlined,
        selectedIcon: Icons.calendar_month_rounded,
        label: l10n.navCalendar,
      ),
      _NavItem(
        icon: Icons.event_note_outlined,
        selectedIcon: Icons.event_note_rounded,
        label: l10n.navEvents,
      ),
      _NavItem(
        icon: Icons.wb_cloudy_outlined,
        selectedIcon: Icons.wb_cloudy_rounded,
        label: l10n.navWeather,
      ),
      _NavItem(
        icon: Icons.grid_view_outlined,
        selectedIcon: Icons.grid_view_rounded,
        label: l10n.navTools,
      ),
    ];

    Widget tab(int i) => Expanded(
      child: _NavButton(
        item: items[i],
        selected: navigationShell.currentIndex == i,
        onTap: () => _goBranch(i),
      ),
    );

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _BottomBar(
        children: [
          tab(0),
          tab(1),
          SizedBox(
            width: _centerSlot,
            child: Center(
              child: _TodayButton(
                onPressed: () {
                  context.read<CalendarBloc>().add(
                    const CalendarTodayRequested(),
                  );
                  navigationShell.goBranch(0);
                },
              ),
            ),
          ),
          tab(2),
          tab(3),
        ],
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Material(
      key: const Key('bottom-nav'),
      color: p.nav,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: p.line)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(height: 72, child: Row(children: children)),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final color = selected ? p.accent : p.muted;
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: 36,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selected ? item.selectedIcon : item.icon,
              size: 26,
              color: color,
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  item.label,
                  maxLines: 1,
                  style: TextStyle(
                    fontFamilyFallback: AppFonts.fallback,
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    color: selected ? p.accent : p.text,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Accent circle with "Today" and today's day number.
class _TodayButton extends StatelessWidget {
  const _TodayButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = context.l10n;
    final today = context.select<CalendarBloc, CivilDate>((b) => b.state.today);
    return Semantics(
      button: true,
      label:
          '${l10n.today}, '
          '${formatCivilDate(today, context.uiLanguage, withWeekday: true)}',
      excludeSemantics: true,
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: p.accent.withValues(alpha: .35),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: p.accent,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            key: const Key('today-button'),
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      context.uiLanguage == UiLanguage.en
                          ? l10n.today.toUpperCase()
                          : l10n.today,
                      maxLines: 1,
                      style: TextStyle(
                        fontFamilyFallback: AppFonts.fallback,
                        fontSize: 9.5,
                        height: 1,
                        fontWeight: FontWeight.w600,
                        letterSpacing: .6,
                        color: p.onAccent.withValues(alpha: .9),
                      ),
                    ),
                  ),
                  Text(
                    context.digits(today.day),
                    style: TextStyle(
                      fontFamilyFallback: AppFonts.fallback,
                      fontSize: 21,
                      height: 1.15,
                      fontWeight: FontWeight.w700,
                      color: p.onAccent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
