import 'package:material_ui/material_ui.dart';

import '../../../../core/date/civil_date.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/royal.dart';
import '../../domain/entities/calendar_event.dart';
import 'event_style.dart';

/// "Next holiday" card with a countdown badge.
class NextEventCard extends StatelessWidget {
  const NextEventCard({
    required this.event,
    required this.today,
    this.margin = const EdgeInsets.fromLTRB(14, 10, 14, 0),
    super.key,
  });

  final CalendarEvent event;
  final CivilDate today;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final decor = context.decor;
    final days = today.daysUntil(event.startDate);
    final countdown = switch (days) {
      < 0 => l10n.ongoing,
      0 => l10n.today,
      1 => l10n.tomorrow,
      _ => l10n.inDays(context.digits(days)),
    };

    return RoyalCard(
      key: const Key('next-event-card'),
      margin: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.nextHoliday,
            style: theme.textTheme.labelMedium?.copyWith(
              color: decor.muted,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            event.localizedTitle(context),
            style: theme.textTheme.titleMedium?.copyWith(
              fontFamilyFallback: AppFonts.fallback,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  formatDateRange(
                    event.startDate,
                    event.endDate,
                    context.uiLanguage,
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: decor.muted,
                  ),
                ),
              ),
              TagBadge(
                label: countdown,
                color: event.isDayOff ? context.calendarColors.holiday : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
