import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import 'enprive_colors.dart';

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

  static const EnpriveSemanticColors light = EnpriveSemanticColors(
    noConcern: SemanticColorPair(
      background: EnpriveColors.stateNoConcernBg,
      foreground: EnpriveColors.stateNoConcernFg,
      border: EnpriveColors.stateNoConcernBorder,
    ),
    reviewRecommended: SemanticColorPair(
      background: EnpriveColors.stateReviewRecommendedBg,
      foreground: EnpriveColors.stateReviewRecommendedFg,
      border: EnpriveColors.stateReviewRecommendedBorder,
    ),
    highConcern: SemanticColorPair(
      background: EnpriveColors.stateHighConcernBg,
      foreground: EnpriveColors.stateHighConcernFg,
      border: EnpriveColors.stateHighConcernBorder,
    ),
    insufficientEvidence: SemanticColorPair(
      background: EnpriveColors.stateInsufficientEvidenceBg,
      foreground: EnpriveColors.stateInsufficientEvidenceFg,
      border: EnpriveColors.stateInsufficientEvidenceBorder,
    ),
    onDevice: SemanticColorPair(
      background: EnpriveColors.chipOnDeviceBg,
      foreground: EnpriveColors.chipOnDeviceFg,
      border: EnpriveColors.chipOnDeviceBorder,
    ),
    inCloud: SemanticColorPair(
      background: EnpriveColors.chipInCloudBg,
      foreground: EnpriveColors.chipInCloudFg,
      border: EnpriveColors.chipInCloudBorder,
    ),
    offlineFallback: SemanticColorPair(
      background: EnpriveColors.chipOfflineBg,
      foreground: EnpriveColors.chipOfflineFg,
      border: EnpriveColors.chipOfflineBorder,
    ),
    unknown: SemanticColorPair(
      background: EnpriveColors.chipUnknownBg,
      foreground: EnpriveColors.chipUnknownFg,
      border: EnpriveColors.chipUnknownBorder,
    ),
    deniPrimaryGlow: Color(0x291E9E8F),
    deniSecondaryGlow: Color(0x12F4A261),
  );

  static const EnpriveSemanticColors dark = EnpriveSemanticColors(
    noConcern: SemanticColorPair(
      background: EnpriveColors.darkStateNoConcernBg,
      foreground: EnpriveColors.darkStateNoConcernFg,
      border: EnpriveColors.darkStateNoConcernBorder,
    ),
    reviewRecommended: SemanticColorPair(
      background: EnpriveColors.darkStateReviewRecommendedBg,
      foreground: EnpriveColors.darkStateReviewRecommendedFg,
      border: EnpriveColors.darkStateReviewRecommendedBorder,
    ),
    highConcern: SemanticColorPair(
      background: EnpriveColors.darkStateHighConcernBg,
      foreground: EnpriveColors.darkStateHighConcernFg,
      border: EnpriveColors.darkStateHighConcernBorder,
    ),
    insufficientEvidence: SemanticColorPair(
      background: EnpriveColors.darkStateInsufficientEvidenceBg,
      foreground: EnpriveColors.darkStateInsufficientEvidenceFg,
      border: EnpriveColors.darkStateInsufficientEvidenceBorder,
    ),
    onDevice: SemanticColorPair(
      background: EnpriveColors.darkChipOnDeviceBg,
      foreground: EnpriveColors.darkChipOnDeviceFg,
      border: EnpriveColors.darkChipOnDeviceBorder,
    ),
    inCloud: SemanticColorPair(
      background: EnpriveColors.darkChipInCloudBg,
      foreground: EnpriveColors.darkChipInCloudFg,
      border: EnpriveColors.darkChipInCloudBorder,
    ),
    offlineFallback: SemanticColorPair(
      background: EnpriveColors.darkChipOfflineBg,
      foreground: EnpriveColors.darkChipOfflineFg,
      border: EnpriveColors.darkChipOfflineBorder,
    ),
    unknown: SemanticColorPair(
      background: EnpriveColors.darkChipUnknownBg,
      foreground: EnpriveColors.darkChipUnknownFg,
      border: EnpriveColors.darkChipUnknownBorder,
    ),
    deniPrimaryGlow: Color(0x472DD4BF),
    deniSecondaryGlow: Color(0x1FF4A261),
  );

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
      deniPrimaryGlow: Color.lerp(
        deniPrimaryGlow,
        other.deniPrimaryGlow,
        t,
      )!,
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
    this.groupedOuterRadius = 20.0,
    this.groupedInnerRadius = 6.0,
  });

  static const EnpriveSurfaceTokens light = EnpriveSurfaceTokens(
    canvas: EnpriveColors.paper,
    card: EnpriveColors.surface,
    cardMuted: EnpriveColors.surfaceMuted,
    cardElevated: EnpriveColors.surface,
    sheetSurface: EnpriveColors.paper,
    quoteSurface: EnpriveColors.quoteSurface,
    hairlineBorder: EnpriveColors.lightHairline,
    strongBorder: EnpriveColors.lightStrongBorder,
    tactilePrimaryBg: EnpriveColors.ctaInk,
    tactilePrimaryFg: Colors.white,
    tactilePrimaryLip: EnpriveColors.ctaLip,
    tactileSecondaryBg: EnpriveColors.surface,
    tactileSecondaryFg: EnpriveColors.ink,
    tactileSecondaryLip: Color(0xFFDAD5CB),
    tactileSecondaryBorder: Color(0xFFE0DBD1),
    disabledBg: Color(0xFFE5E2DC),
    disabledFg: Color(0xFF565E6D), // 5.1:1 contrast on disabledBg
    ambientShadowColor: Color(0x0D1C2333),
  );

  static const EnpriveSurfaceTokens dark = EnpriveSurfaceTokens(
    canvas: EnpriveColors.darkCanvas,
    card: EnpriveColors.darkSurface,
    cardMuted: EnpriveColors.darkSurfaceMuted,
    cardElevated: EnpriveColors.darkSurfaceElevated,
    sheetSurface: EnpriveColors.darkSurface,
    quoteSurface: EnpriveColors.darkQuoteSurface,
    hairlineBorder: EnpriveColors.darkHairline,
    strongBorder: EnpriveColors.darkStrongBorder,
    tactilePrimaryBg: EnpriveColors.darkCtaFill,
    tactilePrimaryFg: EnpriveColors.darkCtaInk,
    tactilePrimaryLip: EnpriveColors.darkCtaLip,
    tactileSecondaryBg: EnpriveColors.darkSurfaceElevated,
    tactileSecondaryFg: EnpriveColors.darkInk,
    tactileSecondaryLip: Color(0xFF0A0F12),
    tactileSecondaryBorder: EnpriveColors.darkHairline,
    disabledBg: Color(0xFF1B2429),
    disabledFg: Color(0xFF8B99A1), // 5.0:1 contrast on disabledBg
    ambientShadowColor: Color(0x42000000),
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

  /// Returns `Duration.zero` when OS reduced-motion accessibility is enabled.
  Duration effectiveDuration(BuildContext context, Duration base) {
    final disableAnimations =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return disableAnimations ? Duration.zero : base;
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
}

/// Centralized shape radii and Material 3 Expressive grouped-list containment helpers.
abstract final class EnpriveRadii {
  static const double xs = 6.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double sheet = 28.0;
  static const double pill = 999.0;

  /// Computes Material 3 Expressive grouped card corner radii (`20dp` outer caps,
  /// `6dp` shared inner edges) for an item at [index] in a list of [count] items.
  static BorderRadius groupedCardRadius({
    required int index,
    required int count,
    double outer = lg,
    double inner = xs,
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

/// Ergonomic `BuildContext` accessors for Enprive's single-source-of-truth theme extensions.
extension EnpriveThemeContext on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  EnpriveSemanticColors get semanticColors =>
      Theme.of(this).extension<EnpriveSemanticColors>() ??
      (isDarkMode ? EnpriveSemanticColors.dark : EnpriveSemanticColors.light);

  EnpriveSurfaceTokens get surfaceTokens =>
      Theme.of(this).extension<EnpriveSurfaceTokens>() ??
      (isDarkMode ? EnpriveSurfaceTokens.dark : EnpriveSurfaceTokens.light);

  EnpriveMotionTokens get motionTokens =>
      Theme.of(this).extension<EnpriveMotionTokens>() ??
      EnpriveMotionTokens.standard;

  EnpriveTypographyExtension get enpriveType =>
      Theme.of(this).extension<EnpriveTypographyExtension>() ??
      EnpriveTypographyExtension.forBrightness(
        primaryInk: isDarkMode ? EnpriveColors.darkInk : EnpriveColors.ink,
        secondaryInk: isDarkMode
            ? EnpriveColors.darkInkSecondary
            : EnpriveColors.inkSecondary,
      );
}
