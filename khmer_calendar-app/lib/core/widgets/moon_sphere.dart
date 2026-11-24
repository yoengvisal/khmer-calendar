import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

/// A shaded, realistic-looking moon showing the phase of a lunar day.
/// [dayNumber] is 0-29 (0 = 1 Kert, 14 = 15 Kert/full, 29 = 15 Roch/new).
class MoonSphere extends StatelessWidget {
  const MoonSphere({required this.dayNumber, this.size = 58, super.key});

  final int dayNumber;
  final double size;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size.square(size),
    painter: _MoonSpherePainter(dayNumber),
  );
}

class _MoonSpherePainter extends CustomPainter {
  const _MoonSpherePainter(this.dayNumber);

  final int dayNumber;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.shortestSide / 2 * .94;
    final c = Offset(size.width / 2, size.height / 2);
    final disc = Rect.fromCircle(center: c, radius: r);
    final waxing = dayNumber < 15;
    final k = (waxing ? (dayNumber + 1) / 15 : (29 - dayNumber) / 15).clamp(
      0.0,
      1.0,
    );

    // Earthshine / dark side.
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0x998E8A86), Color(0x994E4B4A)],
        ).createShader(disc),
    );
    if (k > 0.01) {
      final half = Path()
        ..moveTo(c.dx, c.dy - r)
        ..arcTo(disc, -math.pi / 2, waxing ? math.pi : -math.pi, false)
        ..close();
      final rx = (1 - 2 * k).abs() * r;
      final ellipse = Path()
        ..addOval(Rect.fromCenter(center: c, width: rx * 2, height: r * 2));
      final lit = k >= .5
          ? Path.combine(PathOperation.union, half, ellipse)
          : Path.combine(PathOperation.difference, half, ellipse);
      canvas.drawPath(
        lit,
        Paint()
          ..shader = const RadialGradient(
            center: Alignment(-.16, -.24),
            radius: .75,
            colors: [Color(0xFFFFF8DA), Color(0xFFF3DFA2), Color(0xFFC9A866)],
            stops: [0, .6, 1],
          ).createShader(disc),
      );
      // A couple of soft craters for texture.
      final crater = Paint()..color = const Color(0x40C9A866);
      canvas.save();
      canvas.clipPath(lit);
      canvas.drawCircle(c + Offset(r * .24, -r * .2), r * .1, crater);
      canvas.drawCircle(c + Offset(r * .4, r * .26), r * .07, crater);
      canvas.drawCircle(c + Offset(-r * .3, r * .3), r * .08, crater);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_MoonSpherePainter old) => old.dayNumber != dayNumber;
}
