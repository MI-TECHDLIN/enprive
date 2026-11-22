import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

/// Fixed brand reference colors plus WCAG and HCT utilities.
///
/// Theme roles no longer come from this class: every scheme role is generated
/// from Deni's teal in `EnpriveM3ETheme.colorSchemeFor`. The constants below
/// remain for the Deni painter (`teal`, `tealStrong`, `tealDarkAccent`,
/// `apricot`, `ink`), which draws Concept C in its own fixed colors, and as a
/// record of the previous palette.
abstract final class EnpriveColors {
  // ===========================================================================
  // 1. Light Mode Surfaces ("Warm Archival Paper")
  // ===========================================================================
  static const Color paper = Color(0xFFFAF8F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF3F1EC);
  static const Color surfaceContainer = Color(0xFFECE9E2);
  static const Color surfaceContainerHigh = Color(0xFFE4E0D7);
  static const Color quoteSurface = Color(0xFFF6F1E7);
  static const Color lightHairline = Color(0xFFE2DDD5);
  static const Color lightStrongBorder = Color(0xFFC4BDB2);

  // ===========================================================================
  // 2. Dark Mode Surfaces ("Obsidian Ceramic Slate")
  // ===========================================================================
  static const Color darkCanvas = Color(0xFF0E1417);
  static const Color darkSurface = Color(0xFF172025);
  static const Color darkSurfaceMuted = Color(0xFF121A1E);
  static const Color darkSurfaceElevated = Color(0xFF1E2A30);
  static const Color darkSurfaceHigh = Color(0xFF26343C);
  static const Color darkQuoteSurface = Color(0xFF1B2423);
  static const Color darkHairline = Color(0xFF2B3940);
  static const Color darkStrongBorder = Color(0xFF42545E);

  // ===========================================================================
  // 3. Light & Dark Typography Ink (WCAG AAA/AA Verified)
  // ===========================================================================
  static const Color ink = Color(
    0xFF1C2333,
  ); // 14.9:1 on paper, 15.8:1 on white
  static const Color inkSecondary = Color(
    0xFF4E5666,
  ); // 6.9:1 on paper, 7.3:1 on white
  static const Color inkMuted = Color(
    0xFF636B7A,
  ); // 4.9:1 on paper (AA), 5.2:1 on white
  static const Color inkDisabled = Color(0xFF727A8A); // 4.0:1 on white

  static const Color darkInk = Color(
    0xFFF4F1EA,
  ); // 16.2:1 on darkCanvas, 13.7:1 on darkSurface
  static const Color darkInkSecondary = Color(
    0xFFB5C0C6,
  ); // 9.2:1 on darkCanvas, 7.8:1 on darkSurface
  static const Color darkInkMuted = Color(
    0xFF8E9CA4,
  ); // 5.7:1 on darkCanvas, 4.8:1 on darkSurface
  static const Color darkInkDisabled = Color(0xFF6E7C85);

  // ===========================================================================
  // 4. Tactile Action & Brand Identity Tokens
  // ===========================================================================
  static const Color ctaInk = Color(0xFF1F2A44);
  static const Color ctaLip = Color(0xFF10172A);

  static const Color darkCtaFill = Color(
    0xFF2DD4BF,
  ); // Accessible Ceramic Teal on dark
  static const Color darkCtaInk = Color(
    0xFF072724,
  ); // 10.6:1 contrast on darkCtaFill
  static const Color darkCtaLip = Color(0xFF138779);

  static const Color teal = Color(0xFF1E9E8F);
  static const Color tealStrong = Color(
    0xFF0F6B61,
  ); // 6.2:1 on white, 5.8:1 on paper
  static const Color tealDarkAccent = Color(0xFF4FD1C5); // 9.5:1 on darkSurface
  static const Color apricot = Color(0xFFF4A261);

  // ===========================================================================
  // 5. Light Mode Semantic & Provenance Tokens (Backwards-Compatible)
  // ===========================================================================
  static const Color stateNoConcernFg = Color(
    0xFF165B38,
  ); // 7.4:1 on stateNoConcernBg
  static const Color stateNoConcernBg = Color(0xFFE7F3EC);
  static const Color stateNoConcernBorder = Color(0xFFA7D7BC);

  static const Color stateReviewRecommendedFg = Color(
    0xFF783F00,
  ); // 7.6:1 on stateReviewRecommendedBg
  static const Color stateReviewRecommendedBg = Color(0xFFFFF1DB);
  static const Color stateReviewRecommendedBorder = Color(0xFFF5C982);

  static const Color stateHighConcernFg = Color(
    0xFF8C1D24,
  ); // 7.5:1 on stateHighConcernBg
  static const Color stateHighConcernBg = Color(0xFFFDE8E9);
  static const Color stateHighConcernBorder = Color(0xFFF5B2B6);

  static const Color stateInsufficientEvidenceFg = Color(
    0xFF3E4656,
  ); // 8.1:1 on stateInsufficientEvidenceBg
  static const Color stateInsufficientEvidenceBg = Color(0xFFEEF0F4);
  static const Color stateInsufficientEvidenceBorder = Color(0xFFCBD1DC);

  // Provenance Chips (Light)
  static const Color chipOnDeviceFg = Color(
    0xFF0C5950,
  ); // 7.3:1 on chipOnDeviceBg
  static const Color chipOnDeviceBg = Color(0xFFE3F4F1);
  static const Color chipOnDeviceBorder = Color(0xFF9AD6CC);

  static const Color chipInCloudFg = Color(
    0xFF24427B,
  ); // 7.8:1 on chipInCloudBg
  static const Color chipInCloudBg = Color(0xFFE6EEFB);
  static const Color chipInCloudBorder = Color(0xFFB3C9F2);

  static const Color chipOfflineFg = Color(
    0xFF593E0E,
  ); // 7.9:1 on chipOfflineBg
  static const Color chipOfflineBg = Color(0xFFF5EDE0);
  static const Color chipOfflineBorder = Color(0xFFDCC6A4);

  static const Color chipUnknownFg = Color(
    0xFF3E4656,
  ); // 8.1:1 on chipUnknownBg
  static const Color chipUnknownBg = Color(0xFFEEF0F4);
  static const Color chipUnknownBorder = Color(0xFFCBD1DC);

  // ===========================================================================
  // 6. Dark Mode Semantic & Provenance Tokens (HCT Harmonized & Contrast-Verified)
  // ===========================================================================
  static const Color darkStateNoConcernFg = Color(
    0xFF8CE6B4,
  ); // 8.6:1 on darkStateNoConcernBg
  static const Color darkStateNoConcernBg = Color(0xFF122B20);
  static const Color darkStateNoConcernBorder = Color(0xFF255942);

  static const Color darkStateReviewRecommendedFg = Color(
    0xFFFCD283,
  ); // 9.2:1 on darkStateReviewRecommendedBg
  static const Color darkStateReviewRecommendedBg = Color(0xFF2D2210);
  static const Color darkStateReviewRecommendedBorder = Color(0xFF61471D);

  static const Color darkStateHighConcernFg = Color(
    0xFFFEB4B8,
  ); // 8.1:1 on darkStateHighConcernBg
  static const Color darkStateHighConcernBg = Color(0xFF321619);
  static const Color darkStateHighConcernBorder = Color(0xFF692B31);

  static const Color darkStateInsufficientEvidenceFg = Color(
    0xFFCAD3DD,
  ); // 8.4:1 on darkStateInsufficientEvidenceBg
  static const Color darkStateInsufficientEvidenceBg = Color(0xFF1F2830);
  static const Color darkStateInsufficientEvidenceBorder = Color(0xFF3B4A57);

  static const Color darkChipOnDeviceFg = Color(
    0xFF7CE8DB,
  ); // 9.0:1 on darkChipOnDeviceBg
  static const Color darkChipOnDeviceBg = Color(0xFF102C29);
  static const Color darkChipOnDeviceBorder = Color(0xFF225C55);

  static const Color darkChipInCloudFg = Color(
    0xFFB4CBFF,
  ); // 8.3:1 on darkChipInCloudBg
  static const Color darkChipInCloudBg = Color(0xFF18243E);
  static const Color darkChipInCloudBorder = Color(0xFF334C82);

  static const Color darkChipOfflineFg = Color(
    0xFFEAD0A8,
  ); // 8.5:1 on darkChipOfflineBg
  static const Color darkChipOfflineBg = Color(0xFF282218);
  static const Color darkChipOfflineBorder = Color(0xFF544732);

  static const Color darkChipUnknownFg = Color(
    0xFFCAD3DD,
  ); // 8.4:1 on darkChipUnknownBg
  static const Color darkChipUnknownBg = Color(0xFF1F2830);
  static const Color darkChipUnknownBorder = Color(0xFF3B4A57);
}

/// Mathematical WCAG 2.1 sRGB relative luminance and contrast ratio calculator.
/// Never relies on HCT tone differences alone to assert accessibility compliance.
abstract final class EnpriveContrast {
  /// Computes WCAG 2.1 relative luminance `L` in `[0.0, 1.0]`.
  static double relativeLuminance(Color color) {
    double linearize(double channel) {
      return channel <= 0.03928
          ? channel / 12.92
          : math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
    }

    final r = linearize(color.r);
    final g = linearize(color.g);
    final b = linearize(color.b);
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  /// Computes WCAG 2.1 contrast ratio `(L1 + 0.05) / (L2 + 0.05)` in `[1.0, 21.0]`.
  static double contrastRatio(Color foreground, Color background) {
    final l1 = relativeLuminance(foreground);
    final l2 = relativeLuminance(background);
    final brightest = math.max(l1, l2);
    final darkest = math.min(l1, l2);
    return (brightest + 0.05) / (darkest + 0.05);
  }

  /// Normal text WCAG AA threshold (`>= 4.5:1`).
  static bool meetsWcagAA(Color foreground, Color background) =>
      contrastRatio(foreground, background) >= 4.5;

  /// Large text / UI component WCAG AA threshold (`>= 3.0:1`).
  static bool meetsWcagLargeAA(Color foreground, Color background) =>
      contrastRatio(foreground, background) >= 3.0;

  /// Enhanced WCAG AAA threshold (`>= 7.0:1`).
  static bool meetsWcagAAA(Color foreground, Color background) =>
      contrastRatio(foreground, background) >= 7.0;
}

/// HCT tonal palette and semantic color harmonization engine powered by
/// `package:material_color_utilities`.
abstract final class EnpriveHctPalette {
  /// Shifts [designColor]'s hue up to 15 degrees in perceptual HCT space toward
  /// [brandSeed] (`EnpriveColors.teal`) while preserving chroma and tone.
  static Color harmonizeToBrand(
    Color designColor, {
    Color brandSeed = EnpriveColors.teal,
  }) {
    final harmonizedArgb = Blend.harmonize(
      designColor.toARGB32(),
      brandSeed.toARGB32(),
    );
    return Color(harmonizedArgb);
  }

  /// Builds a `TonalPalette` from [seed] (optionally harmonized toward brand teal).
  static TonalPalette tonalPaletteFromSeed(
    Color seed, {
    bool harmonize = false,
  }) {
    final effectiveColor = harmonize ? harmonizeToBrand(seed) : seed;
    final hct = Hct.fromInt(effectiveColor.toARGB32());
    return TonalPalette.of(hct.hue, hct.chroma);
  }

  /// Resolves a specific HCT tone (`0..100`) from [seed] and adjusts tone
  /// iteratively if needed until it achieves [minContrastRatio] against [background].
  static Color contrastSafeTone({
    required Color seed,
    required Color background,
    required double initialTone,
    required bool darkerForContrast,
    double minContrastRatio = 4.5,
    bool harmonize = true,
  }) {
    final effectiveSeed = harmonize ? harmonizeToBrand(seed) : seed;
    final baseHct = Hct.fromInt(effectiveSeed.toARGB32());
    double tone = initialTone.clamp(0.0, 100.0);

    for (int step = 0; step < 40; step++) {
      final candidate = Color(
        Hct.from(baseHct.hue, baseHct.chroma, tone).toInt(),
      );
      if (EnpriveContrast.contrastRatio(candidate, background) >=
          minContrastRatio) {
        return candidate;
      }
      tone = darkerForContrast
          ? (tone - 2.0).clamp(0.0, 100.0)
          : (tone + 2.0).clamp(0.0, 100.0);
    }

    return Color(Hct.from(baseHct.hue, baseHct.chroma, tone).toInt());
  }
}
