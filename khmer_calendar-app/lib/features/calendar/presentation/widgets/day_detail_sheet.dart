import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/royal.dart';
import '../../../events/presentation/widgets/event_row.dart';
import '../../../my_events/domain/entities/personal_event.dart';
import '../../domain/entities/calendar_day.dart';
import '../../domain/lunar/khmer_lunar_calendar.dart';
import '../../domain/lunar/khmer_lunar_constants.dart';
import '../../domain/lunar/khmer_lunar_formatter.dart';

Future<void> showDayDetailSheet(
  BuildContext context,
  CalendarDay day, {
  List<PersonalEvent> personalEvents = const [],
  VoidCallback? onAddEvent,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  useSafeArea: true,
  builder: (_) => DayDetailSheet(
    day: day,
    personalEvents: personalEvents,
    onAddEvent: onAddEvent,
  ),
);

class DayDetailSheet extends StatelessWidget {
  const DayDetailSheet({
    required this.day,
    this.personalEvents = const [],
    this.onAddEvent,
    super.key,
  });

  /// The user's own events on [day] (blue).
  final List<PersonalEvent> personalEvents;

  /// Shows an "Add event" button when set (the sheet closes first).
  final VoidCallback? onAddEvent;

  final CalendarDay day;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final decor = context.decor;
    final colors = context.calendarColors;
    final lang = context.uiLanguage;
    final lunar = day.lunar;

    Widget sectionLabel(String text) => Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: Text(
        text,
        style: theme.textTheme.labelLarge?.copyWith(
          color: decor.muted,
          letterSpacing: 0.6,
        ),
      ),
    );

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.62,
      minChildSize: 0.35,
      maxChildSize: 0.92,
      builder: (context, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: decor.todayGradient,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  context.digits(day.date.day),
                  style: TextStyle(
                    fontFamilyFallback: AppFonts.fallback,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: colors.onTodayFill,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatCivilDate(day.date, lang, withWeekday: true),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontFamilyFallback: AppFonts.fallback,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${KhmerLunarFormatter.dayLabel(lunar, lang)} · '
                      '${_monthLabel(lunar, lang)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: decor.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          sectionLabel(l10n.lunarDate),
          RoyalCard(
            child: Row(
              children: [
                MoonPhaseIcon.forLunarDay(
                  lunar.moonPhase.index * 15 + lunar.day - 1,
                  size: 48,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableText(
                        KhmerLunarFormatter.formatKm(lunar),
                        key: const Key('formatted-km'),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                        ),
                      ),
                      if (lang != UiLanguage.km) ...[
                        const SizedBox(height: 4),
                        Text(
                          KhmerLunarFormatter.format(lunar, lang),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: decor.muted,
                            height: 1.5,
                          ),
                        ),
                      ],
                      if (day.isHolyDay) ...[
                        const SizedBox(height: 8),
                        TagBadge(
                          label: l10n.holyDay,
                          icon: Icons.brightness_3_rounded,
                          color: colors.holyDay,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          sectionLabel(l10n.dayDetailEvents),
          for (final mine in personalEvents)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colors.myEvent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mine.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (mine.note != null)
                          Text(
                            mine.note!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: decor.muted,
                            ),
                          ),
                        const SizedBox(height: 4),
                        TagBadge(
                          label: l10n.legendMyEvent,
                          color: colors.myEvent,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          if (day.events.isEmpty && personalEvents.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                l10n.dayDetailNoEvents,
                style: theme.textTheme.bodyMedium?.copyWith(color: decor.muted),
              ),
            )
          else
            for (final event in day.events) EventRow(event: event),
          if (onAddEvent != null) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              key: const Key('day-add-event'),
              onPressed: () {
                Navigator.of(context).pop();
                onAddEvent!();
              },
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.addEvent),
            ),
          ],
        ],
      ),
    );
  }

  static String _monthLabel(KhmerLunarDate lunar, UiLanguage lang) =>
      switch (lang) {
        UiLanguage.km => 'ខែ${lunarMonthNamesKm[lunar.month.index]}',
        UiLanguage.en => lunarMonthNamesEn[lunar.month.index],
        UiLanguage.zh => KhmerLunarFormatter.monthLabelZh(lunar.month.index),
      };
}
