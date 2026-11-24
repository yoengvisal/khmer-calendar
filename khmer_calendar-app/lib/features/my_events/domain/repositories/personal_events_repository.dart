import '../entities/personal_event.dart';

/// On-device storage for the user's own events (never sent to the API).
abstract interface class PersonalEventsRepository {
  List<PersonalEvent> loadAll();
  Future<void> saveAll(List<PersonalEvent> events);
}
