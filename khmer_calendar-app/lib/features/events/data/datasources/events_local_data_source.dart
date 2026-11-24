import 'dart:convert';

import '../../../../core/storage/key_value_store.dart';
import '../models/event_dto.dart';

/// A year's events as last saved on the device.
typedef CachedYearEvents = ({List<EventDto> events, DateTime savedAt});

abstract interface class EventsLocalDataSource {
  /// Returns null when nothing (valid) is cached for [year].
  Future<CachedYearEvents?> read(int year);

  Future<void> write(int year, List<EventDto> events, DateTime savedAt);
}

/// Stores each year as one JSON document in shared_preferences.
class PrefsEventsLocalDataSource implements EventsLocalDataSource {
  PrefsEventsLocalDataSource(this._store);

  static const int _schemaVersion = 1;

  final KeyValueStore _store;

  static String keyFor(int year) => 'events.v$_schemaVersion.year.$year';

  @override
  Future<CachedYearEvents?> read(int year) async {
    final raw = _store.getString(keyFor(year));
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return (
        savedAt: DateTime.parse(json['savedAt'] as String),
        events: [
          for (final item in json['events'] as List<dynamic>)
            EventDto.fromJson(item as Map<String, dynamic>),
        ],
      );
    } on Object {
      // Corrupt or incompatible cache: drop it rather than crash.
      await _store.remove(keyFor(year));
      return null;
    }
  }

  @override
  Future<void> write(int year, List<EventDto> events, DateTime savedAt) =>
      _store.setString(
        keyFor(year),
        jsonEncode({
          'savedAt': savedAt.toUtc().toIso8601String(),
          'events': [for (final e in events) e.toJson()],
        }),
      );
}
