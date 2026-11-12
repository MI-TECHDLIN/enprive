import 'package:flutter/material.dart';
import '../core/theme/enprive_colors.dart';

/// A tactile pressable pill button inspired by Brilliant's interaction design.
/// Has a solid 4dp bottom lip that physically collapses on press.
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
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    final Color faceColor = isEnabled
        ? (widget.isSecondary ? EnpriveColors.surface : EnpriveColors.ctaInk)
        : EnpriveColors.surfaceMuted;

    final Color lipColor = isEnabled
        ? (widget.isSecondary ? const Color(0xFFD3CFC7) : EnpriveColors.ctaLip)
        : const Color(0xFFE2E0DB);

    final Color textColor = isEnabled
        ? (widget.isSecondary ? EnpriveColors.ink : Colors.white)
        : EnpriveColors.inkDisabled;

    const double lipHeight = 4.0;
    final double topMargin = _isPressed && !reduceMotion ? lipHeight : 0.0;
    final double currentLip = _isPressed && !reduceMotion ? 0.0 : lipHeight;

    return Semantics(
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
        onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
        child: AnimatedContainer(
          duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 80),
          margin: EdgeInsets.only(top: topMargin),
          height: widget.height,
          decoration: BoxDecoration(
            color: faceColor,
            borderRadius: BorderRadius.circular(widget.height / 2),
            border: widget.isSecondary
                ? Border.all(color: const Color(0xFFE2DFD8), width: 1.5)
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.leading != null) ...[
                  widget.leading!,
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.label,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w700,
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
