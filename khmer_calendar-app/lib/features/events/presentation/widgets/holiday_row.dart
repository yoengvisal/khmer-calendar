import 'package:material_ui/material_ui.dart';

import '../../../../core/date/civil_date.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/royal.dart';
import '../../domain/entities/calendar_event.dart';
import 'event_style.dart';

/// Holidays-list row: date tile, title, dates · length · category.
class HolidayRow extends StatelessWidget {
  const HolidayRow({required this.event, this.today, super.key});

  final CalendarEvent event;

  /// When set, events that ended before [today] are dimmed.
  final CivilDate? today;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final decor = context.decor;
    final colors = context.calendarColors;
    final isPast = today != null && event.endDate.isBefore(today!);
    final days = event.startDate.daysUntil(event.endDate) + 1;
    final start = event.startDate;

    final subtitle = [
      formatDateRange(event.startDate, event.endDate, context.uiLanguage),
      if (event.isMultiDay) l10n.eventDays(days),
      event.categoryLabel(l10n),
      if (isPast) l10n.pastEvent,
    ].join(' · ');

    return Opacity(
      opacity: isPast ? 0.5 : 1,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: decor.line)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: decor.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: decor.line),
              ),
              child: Column(
                children: [
                  Text(
                    context.digits(start.day),
                    style: TextStyle(
                      fontFamilyFallback: AppFonts.fallback,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                      color: event.isDayOff
                          ? colors.holiday
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    weekdayShortLabels(context.uiLanguage)[start.dayOfWeek],
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: decor.muted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.localizedTitle(context),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: decor.muted,
                    ),
                  ),
                ],
              ),
            ),
            if (event.isDayOff) ...[
              const SizedBox(width: 8),
              TagBadge(label: l10n.dayOff, color: colors.holiday),
            ],
          ],
        ),
      ),
    );
  }
}
