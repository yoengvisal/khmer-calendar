import 'package:material_ui/material_ui.dart';

import '../../../../core/date/civil_date.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../my_events/presentation/widgets/my_events_list.dart';
import '../../../my_events/presentation/widgets/personal_event_editor.dart';
import 'holidays_page.dart';

/// Events tab: published holidays and the user's own events.
/// Expects a HolidaysBloc and a MyEventsCubit above it.
class EventsPage extends StatefulWidget {
  const EventsPage({required this.today, super.key});

  final CivilDate today;

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this)
    ..addListener(() => setState(() {}));

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navEvents),
        bottom: TabBar(
          controller: _tabs,
          labelColor: p.accent,
          unselectedLabelColor: p.muted,
          indicatorColor: p.accent,
          dividerColor: p.line,
          tabs: [
            Tab(key: const Key('tab-holidays'), text: l10n.tabHolidays),
            Tab(key: const Key('tab-my-events'), text: l10n.tabMyEvents),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          const HolidaysPage(),
          MyEventsList(today: widget.today),
        ],
      ),
      floatingActionButton: _tabs.index == 1
          ? FloatingActionButton(
              key: const Key('add-my-event'),
              tooltip: l10n.addEvent,
              onPressed: () =>
                  showPersonalEventEditor(context, initialDate: widget.today),
              child: const Icon(Icons.add_rounded),
            )
          : null,
    );
  }
}
