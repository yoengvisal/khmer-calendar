import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/weather_report.dart';
import '../bloc/weather_cubit.dart';
import 'weather_icon.dart';

String weatherKindLabel(WeatherKind kind, AppLocalizations l10n) =>
    switch (kind) {
      WeatherKind.clear => l10n.weatherClear,
      WeatherKind.partlyCloudy => l10n.weatherPartlyCloudy,
      WeatherKind.cloudy => l10n.weatherCloudy,
      WeatherKind.fog => l10n.weatherFog,
      WeatherKind.drizzle => l10n.weatherDrizzle,
      WeatherKind.rain => l10n.weatherRain,
      WeatherKind.thunderstorm => l10n.weatherThunderstorm,
    };

/// Compact "Phnom Penh 31°C · Partly Cloudy" card on the home screen.
/// Hidden until the first report arrives; never blocks the calendar.
class WeatherCard extends StatelessWidget {
  const WeatherCard({this.onTap, super.key});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeatherCubit, WeatherState>(
      builder: (context, state) {
        final report = state.report;
        if (report == null) return const SizedBox.shrink();
        final l10n = context.l10n;
        final theme = Theme.of(context);
        final p = context.palette;
        return Card(
          key: const Key('weather-card'),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
              child: Row(
                children: [
                  WeatherIcon(kind: report.kind, isDay: report.isDay, size: 52),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.place_rounded,
                              size: 15,
                              color: Color(0xFF3B82F6),
                            ),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                l10n.cityPhnomPenh,
                                style: theme.textTheme.bodySmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${context.digits(report.temperature.round())}°C',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            height: 1.15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          weatherKindLabel(report.kind, l10n),
                          style: theme.textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          l10n.highLow(
                            context.digits(report.today.max.round()),
                            context.digits(report.today.min.round()),
                          ),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: p.muted,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: p.muted),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
