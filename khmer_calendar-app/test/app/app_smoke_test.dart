import 'package:flutter_test/flutter_test.dart';
import 'package:khmer_calendar/app/app.dart';
import 'package:khmer_calendar/app/config/app_config.dart';
import 'package:khmer_calendar/app/di/injection.dart';
import 'package:khmer_calendar/app/router/app_router.dart';
import 'package:khmer_calendar/core/date/clock.dart';
import 'package:khmer_calendar/core/storage/key_value_store.dart';
import 'package:khmer_calendar/features/events/presentation/widgets/holiday_row.dart';
import 'package:khmer_calendar/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/fakes.dart';

void main() {
  Future<void> pumpApp(
    WidgetTester tester, {
    Flavor flavor = Flavor.dev,
    Map<String, String>? prefs,
  }) async {
    final config = AppConfig(
      flavor: flavor,
      apiBaseUrl: 'http://localhost:3000/api/v1',
    );
    await configureDependencies(
      config,
      keyValueStore: InMemoryKeyValueStore(prefs),
      eventsRemoteDataSource: FakeEventsRemoteDataSource(
        events: [eventDto(id: 'kny', start: '2025-04-14', end: '2025-04-16')],
      ),
      weatherRemoteDataSource: FakeWeatherRemoteDataSource(),
      clock: Clock.fixed(DateTime(2025, 4, 15)),
    );
    await tester.pumpWidget(
      KhmerCalendarApp(
        config: config,
        router: createAppRouter(),
        createSettingsCubit: sl.call,
      ),
    );
    await tester.pumpAndSettle();
  }

  tearDown(sl.reset);

  testWidgets('boots in Khmer by default with the env banner (dev)', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(find.text('មេសា ២០២៥'), findsOneWidget);
    expect(find.text('ប្រតិទិន'), findsOneWidget); // bottom nav
    expect(find.byType(Banner), findsOneWidget);
  });

  testWidgets('navigates tabs and honours a saved English preference', (
    tester,
  ) async {
    await pumpApp(
      tester,
      flavor: Flavor.production,
      prefs: {SettingsRepositoryImpl.languageKey: 'en'},
    );

    expect(find.text('April 2025'), findsOneWidget);
    expect(find.byType(Banner), findsNothing);

    await tester.tap(find.text('Events'));
    await tester.pumpAndSettle();
    expect(find.text('Holidays 2025'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(HolidayRow),
        matching: find.text('Event kny'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Weather'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('weather-page')), findsOneWidget);
    expect(find.text('Partly Cloudy'), findsOneWidget);

    await tester.tap(find.text('Tools'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tool-converter')), findsOneWidget);

    // Settings live behind the gear on the calendar header.
    await tester.tap(find.text('Calendar'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settings-button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('language-selector')), findsOneWidget);
    expect(find.byKey(const Key('environment-tile')), findsNothing);
  });

  testWidgets('the Today button shows the date and returns to this month', (
    tester,
  ) async {
    await pumpApp(tester, prefs: {SettingsRepositoryImpl.languageKey: 'en'});

    final todayButton = find.byKey(const Key('today-button'));
    expect(
      find.descendant(of: todayButton, matching: find.text('15')),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Next month'));
    await tester.pumpAndSettle();
    expect(find.text('May 2025'), findsOneWidget);

    await tester.tap(find.text('Events'));
    await tester.pumpAndSettle();
    expect(find.text('Holidays 2025'), findsOneWidget);

    await tester.tap(todayButton);
    await tester.pumpAndSettle();
    expect(find.text('April 2025'), findsOneWidget);
  });
}
