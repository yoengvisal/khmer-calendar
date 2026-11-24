import 'package:flutter_test/flutter_test.dart';
import 'package:khmer_calendar/core/date/clock.dart';
import 'package:khmer_calendar/features/calendar/domain/lunar/khmer_lunar_calendar.dart';
import 'package:khmer_calendar/features/tools/presentation/pages/tools_page.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/pump_app.dart';

void main() {
  final clock = Clock.fixed(DateTime(2025, 5, 11, 9));
  final lunar = KhmerLunarCalendar();

  testWidgets('date converter shows the Khmer lunar date', (tester) async {
    await pumpLocalized(tester, ToolsPage(lunar: lunar, clock: clock));
    await tester.tap(find.byKey(const Key('tool-converter')));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'ថ្ងៃអាទិត្យ ១៥កើត ខែពិសាខ ឆ្នាំម្សាញ់ សប្តស័ក ពុទ្ធសករាជ ២៥៦៨',
      ),
      findsOneWidget,
    );
  });

  testWidgets('Khmer New Year tool shows Moha Songkran for the year', (
    tester,
  ) async {
    await pumpLocalized(tester, ToolsPage(lunar: lunar, clock: clock));
    await tester.tap(find.byKey(const Key('tool-new-year')));
    await tester.pumpAndSettle();
    // 2025: Monday 14 April.
    expect(find.text('Monday, 14 April 2025'), findsOneWidget);
    await tester.tap(find.byTooltip('Previous year'));
    await tester.pumpAndSettle();
    expect(find.text('Saturday, 13 April 2024'), findsOneWidget);
  });

  testWidgets('holy days tool lists the month’s Thngai Sel', (tester) async {
    await pumpLocalized(tester, ToolsPage(lunar: lunar, clock: clock));
    await tester.tap(find.byKey(const Key('tool-holy-days')));
    await tester.pumpAndSettle();
    expect(find.text('Sunday, 11 May 2025'), findsOneWidget); // 15 Kert Pisakh
    expect(find.text('15 Kert'), findsOneWidget);
  });
}
