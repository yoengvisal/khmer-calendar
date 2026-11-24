import 'package:material_ui/material_ui.dart';

/// The Khmer Calendar mark ("Kbach Kor"). Master artwork: branding/build_logo.py.
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = 64});

  static const assetPath = 'assets/branding/logo-mark.png';

  final double size;

  @override
  Widget build(BuildContext context) => Image.asset(
    assetPath,
    width: size,
    height: size,
    filterQuality: FilterQuality.medium,
    excludeFromSemantics: true,
  );
}
