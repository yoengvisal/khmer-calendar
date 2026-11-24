import 'dart:math';

import 'package:bloc/bloc.dart';

import '../../../../core/date/civil_date.dart';
import '../../domain/entities/personal_event.dart';
import '../../domain/repositories/personal_events_repository.dart';

/// The user's own events, sorted by date. Shared by the calendar (blue dots)
/// and the Events tab.
class MyEventsCubit extends Cubit<List<PersonalEvent>> {
  MyEventsCubit(this._repository) : super(_sorted(_repository.loadAll()));

  final PersonalEventsRepository _repository;
  final Random _random = Random();

  List<PersonalEvent> on(CivilDate date) =>
      state.where((e) => e.date == date).toList();

  Future<void> add({
    required String title,
    required CivilDate date,
    String? note,
  }) {
    final id =
        '${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}'
        '${_random.nextInt(1 << 20).toRadixString(36)}';
    return _save([
      ...state,
      PersonalEvent(id: id, title: title, date: date, note: note),
    ]);
  }

  Future<void> update(PersonalEvent event) =>
      _save([for (final e in state) e.id == event.id ? event : e]);

  Future<void> delete(String id) =>
      _save(state.where((e) => e.id != id).toList());

  /// Re-inserts a deleted event (undo).
  Future<void> restore(PersonalEvent event) => _save([...state, event]);

  Future<void> _save(List<PersonalEvent> next) async {
    final sorted = _sorted(next);
    emit(sorted);
    await _repository.saveAll(sorted);
  }

  static List<PersonalEvent> _sorted(List<PersonalEvent> events) =>
      [...events]..sort((a, b) {
        final byDate = a.date.compareTo(b.date);
        return byDate != 0 ? byDate : a.title.compareTo(b.title);
      });
}
