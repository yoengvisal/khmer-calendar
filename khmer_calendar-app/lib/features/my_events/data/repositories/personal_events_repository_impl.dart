import 'dart:convert';

import '../../../../core/date/civil_date.dart';
import '../../../../core/storage/key_value_store.dart';
import '../../domain/entities/personal_event.dart';
import '../../domain/repositories/personal_events_repository.dart';

class PersonalEventsRepositoryImpl implements PersonalEventsRepository {
  PersonalEventsRepositoryImpl(this._store);

  static const String storageKey = 'my_events.v1';

  final KeyValueStore _store;

  @override
  List<PersonalEvent> loadAll() {
    final raw = _store.getString(storageKey);
    if (raw == null) return const [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return [
        for (final item in list.cast<Map<String, dynamic>>())
          if (CivilDate.tryParse(item['date'] as String? ?? '')
              case final date?)
            PersonalEvent(
              id: item['id'] as String,
              title: item['title'] as String,
              date: date,
              note: item['note'] as String?,
            ),
      ];
    } on Object {
      // Corrupt data must never crash the calendar.
      return const [];
    }
  }

  @override
  Future<void> saveAll(List<PersonalEvent> events) => _store.setString(
    storageKey,
    jsonEncode([
      for (final e in events)
        {'id': e.id, 'title': e.title, 'date': e.date.toIso(), 'note': e.note},
    ]),
  );
}
