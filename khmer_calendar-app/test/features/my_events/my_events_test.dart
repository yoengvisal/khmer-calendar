import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khmer_calendar/core/date/civil_date.dart';
import 'package:khmer_calendar/core/storage/key_value_store.dart';
import 'package:khmer_calendar/features/my_events/data/repositories/personal_events_repository_impl.dart';
import 'package:khmer_calendar/features/my_events/presentation/bloc/my_events_cubit.dart';

void main() {
  late InMemoryKeyValueStore store;
  setUp(() => store = InMemoryKeyValueStore());

  blocTest<MyEventsCubit, dynamic>(
    'adds events sorted by date and persists them',
    build: () => MyEventsCubit(PersonalEventsRepositoryImpl(store)),
    act: (cubit) async {
      await cubit.add(title: 'Meeting', date: CivilDate(2026, 11, 20));
      await cubit.add(
        title: 'Dinner',
        date: CivilDate(2026, 11, 15),
        note: 'Family',
      );
    },
    verify: (cubit) {
      expect(cubit.state.map((e) => e.title), ['Dinner', 'Meeting']);
      final reloaded = PersonalEventsRepositoryImpl(store).loadAll();
      expect(reloaded.map((e) => (e.title, e.date.toIso(), e.note)), [
        ('Dinner', '2026-11-15', 'Family'),
        ('Meeting', '2026-11-20', null),
      ]);
    },
  );

  test('delete and undo (restore)', () async {
    final cubit = MyEventsCubit(PersonalEventsRepositoryImpl(store));
    await cubit.add(title: 'Pagoda visit', date: CivilDate(2026, 11, 24));
    final event = cubit.state.single;
    await cubit.delete(event.id);
    expect(cubit.state, isEmpty);
    await cubit.restore(event);
    expect(cubit.state.single, event);
    await cubit.close();
  });

  test('corrupt storage never crashes', () {
    store.values[PersonalEventsRepositoryImpl.storageKey] = '{not json';
    expect(PersonalEventsRepositoryImpl(store).loadAll(), isEmpty);
  });
}
