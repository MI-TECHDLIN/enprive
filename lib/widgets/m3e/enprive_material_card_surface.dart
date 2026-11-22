import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:material_3_expressive/material_3_expressive.dart';

import '../../core/theme/enprive_theme.dart';

/// Material 3 Expressive surface roles supported by [EnpriveMaterialCardSurface].
enum EnpriveCardVariant {
  /// Everyday card on the page canvas (`surfaceContainer`).
  elevated,

  /// Tonal well one step stronger (`surfaceContainerHigh`), e.g. stat tiles.
  tonal,

  /// Quiet paper well for policy quotes and evidence receipts.
  archival,

  /// Quietest step (`surfaceContainerLow`) for secondary, read-only rows.
  outlined,

  /// Selected state: `secondaryContainer` fill plus a tighter corner; pair it
  /// with a check icon in the child so selection never relies on color alone.
  selected,
}

/// Core Material 3 Expressive card foundation for Enprive.
///
/// Wraps a real [M3ECard] (state layers, focus ring, hover, haptics and
/// semantics) in a tonal face:
/// - no outline and no shadow: depth comes from `surfaceContainer*` steps;
/// - the fill is chosen per [variant] unless [backgroundColor] is given;
/// - interactive cards morph their corners slightly tighter while pressed,
///   on the fast spatial spring, and stay still under reduced motion.
///
/// [lipHeight], [lipColor], [borderColor], [borderWidth] and [accentColor]
/// are kept for source compatibility with existing call sites and have no
/// visual effect in the tonal skin.
class EnpriveMaterialCardSurface extends StatefulWidget {
  final Widget child;
  final EnpriveCardVariant variant;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? lipColor;
  final Color? accentColor;
  final BorderRadius borderRadius;
  final BorderRadius? pressedBorderRadius;
  final double? lipHeight;
  final double? borderWidth;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final bool selected;
  final bool enabled;
  final String? semanticLabel;
  final M3EHapticFeedback haptic;

  const EnpriveMaterialCardSurface({
    super.key,
    required this.child,
    this.variant = EnpriveCardVariant.elevated,
    this.onPressed,
    this.onLongPress,
    this.backgroundColor,
    this.borderColor,
    this.lipColor,
    this.accentColor,
    this.borderRadius = const BorderRadius.all(
      Radius.circular(EnpriveRadii.card),
    ),
    this.pressedBorderRadius,
    this.lipHeight,
    this.borderWidth,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.selected = false,
    this.enabled = true,
    this.semanticLabel,
    this.haptic = M3EHapticFeedback.light,
  });

  /// The tonal fill for [variant] (or the selected fill) in the current theme.
  static Color resolveFaceColor(
    BuildContext context, {
    required EnpriveCardVariant variant,
    bool selected = false,
  }) {
    final scheme = EnpriveM3ETheme.of(context).colorScheme;
    if (selected || variant == EnpriveCardVariant.selected) {
      return scheme.secondaryContainer;
    }
    return switch (variant) {
      EnpriveCardVariant.elevated => scheme.surfaceContainer,
      EnpriveCardVariant.tonal => scheme.surfaceContainerHigh,
      EnpriveCardVariant.archival => context.enpriveSurfaces.quoteSurface,
      EnpriveCardVariant.outlined => scheme.surfaceContainerLow,
      EnpriveCardVariant.selected => scheme.secondaryContainer,
    };
  }

  @override
  State<EnpriveMaterialCardSurface> createState() =>
      _EnpriveMaterialCardSurfaceState();
}

class _EnpriveMaterialCardSurfaceState
    extends State<EnpriveMaterialCardSurface> {
  bool _isPressed = false;

  bool get _isInteractive =>
      widget.enabled &&
      (widget.onPressed != null || widget.onLongPress != null);

  void _setPressed(bool value) {
    if (_isPressed == value || !mounted) return;
    setState(() => _isPressed = value);
  }

  BorderRadius _tightenRadius(BorderRadius base) {
    if (widget.pressedBorderRadius != null) return widget.pressedBorderRadius!;
    Radius shrink(Radius r) {
      if (r.x <= 8) return r;
      return Radius.circular(math.max(12.0, r.x - 6.0));
    }

    return BorderRadius.only(
      topLeft: shrink(base.topLeft),
      topRight: shrink(base.topRight),
      bottomLeft: shrink(base.bottomLeft),
      bottomRight: shrink(base.bottomRight),
    );
  }

  @override
  Widget build(BuildContext context) {
    final motion = context.enpriveMotion;
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    final effectiveSelected =
        widget.selected || widget.variant == EnpriveCardVariant.selected;
    final Color faceColor =
        widget.backgroundColor ??
        EnpriveMaterialCardSurface.resolveFaceColor(
          context,
          variant: widget.variant,
          selected: effectiveSelected,
        );

    final bool morph =
        !reduceMotion && ((_isInteractive && _isPressed) || effectiveSelected);
    final BorderRadius activeRadius = morph
        ? _tightenRadius(widget.borderRadius)
        : widget.borderRadius;

    final Duration animDuration = reduceMotion
        ? Duration.zero
        : motion.spatialFast;
    final Curve animCurve = reduceMotion
        ? Curves.linear
        : motion.emphasizedCurve;

    Widget cardBody = M3ECard(
      variant: M3ECardVariant.filled,
      color: faceColor,
      elevation: 0,
      // No border argument: M3ECard turns any BorderSide (even
      // BorderSide.none) into Border.all, which paints a 1px hairline.
      borderRadius: activeRadius,
      padding: EdgeInsets.zero,
      enabled: widget.enabled,
      onPressed: _isInteractive ? widget.onPressed : null,
      onLongPress: widget.enabled ? widget.onLongPress : null,
      haptic: widget.haptic,
      semanticLabel: widget.semanticLabel,
      showFocusFill: true,
      showFocusRing: true,
      trackHover: true,
      animationDuration: animDuration,
      animationCurve: animCurve,
      onStateChanged: (states) => _setPressed(states.pressed),
      child: Padding(padding: widget.padding, child: widget.child),
    );

    if (_isInteractive) {
      cardBody = Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => _setPressed(true),
        onPointerUp: (_) => _setPressed(false),
        onPointerCancel: (_) => _setPressed(false),
        child: cardBody,
      );
    }

    Widget animatedShell = AnimatedContainer(
      duration: animDuration,
      curve: animCurve,
      decoration: BoxDecoration(color: faceColor, borderRadius: activeRadius),
      clipBehavior: Clip.antiAlias,
      child: cardBody,
    );

    if (widget.margin != null) {
      animatedShell = Padding(padding: widget.margin!, child: animatedShell);
    }

    return animatedShell;
  }
}
