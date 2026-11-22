import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart' show SpringSimulation;
import 'package:material_3_expressive/material_3_expressive.dart'
    show M3EMotion, M3ESpring;
import 'package:material_color_utilities/material_color_utilities.dart'
    show TonalPalette;

import 'enprive_colors.dart';
import 'enprive_theme.dart' show EnpriveTheme;

/// Immutable semantic color bundle (`background`, `foreground`, `border`, `icon`)
/// with built-in WCAG 2.1 contrast calculation.
@immutable
class SemanticColorPair {
  final Color background;
  final Color foreground;
  final Color border;
  final Color icon;

  const SemanticColorPair({
    required this.background,
    required this.foreground,
    required this.border,
    Color? icon,
  }) : icon = icon ?? foreground;

  /// Actual sRGB WCAG 2.1 contrast ratio between [foreground] and [background].
  double get contrastRatio =>
      EnpriveContrast.contrastRatio(foreground, background);

  SemanticColorPair copyWith({
    Color? background,
    Color? foreground,
    Color? border,
    Color? icon,
  }) {
    return SemanticColorPair(
      background: background ?? this.background,
      foreground: foreground ?? this.foreground,
      border: border ?? this.border,
      icon: icon ?? this.icon,
    );
  }

  static SemanticColorPair lerp(
    SemanticColorPair a,
    SemanticColorPair b,
    double t,
  ) {
    return SemanticColorPair(
      background: Color.lerp(a.background, b.background, t)!,
      foreground: Color.lerp(a.foreground, b.foreground, t)!,
      border: Color.lerp(a.border, b.border, t)!,
      icon: Color.lerp(a.icon, b.icon, t)!,
    );
  }
}

/// Centralized Material 3 `ThemeExtension` for Enprive's evidence states,
/// provenance badges, and Deni ambient stage lighting.
@immutable
class EnpriveSemanticColors extends ThemeExtension<EnpriveSemanticColors> {
  final SemanticColorPair noConcern;
  final SemanticColorPair reviewRecommended;
  final SemanticColorPair highConcern;
  final SemanticColorPair insufficientEvidence;
  final SemanticColorPair onDevice;
  final SemanticColorPair inCloud;
  final SemanticColorPair offlineFallback;
  final SemanticColorPair unknown;
  final Color deniPrimaryGlow;
  final Color deniSecondaryGlow;

  const EnpriveSemanticColors({
    required this.noConcern,
    required this.reviewRecommended,
    required this.highConcern,
    required this.insufficientEvidence,
    required this.onDevice,
    required this.inCloud,
    required this.offlineFallback,
    required this.unknown,
    required this.deniPrimaryGlow,
    required this.deniSecondaryGlow,
  });

  /// Evidence-state and provenance roles derived from the generated
  /// [ColorScheme] plus the review amber static color.
  ///
  /// One meaning per color: review recommended is amber; "no concern" uses
  /// the quiet secondary container with a check icon, never a success green;
  /// insufficient evidence and offline/unknown provenance stay neutral; red
  /// (error) is reserved for failures.
  factory EnpriveSemanticColors.fromColorScheme(
    ColorScheme scheme, {
    double contrastLevel = 0.0,
  }) {
    final amber = EnpriveStaticColors.reviewAmber(
      scheme.brightness,
      contrastLevel: contrastLevel,
    );
    SemanticColorPair pair(Color background, Color foreground) =>
        SemanticColorPair(
          background: background,
          foreground: foreground,
          border: background,
        );
    final neutral = pair(scheme.surfaceContainerHighest, scheme.onSurface);
    final isDark = scheme.brightness == Brightness.dark;
    return EnpriveSemanticColors(
      noConcern: pair(scheme.secondaryContainer, scheme.onSecondaryContainer),
      reviewRecommended: SemanticColorPair(
        background: amber.container,
        foreground: amber.onContainer,
        border: amber.container,
        icon: amber.onContainer,
      ),
      highConcern: pair(scheme.errorContainer, scheme.onErrorContainer),
      insufficientEvidence: neutral,
      onDevice: pair(scheme.primaryContainer, scheme.onPrimaryContainer),
      inCloud: pair(scheme.tertiaryContainer, scheme.onTertiaryContainer),
      offlineFallback: neutral,
      unknown: neutral,
      // Deni's stage glow keeps the mascot's own teal and apricot light.
      deniPrimaryGlow: isDark
          ? const Color(0x472DD4BF)
          : const Color(0x291E9E8F),
      deniSecondaryGlow: isDark
          ? const Color(0x1FF4A261)
          : const Color(0x12F4A261),
    );
  }

  static final EnpriveSemanticColors light =
      EnpriveSemanticColors.fromColorScheme(EnpriveTheme.lightColorScheme);

  static final EnpriveSemanticColors dark =
      EnpriveSemanticColors.fromColorScheme(EnpriveTheme.darkColorScheme);

  @override
  EnpriveSemanticColors copyWith({
    SemanticColorPair? noConcern,
    SemanticColorPair? reviewRecommended,
    SemanticColorPair? highConcern,
    SemanticColorPair? insufficientEvidence,
    SemanticColorPair? onDevice,
    SemanticColorPair? inCloud,
    SemanticColorPair? offlineFallback,
    SemanticColorPair? unknown,
    Color? deniPrimaryGlow,
    Color? deniSecondaryGlow,
  }) {
    return EnpriveSemanticColors(
      noConcern: noConcern ?? this.noConcern,
      reviewRecommended: reviewRecommended ?? this.reviewRecommended,
      highConcern: highConcern ?? this.highConcern,
      insufficientEvidence: insufficientEvidence ?? this.insufficientEvidence,
      onDevice: onDevice ?? this.onDevice,
      inCloud: inCloud ?? this.inCloud,
      offlineFallback: offlineFallback ?? this.offlineFallback,
      unknown: unknown ?? this.unknown,
      deniPrimaryGlow: deniPrimaryGlow ?? this.deniPrimaryGlow,
      deniSecondaryGlow: deniSecondaryGlow ?? this.deniSecondaryGlow,
    );
  }

  @override
  EnpriveSemanticColors lerp(
    covariant ThemeExtension<EnpriveSemanticColors>? other,
    double t,
  ) {
    if (other is! EnpriveSemanticColors) return this;
    return EnpriveSemanticColors(
      noConcern: SemanticColorPair.lerp(noConcern, other.noConcern, t),
      reviewRecommended: SemanticColorPair.lerp(
        reviewRecommended,
        other.reviewRecommended,
        t,
      ),
      highConcern: SemanticColorPair.lerp(highConcern, other.highConcern, t),
      insufficientEvidence: SemanticColorPair.lerp(
        insufficientEvidence,
        other.insufficientEvidence,
        t,
      ),
      onDevice: SemanticColorPair.lerp(onDevice, other.onDevice, t),
      inCloud: SemanticColorPair.lerp(inCloud, other.inCloud, t),
      offlineFallback: SemanticColorPair.lerp(
        offlineFallback,
        other.offlineFallback,
        t,
      ),
      unknown: SemanticColorPair.lerp(unknown, other.unknown, t),
      deniPrimaryGlow: Color.lerp(deniPrimaryGlow, other.deniPrimaryGlow, t)!,
      deniSecondaryGlow: Color.lerp(
        deniSecondaryGlow,
        other.deniSecondaryGlow,
        t,
      )!,
    );
  }
}

/// Centralized Material 3 `ThemeExtension` for Enprive's layered paper/slate
/// surfaces, borders, tactile button lips, and grouped-containment radii.
@immutable
class EnpriveSurfaceTokens extends ThemeExtension<EnpriveSurfaceTokens> {
  final Color canvas;
  final Color card;
  final Color cardMuted;
  final Color cardElevated;
  final Color sheetSurface;
  final Color quoteSurface;
  final Color hairlineBorder;
  final Color strongBorder;
  final Color tactilePrimaryBg;
  final Color tactilePrimaryFg;
  final Color tactilePrimaryLip;
  final Color tactileSecondaryBg;
  final Color tactileSecondaryFg;
  final Color tactileSecondaryLip;
  final Color tactileSecondaryBorder;
  final Color disabledBg;
  final Color disabledFg;
  final Color ambientShadowColor;
  final double groupedOuterRadius;
  final double groupedInnerRadius;

  const EnpriveSurfaceTokens({
    required this.canvas,
    required this.card,
    required this.cardMuted,
    required this.cardElevated,
    required this.sheetSurface,
    required this.quoteSurface,
    required this.hairlineBorder,
    required this.strongBorder,
    required this.tactilePrimaryBg,
    required this.tactilePrimaryFg,
    required this.tactilePrimaryLip,
    required this.tactileSecondaryBg,
    required this.tactileSecondaryFg,
    required this.tactileSecondaryLip,
    required this.tactileSecondaryBorder,
    required this.disabledBg,
    required this.disabledFg,
    required this.ambientShadowColor,
    this.groupedOuterRadius = EnpriveRadii.segmentedOuter,
    this.groupedInnerRadius = EnpriveRadii.segmentedInner,
  });

  Color get container => cardMuted;
  Color get quoteCallout => quoteSurface;

  /// Maps Enprive's surface vocabulary onto tonal `surfaceContainer*` roles.
  ///
  /// Cards are told apart by tone, not by outlines or shadows: the canvas is
  /// `surface`, everyday cards `surfaceContainer`, tonal wells
  /// `surfaceContainerHigh`. The tactile "lip" fields are kept for API
  /// compatibility and now equal their faces, so nothing paints a lip.
  factory EnpriveSurfaceTokens.fromColorScheme(ColorScheme scheme) {
    final disabledBg = Color.alphaBlend(
      scheme.onSurface.withValues(alpha: 0.10),
      scheme.surface,
    );
    return EnpriveSurfaceTokens(
      canvas: scheme.surface,
      card: scheme.surfaceContainer,
      cardMuted: scheme.surfaceContainerHigh,
      cardElevated: scheme.surfaceContainerLow,
      sheetSurface: scheme.surfaceContainerLow,
      quoteSurface: scheme.surfaceContainerHigh,
      hairlineBorder: scheme.outlineVariant,
      strongBorder: scheme.outline,
      tactilePrimaryBg: scheme.primary,
      tactilePrimaryFg: scheme.onPrimary,
      tactilePrimaryLip: scheme.primary,
      tactileSecondaryBg: scheme.secondaryContainer,
      tactileSecondaryFg: scheme.onSecondaryContainer,
      tactileSecondaryLip: scheme.secondaryContainer,
      tactileSecondaryBorder: scheme.secondaryContainer,
      disabledBg: disabledBg,
      disabledFg: scheme.onSurfaceVariant,
      ambientShadowColor: const Color(0x00000000),
      groupedOuterRadius: EnpriveRadii.segmentedOuter,
      groupedInnerRadius: EnpriveRadii.segmentedInner,
    );
  }

  static final EnpriveSurfaceTokens light =
      EnpriveSurfaceTokens.fromColorScheme(EnpriveTheme.lightColorScheme);

  static final EnpriveSurfaceTokens dark = EnpriveSurfaceTokens.fromColorScheme(
    EnpriveTheme.darkColorScheme,
  );

  @override
  EnpriveSurfaceTokens copyWith({
    Color? canvas,
    Color? card,
    Color? cardMuted,
    Color? cardElevated,
    Color? sheetSurface,
    Color? quoteSurface,
    Color? hairlineBorder,
    Color? strongBorder,
    Color? tactilePrimaryBg,
    Color? tactilePrimaryFg,
    Color? tactilePrimaryLip,
    Color? tactileSecondaryBg,
    Color? tactileSecondaryFg,
    Color? tactileSecondaryLip,
    Color? tactileSecondaryBorder,
    Color? disabledBg,
    Color? disabledFg,
    Color? ambientShadowColor,
    double? groupedOuterRadius,
    double? groupedInnerRadius,
  }) {
    return EnpriveSurfaceTokens(
      canvas: canvas ?? this.canvas,
      card: card ?? this.card,
      cardMuted: cardMuted ?? this.cardMuted,
      cardElevated: cardElevated ?? this.cardElevated,
      sheetSurface: sheetSurface ?? this.sheetSurface,
      quoteSurface: quoteSurface ?? this.quoteSurface,
      hairlineBorder: hairlineBorder ?? this.hairlineBorder,
      strongBorder: strongBorder ?? this.strongBorder,
      tactilePrimaryBg: tactilePrimaryBg ?? this.tactilePrimaryBg,
      tactilePrimaryFg: tactilePrimaryFg ?? this.tactilePrimaryFg,
      tactilePrimaryLip: tactilePrimaryLip ?? this.tactilePrimaryLip,
      tactileSecondaryBg: tactileSecondaryBg ?? this.tactileSecondaryBg,
      tactileSecondaryFg: tactileSecondaryFg ?? this.tactileSecondaryFg,
      tactileSecondaryLip: tactileSecondaryLip ?? this.tactileSecondaryLip,
      tactileSecondaryBorder:
          tactileSecondaryBorder ?? this.tactileSecondaryBorder,
      disabledBg: disabledBg ?? this.disabledBg,
      disabledFg: disabledFg ?? this.disabledFg,
      ambientShadowColor: ambientShadowColor ?? this.ambientShadowColor,
      groupedOuterRadius: groupedOuterRadius ?? this.groupedOuterRadius,
      groupedInnerRadius: groupedInnerRadius ?? this.groupedInnerRadius,
    );
  }

  @override
  EnpriveSurfaceTokens lerp(
    covariant ThemeExtension<EnpriveSurfaceTokens>? other,
    double t,
  ) {
    if (other is! EnpriveSurfaceTokens) return this;
    return EnpriveSurfaceTokens(
      canvas: Color.lerp(canvas, other.canvas, t)!,
      card: Color.lerp(card, other.card, t)!,
      cardMuted: Color.lerp(cardMuted, other.cardMuted, t)!,
      cardElevated: Color.lerp(cardElevated, other.cardElevated, t)!,
      sheetSurface: Color.lerp(sheetSurface, other.sheetSurface, t)!,
      quoteSurface: Color.lerp(quoteSurface, other.quoteSurface, t)!,
      hairlineBorder: Color.lerp(hairlineBorder, other.hairlineBorder, t)!,
      strongBorder: Color.lerp(strongBorder, other.strongBorder, t)!,
      tactilePrimaryBg: Color.lerp(
        tactilePrimaryBg,
        other.tactilePrimaryBg,
        t,
      )!,
      tactilePrimaryFg: Color.lerp(
        tactilePrimaryFg,
        other.tactilePrimaryFg,
        t,
      )!,
      tactilePrimaryLip: Color.lerp(
        tactilePrimaryLip,
        other.tactilePrimaryLip,
        t,
      )!,
      tactileSecondaryBg: Color.lerp(
        tactileSecondaryBg,
        other.tactileSecondaryBg,
        t,
      )!,
      tactileSecondaryFg: Color.lerp(
        tactileSecondaryFg,
        other.tactileSecondaryFg,
        t,
      )!,
      tactileSecondaryLip: Color.lerp(
        tactileSecondaryLip,
        other.tactileSecondaryLip,
        t,
      )!,
      tactileSecondaryBorder: Color.lerp(
        tactileSecondaryBorder,
        other.tactileSecondaryBorder,
        t,
      )!,
      disabledBg: Color.lerp(disabledBg, other.disabledBg, t)!,
      disabledFg: Color.lerp(disabledFg, other.disabledFg, t)!,
      ambientShadowColor: Color.lerp(
        ambientShadowColor,
        other.ambientShadowColor,
        t,
      )!,
      groupedOuterRadius: lerpDouble(
        groupedOuterRadius,
        other.groupedOuterRadius,
        t,
      )!,
      groupedInnerRadius: lerpDouble(
        groupedInnerRadius,
        other.groupedInnerRadius,
        t,
      )!,
    );
  }
}

/// Centralized Material 3 Expressive motion & spring tokens.
/// Distinguishes spatial springs (allowing gentle physical overshoot) from
/// effects springs (critically damped for opacity/color).
@immutable
class EnpriveMotionTokens extends ThemeExtension<EnpriveMotionTokens> {
  final Duration spatialFast;
  final Duration spatialDefault;
  final Duration spatialSlow;
  final Duration effectsFast;
  final Duration effectsDefault;
  final Duration effectsSlow;
  final SpringDescription spatialSpring;
  final SpringDescription effectsSpring;
  final double deniSpringZeta;
  final double deniSpringHz;

  const EnpriveMotionTokens({
    this.spatialFast = const Duration(milliseconds: 180),
    this.spatialDefault = const Duration(milliseconds: 320),
    this.spatialSlow = const Duration(milliseconds: 480),
    this.effectsFast = const Duration(milliseconds: 120),
    this.effectsDefault = const Duration(milliseconds: 200),
    this.effectsSlow = const Duration(milliseconds: 300),
    this.spatialSpring = const SpringDescription(
      mass: 1.0,
      stiffness: 700.0,
      damping: 42.3, // dampingRatio ≈ 0.80
    ),
    this.effectsSpring = const SpringDescription(
      mass: 1.0,
      stiffness: 1600.0,
      damping: 80.0, // critically damped = 1.0
    ),
    this.deniSpringZeta = 0.32,
    this.deniSpringHz = 5.5,
  });

  static const EnpriveMotionTokens standard = EnpriveMotionTokens();

  static bool isReducedMotion(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  Duration get standardDuration => spatialDefault;
  Curve get emphasizedCurve => Curves.easeOutCubic;

  /// Returns `Duration.zero` when OS reduced-motion accessibility is enabled.
  Duration effectiveDuration(BuildContext context, Duration base) {
    return isReducedMotion(context) ? Duration.zero : base;
  }

  Curve effectiveCurve(BuildContext context, Curve base) {
    return isReducedMotion(context) ? Curves.linear : base;
  }

  @override
  EnpriveMotionTokens copyWith({
    Duration? spatialFast,
    Duration? spatialDefault,
    Duration? spatialSlow,
    Duration? effectsFast,
    Duration? effectsDefault,
    Duration? effectsSlow,
    SpringDescription? spatialSpring,
    SpringDescription? effectsSpring,
    double? deniSpringZeta,
    double? deniSpringHz,
  }) {
    return EnpriveMotionTokens(
      spatialFast: spatialFast ?? this.spatialFast,
      spatialDefault: spatialDefault ?? this.spatialDefault,
      spatialSlow: spatialSlow ?? this.spatialSlow,
      effectsFast: effectsFast ?? this.effectsFast,
      effectsDefault: effectsDefault ?? this.effectsDefault,
      effectsSlow: effectsSlow ?? this.effectsSlow,
      spatialSpring: spatialSpring ?? this.spatialSpring,
      effectsSpring: effectsSpring ?? this.effectsSpring,
      deniSpringZeta: deniSpringZeta ?? this.deniSpringZeta,
      deniSpringHz: deniSpringHz ?? this.deniSpringHz,
    );
  }

  @override
  EnpriveMotionTokens lerp(
    covariant ThemeExtension<EnpriveMotionTokens>? other,
    double t,
  ) {
    if (other is! EnpriveMotionTokens) return this;
    return t < 0.5 ? this : other;
  }
}

/// A [Curve] that follows a Material 3 Expressive spring from 0 to 1 over
/// [seconds], so implicit animations (`AnimatedContainer`, `TweenAnimationBuilder`)
/// can use the same overshoot-and-settle feel as M3E components.
class EnpriveSpringCurve extends Curve {
  final M3ESpring spring;
  final double seconds;

  const EnpriveSpringCurve(this.spring, {this.seconds = 0.4});

  /// Fast spatial spring (damping 0.6, stiffness 800) for small components.
  static const EnpriveSpringCurve fastSpatial = EnpriveSpringCurve(
    M3EMotion.expressiveSpatialFast,
    seconds: 0.35,
  );

  /// Default spatial spring (damping 0.8, stiffness 380) for larger surfaces.
  static const EnpriveSpringCurve defaultSpatial = EnpriveSpringCurve(
    M3EMotion.expressiveSpatialDefault,
    seconds: 0.5,
  );

  /// Duration that lets the spring settle.
  Duration get duration => Duration(milliseconds: (seconds * 1000).round());

  @override
  double transformInternal(double t) {
    return SpringSimulation(spring.toDescription(), 0, 1, 0).x(t * seconds);
  }
}

/// Dedicated typography extension for verbatim policy quotations, SHA-256
/// receipt digests, tabular numerals, and evidence badges.
@immutable
class EnpriveTypographyExtension
    extends ThemeExtension<EnpriveTypographyExtension> {
  final TextStyle policyQuotation;
  final TextStyle sha256Hash;
  final TextStyle tabularMetricLarge;
  final TextStyle tabularMetricMedium;
  final TextStyle evidenceBadge;

  const EnpriveTypographyExtension({
    required this.policyQuotation,
    required this.sha256Hash,
    required this.tabularMetricLarge,
    required this.tabularMetricMedium,
    required this.evidenceBadge,
  });

  factory EnpriveTypographyExtension.forBrightness({
    required Color primaryInk,
    required Color secondaryInk,
  }) {
    return EnpriveTypographyExtension(
      policyQuotation: TextStyle(
        fontFamily: 'SourceSerif4',
        fontSize: 14.5,
        fontWeight: FontWeight.w600,
        height: 1.52,
        letterSpacing: 0.1,
        color: primaryInk,
      ),
      sha256Hash: TextStyle(
        fontFamily: 'Inter',
        fontSize: 12.0,
        fontWeight: FontWeight.w600,
        height: 1.35,
        letterSpacing: 0.45,
        color: secondaryInk,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      tabularMetricLarge: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 28.0,
        fontWeight: FontWeight.w800,
        height: 1.10,
        letterSpacing: -0.6,
        color: primaryInk,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      tabularMetricMedium: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 20.0,
        fontWeight: FontWeight.w800,
        height: 1.18,
        letterSpacing: -0.3,
        color: primaryInk,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      evidenceBadge: TextStyle(
        fontFamily: 'Inter',
        fontSize: 12.0,
        fontWeight: FontWeight.w700,
        height: 1.25,
        letterSpacing: 0.2,
        color: primaryInk,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }

  @override
  EnpriveTypographyExtension copyWith({
    TextStyle? policyQuotation,
    TextStyle? sha256Hash,
    TextStyle? tabularMetricLarge,
    TextStyle? tabularMetricMedium,
    TextStyle? evidenceBadge,
  }) {
    return EnpriveTypographyExtension(
      policyQuotation: policyQuotation ?? this.policyQuotation,
      sha256Hash: sha256Hash ?? this.sha256Hash,
      tabularMetricLarge: tabularMetricLarge ?? this.tabularMetricLarge,
      tabularMetricMedium: tabularMetricMedium ?? this.tabularMetricMedium,
      evidenceBadge: evidenceBadge ?? this.evidenceBadge,
    );
  }

  @override
  EnpriveTypographyExtension lerp(
    covariant ThemeExtension<EnpriveTypographyExtension>? other,
    double t,
  ) {
    if (other is! EnpriveTypographyExtension) return this;
    return EnpriveTypographyExtension(
      policyQuotation: TextStyle.lerp(
        policyQuotation,
        other.policyQuotation,
        t,
      )!,
      sha256Hash: TextStyle.lerp(sha256Hash, other.sha256Hash, t)!,
      tabularMetricLarge: TextStyle.lerp(
        tabularMetricLarge,
        other.tabularMetricLarge,
        t,
      )!,
      tabularMetricMedium: TextStyle.lerp(
        tabularMetricMedium,
        other.tabularMetricMedium,
        t,
      )!,
      evidenceBadge: TextStyle.lerp(evidenceBadge, other.evidenceBadge, t)!,
    );
  }
}

/// Centralized spacing scale following the 4/8dp Material 3 grid and 48dp
/// accessibility touch-target rule.
abstract final class EnpriveSpacing {
  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double section = 40.0;
  static const double minTouchTarget = 48.0;

  /// Side margin on compact windows (under 600dp).
  static const double compactMargin = 16.0;

  /// Side margin on medium windows and wider.
  static const double mediumMargin = 24.0;

  /// The Material side margin for a window [width].
  static double marginFor(double width) =>
      width < 600 ? compactMargin : mediumMargin;
}

/// Centralized Material 3 Expressive shape scale.
abstract final class EnpriveRadii {
  static const double xs = 4.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double sheet = 28.0;
  static const double pill = 999.0;

  /// Text fields (M3 extra-small).
  static const double field = 4.0;

  /// Chips (M3 small).
  static const double chip = 8.0;

  /// Content cards (M3 large-increased).
  static const double card = 20.0;

  /// Hero containers (M3 extra-large-increased).
  static const double hero = 32.0;

  /// Inner corners shared by neighbours in a segmented list or group.
  static const double segmentedInner = 4.0;

  /// Outer corners of a segmented list or group.
  static const double segmentedOuter = 20.0;

  /// Computes Material 3 Expressive segmented corner radii (`20dp` outer caps,
  /// `4dp` shared inner edges) for an item at [index] in a list of [count] items.
  static BorderRadius groupedCardRadius({
    required int index,
    required int count,
    double outer = segmentedOuter,
    double inner = segmentedInner,
  }) {
    if (count <= 1) {
      return BorderRadius.circular(outer);
    }
    if (index == 0) {
      return BorderRadius.vertical(
        top: Radius.circular(outer),
        bottom: Radius.circular(inner),
      );
    }
    if (index == count - 1) {
      return BorderRadius.vertical(
        top: Radius.circular(inner),
        bottom: Radius.circular(outer),
      );
    }
    return BorderRadius.circular(inner);
  }
}

/// A Material static color: one hue producing four roles that follow light
/// and dark themes, used for meanings the generated scheme does not carry.
@immutable
class EnpriveStaticColor {
  /// Solid mark (icons, chart arcs): tone 40 in light, 80 in dark, so it keeps
  /// 3:1 against every surface.
  final Color color;

  /// Content on [color].
  final Color onColor;

  /// Container fill: tone 90 in light, 30 in dark.
  final Color container;

  /// Content on [container] (at least 7:1).
  final Color onContainer;

  const EnpriveStaticColor({
    required this.color,
    required this.onColor,
    required this.container,
    required this.onContainer,
  });

  static EnpriveStaticColor lerp(
    EnpriveStaticColor a,
    EnpriveStaticColor b,
    double t,
  ) {
    return EnpriveStaticColor(
      color: Color.lerp(a.color, b.color, t)!,
      onColor: Color.lerp(a.onColor, b.onColor, t)!,
      container: Color.lerp(a.container, b.container, t)!,
      onContainer: Color.lerp(a.onContainer, b.onContainer, t)!,
    );
  }
}

/// HCT static colors that sit outside the generated scheme.
abstract final class EnpriveStaticColors {
  /// Hue of the single "Review recommended" amber.
  static const double reviewAmberHue = 70;

  /// Builds the four roles of a static color from an HCT [hue].
  static EnpriveStaticColor fromHue(
    double hue,
    Brightness brightness, {
    double chroma = 40,
    double contrastLevel = 0.0,
  }) {
    final palette = TonalPalette.of(hue, chroma);
    final isDark = brightness == Brightness.dark;
    final high = contrastLevel >= 0.5;
    Color tone(int t) => Color(palette.get(t));
    return isDark
        ? EnpriveStaticColor(
            color: tone(80),
            onColor: tone(20),
            container: tone(30),
            onContainer: tone(high ? 100 : 90),
          )
        : EnpriveStaticColor(
            color: tone(40),
            onColor: tone(100),
            container: tone(90),
            onContainer: tone(high ? 10 : 30),
          );
  }

  /// The one amber used for "Review recommended" everywhere.
  static EnpriveStaticColor reviewAmber(
    Brightness brightness, {
    double contrastLevel = 0.0,
  }) {
    return fromHue(reviewAmberHue, brightness, contrastLevel: contrastLevel);
  }
}

/// One static hue per evidence category, used for the category icon well,
/// the evidence ring arc and the Learn tile, and nowhere else. Color marks the
/// category, never severity.
@immutable
class EnpriveCategoryColors extends ThemeExtension<EnpriveCategoryColors> {
  final EnpriveStaticColor dataCollection;
  final EnpriveStaticColor sharing;
  final EnpriveStaticColor tracking;
  final EnpriveStaticColor retention;
  final EnpriveStaticColor parentalConsent;

  const EnpriveCategoryColors({
    required this.dataCollection,
    required this.sharing,
    required this.tracking,
    required this.retention,
    required this.parentalConsent,
  });

  static const double dataCollectionHue = 241;
  static const double sharingHue = 29;
  static const double trackingHue = 355;
  static const double retentionHue = 119;
  static const double parentalConsentHue = 300;

  factory EnpriveCategoryColors.forBrightness(
    Brightness brightness, {
    double contrastLevel = 0.0,
  }) {
    EnpriveStaticColor hue(double h) => EnpriveStaticColors.fromHue(
      h,
      brightness,
      contrastLevel: contrastLevel,
    );
    return EnpriveCategoryColors(
      dataCollection: hue(dataCollectionHue),
      sharing: hue(sharingHue),
      tracking: hue(trackingHue),
      retention: hue(retentionHue),
      parentalConsent: hue(parentalConsentHue),
    );
  }

  static final EnpriveCategoryColors light =
      EnpriveCategoryColors.forBrightness(Brightness.light);

  static final EnpriveCategoryColors dark = EnpriveCategoryColors.forBrightness(
    Brightness.dark,
  );

  @override
  EnpriveCategoryColors copyWith({
    EnpriveStaticColor? dataCollection,
    EnpriveStaticColor? sharing,
    EnpriveStaticColor? tracking,
    EnpriveStaticColor? retention,
    EnpriveStaticColor? parentalConsent,
  }) {
    return EnpriveCategoryColors(
      dataCollection: dataCollection ?? this.dataCollection,
      sharing: sharing ?? this.sharing,
      tracking: tracking ?? this.tracking,
      retention: retention ?? this.retention,
      parentalConsent: parentalConsent ?? this.parentalConsent,
    );
  }

  @override
  EnpriveCategoryColors lerp(
    covariant ThemeExtension<EnpriveCategoryColors>? other,
    double t,
  ) {
    if (other is! EnpriveCategoryColors) return this;
    return EnpriveCategoryColors(
      dataCollection: EnpriveStaticColor.lerp(
        dataCollection,
        other.dataCollection,
        t,
      ),
      sharing: EnpriveStaticColor.lerp(sharing, other.sharing, t),
      tracking: EnpriveStaticColor.lerp(tracking, other.tracking, t),
      retention: EnpriveStaticColor.lerp(retention, other.retention, t),
      parentalConsent: EnpriveStaticColor.lerp(
        parentalConsent,
        other.parentalConsent,
        t,
      ),
    );
  }
}

/// Ergonomic `BuildContext` accessors for Enprive's single-source-of-truth theme extensions.
extension EnpriveThemeContext on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  EnpriveSemanticColors get semanticColors =>
      Theme.of(this).extension<EnpriveSemanticColors>() ??
      (isDarkMode ? EnpriveSemanticColors.dark : EnpriveSemanticColors.light);

  EnpriveSemanticColors get enpriveSemantics => semanticColors;

  EnpriveSurfaceTokens get surfaceTokens =>
      Theme.of(this).extension<EnpriveSurfaceTokens>() ??
      (isDarkMode ? EnpriveSurfaceTokens.dark : EnpriveSurfaceTokens.light);

  EnpriveSurfaceTokens get enpriveSurfaces => surfaceTokens;

  EnpriveCategoryColors get categoryColors =>
      Theme.of(this).extension<EnpriveCategoryColors>() ??
      (isDarkMode ? EnpriveCategoryColors.dark : EnpriveCategoryColors.light);

  EnpriveMotionTokens get motionTokens =>
      Theme.of(this).extension<EnpriveMotionTokens>() ??
      EnpriveMotionTokens.standard;

  EnpriveMotionTokens get enpriveMotion => motionTokens;

  EnpriveTypographyExtension get enpriveType =>
      Theme.of(this).extension<EnpriveTypographyExtension>() ??
      EnpriveTypographyExtension.forBrightness(
        primaryInk: colorScheme.onSurface,
        secondaryInk: colorScheme.onSurfaceVariant,
      );
}
