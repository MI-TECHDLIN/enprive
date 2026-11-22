import 'package:flutter/material.dart';

import '../core/theme/enprive_theme.dart';
import 'enprive_tactile_pressable.dart';

/// Emphasis of an [EnpriveTactileButton], highest first.
enum EnpriveButtonVariant {
  /// `primary` fill: the one main action on a screen.
  filled,

  /// `secondaryContainer` fill: supporting actions next to a filled button.
  tonal,

  /// `surfaceContainerLowest` face with primary ink: a supporting action
  /// that must stand off a gradient or patterned hero.
  elevated,

  /// `outlineVariant` border on the surface: a way to change your mind.
  outlined,

  /// No container: the lowest-priority action inside a group.
  text,
}

/// Enprive's Material 3 Expressive button.
///
/// A full-pill face (56dp, M3E medium) whose corners morph to 12dp while
/// pressed on the fast spatial spring, colored from the theme roles of
/// [variant]. Focus, keyboard, pointer and semantic activation come from the
/// shared [EnpriveTactilePressable] core, so Tab, Enter, Space, the focus ring
/// and TalkBack behave as before. The label wraps instead of shrinking when
/// text is scaled up, and the shape stays still under reduced motion.
class EnpriveTactileButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  /// Shorthand for [EnpriveButtonVariant.tonal] when [variant] is not given.
  final bool isSecondary;
  final Widget? leading;

  /// Minimum height of the button face.
  final double height;
  final EnpriveButtonVariant? variant;

  const EnpriveTactileButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isSecondary = false,
    this.leading,
    this.height = 56.0,
    this.variant,
  });

  /// Corner radius of the face while pressed.
  static const double pressedRadius = 12.0;

  EnpriveButtonVariant get effectiveVariant =>
      variant ??
      (isSecondary ? EnpriveButtonVariant.tonal : EnpriveButtonVariant.filled);

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
    final scheme = EnpriveM3ETheme.of(context).colorScheme;
    final surfaces = context.enpriveSurfaces;
    final typography = EnpriveM3ETheme.of(context).typography;
    final buttonVariant = effectiveVariant;

    final (Color face, Color ink, Color? border) = !isEnabled
        ? (
            buttonVariant == EnpriveButtonVariant.text
                ? Colors.transparent
                : surfaces.disabledBg,
            surfaces.disabledFg,
            null,
          )
        : switch (buttonVariant) {
            EnpriveButtonVariant.filled => (
              scheme.primary,
              scheme.onPrimary,
              null,
            ),
            EnpriveButtonVariant.tonal => (
              scheme.secondaryContainer,
              scheme.onSecondaryContainer,
              null,
            ),
            EnpriveButtonVariant.elevated => (
              scheme.surfaceContainerLowest,
              scheme.primary,
              null,
            ),
            EnpriveButtonVariant.outlined => (
              Colors.transparent,
              scheme.onSurfaceVariant,
              scheme.outlineVariant,
            ),
            EnpriveButtonVariant.text => (
              Colors.transparent,
              scheme.primary,
              null,
            ),
          };

    final bool morph = isPressed && !reduceMotion;
    final double radius = morph ? pressedRadius : height / 2;
    final TextStyle labelStyle =
        (buttonVariant == EnpriveButtonVariant.filled
                ? typography.emphasized.titleMedium
                : typography.baseline.titleMedium)
            .copyWith(color: ink, height: 1.25);

    return AnimatedContainer(
      duration: reduceMotion
          ? Duration.zero
          : EnpriveSpringCurve.fastSpatial.duration,
      curve: EnpriveSpringCurve.fastSpatial,
      constraints: BoxConstraints(
        minHeight: height < EnpriveSpacing.minTouchTarget
            ? EnpriveSpacing.minTouchTarget
            : height,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: face,
        borderRadius: BorderRadius.circular(radius),
        border: border == null ? null : Border.all(color: border),
      ),
      child: Center(
        heightFactor: 1,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[
              IconTheme.merge(
                data: IconThemeData(color: ink, size: 20),
                child: leading!,
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: labelStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
