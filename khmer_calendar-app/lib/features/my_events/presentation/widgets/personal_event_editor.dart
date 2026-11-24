import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/date/civil_date.dart';
import '../../../../core/l10n/l10n.dart';
import '../../domain/entities/personal_event.dart';
import '../bloc/my_events_cubit.dart';

/// Bottom sheet to add ([existing] == null) or edit a personal event.
Future<void> showPersonalEventEditor(
  BuildContext context, {
  PersonalEvent? existing,
  required CivilDate initialDate,
}) {
  final cubit = context.read<MyEventsCubit>();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: _Editor(existing: existing, initialDate: initialDate),
    ),
  );
}

class _Editor extends StatefulWidget {
  const _Editor({required this.existing, required this.initialDate});

  final PersonalEvent? existing;
  final CivilDate initialDate;

  @override
  State<_Editor> createState() => _EditorState();
}

class _EditorState extends State<_Editor> {
  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.existing?.title);
  late final _note = TextEditingController(text: widget.existing?.note);
  late CivilDate _date = widget.existing?.date ?? widget.initialDate;

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(_date.year, _date.month, _date.day),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100, 12, 31),
    );
    if (picked != null) setState(() => _date = CivilDate.fromDateTime(picked));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final cubit = context.read<MyEventsCubit>();
    final note = _note.text.trim().isEmpty ? null : _note.text.trim();
    final existing = widget.existing;
    if (existing == null) {
      await cubit.add(title: _title.text.trim(), date: _date, note: note);
    } else {
      await cubit.update(
        existing.copyWith(
          title: _title.text.trim(),
          date: _date,
          note: () => note,
        ),
      );
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.existing == null ? l10n.addEvent : l10n.editEvent,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('my-event-title'),
              controller: _title,
              autofocus: widget.existing == null,
              maxLength: 120,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: l10n.eventTitleLabel,
                border: const OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l10n.titleRequired : null,
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              key: const Key('my-event-date'),
              onPressed: _pickDate,
              icon: const Icon(Icons.event_rounded),
              label: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  '${l10n.eventDateLabel}: ${formatCivilDate(_date, context.uiLanguage, withWeekday: true)}',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _note,
              maxLines: 3,
              maxLength: 500,
              decoration: InputDecoration(
                labelText: l10n.eventNoteLabel,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    key: const Key('my-event-save'),
                    onPressed: _save,
                    child: Text(l10n.save),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
