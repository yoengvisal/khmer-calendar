import 'package:equatable/equatable.dart';

import '../../../../core/date/civil_date.dart';
import '../../../events/domain/entities/calendar_event.dart';
import '../lunar/khmer_lunar_calendar.dart';

/// One Gregorian day with its (locally computed) lunar date and the published
/// events covering it.
final class CalendarDay extends Equatable {
  const CalendarDay({
    required this.date,
    required this.lunar,
    this.events = const [],
  });

  final CivilDate date;
  final KhmerLunarDate lunar;
  final List<CalendarEvent> events;

  bool get isHolyDay => lunar.isHolyDay;
  bool get hasEvents => events.isNotEmpty;
  bool get isDayOff => events.any((e) => e.isDayOff);

  @override
  List<Object?> get props => [date, lunar, events];
}
