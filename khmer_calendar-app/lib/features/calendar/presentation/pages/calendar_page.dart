import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/brand_logo.dart';
import '../../../../core/widgets/status_views.dart';
import '../../../my_events/domain/entities/personal_event.dart';
import '../../../my_events/presentation/bloc/my_events_cubit.dart';
import '../../../my_events/presentation/widgets/personal_event_editor.dart';
import '../../../settings/presentation/bloc/settings_cubit.dart';
import '../../../weather/presentation/widgets/weather_card.dart';
import '../../domain/entities/calendar_day.dart';
import '../../domain/entities/calendar_month.dart';
import '../../domain/entities/year_month.dart';
import '../../domain/lunar/khmer_lunar_calendar.dart';
import '../bloc/calendar_bloc.dart';
import '../widgets/day_detail_sheet.dart';
import '../widgets/month_card.dart';
import '../widgets/today_card.dart';

/// Home: illustrated header, Today card, the month card, then weather.
/// Expects [CalendarBloc], [MyEventsCubit] and [SettingsCubit] above it
/// (and a WeatherCubit for the weather card).
class CalendarPage extends StatelessWidget {
  const CalendarPage({
    required this.lunar,
    this.onOpenSettings,
    this.onOpenSearch,
    this.onOpenWeather,
    super.key,
  });

  final KhmerLunarCalendar lunar;
  final VoidCallback? onOpenSettings;
  final VoidCallback? onOpenSearch;
  final VoidCallback? onOpenWeather;

  static const double _sceneHeight = 262;
  static const double _sceneLift = .15;
  static const double _swipeVelocity = 250;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final topInset = MediaQuery.paddingOf(context).top;
    final bloc = context.read<CalendarBloc>();
    final showLunarDays = context.select<SettingsCubit, bool>(
      (c) => c.state.showLunarDays,
    );

    void openDay(CalendarDay day, List<PersonalEvent> mine) =>
        showDayDetailSheet(
          context,
          day,
          personalEvents: mine.where((e) => e.date == day.date).toList(),
          onAddEvent: () =>
              showPersonalEventEditor(context, initialDate: day.date),
        );

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            // Shifted up by 15% of its height so the artwork sits above the
            // cards instead of behind them.
            top: -(_sceneHeight + topInset) * _sceneLift,
            height: _sceneHeight + topInset,
            child: _Scene(asset: p.scene, fadeTo: p.background),
          ),
          BlocBuilder<CalendarBloc, CalendarState>(
            builder: (context, state) {
              final month = state.month;
              final todayDay =
                  _findDay(month, state) ??
                  CalendarDay(
                    date: state.today,
                    lunar: lunar.toLunar(state.today),
                  );
              return BlocBuilder<MyEventsCubit, List<PersonalEvent>>(
                builder: (context, mine) => GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onHorizontalDragEnd: (details) {
                    final v = details.primaryVelocity ?? 0;
                    if (v < -_swipeVelocity) {
                      bloc.add(const CalendarMonthShifted(1));
                    }
                    if (v > _swipeVelocity) {
                      bloc.add(const CalendarMonthShifted(-1));
                    }
                  },
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(14, topInset + 6, 14, 24),
                    children: [
                      _Header(
                        title: l10n.appTitle,
                        subtitle: context.uiLanguage == UiLanguage.km
                            ? 'Khmer Calendar'
                            : 'ប្រតិទិនខ្មែរ',
                        onSearch: onOpenSearch,
                        onSettings: onOpenSettings,
                      ),
                      const SizedBox(height: 86),
                      TodayCard(
                        day: todayDay,
                        // Back to this month first; then show the day's details.
                        onTap: state.isShowingToday
                            ? () => openDay(todayDay, mine)
                            : () => bloc.add(const CalendarTodayRequested()),
                      ),
                      const SizedBox(height: 10),
                      if (month != null) _EventsStatusBanner(month: month),
                      MonthCard(
                        visibleMonth: state.visibleMonth,
                        month: state.status == CalendarStatus.success
                            ? month
                            : null,
                        today: state.today,
                        personalEvents: mine,
                        showLunarDays: showLunarDays,
                        onPrevious: () =>
                            bloc.add(const CalendarMonthShifted(-1)),
                        onNext: () => bloc.add(const CalendarMonthShifted(1)),
                        onPickMonth: () =>
                            _pickMonth(context, state.visibleMonth),
                        onDayTap: (day) => openDay(day, mine),
                      ),
                      // Weather is secondary: below the month.
                      const SizedBox(height: 10),
                      WeatherCard(onTap: onOpenWeather),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  static CalendarDay? _findDay(CalendarMonth? month, CalendarState state) {
    if (month == null || !state.isShowingToday) return null;
    for (final d in month.days) {
      if (d.date == state.today) return d;
    }
    return null;
  }

  Future<void> _pickMonth(BuildContext context, YearMonth current) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(current.year, current.month),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100, 12, 31),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null && context.mounted) {
      context.read<CalendarBloc>().add(
        CalendarMonthSelected(YearMonth(picked.year, picked.month)),
      );
    }
  }
}

class _Scene extends StatelessWidget {
  const _Scene({required this.asset, required this.fadeTo});

  final String asset;
  final Color fadeTo;

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      SvgPicture.asset(
        asset,
        key: ValueKey(asset),
        fit: BoxFit.cover,
        alignment: Alignment.bottomCenter,
        excludeFromSemantics: true,
      ),
      DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [fadeTo.withValues(alpha: 0), fadeTo],
            stops: const [.72, 1],
          ),
        ),
      ),
    ],
  );
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.subtitle,
    this.onSearch,
    this.onSettings,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onSearch;
  final VoidCallback? onSettings;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = context.l10n;
    Widget round(IconData icon, String tooltip, VoidCallback? onTap, Key key) =>
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 10),
          child: Material(
            color: p.glass,
            shape: const CircleBorder(),
            child: IconButton(
              key: key,
              tooltip: tooltip,
              onPressed: onTap,
              icon: Icon(icon, color: p.text),
            ),
          ),
        );
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: const BrandLogo(size: 50),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamilyFallback: AppFonts.fallback,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: p.headerText,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontFamilyFallback: AppFonts.fallback,
                  fontSize: 14,
                  color: p.headerText.withValues(alpha: .9),
                ),
              ),
            ],
          ),
        ),
        round(
          Icons.search_rounded,
          l10n.search,
          onSearch,
          const Key('search-button'),
        ),
        round(
          Icons.settings_rounded,
          l10n.navSettings,
          onSettings,
          const Key('settings-button'),
        ),
      ],
    );
  }
}

class _EventsStatusBanner extends StatelessWidget {
  const _EventsStatusBanner({required this.month});

  final CalendarMonth month;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final banner = switch (month.eventsAvailability) {
      EventsAvailability.live => null,
      EventsAvailability.cached => InfoBanner(message: l10n.offlineBanner),
      EventsAvailability.unavailable => InkWell(
        onTap: () =>
            context.read<CalendarBloc>().add(const CalendarRefreshRequested()),
        child: InfoBanner(
          message: '${l10n.eventsUnavailableBanner} ${l10n.retry}',
          icon: Icons.sync_problem_rounded,
        ),
      ),
    };
    if (banner == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(borderRadius: BorderRadius.circular(14), child: banner),
    );
  }
}
