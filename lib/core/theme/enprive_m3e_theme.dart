import 'package:flutter/material.dart' as legacy;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    as legacy_l10n;
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:material_ui/material_ui.dart' as modern;

import '../../l10n/app_localizations.dart';
import 'enprive_theme.dart';

/// Enprive's Material 3 Expressive (`material_3_expressive: 1.2.1`) Design System
/// Single Source of Truth, Direction A "Calm evidence".
///
/// Combines:
/// 1. Tonal color roles generated with `material_color_utilities` from Deni's
///    body teal [seedColor] (`#1F9E8F`): a teal primary (H185 C40), a quiet
///    teal secondary (H185 C14), a blue tertiary (H250 C28) and warm paper
///    neutrals (H75 C2.5 / C5). Light and dark come from the same palettes,
///    so the brand hue never flips between themes, and standard, medium and
///    high contrast variants are available through [colorSchemeFor].
/// 2. Expressive dual-scale typography: `Nunito` (brand) on display, headline
///    and title large, `Inter` (plain) everywhere else, `SourceSerif4` for
///    verbatim policy quotes. Baseline weights stay calm (700/600/400/500);
///    the emphasized scale is one step heavier and reserved for the hero
///    title, the primary button, the selected navigation label and key numbers.
/// 3. Tonal elevation: every container sits at level 0 and is told apart by
///    `surfaceContainer*` steps instead of outlines or shadows.
abstract final class EnpriveM3ETheme {
  /// Deni's body teal, the single seed every color role is generated from.
  static const Color seedColor = Color(0xFF1F9E8F);

  /// Standard contrast level (Android default).
  static const double standardContrast = 0.0;

  /// Contrast level used when the platform requests high contrast text.
  static const double highContrast = 1.0;

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

  /// The `material_color_utilities` scheme behind every Enprive color role.
  static DynamicScheme dynamicSchemeFor(
    Brightness brightness, {
    double contrastLevel = standardContrast,
  }) {
    return DynamicScheme(
      sourceColorHct: Hct.fromInt(seedColor.toARGB32()),
      variant: Variant.tonalSpot,
      isDark: brightness == Brightness.dark,
      contrastLevel: contrastLevel,
      primaryPalette: TonalPalette.of(185, 40),
      secondaryPalette: TonalPalette.of(185, 14),
      tertiaryPalette: TonalPalette.of(250, 28),
      neutralPalette: TonalPalette.of(75, 2.5),
      neutralVariantPalette: TonalPalette.of(75, 5),
    );
  }

  /// Complete 44-role [M3EColorScheme] generated from [seedColor].
  static M3EColorScheme colorSchemeFor(
    Brightness brightness, {
    double contrastLevel = standardContrast,
  }) {
    final s = dynamicSchemeFor(brightness, contrastLevel: contrastLevel);
    Color c(DynamicColor role) => Color(role.getArgb(s));
    final review = EnpriveStaticColors.reviewAmber(brightness);

    return M3EColorScheme(
      brightness: brightness,
      primary: c(MaterialDynamicColors.primary),
      onPrimary: c(MaterialDynamicColors.onPrimary),
      primaryContainer: c(MaterialDynamicColors.primaryContainer),
      onPrimaryContainer: c(MaterialDynamicColors.onPrimaryContainer),
      secondary: c(MaterialDynamicColors.secondary),
      onSecondary: c(MaterialDynamicColors.onSecondary),
      secondaryContainer: c(MaterialDynamicColors.secondaryContainer),
      onSecondaryContainer: c(MaterialDynamicColors.onSecondaryContainer),
      tertiary: c(MaterialDynamicColors.tertiary),
      onTertiary: c(MaterialDynamicColors.onTertiary),
      tertiaryContainer: c(MaterialDynamicColors.tertiaryContainer),
      onTertiaryContainer: c(MaterialDynamicColors.onTertiaryContainer),
      error: c(MaterialDynamicColors.error),
      onError: c(MaterialDynamicColors.onError),
      errorContainer: c(MaterialDynamicColors.errorContainer),
      onErrorContainer: c(MaterialDynamicColors.onErrorContainer),
      surface: c(MaterialDynamicColors.surface),
      onSurface: c(MaterialDynamicColors.onSurface),
      onSurfaceVariant: c(MaterialDynamicColors.onSurfaceVariant),
      surfaceContainerLowest: c(MaterialDynamicColors.surfaceContainerLowest),
      surfaceContainerLow: c(MaterialDynamicColors.surfaceContainerLow),
      surfaceContainer: c(MaterialDynamicColors.surfaceContainer),
      surfaceContainerHigh: c(MaterialDynamicColors.surfaceContainerHigh),
      surfaceContainerHighest: c(MaterialDynamicColors.surfaceContainerHighest),
      surfaceDim: c(MaterialDynamicColors.surfaceDim),
      surfaceBright: c(MaterialDynamicColors.surfaceBright),
      inverseSurface: c(MaterialDynamicColors.inverseSurface),
      onInverseSurface: c(MaterialDynamicColors.inverseOnSurface),
      inversePrimary: c(MaterialDynamicColors.inversePrimary),
      outline: c(MaterialDynamicColors.outline),
      outlineVariant: c(MaterialDynamicColors.outlineVariant),
      shadow: c(MaterialDynamicColors.shadow),
      scrim: c(MaterialDynamicColors.scrim),
      surfaceTint: const Color(0x00000000),
      emphasis: c(MaterialDynamicColors.primary),
      onEmphasis: c(MaterialDynamicColors.onPrimary),
      info: c(MaterialDynamicColors.tertiary),
      // Enprive never paints a green "safe" verdict, so the expressive
      // success role maps to the quiet secondary teal.
      success: c(MaterialDynamicColors.secondary),
      warning: review.color,
      danger: c(MaterialDynamicColors.error),
      surfaceStrong: c(MaterialDynamicColors.surfaceContainerHigh),
      onSurfaceStrong: c(MaterialDynamicColors.onSurface),
      outlineStrong: c(MaterialDynamicColors.outline),
    );
  }

  /// Light [M3EColorScheme] at standard contrast.
  static final M3EColorScheme lightColorScheme = colorSchemeFor(
    Brightness.light,
  );

  /// Dark [M3EColorScheme] at standard contrast, from the same palettes.
  static final M3EColorScheme darkColorScheme = colorSchemeFor(Brightness.dark);

  /// Expressive typography pairing `Nunito` (brand: display, headline,
  /// title large) with `Inter` (plain: title medium/small, body, label).
  static M3ETypography get typography => _typography;

  static final M3ETypography _typography = _buildTypography();

  static final Map<(Brightness, double), M3EThemeData> _themeDataCache = {};

  static M3ETypography _buildTypography() {
    final base = M3ETypography.material3().apply(typeface: typefaceConfig);
    const plain = EnpriveTheme.secondaryFontBaseFamily;
    return M3ETypography(
      baseline: M3ETypeScale(
        displayLarge: base.baseline.displayLarge.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        displayMedium: base.baseline.displayMedium.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
        displaySmall: base.baseline.displaySmall.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        headlineLarge: base.baseline.headlineLarge.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.25,
        ),
        headlineMedium: base.baseline.headlineMedium.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        headlineSmall: base.baseline.headlineSmall.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.1,
        ),
        titleLarge: base.baseline.titleLarge.copyWith(
          fontWeight: FontWeight.w700,
        ),
        // Inter is already open; Roboto-tuned M3 tracking (0.5) reads loose.
        titleMedium: base.baseline.titleMedium.copyWith(
          fontFamily: plain,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
        titleSmall: base.baseline.titleSmall.copyWith(
          fontFamily: plain,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
        bodyLarge: base.baseline.bodyLarge.copyWith(
          fontWeight: FontWeight.w400,
          height: 1.5,
          letterSpacing: 0,
        ),
        bodyMedium: base.baseline.bodyMedium.copyWith(
          fontWeight: FontWeight.w400,
          height: 1.45,
          letterSpacing: 0,
        ),
        bodySmall: base.baseline.bodySmall.copyWith(
          fontWeight: FontWeight.w400,
          height: 1.4,
          letterSpacing: 0.1,
        ),
        labelLarge: base.baseline.labelLarge.copyWith(
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
        ),
        labelMedium: base.baseline.labelMedium.copyWith(
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        labelSmall: base.baseline.labelSmall.copyWith(
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
      ),
      emphasized: base.emphasized.copyWithRoles(
        brandWeight: FontWeight.w800,
        titleWeight: FontWeight.w700,
        bodyWeight: FontWeight.w500,
        labelWeight: FontWeight.w700,
      ),
    );
  }

  /// Light `M3EThemeData` at standard contrast.
  static M3EThemeData get lightThemeData => themeDataFor(Brightness.light);

  /// Dark `M3EThemeData` at standard contrast.
  static M3EThemeData get darkThemeData => themeDataFor(Brightness.dark);

  /// `M3EThemeData` for [brightness] at [contrastLevel].
  static M3EThemeData themeDataFor(
    Brightness brightness, {
    double contrastLevel = standardContrast,
  }) {
    return _themeDataCache.putIfAbsent((brightness, contrastLevel), () {
      final colorScheme = contrastLevel == standardContrast
          ? (brightness == Brightness.dark ? darkColorScheme : lightColorScheme)
          : colorSchemeFor(brightness, contrastLevel: contrastLevel);
      return _buildM3EThemeData(colorScheme: colorScheme);
    });
  }

  /// Resolves `M3EThemeData` for the given [mode] and [platformBrightness].
  static M3EThemeData resolve({
    required legacy.ThemeMode mode,
    required Brightness platformBrightness,
    double contrastLevel = standardContrast,
  }) {
    return themeDataFor(
      brightnessFor(mode: mode, platformBrightness: platformBrightness),
      contrastLevel: contrastLevel,
    );
  }

  /// The brightness the app renders in for [mode].
  static Brightness brightnessFor({
    required legacy.ThemeMode mode,
    required Brightness platformBrightness,
  }) {
    return switch (mode) {
      legacy.ThemeMode.dark => Brightness.dark,
      legacy.ThemeMode.light => Brightness.light,
      legacy.ThemeMode.system => platformBrightness,
    };
  }

  /// The contrast level matching the platform accessibility settings.
  static double contrastLevelOf(BuildContext context) {
    return MediaQuery.maybeHighContrastOf(context) ?? false
        ? highContrast
        : standardContrast;
  }

  static M3EThemeData _buildM3EThemeData({
    required M3EColorScheme colorScheme,
  }) {
    return M3EThemeData(
      colorScheme: colorScheme,
      typography: typography,
      useMaterial3: true,
      cardTheme: M3ECardTheme(
        radius: EnpriveRadii.card,
        gap: 8,
        maxGap: 16,
        contentPadding: const EdgeInsets.all(16),
        elevatedElevation: M3EElevation.level0,
        filledElevation: M3EElevation.level0,
        outlinedElevation: M3EElevation.level0,
        elevatedContainerColor: colorScheme.surfaceContainerLow,
        filledContainerColor: colorScheme.surfaceContainer,
        outlinedContainerColor: colorScheme.surface,
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
        scrolledElevation: M3EElevation.level2,
        smallHeight: 64,
        titleInset: 16,
      ),
      chipTheme: const M3EChipTheme(
        height: 32,
        cornerRadius: EnpriveRadii.chip,
        outlineWidth: 1,
      ),
      navigationBarTheme: const M3ENavigationBarTheme(
        elevation: M3EElevation.level0,
        activeLabelWeight: FontWeight.w700,
        inactiveLabelWeight: FontWeight.w500,
      ),
    );
  }

  /// Resolves the active [M3EThemeData] from the nearest [M3ETheme], or falls
  /// back to Enprive's [lightThemeData] / [darkThemeData] matching
  /// `Theme.of(context).brightness` when rendered inside a standalone test harness.
  static M3EThemeData of(BuildContext context) {
    final materialBrightness = legacy.Theme.of(context).brightness;
    if (M3ETheme.maybeOf(context) != null) {
      final resolved = M3ETheme.of(context);
      if (resolved.brightness == materialBrightness) {
        return resolved;
      }
    }
    return materialBrightness == Brightness.dark
        ? darkThemeData
        : lightThemeData;
  }
}

extension on M3ETypeScale {
  M3ETypeScale copyWithRoles({
    required FontWeight brandWeight,
    required FontWeight titleWeight,
    required FontWeight bodyWeight,
    required FontWeight labelWeight,
  }) {
    const plain = EnpriveTheme.secondaryFontBaseFamily;
    return M3ETypeScale(
      displayLarge: displayLarge.copyWith(
        fontWeight: brandWeight,
        letterSpacing: -0.6,
      ),
      displayMedium: displayMedium.copyWith(
        fontWeight: brandWeight,
        letterSpacing: -0.5,
      ),
      displaySmall: displaySmall.copyWith(
        fontWeight: brandWeight,
        letterSpacing: -0.4,
      ),
      headlineLarge: headlineLarge.copyWith(
        fontWeight: brandWeight,
        letterSpacing: -0.3,
      ),
      headlineMedium: headlineMedium.copyWith(
        fontWeight: brandWeight,
        letterSpacing: -0.25,
      ),
      headlineSmall: headlineSmall.copyWith(
        fontWeight: brandWeight,
        letterSpacing: -0.15,
      ),
      titleLarge: titleLarge.copyWith(fontWeight: brandWeight),
      titleMedium: titleMedium.copyWith(
        fontFamily: plain,
        fontWeight: titleWeight,
        letterSpacing: 0,
      ),
      titleSmall: titleSmall.copyWith(
        fontFamily: plain,
        fontWeight: titleWeight,
        letterSpacing: 0,
      ),
      bodyLarge: bodyLarge.copyWith(fontWeight: bodyWeight, letterSpacing: 0),
      bodyMedium: bodyMedium.copyWith(
        fontWeight: bodyWeight,
        letterSpacing: 0,
      ),
      bodySmall: bodySmall.copyWith(fontWeight: bodyWeight, letterSpacing: 0.1),
      labelLarge: labelLarge.copyWith(fontWeight: labelWeight, letterSpacing: 0),
      labelMedium: labelMedium.copyWith(
        fontWeight: labelWeight,
        letterSpacing: 0.1,
      ),
      labelSmall: labelSmall.copyWith(
        fontWeight: labelWeight,
        letterSpacing: 0.1,
      ),
    );
  }
}

/// Bridges `M3EThemeData` (`package:material_3_expressive`),
/// `modern.ThemeData` (`package:material_ui`), and `legacy.ThemeData`
/// (`package:flutter/material.dart` + Enprive's `ThemeExtension`s) so that
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

  /// Ensures `M3ETheme`, `modern.Theme`, and `EnpriveTheme` extensions are
  /// present in the widget tree even when a screen or sheet is pumped inside a
  /// standalone `MaterialApp` test harness.
  static Widget ensure(BuildContext context, {required Widget child}) {
    if (M3ETheme.maybeOf(context) != null) {
      return child;
    }
    final isDark = legacy.Theme.of(context).brightness == Brightness.dark;
    return EnpriveM3EBridgeScope(
      themeMode: isDark ? legacy.ThemeMode.dark : legacy.ThemeMode.light,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final platformBrightness =
        MediaQuery.maybePlatformBrightnessOf(context) ??
        View.maybeOf(context)?.platformDispatcher.platformBrightness ??
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final contrastLevel = EnpriveM3ETheme.contrastLevelOf(context);
    final m3eData = EnpriveM3ETheme.resolve(
      mode: themeMode,
      platformBrightness: platformBrightness,
      contrastLevel: contrastLevel,
    );
    final legacyTheme = EnpriveTheme.themeFor(
      m3eData.brightness,
      contrastLevel: contrastLevel,
    );

    final isDark = m3eData.brightness == Brightness.dark;
    final iconBrightness = isDark ? Brightness.light : Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: const Color(0x00000000),
        systemNavigationBarColor: const Color(0x00000000),
        statusBarIconBrightness: iconBrightness,
        systemNavigationBarIconBrightness: iconBrightness,
        statusBarBrightness: m3eData.brightness,
        systemStatusBarContrastEnforced: false,
      ),
      child: M3ETheme(
        data: m3eData,
        child: modern.Theme(
          data: m3eData.toThemeData(),
          // ignore: deprecated_member_use
          child: modern.MaterialUiCompatibilityBridge(
            delegates: EnpriveM3ETheme.localizationsDelegates,
            child: legacy.Theme(
              data: legacyTheme,
              child: legacy.ScaffoldMessenger.maybeOf(context) != null
                  ? child
                  : legacy.ScaffoldMessenger(child: child),
            ),
          ),
        ),
      ),
    );
  }
}
