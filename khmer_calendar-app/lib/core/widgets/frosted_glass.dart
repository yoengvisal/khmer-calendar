import 'dart:ui' show ImageFilter;

import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

/// Frosted-glass backing for a [Card] that sits over the header wallpaper:
/// blurs whatever is behind it and lets the card's fill be a little more
/// see-through, so the wallpaper glows through softly while the content stays
/// sharp and readable.
class FrostedGlass extends StatelessWidget {
  const FrostedGlass({
    required this.child,
    this.radius = 22,
    this.sigma = 18,
    super.key,
  });

  final Widget child;

  /// Must match the card's corner radius (cardTheme uses 22).
  final double radius;
  final double sigma;

  /// Highest fill opacity a frosted card keeps; more opaque fills hide the
  /// blur entirely.
  static const double maxFillAlpha = .8;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fill = context.palette.card;
    final glassFill = fill.a > maxFillAlpha
        ? fill.withValues(alpha: maxFillAlpha)
        : fill;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: Theme(
          data: theme.copyWith(
            cardTheme: theme.cardTheme.copyWith(color: glassFill),
          ),
          child: child,
        ),
      ),
    );
  }
}
