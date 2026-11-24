import 'package:material_ui/material_ui.dart';

import '../../domain/entities/weather_report.dart';

/// Colourful layered icon (sun / moon / cloud / rain) for a [WeatherKind].
class WeatherIcon extends StatelessWidget {
  const WeatherIcon({
    required this.kind,
    this.isDay = true,
    this.size = 48,
    super.key,
  });

  final WeatherKind kind;
  final bool isDay;
  final double size;

  static const Color _sun = Color(0xFFFDB813);
  static const Color _moon = Color(0xFFFCE38A);
  static const Color _cloud = Color(0xFFE3E9F4);
  static const Color _cloudDark = Color(0xFFB5C0D3);
  static const Color _rain = Color(0xFF4A9BFF);

  @override
  Widget build(BuildContext context) {
    final orb = Icon(
      isDay ? Icons.wb_sunny_rounded : Icons.nightlight_round,
      color: isDay ? _sun : _moon,
      size: size * 0.62,
    );
    Widget cloud(Color c) =>
        Icon(Icons.cloud_rounded, color: c, size: size * 0.78);

    final layers = <Widget>[
      switch (kind) {
        WeatherKind.clear => Center(
          child: Icon(
            isDay ? Icons.wb_sunny_rounded : Icons.nightlight_round,
            color: isDay ? _sun : _moon,
            size: size * 0.85,
          ),
        ),
        WeatherKind.partlyCloudy => Stack(
          children: [
            Positioned(left: 0, top: 0, child: orb),
            Positioned(right: 0, bottom: 0, child: cloud(_cloud)),
          ],
        ),
        WeatherKind.cloudy || WeatherKind.fog => Stack(
          children: [
            Positioned(left: 0, top: size * .08, child: cloud(_cloudDark)),
            Positioned(right: 0, bottom: 0, child: cloud(_cloud)),
          ],
        ),
        WeatherKind.drizzle || WeatherKind.rain => Stack(
          children: [
            Positioned(left: size * .1, top: 0, child: cloud(_cloud)),
            Positioned(
              left: size * .3,
              bottom: 0,
              child: Icon(
                Icons.water_drop_rounded,
                color: _rain,
                size: size * .32,
              ),
            ),
          ],
        ),
        WeatherKind.thunderstorm => Center(
          child: Icon(
            Icons.thunderstorm_rounded,
            color: _cloudDark,
            size: size * .9,
          ),
        ),
      },
    ];
    return SizedBox.square(
      dimension: size,
      child: Stack(children: layers),
    );
  }
}
