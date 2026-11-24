import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/status_views.dart';
import '../bloc/weather_cubit.dart';
import '../widgets/weather_card.dart';
import '../widgets/weather_icon.dart';

/// Weather tab: current conditions in Phnom Penh + 7-day forecast.
/// Expects a [WeatherCubit] above it (provided by the app shell).
class WeatherPage extends StatelessWidget {
  const WeatherPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final p = context.palette;
    final cubit = context.read<WeatherCubit>();
    final lang = context.uiLanguage;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navWeather)),
      body: BlocBuilder<WeatherCubit, WeatherState>(
        builder: (context, state) {
          final report = state.report;
          if (report == null) {
            return state.status == WeatherStatus.failure
                ? FailureView(
                    key: const Key('weather-error'),
                    message: l10n.weatherUnavailable,
                    onRetry: () => cubit.load(forceRefresh: true),
                  )
                : const Center(child: CircularProgressIndicator());
          }
          return RefreshIndicator(
            onRefresh: () => cubit.load(forceRefresh: true),
            child: ListView(
              key: const Key('weather-page'),
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              children: [
                if (report.isStale) InfoBanner(message: l10n.offlineBanner),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          l10n.cityPhnomPenh,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        WeatherIcon(
                          kind: report.kind,
                          isDay: report.isDay,
                          size: 96,
                        ),
                        Text(
                          '${context.digits(report.temperature.round())}°C',
                          style: theme.textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: p.text,
                          ),
                        ),
                        Text(
                          weatherKindLabel(report.kind, l10n),
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.highLow(
                            context.digits(report.today.max.round()),
                            context.digits(report.today.min.round()),
                          ),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: p.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
                  child: Text(
                    l10n.weatherForecast,
                    style: theme.textTheme.titleSmall?.copyWith(color: p.muted),
                  ),
                ),
                Card(
                  child: Column(
                    children: [
                      for (final day in report.daily)
                        ListTile(
                          leading: WeatherIcon(kind: day.kind, size: 36),
                          title: Text(
                            weekdayShortLabels(lang)[day.date.dayOfWeek] +
                                (lang == UiLanguage.zh ? '' : ' ') +
                                formatCivilDate(
                                  day.date,
                                  lang,
                                  withYear: false,
                                ),
                          ),
                          subtitle: day.rainChance == null
                              ? null
                              : Text(
                                  l10n.rainChance(
                                    context.digits(day.rainChance!),
                                  ),
                                ),
                          trailing: Text(
                            '${context.digits(day.max.round())}° / ${context.digits(day.min.round())}°',
                            style: theme.textTheme.titleSmall,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.weatherAttribution,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(color: p.muted),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
