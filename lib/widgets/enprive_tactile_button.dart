import 'package:flutter/material.dart';
import '../core/theme/enprive_theme.dart';

/// A tactile pressable pill button with a solid 4dp bottom lip that physically
/// collapses and subtly morphs corner curvature on press (M3 Expressive pattern),
/// adapting automatically to Light and Dark themes via [EnpriveSurfaceTokens].
class EnpriveTactileButton extends StatefulWidget {
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
  State<EnpriveTactileButton> createState() => _EnpriveTactileButtonState();
}

class _EnpriveTactileButtonState extends State<EnpriveTactileButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onPressed != null;
    final bool reduceMotion =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final surfaces = context.surfaceTokens;

    final Color faceColor = isEnabled
        ? (widget.isSecondary
            ? surfaces.tactileSecondaryBg
            : surfaces.tactilePrimaryBg)
        : surfaces.disabledBg;

    final Color lipColor = isEnabled
        ? (widget.isSecondary
            ? surfaces.tactileSecondaryLip
            : surfaces.tactilePrimaryLip)
        : surfaces.hairlineBorder;

    final Color textColor = isEnabled
        ? (widget.isSecondary
            ? surfaces.tactileSecondaryFg
            : surfaces.tactilePrimaryFg)
        : surfaces.disabledFg;

    const double lipHeight = 4.0;
    final double topMargin = _isPressed && !reduceMotion ? lipHeight : 0.0;
    final double currentLip = _isPressed && !reduceMotion ? 0.0 : lipHeight;
    // M3 Expressive interactive shape tension: stadium at rest, slightly squircle on press
    final double cornerRadius =
        _isPressed && !reduceMotion ? 16.0 : widget.height / 2;

    return Semantics(
      container: true,
      button: true,
      enabled: isEnabled,
      label: widget.label,
      child: GestureDetector(
        onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
        onTapUp: isEnabled
            ? (_) {
                setState(() => _isPressed = false);
                widget.onPressed?.call();
              }
            : null,
        onTapCancel:
            isEnabled ? () => setState(() => _isPressed = false) : null,
        child: AnimatedContainer(
          duration: reduceMotion
              ? Duration.zero
              : const Duration(milliseconds: 90),
          curve: Curves.easeOutCubic,
          margin: EdgeInsets.only(top: topMargin),
          constraints: const BoxConstraints(
            minHeight: EnpriveSpacing.minTouchTarget,
          ),
          height: widget.height,
          decoration: BoxDecoration(
            color: faceColor,
            borderRadius: BorderRadius.circular(cornerRadius),
            border: widget.isSecondary || !isEnabled
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
              child: ExcludeSemantics(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.leading != null) ...[
                        widget.leading!,
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.label,
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
          ),
        ),
      ),
    );
  }
}
