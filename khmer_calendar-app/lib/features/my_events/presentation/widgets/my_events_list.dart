import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/date/civil_date.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/status_views.dart';
import '../../domain/entities/personal_event.dart';
import '../bloc/my_events_cubit.dart';
import 'personal_event_editor.dart';

/// The user's events; swipe to delete (with undo), tap to edit.
class MyEventsList extends StatelessWidget {
  const MyEventsList({required this.today, super.key});

  final CivilDate today;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<MyEventsCubit, List<PersonalEvent>>(
      builder: (context, events) {
        if (events.isEmpty) {
          return MessageView(
            key: const Key('my-events-empty'),
            icon: Icons.event_note_rounded,
            message: l10n.noMyEvents,
          );
        }
        return ListView.separated(
          key: const Key('my-events-list'),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          itemCount: events.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, i) =>
              _PersonalEventTile(event: events[i], today: today),
        );
      },
    );
  }
}

class _PersonalEventTile extends StatelessWidget {
  const _PersonalEventTile({required this.event, required this.today});

  final PersonalEvent event;
  final CivilDate today;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final colors = context.calendarColors;
    final cubit = context.read<MyEventsCubit>();
    final isPast = event.date.isBefore(today);

    return Dismissible(
      key: ValueKey(event.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: colors.holiday,
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      onDismissed: (_) {
        cubit.delete(event.id);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(l10n.eventDeleted),
              action: SnackBarAction(
                label: l10n.undo,
                onPressed: () => cubit.restore(event),
              ),
            ),
          );
      },
      child: Opacity(
        opacity: isPast ? .55 : 1,
        child: Card(
          child: ListTile(
            onTap: () => showPersonalEventEditor(
              context,
              existing: event,
              initialDate: event.date,
            ),
            leading: CircleAvatar(
              backgroundColor: colors.myEvent.withValues(alpha: .15),
              foregroundColor: colors.myEvent,
              child: Text(
                context.digits(event.date.day),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            title: Text(
              event.title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              [
                formatCivilDate(
                  event.date,
                  context.uiLanguage,
                  withWeekday: true,
                ),
                if (event.note != null) event.note!,
              ].join('\n'),
              style: TextStyle(color: p.muted),
            ),
            isThreeLine: event.note != null,
          ),
        ),
      ),
    );
  }
}
