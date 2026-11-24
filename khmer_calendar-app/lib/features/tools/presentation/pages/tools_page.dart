import 'package:material_ui/material_ui.dart';

import '../../../../core/date/civil_date.dart';
import '../../../../core/date/clock.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/royal.dart';
import '../../../calendar/domain/entities/year_month.dart';
import '../../../calendar/domain/lunar/khmer_lunar_calendar.dart';
import '../../../calendar/domain/lunar/khmer_lunar_constants.dart';
import '../../../calendar/domain/lunar/khmer_lunar_formatter.dart';

/// Offline tools built on the lunar engine.
class ToolsPage extends StatelessWidget {
  const ToolsPage({required this.lunar, this.clock = const Clock(), super.key});

  final KhmerLunarCalendar lunar;
  final Clock clock;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    Widget tool(
      Key key,
      IconData icon,
      Color color,
      String title,
      String subtitle,
      Widget page,
    ) => Card(
      key: key,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: color.withValues(alpha: .14),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: TextStyle(color: p.muted)),
        trailing: Icon(Icons.chevron_right_rounded, color: p.muted),
        onTap: () =>
            Navigator.of(context)
                .push(MaterialPageRoute<void>(builder: (_) => page)),
      ),
    );
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navTools)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          tool(
            const Key('tool-converter'),
            Icons.swap_horiz_rounded,
            p.accent,
            l10n.toolConverter,
            l10n.toolConverterSub,
            DateConverterPage(lunar: lunar, today: clock.today()),
          ),
          const SizedBox(height: 10),
          tool(
            const Key('tool-new-year'),
            Icons.celebration_rounded,
            const Color(0xFFE2562B),
            l10n.toolNewYear,
            l10n.toolNewYearSub,
            NewYearPage(lunar: lunar, today: clock.today()),
          ),
          const SizedBox(height: 10),
          tool(
            const Key('tool-holy-days'),
            Icons.brightness_3_rounded,
            const Color(0xFFD59A2E),
            l10n.toolHolyDays,
            l10n.toolHolyDaysSub,
            HolyDaysPage(lunar: lunar, today: clock.today()),
          ),
        ],
      ),
    );
  }
}

/// Gregorian → Khmer lunar date.
class DateConverterPage extends StatefulWidget {
  const DateConverterPage({
    required this.lunar,
    required this.today,
    super.key,
  });

  final KhmerLunarCalendar lunar;
  final CivilDate today;

  @override
  State<DateConverterPage> createState() => _DateConverterPageState();
}

class _DateConverterPageState extends State<DateConverterPage> {
  late CivilDate _date = widget.today;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final lang = context.uiLanguage;
    final lunar = widget.lunar.toLunar(_date);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.toolConverter)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FilledButton.tonalIcon(
            key: const Key('converter-pick'),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime(_date.year, _date.month, _date.day),
                firstDate: DateTime(1900),
                lastDate: DateTime(2100, 12, 31),
              );
              if (picked != null) {
                setState(() => _date = CivilDate.fromDateTime(picked));
              }
            },
            icon: const Icon(Icons.event_rounded),
            label: Text(formatCivilDate(_date, lang, withWeekday: true)),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  MoonPhaseIcon.forLunarDay(
                    lunar.moonPhase.index * 15 + lunar.day - 1,
                    size: 64,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SelectableText(
                          KhmerLunarFormatter.formatKm(lunar),
                          key: const Key('converter-result'),
                          style: theme.textTheme.titleMedium?.copyWith(
                            height: 1.5,
                          ),
                        ),
                        if (lang != UiLanguage.km) ...[
                          const SizedBox(height: 6),
                          Text(
                            KhmerLunarFormatter.format(lunar, lang),
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                        if (lunar.isHolyDay) ...[
                          const SizedBox(height: 8),
                          TagBadge(
                            label: l10n.holyDay,
                            icon: Icons.brightness_3_rounded,
                            color: context.calendarColors.holyDay,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Khmer New Year (Moha Songkran) date and time for any year.
class NewYearPage extends StatefulWidget {
  const NewYearPage({required this.lunar, required this.today, super.key});

  final KhmerLunarCalendar lunar;
  final CivilDate today;

  @override
  State<NewYearPage> createState() => _NewYearPageState();
}

class _NewYearPageState extends State<NewYearPage> {
  late int _year = widget.today.year;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final lang = context.uiLanguage;
    final info = widget.lunar.newYear(_year);
    final animal = widget.lunar.toLunar(info.mohaSongkran).animalYear;
    final animalName = switch (lang) {
      UiLanguage.km => 'ឆ្នាំ${animalYearNamesKm[animal]}',
      UiLanguage.en => 'Year of the ${animalYearNamesEn[animal]}',
      UiLanguage.zh => '${animalYearNamesZh[animal]}年',
    };
    final until = widget.today.daysUntil(info.mohaSongkran);
    final time =
        '${info.hour.toString().padLeft(2, '0')}:${info.minute.toString().padLeft(2, '0')}';

    Widget row(String label, String value, {Key? key}) => ListTile(
      title: Text(label, style: TextStyle(color: context.palette.muted)),
      trailing: Text(value, key: key, style: theme.textTheme.titleSmall),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.toolNewYear)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              RoundIconButton(
                icon: Icons.chevron_left_rounded,
                tooltip: l10n.previousYear,
                onPressed: () => setState(() => _year--),
              ),
              Expanded(
                child: Text(
                  context.digits(_year),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall,
                ),
              ),
              RoundIconButton(
                icon: Icons.chevron_right_rounded,
                tooltip: l10n.nextYear,
                onPressed: () => setState(() => _year++),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                const SizedBox(height: 16),
                Text(animalName, style: theme.textTheme.titleLarge),
                if (until > 0) ...[
                  const SizedBox(height: 6),
                  TagBadge(label: l10n.inDays(context.digits(until))),
                ],
                const SizedBox(height: 8),
                row(
                  l10n.newYearStart,
                  formatCivilDate(info.mohaSongkran, lang, withWeekday: true),
                  key: const Key('new-year-date'),
                ),
                row(
                  l10n.newYearTime,
                  lang == UiLanguage.km ? toKhmerDigits(time) : time,
                ),
                row(
                  l10n.newYearLerngSak,
                  formatCivilDate(info.lerngSak, lang, withWeekday: true),
                ),
                row(l10n.dayDetailEvents, l10n.eventDays(info.numberOfDays)),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String toKhmerDigits(String s) => s.replaceAllMapped(
  RegExp(r'\d'),
  (m) => const [
    '០',
    '១',
    '២',
    '៣',
    '៤',
    '៥',
    '៦',
    '៧',
    '៨',
    '៩',
  ][int.parse(m.group(0)!)],
);

/// Holy days (ថ្ងៃសីល) of a month.
class HolyDaysPage extends StatefulWidget {
  const HolyDaysPage({required this.lunar, required this.today, super.key});

  final KhmerLunarCalendar lunar;
  final CivilDate today;

  @override
  State<HolyDaysPage> createState() => _HolyDaysPageState();
}

class _HolyDaysPageState extends State<HolyDaysPage> {
  late YearMonth _month = YearMonth.of(widget.today);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final lang = context.uiLanguage;
    final holy = [
      for (var d = 1; d <= daysInGregorianMonth(_month.year, _month.month); d++)
        if (widget.lunar.toLunar(CivilDate(_month.year, _month.month, d))
            case final l when l.isHolyDay)
          (CivilDate(_month.year, _month.month, d), l),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.toolHolyDays)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              RoundIconButton(
                icon: Icons.chevron_left_rounded,
                tooltip: l10n.previousMonth,
                onPressed: () => setState(() => _month = _month.addMonths(-1)),
              ),
              Expanded(
                child: Text(
                  formatMonthYear(_month.year, _month.month, lang),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge,
                ),
              ),
              RoundIconButton(
                icon: Icons.chevron_right_rounded,
                tooltip: l10n.nextMonth,
                onPressed: () => setState(() => _month = _month.addMonths(1)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                for (final (date, lunar) in holy)
                  ListTile(
                    leading: MoonPhaseIcon.forLunarDay(
                      lunar.moonPhase.index * 15 + lunar.day - 1,
                      size: 36,
                    ),
                    title: Text(formatCivilDate(date, lang, withWeekday: true)),
                    subtitle: Text(KhmerLunarFormatter.dayLabel(lunar, lang)),
                    trailing: date == widget.today
                        ? TagBadge(label: l10n.today)
                        : null,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
