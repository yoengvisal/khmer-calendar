import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n/l10n.dart';

/// Scaffold with the bottom navigation: Calendar / Events / Weather / Tools.
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.calendar_month_rounded),
            selectedIcon: const Icon(Icons.calendar_month_rounded),
            label: l10n.navCalendar,
          ),
          NavigationDestination(
            icon: const Icon(Icons.event_note_rounded),
            selectedIcon: const Icon(Icons.event_note_rounded),
            label: l10n.navEvents,
          ),
          NavigationDestination(
            icon: const Icon(Icons.wb_cloudy_rounded),
            selectedIcon: const Icon(Icons.wb_cloudy_rounded),
            label: l10n.navWeather,
          ),
          NavigationDestination(
            icon: const Icon(Icons.grid_view_rounded),
            selectedIcon: const Icon(Icons.grid_view_rounded),
            label: l10n.navTools,
          ),
        ],
      ),
    );
  }
}
