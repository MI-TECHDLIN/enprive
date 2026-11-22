import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Builds the visual face of an [EnpriveTactilePressable] for its current
/// pointer press state.
typedef EnpriveTactileFaceBuilder = Widget Function(
  BuildContext context,
  bool isPressed,
);

/// Shared accessible core of Enprive's tactile pill buttons
/// ([EnpriveTactileButton] and the review hero CTA).
///
/// It owns the one activation path for every input method, so [onPressed]
/// fires exactly once per activation:
/// - pointer: a completed tap ([GestureDetector.onTap]);
/// - keyboard: Enter or Space while focused ([ActivateIntent] /
///   [ButtonActivateIntent]);
/// - TalkBack, Switch Access and other assistive technology: the explicit
///   [SemanticsAction.tap] on the single button node.
///
/// The gesture detector is excluded from semantics and only drives the
/// pressed-lip visuals through [builder]. The face is excluded from semantics
/// so [label] is announced once. A focus ring is painted outside the stadium
/// face while the button holds keyboard focus. A null [onPressed] disables the
/// button: no semantic actions, not focusable, and no press visuals.
class EnpriveTactilePressable extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final EnpriveTactileFaceBuilder builder;

  const EnpriveTactilePressable({
    super.key,
    required this.label,
    required this.onPressed,
    required this.builder,
  });

  /// Key of the [CustomPaint] that draws the keyboard focus ring.
  @visibleForTesting
  static const Key focusRingKey = Key('enprive_tactile_focus_ring');

  /// Stroke width of the focus ring, following the M3 focus indicator.
  static const double focusRingWidth = 3.0;

  /// Gap between the button face and the focus ring.
  static const double focusRingGap = 2.0;

  /// Focus ring colour: the theme's on-surface ink, which keeps at least
  /// 3:1 contrast against every Enprive canvas, card and sheet surface in
  /// light and dark.
  static Color focusRingColorOf(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  @override
  State<EnpriveTactilePressable> createState() =>
      _EnpriveTactilePressableState();
}

class _EnpriveTactilePressableState extends State<EnpriveTactilePressable> {
  final FocusNode _focusNode = FocusNode(debugLabel: 'EnpriveTactilePressable');
  late final Map<Type, Action<Intent>> _actions = <Type, Action<Intent>>{
    ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: _invoke),
    ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(
      onInvoke: _invoke,
    ),
  };

  bool _isPressed = false;
  bool _hasFocus = false;
  bool _showFocusRing = false;

  bool get _isEnabled => widget.onPressed != null;

  Object? _invoke(Intent intent) {
    _activate();
    return null;
  }

  void _activate() {
    if (_isEnabled) widget.onPressed!();
  }

  void _setPressed(bool value) {
    if (_isPressed != value) setState(() => _isPressed = value);
  }

  @override
  void didUpdateWidget(EnpriveTactilePressable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isEnabled) _isPressed = false;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = _isEnabled;

    return Semantics(
      container: true,
      excludeSemantics: true,
      button: true,
      enabled: isEnabled,
      focusable: isEnabled,
      focused: isEnabled ? _hasFocus : null,
      label: widget.label,
      onTap: isEnabled ? _activate : null,
      onFocus: isEnabled && defaultTargetPlatform != TargetPlatform.iOS
          ? _focusNode.requestFocus
          : null,
      child: FocusableActionDetector(
        enabled: isEnabled,
        focusNode: _focusNode,
        includeFocusSemantics: false,
        mouseCursor: isEnabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        actions: _actions,
        onFocusChange: (focused) => setState(() => _hasFocus = focused),
        onShowFocusHighlight: (show) => setState(() => _showFocusRing = show),
        child: GestureDetector(
          excludeFromSemantics: true,
          onTapDown: isEnabled ? (_) => _setPressed(true) : null,
          onTapUp: isEnabled ? (_) => _setPressed(false) : null,
          onTapCancel: isEnabled ? () => _setPressed(false) : null,
          onTap: isEnabled ? _activate : null,
          child: CustomPaint(
            key: EnpriveTactilePressable.focusRingKey,
            foregroundPainter: isEnabled && _showFocusRing
                ? _FocusRingPainter(
                    color: EnpriveTactilePressable.focusRingColorOf(context),
                  )
                : null,
            child: widget.builder(context, isEnabled && _isPressed),
          ),
        ),
      ),
    );
  }
}

/// Paints a stadium focus ring just outside the button bounds.
class _FocusRingPainter extends CustomPainter {
  final Color color;

  const _FocusRingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const double outset =
        EnpriveTactilePressable.focusRingGap +
        EnpriveTactilePressable.focusRingWidth / 2;
    final Rect ring = (Offset.zero & size).inflate(outset);
    canvas.drawRRect(
      RRect.fromRectAndRadius(ring, Radius.circular(ring.shortestSide / 2)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = EnpriveTactilePressable.focusRingWidth
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_FocusRingPainter oldDelegate) =>
      oldDelegate.color != color;
}
