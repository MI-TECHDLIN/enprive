import 'package:flutter/material.dart' as legacy;
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart' as legacy_l10n;
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart' as modern;

import '../../l10n/app_localizations.dart';
import 'enprive_colors.dart';
import 'enprive_theme.dart';

/// Enprive's Material 3 Expressive (`material_3_expressive: 1.2.1`) Design System
/// Single Source of Truth.
///
/// Combines:
/// 1. Enprive's brand-locked HCT color architecture (`dynamicColoring: false`):
///    - Light Mode: "Warm Archival Paper" (`#FAF8F5` surface, `#0D5C56` ceramic
///      teal primary, `#1C2333` deep charcoal ink, oatmeal tonal containers).
///    - Dark Mode: "Obsidian Ceramic Slate" (`#0E1417` surface, `#2DD4BF`
///      luminous teal primary with `#072724` `onPrimary` at `8.52:1` AAA contrast,
///      layered slate containers).
/// 2. Expressive Dual-Scale Typography (`M3ETypography` with `baseline` +
///    `emphasized` `M3ETypeScale`s) using offline bundled `Nunito` (brand) and
///    `Inter` (plain), paired with `SourceSerif4` for verbatim policy quotes.
/// 3. Inspiration-calibrated component themes (`24dp` squircle bento cards,
///    `2dp`-gapped segmented lists without hairline dividers, tactile pill CTAs,
///    and spring physics via `M3EMotion`).
abstract final class EnpriveM3ETheme {
  static const M3ETypefaceConfig typefaceConfig = M3ETypefaceConfig(
    brand: EnpriveTheme.primaryDisplayFontFamily,
    plain: EnpriveTheme.secondaryFontBaseFamily,
  );

  /// Complete localization delegates list for `M3EMaterialApp`, combining
  /// `AppLocalizations`, `modern.GlobalMaterialLocalizations.delegates`
  /// (`package:material_ui` + `package:cupertino_ui`), and
  /// `legacy_l10n.Global*Localizations` (`package:flutter/material.dart`) so all
  /// 13 locales (including RTL `ar`) resolve cleanly across both namespaces.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    AppLocalizations.delegate,
    ...modern.GlobalMaterialLocalizations.delegates,
    legacy_l10n.GlobalMaterialLocalizations.delegate,
    legacy_l10n.GlobalWidgetsLocalizations.delegate,
    legacy_l10n.GlobalCupertinoLocalizations.delegate,
  ];

  /// Complete 44-role Light `M3EColorScheme` ("Warm Archival Paper").
  static const M3EColorScheme lightColorScheme = M3EColorScheme(
    brightness: Brightness.light,
    primary: EnpriveColors.ctaInk, // #0D5C56
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: EnpriveColors.chipOnDeviceBg, // #E1F2EE
    onPrimaryContainer: EnpriveColors.chipOnDeviceFg, // #0F5248
    secondary: EnpriveColors.tealStrong, // #136B63
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: EnpriveColors.surfaceContainer, // #EDE8DF
    onSecondaryContainer: EnpriveColors.ink, // #1C2333
    tertiary: Color(0xFF9E5316),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: EnpriveColors.stateReviewRecommendedBg, // #FDF0E1
    onTertiaryContainer: EnpriveColors.stateReviewRecommendedFg, // #783D0A
    error: EnpriveColors.stateHighConcernFg, // #8A1C24
    onError: Color(0xFFFFFFFF),
    errorContainer: EnpriveColors.stateHighConcernBg, // #FCE8EA
    onErrorContainer: EnpriveColors.stateHighConcernFg, // #8A1C24
    surface: EnpriveColors.paper, // #FAF8F5
    onSurface: EnpriveColors.ink, // #1C2333
    onSurfaceVariant: EnpriveColors.inkSecondary, // #4A5264
    surfaceContainerLowest: EnpriveColors.surface, // #FFFFFF
    surfaceContainerLow: Color(0xFFF6F2EB),
    surfaceContainer: EnpriveColors.surfaceMuted, // #F3EFE8
    surfaceContainerHigh: EnpriveColors.surfaceContainer, // #EDE8DF
    surfaceContainerHighest: EnpriveColors.surfaceContainerHigh, // #E4DDD0
    surfaceDim: EnpriveColors.surfaceContainerHigh, // #E4DDD0
    surfaceBright: EnpriveColors.surface, // #FFFFFF
    inverseSurface: EnpriveColors.darkSurface, // #161F24
    onInverseSurface: EnpriveColors.darkInk, // #F3F0EA
    inversePrimary: EnpriveColors.tealDarkAccent, // #38D9C0
    outline: EnpriveColors.inkMuted, // #5E6678
    outlineVariant: EnpriveColors.lightHairline, // #E0D9CC
    shadow: Color(0x141C2333),
    scrim: Color(0x660E1417),
    surfaceTint: Color(0x00000000),
    emphasis: EnpriveColors.ctaInk, // #1F2A44
    onEmphasis: Color(0xFFFFFFFF),
    info: EnpriveColors.chipInCloudFg, // #24427B
    success: EnpriveColors.stateNoConcernFg, // #165B38
    warning: EnpriveColors.stateReviewRecommendedFg, // #783F00
    danger: EnpriveColors.stateHighConcernFg, // #8C1D24
    surfaceStrong: EnpriveColors.surfaceContainer, // #ECE9E2
    onSurfaceStrong: EnpriveColors.ink, // #1C2333
    outlineStrong: EnpriveColors.lightStrongBorder, // #C4BDB2
  );

  /// Complete 44-role Dark `M3EColorScheme` ("Obsidian Ceramic Slate").
  static const M3EColorScheme darkColorScheme = M3EColorScheme(
    brightness: Brightness.dark,
    primary: EnpriveColors.darkCtaFill, // #2DD4BF
    onPrimary: EnpriveColors.darkCtaInk, // #072724 (8.52:1 AAA)
    primaryContainer: EnpriveColors.darkChipOnDeviceBg, // #102C29
    onPrimaryContainer: EnpriveColors.darkChipOnDeviceFg, // #7CE8DB
    secondary: EnpriveColors.tealDarkAccent, // #4FD1C5
    onSecondary: EnpriveColors.darkCtaInk, // #072724
    secondaryContainer: EnpriveColors.darkSurfaceElevated, // #1E2A30
    onSecondaryContainer: EnpriveColors.darkInk, // #F4F1EA
    tertiary: EnpriveColors.apricot, // #F4A261
    onTertiary: Color(0xFF2B1704),
    tertiaryContainer: EnpriveColors.darkStateReviewRecommendedBg, // #2D2210
    onTertiaryContainer: EnpriveColors.darkStateReviewRecommendedFg, // #FCD283
    error: EnpriveColors.darkStateHighConcernFg, // #FEB4B8
    onError: Color(0xFF3B090E),
    errorContainer: EnpriveColors.darkStateHighConcernBg, // #321619
    onErrorContainer: EnpriveColors.darkStateHighConcernFg, // #FEB4B8
    surface: EnpriveColors.darkCanvas, // #0E1417
    onSurface: EnpriveColors.darkInk, // #F4F1EA
    onSurfaceVariant: EnpriveColors.darkInkSecondary, // #B5C0C6
    surfaceContainerLowest: Color(0xFF0A0F12),
    surfaceContainerLow: EnpriveColors.darkSurface, // #172025
    surfaceContainer: EnpriveColors.darkSurfaceMuted, // #121A1E
    surfaceContainerHigh: EnpriveColors.darkSurfaceElevated, // #1E2A30
    surfaceContainerHighest: EnpriveColors.darkSurfaceHigh, // #26343C
    surfaceDim: Color(0xFF0A0F12),
    surfaceBright: EnpriveColors.darkSurfaceHigh, // #26343C
    inverseSurface: EnpriveColors.paper, // #FAF8F5
    onInverseSurface: EnpriveColors.ink, // #1C2333
    inversePrimary: EnpriveColors.ctaInk, // #1F2A44
    outline: EnpriveColors.darkInkMuted, // #8E9CA4
    outlineVariant: EnpriveColors.darkHairline, // #2B3940
    shadow: Color(0x66000000),
    scrim: Color(0x99000000),
    surfaceTint: Color(0x00000000),
    emphasis: EnpriveColors.darkCtaFill, // #2DD4BF
    onEmphasis: EnpriveColors.darkCtaInk, // #072724
    info: EnpriveColors.darkChipInCloudFg, // #B4CBFF
    success: EnpriveColors.darkStateNoConcernFg, // #86EFAC
    warning: EnpriveColors.darkStateReviewRecommendedFg, // #FBD38D
    danger: EnpriveColors.darkStateHighConcernFg, // #FEB2B2
    surfaceStrong: EnpriveColors.darkSurfaceElevated, // #222D35
    onSurfaceStrong: EnpriveColors.darkInk, // #F3F0EA
    outlineStrong: EnpriveColors.darkStrongBorder, // #3E4F5C
  );

  /// Expressive typography pairing `Nunito` (brand: display, headline, title)
  /// with `Inter` (plain: body, label).
  static M3ETypography get typography {
    final base = M3ETypography.material3().apply(typeface: typefaceConfig);
    return M3ETypography(
      baseline: M3ETypeScale(
        displayLarge: base.baseline.displayLarge.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.6,
        ),
        displayMedium: base.baseline.displayMedium.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        displaySmall: base.baseline.displaySmall.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
        ),
        headlineLarge: base.baseline.headlineLarge.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.35,
        ),
        headlineMedium: base.baseline.headlineMedium.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.25,
        ),
        headlineSmall: base.baseline.headlineSmall.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.15,
        ),
        titleLarge: base.baseline.titleLarge.copyWith(
          fontWeight: FontWeight.w800,
        ),
        titleMedium: base.baseline.titleMedium.copyWith(
          fontWeight: FontWeight.w700,
        ),
        titleSmall: base.baseline.titleSmall.copyWith(
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: base.baseline.bodyLarge.copyWith(
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        bodyMedium: base.baseline.bodyMedium.copyWith(
          fontWeight: FontWeight.w400,
          height: 1.45,
        ),
        bodySmall: base.baseline.bodySmall.copyWith(
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
        labelLarge: base.baseline.labelLarge.copyWith(
          fontFamily: EnpriveTheme.primaryDisplayFontFamily,
          fontWeight: FontWeight.w800,
        ),
        labelMedium: base.baseline.labelMedium.copyWith(
          fontWeight: FontWeight.w700,
        ),
        labelSmall: base.baseline.labelSmall.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      emphasized: base.emphasized.copyWithRoles(
        displayWeight: FontWeight.w900,
        headlineWeight: FontWeight.w800,
        titleWeight: FontWeight.w800,
        labelWeight: FontWeight.w800,
      ),
    );
  }

  /// Light `M3EThemeData` ("Warm Archival Paper").
  static M3EThemeData get lightThemeData => _buildM3EThemeData(
    colorScheme: lightColorScheme,
  );

  /// Dark `M3EThemeData` ("Obsidian Ceramic Slate").
  static M3EThemeData get darkThemeData => _buildM3EThemeData(
    colorScheme: darkColorScheme,
  );

  /// Resolves `M3EThemeData` for the given [mode] and [platformBrightness].
  static M3EThemeData resolve({
    required legacy.ThemeMode mode,
    required Brightness platformBrightness,
  }) {
    final isDark = switch (mode) {
      legacy.ThemeMode.dark => true,
      legacy.ThemeMode.light => false,
      legacy.ThemeMode.system => platformBrightness == Brightness.dark,
    };
    return isDark ? darkThemeData : lightThemeData;
  }

  static M3EThemeData _buildM3EThemeData({
    required M3EColorScheme colorScheme,
  }) {
    return M3EThemeData(
      colorScheme: colorScheme,
      typography: typography,
      useMaterial3: true,
      cardTheme: M3ECardTheme(
        radius: 24,
        gap: 10,
        maxGap: 16,
        contentPadding: const EdgeInsets.all(18),
        elevatedElevation: M3EElevation.level0,
        filledElevation: M3EElevation.level0,
        outlinedElevation: M3EElevation.level0,
        elevatedContainerColor: colorScheme.surfaceContainerLowest,
        filledContainerColor: colorScheme.surfaceContainerLow,
        outlinedContainerColor: colorScheme.surfaceContainerLowest,
        outlineColorOverride: colorScheme.outlineVariant,
        headlineColor: colorScheme.onSurface,
        subheadColor: colorScheme.onSurfaceVariant,
        supportingColor: colorScheme.onSurfaceVariant,
      ),
      buttonTheme: const M3EButtonTheme(
        minWidthFloor: 48,
        connectedInnerRadius: 8,
        connectedPressedInnerRadius: 4,
        shapeSpring: M3EMotion.expressiveSpatialFast,
      ),
      appBarTheme: const M3EAppBarTheme(
        elevation: M3EElevation.level0,
        scrolledElevation: M3EElevation.level0,
        smallHeight: 64,
        titleInset: 20,
      ),
      navigationBarTheme: const M3ENavigationBarTheme(
        elevation: M3EElevation.level0,
        activeLabelWeight: FontWeight.w800,
        inactiveLabelWeight: FontWeight.w600,
      ),
    );
  }

  /// Resolves the active [M3EThemeData] from the nearest [M3ETheme], or falls
  /// back to Enprive's [lightThemeData] / [darkThemeData] matching
  /// `Theme.of(context).brightness` when rendered inside a standalone test harness.
  static M3EThemeData of(BuildContext context) {
    final inherited = M3ETheme.maybeOf(context);
    if (inherited != null) return inherited;
    final brightness = legacy.Theme.of(context).brightness;
    return brightness == Brightness.dark ? darkThemeData : lightThemeData;
  }
}

extension on M3ETypeScale {
  M3ETypeScale copyWithRoles({
    required FontWeight displayWeight,
    required FontWeight headlineWeight,
    required FontWeight titleWeight,
    required FontWeight labelWeight,
  }) {
    return M3ETypeScale(
      displayLarge: displayLarge.copyWith(
        fontWeight: displayWeight,
        letterSpacing: -0.7,
      ),
      displayMedium: displayMedium.copyWith(
        fontWeight: displayWeight,
        letterSpacing: -0.55,
      ),
      displaySmall: displaySmall.copyWith(
        fontWeight: displayWeight,
        letterSpacing: -0.45,
      ),
      headlineLarge: headlineLarge.copyWith(
        fontWeight: headlineWeight,
        letterSpacing: -0.35,
      ),
      headlineMedium: headlineMedium.copyWith(
        fontWeight: headlineWeight,
        letterSpacing: -0.25,
      ),
      headlineSmall: headlineSmall.copyWith(
        fontWeight: headlineWeight,
        letterSpacing: -0.15,
      ),
      titleLarge: titleLarge.copyWith(fontWeight: titleWeight),
      titleMedium: titleMedium.copyWith(fontWeight: titleWeight),
      titleSmall: titleSmall.copyWith(fontWeight: titleWeight),
      bodyLarge: bodyLarge.copyWith(fontWeight: FontWeight.w600),
      bodyMedium: bodyMedium.copyWith(fontWeight: FontWeight.w600),
      bodySmall: bodySmall.copyWith(fontWeight: FontWeight.w600),
      labelLarge: labelLarge.copyWith(
        fontFamily: EnpriveTheme.primaryDisplayFontFamily,
        fontWeight: labelWeight,
      ),
      labelMedium: labelMedium.copyWith(fontWeight: labelWeight),
      labelSmall: labelSmall.copyWith(fontWeight: labelWeight),
    );
  }
}

/// Bridges `M3EThemeData` (`package:material_3_expressive`),
/// `modern.ThemeData` (`package:material_ui`), and `legacy.ThemeData`
/// (`package:flutter/material.dart` + Enprive's 4 `ThemeExtension`s) so that
/// migrated M3E components and unmigrated screens/packages share a single
/// synchronized theme tree.
class EnpriveM3EBridgeScope extends StatelessWidget {
  final legacy.ThemeMode themeMode;
  final Widget child;

  const EnpriveM3EBridgeScope({
    super.key,
    required this.themeMode,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final platformBrightness =
        MediaQuery.maybePlatformBrightnessOf(context) ?? Brightness.light;
    final m3eData = EnpriveM3ETheme.resolve(
      mode: themeMode,
      platformBrightness: platformBrightness,
    );
    final isDark = m3eData.brightness == Brightness.dark;
    final legacyTheme = isDark
        ? EnpriveTheme.darkTheme
        : EnpriveTheme.lightTheme;

    return M3ETheme(
      data: m3eData,
      child: modern.Theme(
        data: m3eData.toThemeData(),
        // ignore: deprecated_member_use
        child: modern.MaterialUiCompatibilityBridge(
          delegates: EnpriveM3ETheme.localizationsDelegates,
          child: legacy.Theme(
            data: legacyTheme,
            child: legacy.ScaffoldMessenger(
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
