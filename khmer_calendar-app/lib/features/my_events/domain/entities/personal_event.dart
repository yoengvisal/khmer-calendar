import 'package:equatable/equatable.dart';

import '../../../../core/date/civil_date.dart';

/// An event the user created on this device ("My Event", blue dot).
final class PersonalEvent extends Equatable {
  const PersonalEvent({
    required this.id,
    required this.title,
    required this.date,
    this.note,
  });

  final String id;
  final String title;
  final CivilDate date;
  final String? note;

  PersonalEvent copyWith({
    String? title,
    CivilDate? date,
    String? Function()? note,
  }) => PersonalEvent(
    id: id,
    title: title ?? this.title,
    date: date ?? this.date,
    note: note != null ? note() : this.note,
  );

  @override
  List<Object?> get props => [id, title, date, note];
}
