import 'dart:ui' show ImageFilter;

import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/khmer_digits.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/moon_sphere.dart';
import '../../domain/entities/calendar_day.dart';
import '../../domain/lunar/khmer_lunar_constants.dart';
import '../../domain/lunar/khmer_lunar_formatter.dart';

/// "Today" card: Gregorian date, Khmer lunar line and the moon's phase.
class TodayCard extends StatelessWidget {
  const TodayCard({required this.day, this.onTap, super.key});

  final CalendarDay day;
  final VoidCallback? onTap;

  static const _shortMonthsEn = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  static const _shortWeekdaysEn = [
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
  ];

  static String headline(CalendarDay day, UiLanguage lang) {
    final d = day.date;
    return switch (lang) {
      UiLanguage.en =>
        '${_shortWeekdaysEn[d.dayOfWeek]}, ${_shortMonthsEn[d.month - 1]} ${d.day}, ${d.year}',
      _ => formatCivilDate(d, lang, withWeekday: true),
    };
  }

  /// "ថ្ងៃអាទិត្យ ៦ កើត ខែកត្ដិក ឆ្នាំមមី"
  static String khmerLine(CalendarDay day) {
    final l = day.lunar;
    return 'ថ្ងៃ${weekdayNamesKm[day.date.dayOfWeek]} ${toKhmerNumeral(l.day)} '
        '${moonPhaseNamesKm[l.moonPhase.index]} ខែ${lunarMonthNamesKm[l.month.index]} '
        'ឆ្នាំ${animalYearNamesKm[l.animalYear]}';
  }

  static String _ordinal(int n) {
    if (n % 100 >= 11 && n % 100 <= 13) return '${n}th';
    return '$n${switch (n % 10) {
      1 => 'st',
      2 => 'nd',
      3 => 'rd',
      _ => 'th',
    }}';
  }

  /// "6th day of Kadeuk" / "៦កើត ខែកត្ដិក" / "柬历十二月初六"
  static String moonCaption(CalendarDay day, UiLanguage lang) {
    final l = day.lunar;
    return switch (lang) {
      UiLanguage.en =>
        '${_ordinal(l.day)} day of ${lunarMonthNamesEn[l.month.index]}',
      UiLanguage.km =>
        '${KhmerLunarFormatter.dayLabelKm(l)} ខែ${lunarMonthNamesKm[l.month.index]}',
      UiLanguage.zh =>
        '${KhmerLunarFormatter.monthLabelZh(l.month.index)}${KhmerLunarFormatter.dayLabelZh(l)}',
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final p = context.palette;
    final lang = context.uiLanguage;
    final waxing = day.lunar.moonPhase == MoonPhase.waxing;
    final dark = theme.brightness == Brightness.dark;

    // Compact frosted-glass strip: the header illustration stays visible.
    return ClipRRect(
      key: const Key('today-card'),
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Material(
          color: p.card.withValues(alpha: dark ? .45 : .55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: Colors.white.withValues(alpha: dark ? .10 : .45),
            ),
          ),
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 14, 10),
              child: Row(
                children: [
                  MoonSphere(
                    dayNumber:
                        day.lunar.moonPhase.index * 15 + day.lunar.day - 1,
                    size: 40,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: p.accent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                l10n.today,
                                style: TextStyle(
                                  color: p.onAccent,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                headline(day, lang),
                                key: const Key('today-headline'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          khmerLine(day),
                          key: const Key('today-khmer-line'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 13.5,
                          ),
                        ),
                        Text(
                          '${waxing ? l10n.waxingMoon : l10n.waningMoon} · ${moonCaption(day, lang)}',
                          key: const Key('today-moon'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            color: p.text.withValues(alpha: .7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
