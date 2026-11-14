import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'enprive_colors.dart';
import 'enprive_tokens.dart';

export 'enprive_m3e_theme.dart';
export 'enprive_tokens.dart';

/// Enprive Material 3 Expressive Theme Foundation (Single Source of Truth):
/// - Light Mode: "Warm Archival Paper" (`#FAF8F5` canvas, oatmeal containers,
///   deep charcoal ink, ceramic teal accents).
/// - Dark Mode: "Obsidian Ceramic Slate" (`#0E1417` canvas, layered slate
///   containers, warm cream ink, accessible teal & harmonized semantic accents).
/// - Typography:
///   - Primary Display/UI Font: `Nunito`
///   - Secondary Body/Data Font: `Inter`
///   - Verbatim Policy Quote Font: `SourceSerif4`
abstract final class EnpriveTheme {
  static const String primaryDisplayFontFamily = 'Nunito';
  static const String secondaryFontBaseFamily = 'Inter';
  static const String quoteFontFamily = 'SourceSerif4';

  static ColorScheme get lightColorScheme {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: EnpriveColors.ctaInk,
      onPrimary: Colors.white,
      primaryContainer: EnpriveColors.chipOnDeviceBg,
      onPrimaryContainer: EnpriveColors.chipOnDeviceFg,
      secondary: EnpriveColors.tealStrong,
      onSecondary: Colors.white,
      secondaryContainer: EnpriveColors.surfaceContainer,
      onSecondaryContainer: EnpriveColors.ink,
      tertiary: Color(0xFF9E5316),
      onTertiary: Colors.white,
      tertiaryContainer: EnpriveColors.stateReviewRecommendedBg,
      onTertiaryContainer: EnpriveColors.stateReviewRecommendedFg,
      error: EnpriveColors.stateHighConcernFg,
      onError: Colors.white,
      errorContainer: EnpriveColors.stateHighConcernBg,
      onErrorContainer: EnpriveColors.stateHighConcernFg,
      surface: EnpriveColors.surface,
      onSurface: EnpriveColors.ink,
      surfaceDim: EnpriveColors.surfaceContainerHigh,
      surfaceBright: EnpriveColors.surface,
      surfaceContainerLowest: EnpriveColors.surface,
      surfaceContainerLow: EnpriveColors.paper,
      surfaceContainer: EnpriveColors.surfaceMuted,
      surfaceContainerHigh: EnpriveColors.surfaceContainer,
      surfaceContainerHighest: EnpriveColors.surfaceContainerHigh,
      onSurfaceVariant: EnpriveColors.inkSecondary,
      outline: EnpriveColors.inkMuted,
      outlineVariant: EnpriveColors.lightHairline,
      shadow: Color(0x141C2333),
      scrim: Color(0x660E1417),
      inverseSurface: EnpriveColors.darkSurface,
      onInverseSurface: EnpriveColors.darkInk,
      inversePrimary: EnpriveColors.tealDarkAccent,
    );
  }

  static ColorScheme get darkColorScheme {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: EnpriveColors.darkCtaFill,
      onPrimary: EnpriveColors.darkCtaInk,
      primaryContainer: EnpriveColors.darkChipOnDeviceBg,
      onPrimaryContainer: EnpriveColors.darkChipOnDeviceFg,
      secondary: EnpriveColors.tealDarkAccent,
      onSecondary: EnpriveColors.darkCtaInk,
      secondaryContainer: EnpriveColors.darkSurfaceElevated,
      onSecondaryContainer: EnpriveColors.darkInk,
      tertiary: EnpriveColors.apricot,
      onTertiary: Color(0xFF2B1704),
      tertiaryContainer: EnpriveColors.darkStateReviewRecommendedBg,
      onTertiaryContainer: EnpriveColors.darkStateReviewRecommendedFg,
      error: EnpriveColors.darkStateHighConcernFg,
      onError: Color(0xFF3B090E),
      errorContainer: EnpriveColors.darkStateHighConcernBg,
      onErrorContainer: EnpriveColors.darkStateHighConcernFg,
      surface: EnpriveColors.darkSurface,
      onSurface: EnpriveColors.darkInk,
      surfaceDim: EnpriveColors.darkCanvas,
      surfaceBright: EnpriveColors.darkSurfaceHigh,
      surfaceContainerLowest: Color(0xFF0A0F12),
      surfaceContainerLow: EnpriveColors.darkSurfaceMuted,
      surfaceContainer: EnpriveColors.darkSurface,
      surfaceContainerHigh: EnpriveColors.darkSurfaceElevated,
      surfaceContainerHighest: EnpriveColors.darkSurfaceHigh,
      onSurfaceVariant: EnpriveColors.darkInkSecondary,
      outline: EnpriveColors.darkInkMuted,
      outlineVariant: EnpriveColors.darkHairline,
      shadow: Color(0x66000000),
      scrim: Color(0x99000000),
      inverseSurface: EnpriveColors.paper,
      onInverseSurface: EnpriveColors.ink,
      inversePrimary: EnpriveColors.tealStrong,
    );
  }

  static ThemeData get lightTheme => _buildTheme(
    brightness: Brightness.light,
    colorScheme: lightColorScheme,
    surfaces: EnpriveSurfaceTokens.light,
    semantics: EnpriveSemanticColors.light,
    primaryInk: EnpriveColors.ink,
    secondaryInk: EnpriveColors.inkSecondary,
    mutedInk: EnpriveColors.inkMuted,
  );

  static ThemeData get darkTheme => _buildTheme(
    brightness: Brightness.dark,
    colorScheme: darkColorScheme,
    surfaces: EnpriveSurfaceTokens.dark,
    semantics: EnpriveSemanticColors.dark,
    primaryInk: EnpriveColors.darkInk,
    secondaryInk: EnpriveColors.darkInkSecondary,
    mutedInk: EnpriveColors.darkInkMuted,
  );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required ColorScheme colorScheme,
    required EnpriveSurfaceTokens surfaces,
    required EnpriveSemanticColors semantics,
    required Color primaryInk,
    required Color secondaryInk,
    required Color mutedInk,
  }) {
    final isDark = brightness == Brightness.dark;
    final baseTextTheme = isDark
        ? Typography.material2021().white
        : Typography.material2021().black;

    final textTheme = TextTheme(
      displayLarge: baseTextTheme.displayLarge?.copyWith(
        fontFamily: primaryDisplayFontFamily,
        color: primaryInk,
        fontWeight: FontWeight.w800,
        fontSize: 32,
        height: 1.18,
        letterSpacing: -0.4,
      ),
      displayMedium: baseTextTheme.displayMedium?.copyWith(
        fontFamily: primaryDisplayFontFamily,
        color: primaryInk,
        fontWeight: FontWeight.w800,
        fontSize: 28,
        height: 1.20,
        letterSpacing: -0.35,
      ),
      displaySmall: baseTextTheme.displaySmall?.copyWith(
        fontFamily: primaryDisplayFontFamily,
        color: primaryInk,
        fontWeight: FontWeight.w800,
        fontSize: 24,
        height: 1.22,
        letterSpacing: -0.3,
      ),
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(
        fontFamily: primaryDisplayFontFamily,
        color: primaryInk,
        fontWeight: FontWeight.w800,
        fontSize: 26,
        height: 1.22,
        letterSpacing: -0.3,
      ),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        fontFamily: primaryDisplayFontFamily,
        color: primaryInk,
        fontWeight: FontWeight.w800,
        fontSize: 20,
        height: 1.28,
        letterSpacing: -0.2,
      ),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        fontFamily: primaryDisplayFontFamily,
        color: primaryInk,
        fontWeight: FontWeight.w800,
        fontSize: 18,
        height: 1.30,
        letterSpacing: -0.15,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontFamily: primaryDisplayFontFamily,
        color: primaryInk,
        fontWeight: FontWeight.w800,
        fontSize: 19,
        height: 1.32,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        fontFamily: primaryDisplayFontFamily,
        color: primaryInk,
        fontWeight: FontWeight.w700,
        fontSize: 17,
        height: 1.35,
      ),
      titleSmall: baseTextTheme.titleSmall?.copyWith(
        fontFamily: primaryDisplayFontFamily,
        color: primaryInk,
        fontWeight: FontWeight.w700,
        fontSize: 15,
        height: 1.35,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        fontFamily: secondaryFontBaseFamily,
        color: primaryInk,
        fontWeight: FontWeight.w400,
        fontSize: 15,
        height: 1.5,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        fontFamily: secondaryFontBaseFamily,
        color: secondaryInk,
        fontWeight: FontWeight.w400,
        fontSize: 14,
        height: 1.45,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        fontFamily: secondaryFontBaseFamily,
        color: secondaryInk,
        fontWeight: FontWeight.w500,
        fontSize: 12.5,
        height: 1.4,
      ),
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        fontFamily: primaryDisplayFontFamily,
        color: primaryInk,
        fontWeight: FontWeight.w800,
        fontSize: 16,
        height: 1.25,
      ),
      labelMedium: baseTextTheme.labelMedium?.copyWith(
        fontFamily: secondaryFontBaseFamily,
        color: secondaryInk,
        fontWeight: FontWeight.w700,
        fontSize: 13,
        height: 1.3,
        letterSpacing: 0.15,
      ),
      labelSmall: baseTextTheme.labelSmall?.copyWith(
        fontFamily: secondaryFontBaseFamily,
        color: secondaryInk,
        fontWeight: FontWeight.w600,
        fontSize: 12,
        height: 1.3,
        letterSpacing: 0.2,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: primaryDisplayFontFamily,
      scaffoldBackgroundColor: surfaces.canvas,
      colorScheme: colorScheme,
      textTheme: textTheme,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      extensions: <ThemeExtension<dynamic>>[
        semantics,
        surfaces,
        EnpriveMotionTokens.standard,
        EnpriveTypographyExtension.forBrightness(
          primaryInk: primaryInk,
          secondaryInk: secondaryInk,
        ),
      ],
      cardTheme: CardThemeData(
        color: surfaces.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(EnpriveRadii.xl),
          ),
          side: BorderSide(color: surfaces.hairlineBorder, width: 1.0),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaces.canvas,
        foregroundColor: primaryInk,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaces.card,
        indicatorColor: semantics.onDevice.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontFamily: primaryDisplayFontFamily,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
            color: selected ? primaryInk : secondaryInk,
          );
        }),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaces.sheetSurface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: surfaces.sheetSurface,
        elevation: 0,
        showDragHandle: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(EnpriveRadii.sheet),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaces.card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(EnpriveRadii.xl),
          side: BorderSide(color: surfaces.hairlineBorder, width: 1.0),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaces.cardMuted,
        selectedColor: semantics.onDevice.background,
        side: BorderSide(color: surfaces.hairlineBorder),
        shape: const StadiumBorder(),
        labelStyle: TextStyle(
          fontFamily: secondaryFontBaseFamily,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: primaryInk,
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
          shape: const WidgetStatePropertyAll(StadiumBorder()),
          side: WidgetStatePropertyAll(
            BorderSide(color: surfaces.hairlineBorder),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: surfaces.tactilePrimaryBg,
          foregroundColor: surfaces.tactilePrimaryFg,
          disabledBackgroundColor: surfaces.disabledBg,
          disabledForegroundColor: surfaces.disabledFg,
          minimumSize: const Size(64, EnpriveSpacing.minTouchTarget),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontFamily: primaryDisplayFontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryInk,
          backgroundColor: surfaces.card,
          minimumSize: const Size(64, EnpriveSpacing.minTouchTarget),
          side: BorderSide(color: surfaces.strongBorder, width: 1.2),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontFamily: primaryDisplayFontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: isDark
              ? EnpriveColors.tealDarkAccent
              : EnpriveColors.tealStrong,
          minimumSize: const Size(48, EnpriveSpacing.minTouchTarget),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontFamily: primaryDisplayFontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(
            EnpriveSpacing.minTouchTarget,
            EnpriveSpacing.minTouchTarget,
          ),
          foregroundColor: primaryInk,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaces.cardMuted,
        hintStyle: TextStyle(
          fontFamily: secondaryFontBaseFamily,
          fontSize: 14,
          color: mutedInk,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(EnpriveRadii.lg),
          borderSide: BorderSide(color: surfaces.hairlineBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(EnpriveRadii.lg),
          borderSide: BorderSide(color: surfaces.hairlineBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(EnpriveRadii.lg),
          borderSide: BorderSide(
            color: isDark ? EnpriveColors.tealDarkAccent : EnpriveColors.teal,
            width: 2.0,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: surfaces.hairlineBorder,
        thickness: 1.0,
        space: 1.0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark
            ? EnpriveColors.darkSurfaceElevated
            : EnpriveColors.ink,
        contentTextStyle: TextStyle(
          fontFamily: secondaryFontBaseFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark ? EnpriveColors.darkInk : Colors.white,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(EnpriveRadii.md),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: isDark ? EnpriveColors.tealDarkAccent : EnpriveColors.teal,
        linearTrackColor: surfaces.cardMuted,
      ),
    );
  }
}
