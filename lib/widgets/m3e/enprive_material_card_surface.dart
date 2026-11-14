import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:material_3_expressive/material_3_expressive.dart';

import '../../core/theme/enprive_theme.dart';

/// Material 3 Expressive surface roles supported by [EnpriveMaterialCardSurface].
enum EnpriveCardVariant {
  /// Crisp primary surface with strong tactile lip (e.g. actionable cards, companion cards).
  elevated,

  /// High-chroma/tonal container fill (e.g. stat tiles, telemetry bento blocks).
  tonal,

  /// Warm archival paper / obsidian slate well for policy quotes and evidence receipts.
  archival,

  /// Low-glare outline container for secondary specs and read-only detail rows.
  outlined,

  /// Selected state surface using dual cues (2dp primary border + container tint + tighter corner radius).
  selected,
}

/// Core tactile Material 3 Expressive card foundation for Enprive.
///
/// Merges real [M3ECard] interaction state layers, focus/hover handling, and
/// accessibility semantics with Enprive's signature [EnpriveTactileButton]
/// physical construction:
/// - Crisp `1.5dp` (`2.0dp` when selected) Material border
/// - Grounded solid `0dp`-blur bottom lip (`lipHeight`) in matching/harmonized stone or dark slate
/// - Zero-layout-jump press depression (`topMargin + currentLip == lipHeight`)
/// - M3E spatial corner-radius morphing (`24dp` -> `18dp` on press)
/// - Full `disableAnimations` / reduced-motion compliance
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
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.pressedBorderRadius,
    this.lipHeight,
    this.borderWidth,
    this.padding = const EdgeInsets.all(18),
    this.margin,
    this.selected = false,
    this.enabled = true,
    this.semanticLabel,
    this.haptic = M3EHapticFeedback.light,
  });

  /// Resolves a harmonized bottom tactile lip color matching the surface tone.
  static Color resolveLipColor(
    BuildContext context,
    Color faceColor, {
    Color? accentColor,
    bool selected = false,
  }) {
    final surfaces = context.enpriveSurfaces;
    final scheme = EnpriveM3ETheme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (selected) {
      final keyAccent = accentColor ?? scheme.primary;
      return Color.lerp(
        keyAccent,
        surfaces.tactileSecondaryLip,
        isDark ? 0.55 : 0.28,
      )!;
    }

    if (faceColor == surfaces.card ||
        faceColor == surfaces.cardElevated ||
        faceColor == surfaces.tactileSecondaryBg) {
      return surfaces.tactileSecondaryLip;
    }

    return Color.lerp(
      faceColor,
      isDark ? surfaces.tactileSecondaryLip : surfaces.strongBorder,
      isDark ? 0.72 : 0.44,
    )!;
  }

  /// Resolves the resting Material border color matching card variant and selection.
  static Color resolveBorderColor(
    BuildContext context, {
    required EnpriveCardVariant variant,
    required Color faceColor,
    Color? borderColor,
    Color? accentColor,
    bool selected = false,
  }) {
    if (borderColor != null) return borderColor;
    final surfaces = context.enpriveSurfaces;
    final scheme = EnpriveM3ETheme.of(context).colorScheme;

    if (selected || variant == EnpriveCardVariant.selected) {
      return accentColor ?? scheme.primary;
    }

    return switch (variant) {
      EnpriveCardVariant.elevated => surfaces.tactileSecondaryBorder,
      EnpriveCardVariant.tonal => Color.lerp(
        faceColor,
        surfaces.strongBorder,
        0.55,
      )!,
      EnpriveCardVariant.archival => surfaces.strongBorder.withValues(
        alpha: 0.72,
      ),
      EnpriveCardVariant.outlined => surfaces.strongBorder,
      EnpriveCardVariant.selected => accentColor ?? scheme.primary,
    };
  }

  @override
  State<EnpriveMaterialCardSurface> createState() =>
      _EnpriveMaterialCardSurfaceState();
}

class _EnpriveMaterialCardSurfaceState
    extends State<EnpriveMaterialCardSurface> {
  bool _isPressed = false;
  bool _isHovered = false;
  bool _isFocused = false;

  bool get _isInteractive =>
      widget.enabled && (widget.onPressed != null || widget.onLongPress != null);

  void _setPressed(bool value) {
    if (_isPressed == value || !mounted) return;
    setState(() => _isPressed = value);
  }

  BorderRadius _tightenRadius(BorderRadius base) {
    if (widget.pressedBorderRadius != null) return widget.pressedBorderRadius!;
    Radius shrink(Radius r) {
      if (r.x <= 8) return Radius.circular(math.max(4.0, r.x - 1.5));
      return Radius.circular(math.max(12.0, r.x - 5.0));
    }

    return BorderRadius.only(
      topLeft: shrink(base.topLeft),
      topRight: shrink(base.topRight),
      bottomLeft: shrink(base.bottomLeft),
      bottomRight: shrink(base.bottomRight),
    );
  }

  BorderRadius _insetRadius(BorderRadius base, double inset) {
    Radius insetCorner(Radius r) => Radius.circular(math.max(0.0, r.x - inset));
    return BorderRadius.only(
      topLeft: insetCorner(base.topLeft),
      topRight: insetCorner(base.topRight),
      bottomLeft: insetCorner(base.bottomLeft),
      bottomRight: insetCorner(base.bottomRight),
    );
  }

  @override
  Widget build(BuildContext context) {
    final m3e = EnpriveM3ETheme.of(context);
    final scheme = m3e.colorScheme;
    final surfaces = context.enpriveSurfaces;
    final motion = context.enpriveMotion;
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    final effectiveSelected =
        widget.selected || widget.variant == EnpriveCardVariant.selected;

    final Color defaultFace = switch (widget.variant) {
      EnpriveCardVariant.elevated => surfaces.card,
      EnpriveCardVariant.tonal => surfaces.cardMuted,
      EnpriveCardVariant.archival => surfaces.quoteSurface,
      EnpriveCardVariant.outlined => surfaces.canvas,
      EnpriveCardVariant.selected => scheme.primaryContainer,
    };
    final Color faceColor = widget.backgroundColor ?? defaultFace;

    final double restingLip =
        widget.lipHeight ??
        (effectiveSelected
            ? 3.5
            : (_isInteractive
                  ? 3.5
                  : (widget.variant == EnpriveCardVariant.outlined
                        ? 1.5
                        : 2.5)));

    final double effectiveBorderWidth =
        widget.borderWidth ?? (effectiveSelected ? 2.0 : 1.5);

    final Color resolvedBorder = EnpriveMaterialCardSurface.resolveBorderColor(
      context,
      variant: widget.variant,
      faceColor: faceColor,
      borderColor: widget.borderColor,
      accentColor: widget.accentColor,
      selected: effectiveSelected,
    );

    final Color hoveredBorder =
        (_isHovered || _isFocused) && !effectiveSelected && _isInteractive
        ? Color.lerp(resolvedBorder, scheme.primary, 0.45)!
        : resolvedBorder;

    final Color resolvedLip =
        widget.lipColor ??
        EnpriveMaterialCardSurface.resolveLipColor(
          context,
          faceColor,
          accentColor: widget.accentColor,
          selected: effectiveSelected,
        );

    final bool depressed = _isInteractive && _isPressed && !reduceMotion;
    final double topOffset = depressed ? restingLip : 0.0;
    final double currentLip = depressed ? 0.0 : restingLip;

    final BorderRadius activeRadius = depressed
        ? _tightenRadius(widget.borderRadius)
        : widget.borderRadius;
    final BorderRadius innerRadius = _insetRadius(
      activeRadius,
      effectiveBorderWidth,
    );

    final Duration animDuration = reduceMotion
        ? Duration.zero
        : (_isPressed
              ? const Duration(milliseconds: 90)
              : motion.spatialFast);
    final Curve animCurve = reduceMotion
        ? Curves.linear
        : motion.emphasizedCurve;

    Widget cardBody = M3ECard(
      variant: M3ECardVariant.filled,
      color: faceColor,
      elevation: 0,
      border: BorderSide.none,
      borderRadius: innerRadius,
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
      onStateChanged: (states) {
        final nextPressed = states.pressed;
        final nextHovered = states.hovered;
        final nextFocused = states.focused;
        if (nextPressed != _isPressed ||
            nextHovered != _isHovered ||
            nextFocused != _isFocused) {
          if (!mounted) return;
          setState(() {
            _isPressed = nextPressed;
            _isHovered = nextHovered;
            _isFocused = nextFocused;
          });
        }
      },
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
      margin: EdgeInsets.only(top: topOffset, bottom: currentLip),
      decoration: BoxDecoration(
        color: faceColor,
        borderRadius: activeRadius,
        border: effectiveBorderWidth > 0
            ? Border.all(color: hoveredBorder, width: effectiveBorderWidth)
            : null,
        boxShadow: currentLip > 0
            ? [
                BoxShadow(
                  color: resolvedLip,
                  offset: Offset(0, currentLip),
                  blurRadius: 0,
                ),
              ]
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: cardBody,
    );

    if (widget.margin != null) {
      animatedShell = Padding(padding: widget.margin!, child: animatedShell);
    }

    return animatedShell;
  }
}
