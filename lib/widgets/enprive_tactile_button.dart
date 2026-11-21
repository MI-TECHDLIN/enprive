import 'package:flutter/material.dart';

import '../core/theme/enprive_theme.dart';
import 'enprive_tactile_pressable.dart';

/// A tactile pressable pill button with a solid 4dp bottom lip that physically
/// collapses and subtly morphs corner curvature on press (M3 Expressive pattern),
/// adapting automatically to Light and Dark themes via [EnpriveSurfaceTokens].
///
/// Focus, keyboard, pointer and semantic activation come from the shared
/// [EnpriveTactilePressable] core.
class EnpriveTactileButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isSecondary;
  final Widget? leading;
  final double height;

  const EnpriveTactileButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isSecondary = false,
    this.leading,
    this.height = 54.0,
  });

  @override
  Widget build(BuildContext context) {
    return EnpriveTactilePressable(
      label: label,
      onPressed: onPressed,
      builder: _buildFace,
    );
  }

  Widget _buildFace(BuildContext context, bool isPressed) {
    final bool isEnabled = onPressed != null;
    final bool reduceMotion =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final surfaces = context.surfaceTokens;

    final Color faceColor = isEnabled
        ? (isSecondary
              ? surfaces.tactileSecondaryBg
              : surfaces.tactilePrimaryBg)
        : surfaces.disabledBg;

    final Color lipColor = isEnabled
        ? (isSecondary
              ? surfaces.tactileSecondaryLip
              : surfaces.tactilePrimaryLip)
        : surfaces.hairlineBorder;

    final Color textColor = isEnabled
        ? (isSecondary
              ? surfaces.tactileSecondaryFg
              : surfaces.tactilePrimaryFg)
        : surfaces.disabledFg;

    const double lipHeight = 4.0;
    final double topMargin = isPressed && !reduceMotion ? lipHeight : 0.0;
    final double currentLip = isPressed && !reduceMotion ? 0.0 : lipHeight;
    // M3 Expressive interactive shape tension: stadium at rest, slightly squircle on press
    final double cornerRadius = isPressed && !reduceMotion ? 16.0 : height / 2;

    return AnimatedContainer(
      duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 90),
      curve: Curves.easeOutCubic,
      margin: EdgeInsets.only(top: topMargin),
      constraints: const BoxConstraints(
        minHeight: EnpriveSpacing.minTouchTarget,
      ),
      height: height,
      decoration: BoxDecoration(
        color: faceColor,
        borderRadius: BorderRadius.circular(cornerRadius),
        border: isSecondary || !isEnabled
            ? Border.all(
                color: isEnabled
                    ? surfaces.tactileSecondaryBorder
                    : surfaces.hairlineBorder,
                width: 1.5,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: lipColor,
            offset: Offset(0, currentLip),
            blurRadius: 0,
          ),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (leading != null) ...[leading!, const SizedBox(width: 8)],
                Text(
                  label,
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: EnpriveTheme.primaryDisplayFontFamily,
                    color: textColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
