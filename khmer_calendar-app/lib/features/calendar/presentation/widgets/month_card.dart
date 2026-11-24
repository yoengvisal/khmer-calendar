import 'package:material_ui/material_ui.dart';

import '../../../../core/date/civil_date.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../events/domain/entities/calendar_event.dart';
import '../../../my_events/domain/entities/personal_event.dart';
import '../../domain/entities/calendar_day.dart';
import '../../domain/entities/calendar_month.dart';
import '../../domain/entities/year_month.dart';
import '../../domain/lunar/khmer_lunar_formatter.dart';

/// Monday-first month card: navigation, weekday header, day grid with
/// coloured dots, and the legend.
class MonthCard extends StatelessWidget {
  const MonthCard({
    required this.visibleMonth,
    required this.month,
    required this.today,
    required this.personalEvents,
    required this.showLunarDays,
    required this.onPrevious,
    required this.onNext,
    required this.onPickMonth,
    required this.onDayTap,
    super.key,
  });

  final YearMonth visibleMonth;

  /// Null while loading.
  final CalendarMonth? month;
  final CivilDate today;
  final List<PersonalEvent> personalEvents;
  final bool showLunarDays;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onPickMonth;
  final ValueChanged<CalendarDay> onDayTap;

  static const double rowHeight = 44;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final p = context.palette;
    final lang = context.uiLanguage;
    final labels = weekdayShortLabels(lang);
    // Monday-first order of Sunday-first labels.
    final mondayFirst = [...labels.sublist(1), labels.first];

    return Card(
      key: const Key('month-card'),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6, 4, 6, 10),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: l10n.previousMonth,
                  icon: const Icon(Icons.chevron_left_rounded),
                  onPressed: onPrevious,
                ),
                Expanded(
                  child: TextButton(
                    onPressed: onPickMonth,
                    style: TextButton.styleFrom(foregroundColor: p.text),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            formatMonthYear(
                              visibleMonth.year,
                              visibleMonth.month,
                              lang,
                            ),
                            key: const Key('month-title'),
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontSize: 20,
                            ),
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down_rounded),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  tooltip: l10n.nextMonth,
                  icon: const Icon(Icons.chevron_right_rounded),
                  onPressed: onNext,
                ),
              ],
            ),
            Row(
              children: [
                for (var i = 0; i < 7; i++)
                  Expanded(
                    child: Center(
                      child: Text(
                        mondayFirst[i],
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: i == 5
                              ? p.saturday
                              : i == 6
                              ? p.sunday
                              : p.text,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            if (month == null)
              const SizedBox(
                key: Key('calendar-loading'),
                height: rowHeight * 6,
                child: Center(child: CircularProgressIndicator()),
              )
            else
              _Grid(
                month: month!,
                today: today,
                personalEvents: personalEvents,
                showLunarDays: showLunarDays,
                onDayTap: onDayTap,
              ),
            const SizedBox(height: 8),
            const _Legend(),
          ],
        ),
      ),
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({
    required this.month,
    required this.today,
    required this.personalEvents,
    required this.showLunarDays,
    required this.onDayTap,
  });

  final CalendarMonth month;
  final CivilDate today;
  final List<PersonalEvent> personalEvents;
  final bool showLunarDays;
  final ValueChanged<CalendarDay> onDayTap;

  @override
  Widget build(BuildContext context) {
    final first = month.days.first.date;
    final leading = (first.dayOfWeek + 6) % 7; // Monday-first
    final total = ((leading + month.days.length) / 7).ceil() * 7;
    final mine = <CivilDate, int>{};
    for (final e in personalEvents) {
      mine[e.date] = (mine[e.date] ?? 0) + 1;
    }

    return Column(
      children: [
        for (var row = 0; row < total ~/ 7; row++)
          SizedBox(
            height: showLunarDays
                ? MonthCard.rowHeight + 10
                : MonthCard.rowHeight,
            child: Row(
              children: [
                for (var col = 0; col < 7; col++)
                  Expanded(
                    child: _cell(
                      context,
                      row * 7 + col - leading,
                      col,
                      first,
                      mine,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _cell(
    BuildContext context,
    int index,
    int col,
    CivilDate first,
    Map<CivilDate, int> mine,
  ) {
    final p = context.palette;
    final theme = Theme.of(context);
    final date = first.addDays(index);
    final inMonth = index >= 0 && index < month.days.length;
    final numberStyle = theme.textTheme.titleMedium?.copyWith(
      fontSize: 18,
      fontWeight: FontWeight.w500,
    );

    if (!inMonth) {
      return Center(
        child: Text(
          context.digits(date.day),
          style: numberStyle?.copyWith(
            color: (col == 6 ? p.sunday : p.muted).withValues(alpha: .55),
            fontWeight: FontWeight.w400,
          ),
        ),
      );
    }

    final day = month.days[index];
    final isToday = day.date == today;
    final colors = context.calendarColors;
    final dots = <Color>[
      if (day.events.any(
        (e) => e.isDayOff || e.category == EventCategory.publicHoliday,
      ))
        colors.holiday,
      if (day.isHolyDay ||
          day.events.any(
            (e) => !e.isDayOff && e.category == EventCategory.buddhistHolyDay,
          ))
        colors.holyDay,
      if ((mine[day.date] ?? 0) > 0) colors.myEvent,
      if (day.events.any(
        (e) =>
            !e.isDayOff &&
            (e.category == EventCategory.cultural ||
                e.category == EventCategory.observance ||
                e.category == EventCategory.other),
      ))
        colors.otherEvent,
    ];
    final fg = isToday ? p.onAccent : (col == 6 ? p.sunday : p.text);

    return Semantics(
      button: true,
      label: [
        formatCivilDate(day.date, context.uiLanguage, withWeekday: true),
        KhmerLunarFormatter.dayLabel(day.lunar, context.uiLanguage),
      ].join(', '),
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Material(
          color: isToday ? p.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            key: ValueKey('day-${day.date.toIso()}'),
            borderRadius: BorderRadius.circular(12),
            onTap: () => onDayTap(day),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  context.digits(day.date.day),
                  style: numberStyle?.copyWith(
                    color: fg,
                    fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                if (showLunarDays)
                  Text(
                    KhmerLunarFormatter.dayLabel(day.lunar, context.uiLanguage),
                    key: const Key('cell-lunar-label'),
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 10,
                      height: 1.1,
                      color: isToday ? p.onAccent : p.muted,
                    ),
                  ),
                SizedBox(
                  height: 7,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (final c in dots.take(3))
                        Container(
                          width: 5,
                          height: 5,
                          margin: const EdgeInsets.only(
                            top: 2,
                            left: 1,
                            right: 1,
                          ),
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: isToday
                                ? Border.all(color: p.onAccent, width: .6)
                                : null,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.calendarColors;
    final style = Theme.of(context).textTheme.bodySmall
        ?.copyWith(fontSize: 11.5);
    Widget item(Color c, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: c, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: style),
      ],
    );
    // One line like the design; shrinks slightly for long translations.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          children: [
            item(colors.holiday, l10n.legendPublicHoliday),
            const SizedBox(width: 12),
            item(colors.holyDay, l10n.legendBuddhistDay),
            const SizedBox(width: 12),
            item(colors.myEvent, l10n.legendMyEvent),
            const SizedBox(width: 12),
            item(colors.otherEvent, l10n.legendOtherEvent),
          ],
        ),
      ),
    );
  }
}
