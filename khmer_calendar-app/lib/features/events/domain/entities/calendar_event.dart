import 'package:equatable/equatable.dart';

import '../../../../core/date/civil_date.dart';

enum EventCategory {
  publicHoliday,
  buddhistHolyDay,
  cultural,
  observance,

  /// A category added by the API after this app version shipped.
  other,
}

/// A published calendar event (holiday, observance…). Dates are inclusive.
final class CalendarEvent extends Equatable {
  const CalendarEvent({
    required this.id,
    required this.titleKm,
    required this.titleEn,
    required this.category,
    required this.startDate,
    required this.endDate,
    required this.isDayOff,
    this.descriptionKm,
    this.descriptionEn,
    this.titleZh,
    this.descriptionZh,
  });

  final String id;
  final String titleKm;
  final String titleEn;

  /// Simplified Chinese; null when not translated (UI falls back to English).
  final String? titleZh;
  final String? descriptionKm;
  final String? descriptionEn;
  final String? descriptionZh;
  final EventCategory category;
  final CivilDate startDate;
  final CivilDate endDate;
  final bool isDayOff;

  bool covers(CivilDate date) =>
      !date.isBefore(startDate) && !date.isAfter(endDate);

  bool get isMultiDay => endDate != startDate;

  @override
  List<Object?> get props => [
    id,
    titleKm,
    titleEn,
    titleZh,
    descriptionKm,
    descriptionEn,
    descriptionZh,
    category,
    startDate,
    endDate,
    isDayOff,
  ];
}
