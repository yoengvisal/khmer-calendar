import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khmer_calendar/core/date/clock.dart';
import 'package:khmer_calendar/core/errors/app_failure.dart';
import 'package:khmer_calendar/core/errors/result.dart';
import 'package:khmer_calendar/core/storage/key_value_store.dart';
import 'package:khmer_calendar/features/calendar/domain/lunar/khmer_lunar_calendar.dart';
import 'package:khmer_calendar/features/calendar/domain/usecases/get_month_calendar.dart';
import 'package:khmer_calendar/features/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:khmer_calendar/features/calendar/presentation/pages/calendar_page.dart';
import 'package:khmer_calendar/features/events/domain/entities/calendar_event.dart';
import 'package:khmer_calendar/features/events/domain/entities/year_events.dart';
import 'package:khmer_calendar/features/my_events/data/repositories/personal_events_repository_impl.dart';
import 'package:khmer_calendar/features/my_events/presentation/bloc/my_events_cubit.dart';
import 'package:khmer_calendar/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:khmer_calendar/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:khmer_calendar/features/weather/data/repositories/weather_repository_impl.dart';
import 'package:khmer_calendar/features/weather/presentation/bloc/weather_cubit.dart';
import 'package:material_ui/material_ui.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/pump_app.dart';

void main() {
  // 11 May 2025 = Visakha Bochea (15 Kert Pisakh, a holy day), a Sunday.
  final clock = Clock.fixed(DateTime(2025, 5, 11, 9));
  final lunar = KhmerLunarCalendar();
  late FakeEventsRepository events;
  late InMemoryKeyValueStore store;
  late MyEventsCubit myEvents;
  late SettingsCubit settings;
  late WeatherCubit weather;

  setUp(() {
    store = InMemoryKeyValueStore();
    events = FakeEventsRepository(
      (year) => Ok(
        YearEvents(
          year: year,
          events: [
            calendarEvent(
              id: 'visak',
              start: '2025-05-11',
              category: EventCategory.buddhistHolyDay,
            ),
          ],
        ),
      ),
    );
    myEvents = MyEventsCubit(PersonalEventsRepositoryImpl(store));
    settings = SettingsCubit(SettingsRepositoryImpl(store));
    weather = WeatherCubit(
      WeatherRepositoryImpl(
        remote: FakeWeatherRemoteDataSource(),
        store: store,
        clock: clock,
      ),
    );
  });

  tearDown(() async {
    await myEvents.close();
    await settings.close();
    await weather.close();
  });

  Widget page() => MultiBlocProvider(
    providers: [
      BlocProvider.value(value: myEvents),
      BlocProvider.value(value: settings),
      BlocProvider.value(value: weather),
      BlocProvider(
        create: (_) => CalendarBloc(
          getMonthCalendar: GetMonthCalendar(
            lunarCalendar: lunar,
            eventsRepository: events,
          ),
          clock: clock,
        )..add(const CalendarStarted()),
      ),
    ],
    child: CalendarPage(lunar: lunar),
  );

  Future<void> pumpPage(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
  }) async {
    tester.view.physicalSize = const Size(430, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpLocalized(tester, page(), locale: locale);
  }

  testWidgets('renders loading, then today card, weather and the month', (
    tester,
  ) async {
    final gate = events.gate = Completer<void>();
    await pumpPage(tester);
    await tester.pump();
    expect(find.byKey(const Key('calendar-loading')), findsOneWidget);

    await weather.load();
    gate.complete();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('calendar-loading')), findsNothing);
    expect(find.text('May 2025'), findsOneWidget);
    expect(find.text('Sun, May 11, 2025'), findsOneWidget);
    expect(find.text('ថ្ងៃអាទិត្យ ១៥ កើត ខែពិសាខ ឆ្នាំម្សាញ់'), findsOneWidget);
    expect(find.text('Waxing Moon · 15th day of Pisakh'), findsOneWidget);
    // Weather sits below the month card.
    await tester.scrollUntilVisible(find.byKey(const Key('weather-card')), 200);
    expect(find.text('31°C'), findsOneWidget);
    expect(find.text('Partly Cloudy'), findsOneWidget);
    expect(
      tester.getTopLeft(find.byKey(const Key('weather-card'))).dy,
      greaterThan(tester.getTopLeft(find.byKey(const Key('month-card'))).dy),
    );
    // Monday-first header and no lunar labels by default (like the design).
    expect(find.text('Mon'), findsOneWidget);
    expect(find.byKey(const Key('cell-lunar-label')), findsNothing);
  });

  testWidgets('optionally shows lunar days under each date', (tester) async {
    await settings.setShowLunarDays(true);
    await pumpPage(tester);
    await tester.pumpAndSettle();
    expect(find.text('15 Kert'), findsWidgets);
  });

  testWidgets('uses Khmer numerals in Khmer', (tester) async {
    await pumpPage(tester, locale: const Locale('km'));
    await tester.pumpAndSettle();
    expect(find.text('ឧសភា ២០២៥'), findsOneWidget);
    expect(find.text('៣១'), findsOneWidget);
    expect(find.textContaining('ព្រះចន្ទខាងកើត'), findsOneWidget);
  });

  testWidgets('uses Chinese dates and lunar terms in Chinese', (tester) async {
    await pumpPage(tester, locale: const Locale('zh'));
    await tester.pumpAndSettle();
    expect(find.text('2025年5月'), findsOneWidget);
    expect(find.text('盈月 · 柬历六月十五'), findsOneWidget);
  });

  testWidgets('tapping a day opens the sheet, which can add a personal event', (
    tester,
  ) async {
    await pumpPage(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('day-2025-05-11')));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'ថ្ងៃអាទិត្យ ១៥កើត ខែពិសាខ ឆ្នាំម្សាញ់ សប្តស័ក ពុទ្ធសករាជ ២៥៦៨',
      ),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(
      find.byKey(const Key('day-add-event')),
      100,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.byKey(const Key('day-add-event')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('my-event-title')),
      'Family dinner',
    );
    await tester.tap(find.byKey(const Key('my-event-save')));
    await tester.pumpAndSettle();

    expect(myEvents.state.single.title, 'Family dinner');
    expect(myEvents.state.single.date.toIso(), '2025-05-11');
  });

  testWidgets('next/previous change the month; the Today card returns', (
    tester,
  ) async {
    await pumpPage(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Next month'));
    await tester.pumpAndSettle();
    expect(find.text('June 2025'), findsOneWidget);

    await tester.tap(find.byKey(const Key('today-card')));
    await tester.pumpAndSettle();
    expect(find.text('May 2025'), findsOneWidget);
  });

  testWidgets('shows a banner when events are unavailable', (tester) async {
    events.result = (_) => const Err(NetworkFailure());
    await pumpPage(tester);
    await tester.pumpAndSettle();
    expect(find.textContaining("Couldn't load events"), findsOneWidget);
    expect(find.text('31'), findsOneWidget); // lunar grid still rendered
  });
}
