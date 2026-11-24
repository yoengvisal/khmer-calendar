import '../../../../core/date/civil_date.dart';
import '../../domain/entities/calendar_event.dart';

/// Wire model for the API `Event` / `EventSummary`. Unknown fields are ignored
/// (additive API changes are non-breaking).
final class EventDto {
  const EventDto({
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

  /// Throws [FormatException] on a malformed payload.
  factory EventDto.fromJson(Map<String, dynamic> json) {
    T field<T>(String key) {
      final value = json[key];
      if (value is T) return value;
      throw FormatException('Event.$key has unexpected type', value);
    }

    final dto = EventDto(
      id: field<String>('id'),
      titleKm: field<String>('titleKm'),
      titleEn: field<String>('titleEn'),
      // Optional: absent in older API versions and older cached payloads.
      titleZh: field<String?>('titleZh'),
      descriptionKm: field<String?>('descriptionKm'),
      descriptionEn: field<String?>('descriptionEn'),
      descriptionZh: field<String?>('descriptionZh'),
      category: field<String>('category'),
      startDate: field<String>('startDate'),
      endDate: field<String>('endDate'),
      isDayOff: field<bool>('isDayOff'),
    );
    // Validate dates eagerly so bad rows fail here, not in the UI.
    final start = CivilDate.parse(dto.startDate);
    final end = CivilDate.parse(dto.endDate);
    if (end.isBefore(start)) {
      throw FormatException('Event.endDate before startDate', dto.id);
    }
    return dto;
  }

  final String id;
  final String titleKm;
  final String titleEn;
  final String? titleZh;
  final String? descriptionKm;
  final String? descriptionEn;
  final String? descriptionZh;
  final String category;
  final String startDate;
  final String endDate;
  final bool isDayOff;

  Map<String, dynamic> toJson() => {
    'id': id,
    'titleKm': titleKm,
    'titleEn': titleEn,
    'titleZh': titleZh,
    'descriptionKm': descriptionKm,
    'descriptionEn': descriptionEn,
    'descriptionZh': descriptionZh,
    'category': category,
    'startDate': startDate,
    'endDate': endDate,
    'isDayOff': isDayOff,
  };

  CalendarEvent toEntity() => CalendarEvent(
    id: id,
    titleKm: titleKm,
    titleEn: titleEn,
    titleZh: titleZh,
    descriptionKm: descriptionKm,
    descriptionEn: descriptionEn,
    descriptionZh: descriptionZh,
    category: switch (category) {
      'PUBLIC_HOLIDAY' => EventCategory.publicHoliday,
      'BUDDHIST_HOLY_DAY' => EventCategory.buddhistHolyDay,
      'CULTURAL' => EventCategory.cultural,
      'OBSERVANCE' => EventCategory.observance,
      _ => EventCategory.other,
    },
    startDate: CivilDate.parse(startDate),
    endDate: CivilDate.parse(endDate),
    isDayOff: isDayOff,
  );
}
