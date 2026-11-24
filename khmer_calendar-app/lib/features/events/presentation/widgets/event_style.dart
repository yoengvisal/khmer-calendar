import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/calendar_event.dart';

/// Presentation helpers shared by the calendar and holidays screens.
extension CalendarEventPresentation on CalendarEvent {
  /// Title in the UI language; Chinese falls back to English when missing.
  String localizedTitle(BuildContext context) => switch (context.uiLanguage) {
    UiLanguage.km => titleKm,
    UiLanguage.en => titleEn,
    UiLanguage.zh => _nonBlank(titleZh) ?? titleEn,
  };

  String? localizedDescription(BuildContext context) =>
      switch (context.uiLanguage) {
        UiLanguage.km => descriptionKm,
        UiLanguage.en => descriptionEn,
        UiLanguage.zh => _nonBlank(descriptionZh) ?? descriptionEn,
      };

  String categoryLabel(AppLocalizations l10n) =>
      eventCategoryLabel(category, l10n);

  /// Day-off holidays are red; everything else uses the event color.
  Color markerColor(BuildContext context) {
    final colors = context.calendarColors;
    return isDayOff ? colors.holiday : colors.event;
  }

  IconData get categoryIcon => switch (category) {
    EventCategory.publicHoliday => Icons.flag_rounded,
    EventCategory.buddhistHolyDay => Icons.temple_buddhist_rounded,
    EventCategory.cultural => Icons.celebration_rounded,
    EventCategory.observance => Icons.event_note_rounded,
    EventCategory.other => Icons.event_rounded,
  };
}

String? _nonBlank(String? value) =>
    value == null || value.trim().isEmpty ? null : value;

/// Localized name of an [EventCategory].
String eventCategoryLabel(EventCategory category, AppLocalizations l10n) =>
    switch (category) {
      EventCategory.publicHoliday => l10n.categoryPublicHoliday,
      EventCategory.buddhistHolyDay => l10n.categoryBuddhistHolyDay,
      EventCategory.cultural => l10n.categoryCultural,
      EventCategory.observance => l10n.categoryObservance,
      EventCategory.other => l10n.categoryOther,
    };
