import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

/// Full-screen "Royal Night" background (gradient + faint gold starfield).
class RoyalBackground extends StatelessWidget {
  const RoyalBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final decor = context.decor;
    return DecoratedBox(
      decoration: BoxDecoration(gradient: decor.background),
      child: Stack(
        children: [
          if (decor.starfield)
            const Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: 280,
              child: IgnorePointer(
                child: CustomPaint(painter: _StarfieldPainter()),
              ),
            ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _StarfieldPainter extends CustomPainter {
  const _StarfieldPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Deterministic pseudo-random stars that fade out towards the bottom.
    final random = math.Random(7);
    final paint = Paint();
    final count = (size.width * size.height / 2600).round();
    for (var i = 0; i < count; i++) {
      final dx = random.nextDouble() * size.width;
      final dy = random.nextDouble() * size.height;
      final fade = 1 - dy / size.height;
      final gold = random.nextBool();
      paint.color = (gold ? AppColors.goldLight : Colors.white).withValues(
        alpha: (0.15 + random.nextDouble() * 0.45) * fade,
      );
      canvas.drawCircle(Offset(dx, dy), 0.6 + random.nextDouble() * 0.8, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Display text painted with the theme's heading gradient (gold at night).
class GoldText extends StatelessWidget {
  const GoldText(this.text, {this.style, this.textAlign, super.key});

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) => ShaderMask(
    blendMode: BlendMode.srcIn,
    shaderCallback: (bounds) =>
        context.decor.headingGradient.createShader(bounds),
    child: Text(text, style: style, textAlign: textAlign),
  );
}

/// Hairline that fades in from the edges (gold at night).
class GoldDivider extends StatelessWidget {
  const GoldDivider({
    this.margin = const EdgeInsets.symmetric(horizontal: 48),
    super.key,
  });

  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).brightness == Brightness.dark
        ? AppColors.goldDeep
        : context.decor.line;
    return Container(
      height: 1,
      margin: margin,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0),
            color,
            color.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}

/// Translucent rounded card with a hairline border.
class RoyalCard extends StatelessWidget {
  const RoyalCard({
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.margin = EdgeInsets.zero,
    this.radius = 18,
    this.onTap,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final decor = context.decor;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: BorderSide(color: decor.line),
    );
    return Padding(
      padding: margin,
      child: Material(
        color: decor.card,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Small round outlined icon button (month / year arrows).
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final decor = context.decor;
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      color: decor.muted,
      style: IconButton.styleFrom(
        minimumSize: const Size(36, 36),
        fixedSize: const Size(36, 36),
        side: BorderSide(color: decor.line),
        shape: const CircleBorder(),
      ),
    );
  }
}

/// Outlined pill button, e.g. "Today".
class PillButton extends StatelessWidget {
  const PillButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    super.key,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final decor = context.decor;
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: decor.accent,
        disabledForegroundColor: decor.muted,
        side: BorderSide(color: decor.line),
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(
          fontFamilyFallback: AppFonts.fallback,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Small rounded label, e.g. a category or "in 8 days".
class TagBadge extends StatelessWidget {
  const TagBadge({required this.label, this.color, this.icon, super.key});

  final String label;

  /// Text/icon color; the background is a translucent tint of it.
  final Color? color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final fg = color ?? context.decor.accent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: fg.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontFamilyFallback: AppFonts.fallback,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// The moon as it looks on a given lunar day: [illumination] 0 = new, 1 = full;
/// [waxing] lights the right side (as seen from Cambodia).
class MoonPhaseIcon extends StatelessWidget {
  const MoonPhaseIcon({
    required this.illumination,
    required this.waxing,
    this.size = 48,
    super.key,
  });

  /// Illumination for a lunar day number 0-29 (0 = 1 Kert, 14 = 15 Kert).
  factory MoonPhaseIcon.forLunarDay(
    int dayNumber, {
    double size = 48,
    Key? key,
  }) {
    final waxing = dayNumber < 15;
    final k = waxing ? (dayNumber + 1) / 15 : (29 - dayNumber) / 15;
    return MoonPhaseIcon(
      illumination: k.clamp(0, 1).toDouble(),
      waxing: waxing,
      size: size,
      key: key,
    );
  }

  final double illumination;
  final bool waxing;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return CustomPaint(
      size: Size.square(size),
      painter: _MoonPainter(
        illumination: illumination,
        waxing: waxing,
        lit: isDark ? AppColors.goldLight : AppColors.goldDeep,
        dark: isDark ? const Color(0x24FFFFFF) : const Color(0xFFE6E9F2),
      ),
    );
  }
}

class _MoonPainter extends CustomPainter {
  const _MoonPainter({
    required this.illumination,
    required this.waxing,
    required this.lit,
    required this.dark,
  });

  final double illumination;
  final bool waxing;
  final Color lit;
  final Color dark;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.shortestSide / 2;
    final c = Offset(size.width / 2, size.height / 2);
    final disc = Rect.fromCircle(center: c, radius: r);
    canvas.drawCircle(c, r, Paint()..color = dark);
    if (illumination <= 0.01) return;

    // Lit half (right when waxing) …
    final half = Path()
      ..moveTo(c.dx, c.dy - r)
      ..arcTo(disc, -math.pi / 2, waxing ? math.pi : -math.pi, false)
      ..close();
    // … plus or minus the terminator ellipse.
    final rx = (1 - 2 * illumination).abs() * r;
    final ellipse = Path()
      ..addOval(Rect.fromCenter(center: c, width: rx * 2, height: r * 2));
    final litPath = illumination >= 0.5
        ? Path.combine(PathOperation.union, half, ellipse)
        : Path.combine(PathOperation.difference, half, ellipse);
    canvas.drawPath(litPath, Paint()..color = lit);
  }

  @override
  bool shouldRepaint(_MoonPainter old) =>
      old.illumination != illumination ||
      old.waxing != waxing ||
      old.lit != lit ||
      old.dark != dark;
}
