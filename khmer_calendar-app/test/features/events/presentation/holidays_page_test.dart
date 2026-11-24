import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khmer_calendar/core/date/civil_date.dart';
import 'package:khmer_calendar/core/errors/app_failure.dart';
import 'package:khmer_calendar/features/events/presentation/bloc/holidays_bloc.dart';
import 'package:khmer_calendar/features/events/presentation/pages/holidays_page.dart';
import 'package:khmer_calendar/features/events/presentation/widgets/holiday_row.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/pump_app.dart';

class MockHolidaysBloc extends MockBloc<HolidaysEvent, HolidaysState>
    implements HolidaysBloc {}

void main() {
  late MockHolidaysBloc bloc;

  setUpAll(() => registerFallbackValue(const HolidaysStarted()));
  setUp(() => bloc = MockHolidaysBloc());

  Future<void> pumpWith(WidgetTester tester, HolidaysState state) {
    whenListen(bloc, const Stream<HolidaysState>.empty(), initialState: state);
    return pumpLocalized(
      tester,
      BlocProvider<HolidaysBloc>.value(
        value: bloc,
        child: const HolidaysPage(),
      ),
    );
  }

  testWidgets('loading state', (tester) async {
    await pumpWith(tester, const HolidaysLoading(year: 2025));
    expect(find.byKey(const Key('holidays-loading')), findsOneWidget);
    expect(find.text('Holidays 2025'), findsOneWidget);
  });

  testWidgets('empty state', (tester) async {
    await pumpWith(tester, const HolidaysEmpty(year: 2025));
    expect(find.byKey(const Key('holidays-empty')), findsOneWidget);
    expect(
      find.text('No published holidays or events for this year yet.'),
      findsOneWidget,
    );
  });

  testWidgets('error state shows a safe message and retries', (tester) async {
    await pumpWith(
      tester,
      const HolidaysFailure(
        year: 2025,
        failure: ServerFailure(statusCode: 500, code: 'INTERNAL_ERROR'),
      ),
    );

    expect(find.byKey(const Key('holidays-error')), findsOneWidget);
    expect(
      find.text('Something went wrong on our side. Please try again later.'),
      findsOneWidget,
    );
    expect(find.textContaining('INTERNAL_ERROR'), findsNothing);

    await tester.tap(find.text('Retry'));
    verify(() => bloc.add(any(that: isA<HolidaysRefreshRequested>())))
        .called(1);
  });

  testWidgets('stale success shows the offline banner and month groups', (
    tester,
  ) async {
    await pumpWith(
      tester,
      HolidaysSuccess(
        year: 2025,
        today: CivilDate(2025, 6, 1),
        isStale: true,
        events: [
          calendarEvent(id: 'a', start: '2025-04-14', end: '2025-04-16'),
          calendarEvent(id: 'b', start: '2025-09-22', isDayOff: false),
        ],
      ),
    );

    expect(find.byKey(const Key('offline-banner')), findsOneWidget);
    expect(find.text('Offline — showing saved data'), findsOneWidget);
    expect(find.text('April'), findsOneWidget);
    expect(find.text('September'), findsOneWidget);
    expect(find.text('Event a'), findsOneWidget);
    // The holiday row shows the length; the next-holiday card shows a countdown.
    expect(
      find.descendant(
        of: find.byType(HolidayRow),
        matching: find.textContaining('3 days'),
      ),
      findsOneWidget,
    );
    expect(find.text('Day off'), findsOneWidget);
  });

  testWidgets('year arrows dispatch year changes', (tester) async {
    await pumpWith(tester, const HolidaysEmpty(year: 2025));
    await tester.tap(find.byTooltip('Next year'));
    verify(() => bloc.add(const HolidaysYearShifted(1))).called(1);
  });
}
