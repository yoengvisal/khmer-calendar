import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/date/civil_date.dart';
import '../../core/date/clock.dart';
import '../../features/calendar/domain/entities/year_month.dart';
import '../../features/calendar/presentation/bloc/calendar_bloc.dart';
import '../../features/calendar/presentation/pages/calendar_page.dart';
import '../../features/events/presentation/bloc/holidays_bloc.dart';
import '../../features/events/presentation/pages/events_page.dart';
import '../../features/my_events/presentation/bloc/my_events_cubit.dart';
import '../../features/search/presentation/pages/search_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/tools/presentation/pages/tools_page.dart';
import '../../features/weather/presentation/bloc/weather_cubit.dart';
import '../../features/weather/presentation/pages/weather_page.dart';
import '../di/injection.dart';
import 'app_shell.dart';

abstract final class AppRoutes {
  static const String calendar = '/calendar';
  static const String events = '/events';
  static const String weather = '/weather';
  static const String tools = '/tools';
  static const String settings = '/settings';
}

/// Bottom-navigation shell with one branch per tab. Weather and the user's own
/// events are shared by several tabs, so they are provided around the shell.
GoRouter createAppRouter() => GoRouter(
  initialLocation: AppRoutes.calendar,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => sl<WeatherCubit>()..load()),
          BlocProvider(create: (_) => sl<MyEventsCubit>()),
        ],
        child: AppShell(navigationShell: shell),
      ),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.calendar,
              builder: (context, state) => BlocProvider(
                create: (_) => sl<CalendarBloc>()..add(const CalendarStarted()),
                child: Builder(
                  builder: (context) => CalendarPage(
                    lunar: sl(),
                    onOpenSettings: () => context.push(AppRoutes.settings),
                    onOpenWeather: () =>
                        StatefulNavigationShell.of(context).goBranch(2),
                    onOpenSearch: () => _openSearch(context),
                  ),
                ),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.events,
              builder: (context, state) => BlocProvider(
                create: (_) => sl<HolidaysBloc>()..add(const HolidaysStarted()),
                child: EventsPage(today: sl<Clock>().today()),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.weather,
              builder: (context, state) => const WeatherPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.tools,
              builder: (context, state) => ToolsPage(lunar: sl(), clock: sl()),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsPage(),
    ),
  ],
);

Future<void> _openSearch(BuildContext context) async {
  final myEvents = context.read<MyEventsCubit>();
  final calendar = context.read<CalendarBloc>();
  final date = await Navigator.of(context, rootNavigator: true).push<CivilDate>(
    MaterialPageRoute(
      builder: (_) => BlocProvider.value(
        value: myEvents,
        child: SearchPage(events: sl(), today: sl<Clock>().today()),
      ),
    ),
  );
  if (date != null) calendar.add(CalendarMonthSelected(YearMonth.of(date)));
}
