import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/royal.dart';
import '../../domain/entities/calendar_event.dart';
import 'event_style.dart';

/// Event line used in the day sheet: color bar, title, dates and tags.
class EventRow extends StatelessWidget {
  const EventRow({required this.event, super.key});

  final CalendarEvent event;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final decor = context.decor;
    final colors = context.calendarColors;
    final days = event.startDate.daysUntil(event.endDate) + 1;
    final description = event.localizedDescription(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: event.markerColor(context),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.localizedTitle(context),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [
                      formatDateRange(
                        event.startDate,
                        event.endDate,
                        context.uiLanguage,
                      ),
                      if (event.isMultiDay) l10n.eventDays(days),
                    ].join(' · '),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: decor.muted,
                    ),
                  ),
                  if (description != null && description.trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        description,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      TagBadge(
                        label: event.categoryLabel(l10n),
                        icon: event.categoryIcon,
                      ),
                      if (event.isDayOff)
                        TagBadge(label: l10n.dayOff, color: colors.holiday),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
