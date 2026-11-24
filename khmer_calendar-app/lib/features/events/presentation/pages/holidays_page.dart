import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/date/date_names.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/royal.dart';
import '../../../../core/widgets/status_views.dart';
import '../../domain/entities/calendar_event.dart';
import '../bloc/holidays_bloc.dart';
import '../widgets/event_style.dart';
import '../widgets/holiday_row.dart';
import '../widgets/next_event_card.dart';

/// Published events of the selected year, grouped by month.
/// Expects a [HolidaysBloc] above it (provided at route level).
class HolidaysPage extends StatelessWidget {
  const HolidaysPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bloc = context.read<HolidaysBloc>();

    Future<void> refresh() {
      final completer = Completer<void>();
      bloc.add(HolidaysRefreshRequested(completer: completer));
      return completer.future;
    }

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: BlocSelector<HolidaysBloc, HolidaysState, int>(
          selector: (state) => state.year,
          builder: (context, year) =>
              Text(l10n.holidaysTitle(context.digits(year))),
        ),
        actions: [
          RoundIconButton(
            tooltip: l10n.previousYear,
            icon: Icons.chevron_left_rounded,
            onPressed: () => bloc.add(const HolidaysYearShifted(-1)),
          ),
          const SizedBox(width: 6),
          RoundIconButton(
            tooltip: l10n.nextYear,
            icon: Icons.chevron_right_rounded,
            onPressed: () => bloc.add(const HolidaysYearShifted(1)),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: BlocBuilder<HolidaysBloc, HolidaysState>(
        builder: (context, state) => switch (state) {
          HolidaysInitial() || HolidaysLoading() => const Center(
            key: Key('holidays-loading'),
            child: CircularProgressIndicator(),
          ),
          HolidaysFailure(:final failure) => FailureView(
            key: const Key('holidays-error'),
            message: failureMessage(l10n, failure),
            onRetry: () => bloc.add(const HolidaysRefreshRequested()),
          ),
          HolidaysEmpty(:final isStale) => RefreshIndicator(
            onRefresh: refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                if (isStale) InfoBanner(message: l10n.offlineBanner),
                SizedBox(
                  height: 320,
                  child: MessageView(
                    key: const Key('holidays-empty'),
                    icon: Icons.event_busy_rounded,
                    message: l10n.noEventsForYear,
                  ),
                ),
              ],
            ),
          ),
          HolidaysSuccess() => RefreshIndicator(
            onRefresh: refresh,
            child: _EventList(state: state),
          ),
        },
      ),
    );
  }
}

class _EventList extends StatefulWidget {
  const _EventList({required this.state});

  final HolidaysSuccess state;

  @override
  State<_EventList> createState() => _EventListState();
}

class _EventListState extends State<_EventList> {
  /// null = all categories.
  EventCategory? _category;

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final decor = context.decor;
    final lang = context.uiLanguage;

    final categories = [
      for (final c in EventCategory.values)
        if (state.events.any((e) => e.category == c)) c,
    ];
    bool visible(CalendarEvent e) =>
        _category == null || e.category == _category;
    final groups =
        state.byMonth.entries
            .map((g) => MapEntry(g.key, g.value.where(visible).toList()))
            .where((g) => g.value.isNotEmpty)
            .toList()
          ..sort((a, b) => a.key.compareTo(b.key));
    final upcoming = state.events
        .where((e) => visible(e) && !e.endDate.isBefore(state.today))
        .toList();
    final next = state.today.year == state.year && upcoming.isNotEmpty
        ? upcoming.first
        : null;

    Widget chip(String label, EventCategory? value) => Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: _category == value,
        showCheckmark: false,
        onSelected: (_) => setState(() => _category = value),
        labelStyle: TextStyle(
          fontFamilyFallback: AppFonts.fallback,
          fontSize: 12.5,
          fontWeight: _category == value ? FontWeight.w600 : FontWeight.w400,
          color: _category == value ? theme.colorScheme.onPrimary : decor.muted,
        ),
        visualDensity: VisualDensity.compact,
      ),
    );

    return CustomScrollView(
      key: const Key('holidays-list'),
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        if (state.isStale)
          SliverToBoxAdapter(
            child: InfoBanner(
              key: const Key('offline-banner'),
              message: l10n.offlineBanner,
            ),
          ),
        if (categories.length > 1)
          SliverToBoxAdapter(
            child: SizedBox(
              height: 48,
              child: ListView(
                key: const Key('holiday-filters'),
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(14, 6, 8, 6),
                children: [
                  chip(l10n.filterAll, null),
                  for (final c in categories)
                    chip(eventCategoryLabel(c, l10n), c),
                ],
              ),
            ),
          ),
        if (next != null)
          SliverToBoxAdapter(
            child: NextEventCard(
              event: next,
              today: state.today,
              margin: const EdgeInsets.fromLTRB(14, 4, 14, 4),
            ),
          ),
        for (final group in groups) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 2),
              child: Text(
                switch (lang) {
                  UiLanguage.km => solarMonthNamesKm[group.key - 1],
                  UiLanguage.en => solarMonthNamesEn[group.key - 1],
                  UiLanguage.zh => '${group.key}月',
                },
                style: theme.textTheme.titleSmall?.copyWith(
                  fontFamilyFallback: AppFonts.fallback,
                  color: decor.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          SliverList.list(
            children: [
              for (final event in group.value)
                HolidayRow(event: event, today: state.today),
            ],
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}
