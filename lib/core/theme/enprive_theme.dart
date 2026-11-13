import 'package:flutter/material.dart';
import 'enprive_colors.dart';

/// Enprive Typography & Material 3 Theme:
/// - Primary Font: Google Fonts `Nunito` (`Nunito` — rounded, approachable,
///   high-craft character-led headings, titles, buttons, and primary UI)
/// - Secondary Font (FontBase https://fontba.se/?ref=panda): `Inter`
/// - Policy Quote Font: `SourceSerif4` (distinct editorial serif for verbatim quotes)
/// All families are bundled locally in `assets/fonts/` and declared in
/// `pubspec.yaml` for 100% offline rendering.
abstract final class EnpriveTheme {
  static const String primaryDisplayFontFamily = 'Nunito';
  static const String secondaryFontBaseFamily = 'Inter';
  static const String quoteFontFamily = 'SourceSerif4';

  static ThemeData get lightTheme {
    final baseTextTheme = Typography.material2021().black;

    return ThemeData(
      useMaterial3: true,
      fontFamily: primaryDisplayFontFamily,
      scaffoldBackgroundColor: EnpriveColors.paper,
      colorScheme: ColorScheme.fromSeed(
        seedColor: EnpriveColors.teal,
        surface: EnpriveColors.surface,
        onSurface: EnpriveColors.ink,
        primary: EnpriveColors.ctaInk,
        onPrimary: Colors.white,
        secondary: EnpriveColors.tealStrong,
      ),
      textTheme: TextTheme(
        // Primary Font: Nunito (Headlines, Titles, Buttons & Primary Hierarchy)
        displayLarge: baseTextTheme.displayLarge?.copyWith(
          fontFamily: primaryDisplayFontFamily,
          color: EnpriveColors.ink,
          fontWeight: FontWeight.w800,
          fontSize: 32,
          height: 1.18,
          letterSpacing: -0.4,
        ),
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(
          fontFamily: primaryDisplayFontFamily,
          color: EnpriveColors.ink,
          fontWeight: FontWeight.w800,
          fontSize: 26,
          height: 1.22,
          letterSpacing: -0.3,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          fontFamily: primaryDisplayFontFamily,
          color: EnpriveColors.ink,
          fontWeight: FontWeight.w800,
          fontSize: 20,
          height: 1.28,
          letterSpacing: -0.2,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          fontFamily: primaryDisplayFontFamily,
          color: EnpriveColors.ink,
          fontWeight: FontWeight.w700,
          fontSize: 17,
          height: 1.35,
        ),
        labelLarge: baseTextTheme.labelLarge?.copyWith(
          fontFamily: primaryDisplayFontFamily,
          fontWeight: FontWeight.w800,
          fontSize: 16,
        ),
        // Secondary Font: FontBase Inter (Readable Body & Captions)
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          fontFamily: secondaryFontBaseFamily,
          color: EnpriveColors.ink,
          fontWeight: FontWeight.w400,
          fontSize: 15,
          height: 1.5,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          fontFamily: secondaryFontBaseFamily,
          color: EnpriveColors.inkSecondary,
          fontWeight: FontWeight.w400,
          fontSize: 14,
          height: 1.45,
        ),
        labelSmall: baseTextTheme.labelSmall?.copyWith(
          fontFamily: secondaryFontBaseFamily,
          color: EnpriveColors.inkSecondary,
          fontWeight: FontWeight.w600,
          fontSize: 12,
          letterSpacing: 0.2,
        ),
      ),
      cardTheme: const CardThemeData(
        color: EnpriveColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: EnpriveColors.paper,
        foregroundColor: EnpriveColors.ink,
        elevation: 0,
        centerTitle: false,
      ),
    );
  }
}
