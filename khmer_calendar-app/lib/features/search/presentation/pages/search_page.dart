import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/date/civil_date.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../events/domain/entities/calendar_event.dart';
import '../../../events/domain/repositories/events_repository.dart';
import '../../../events/presentation/widgets/event_style.dart';
import '../../../my_events/domain/entities/personal_event.dart';
import '../../../my_events/presentation/bloc/my_events_cubit.dart';

/// Searches published events (this year and next) and the user's own events.
/// Pops with the [CivilDate] of the chosen result.
class SearchPage extends StatefulWidget {
  const SearchPage({required this.events, required this.today, super.key});

  final EventsRepository events;
  final CivilDate today;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _query = TextEditingController();
  List<CalendarEvent> _published = const [];

  @override
  void initState() {
    super.initState();
    _loadPublished();
  }

  Future<void> _loadPublished() async {
    final all = <CalendarEvent>[];
    for (final year in [widget.today.year, widget.today.year + 1]) {
      final result = await widget.events.getEventsForYear(year);
      result.fold((y) => all.addAll(y.events), (_) {});
    }
    if (mounted) setState(() => _published = all);
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final colors = context.calendarColors;
    final lang = context.uiLanguage;
    final q = _query.text.trim().toLowerCase();
    final mine = context.watch<MyEventsCubit>().state;

    bool matches(String? s) => s != null && s.toLowerCase().contains(q);
    final results =
        q.isEmpty
              ? const <(CivilDate, String, Color)>[]
              : [
                  for (final e in _published)
                    if (matches(e.titleKm) ||
                        matches(e.titleEn) ||
                        matches(e.titleZh))
                      (
                        e.startDate,
                        e.localizedTitle(context),
                        e.isDayOff ? colors.holiday : colors.otherEvent,
                      ),
                  for (final PersonalEvent e in mine)
                    if (matches(e.title) || matches(e.note))
                      (e.date, e.title, colors.myEvent),
                ]
          ..sort((a, b) => a.$1.compareTo(b.$1));

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          key: const Key('search-field'),
          controller: _query,
          autofocus: true,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: l10n.searchHint,
            border: InputBorder.none,
          ),
        ),
      ),
      body: q.isNotEmpty && results.isEmpty
          ? Center(
              child: Text(l10n.noResults, style: TextStyle(color: p.muted)),
            )
          : ListView(
              children: [
                for (final (date, title, color) in results)
                  ListTile(
                    leading: CircleAvatar(radius: 6, backgroundColor: color),
                    title: Text(title),
                    subtitle: Text(
                      formatCivilDate(date, lang, withWeekday: true),
                    ),
                    onTap: () => Navigator.of(context).pop(date),
                  ),
              ],
            ),
    );
  }
}
