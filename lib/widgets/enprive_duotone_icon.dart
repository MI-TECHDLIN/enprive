import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';

/// Renders a layered duotone SVG icon via [Iconify] with centered sizing
/// so fixed-size containers do not stretch the vector artwork.
class EnpriveDuotoneIcon extends StatelessWidget {
  final String svg;
  final Color color;
  final double size;

  const EnpriveDuotoneIcon(
    this.svg, {
    super.key,
    required this.color,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Center(
        child: Iconify(
          svg,
          size: size,
          color: color,
        ),
      ),
    );
  }
}
