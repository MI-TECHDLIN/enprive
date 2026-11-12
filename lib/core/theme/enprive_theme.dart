import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'enprive_colors.dart';

/// Enprive Typography & Material 3 Theme:
/// - Primary Display / Editorial Quotes: `Source Serif 4` (`SourceSerif4`)
/// - Secondary UI / Body Font (FontBase https://fontba.se/?ref=panda): `Inter`
/// Both families are bundled locally in `assets/fonts/` so typography remains
/// 100% deterministic in Airplane Mode during offline Gemini Nano 4 reviews.
abstract final class EnpriveTheme {
  static const String primaryDisplayFontFamily = 'SourceSerif4';
  static const String secondaryFontBaseFamily = 'Inter';

  static ThemeData get lightTheme {
    final baseTextTheme = Typography.material2021().black;

    return ThemeData(
      useMaterial3: true,
      fontFamily: secondaryFontBaseFamily,
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
        // Primary Font: Source Serif 4 (Editorial Headlines & Verbatim Quotes)
        displayLarge: GoogleFonts.sourceSerif4(
          textStyle: baseTextTheme.displayLarge?.copyWith(
            fontFamily: primaryDisplayFontFamily,
            color: EnpriveColors.ink,
            fontWeight: FontWeight.w700,
            fontSize: 32,
            height: 1.2,
          ),
        ),
        headlineLarge: GoogleFonts.sourceSerif4(
          textStyle: baseTextTheme.headlineLarge?.copyWith(
            fontFamily: primaryDisplayFontFamily,
            color: EnpriveColors.ink,
            fontWeight: FontWeight.w700,
            fontSize: 26,
            height: 1.25,
          ),
        ),
        // Secondary Font: FontBase Inter (UI, Subheadings, Body, Pills, CTAs)
        headlineMedium: GoogleFonts.inter(
          textStyle: baseTextTheme.headlineMedium?.copyWith(
            fontFamily: secondaryFontBaseFamily,
            color: EnpriveColors.ink,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            height: 1.3,
            letterSpacing: -0.3,
          ),
        ),
        titleMedium: GoogleFonts.inter(
          textStyle: baseTextTheme.titleMedium?.copyWith(
            fontFamily: secondaryFontBaseFamily,
            color: EnpriveColors.ink,
            fontWeight: FontWeight.w600,
            fontSize: 17,
            height: 1.4,
            letterSpacing: -0.2,
          ),
        ),
        bodyLarge: GoogleFonts.inter(
          textStyle: baseTextTheme.bodyLarge?.copyWith(
            fontFamily: secondaryFontBaseFamily,
            color: EnpriveColors.ink,
            fontWeight: FontWeight.w400,
            fontSize: 15,
            height: 1.5,
          ),
        ),
        bodyMedium: GoogleFonts.inter(
          textStyle: baseTextTheme.bodyMedium?.copyWith(
            fontFamily: secondaryFontBaseFamily,
            color: EnpriveColors.inkSecondary,
            fontWeight: FontWeight.w400,
            fontSize: 14,
            height: 1.45,
          ),
        ),
        labelLarge: GoogleFonts.inter(
          textStyle: baseTextTheme.labelLarge?.copyWith(
            fontFamily: secondaryFontBaseFamily,
            fontWeight: FontWeight.w700,
            fontSize: 16,
            letterSpacing: -0.1,
          ),
        ),
        labelSmall: GoogleFonts.inter(
          textStyle: baseTextTheme.labelSmall?.copyWith(
            fontFamily: secondaryFontBaseFamily,
            color: EnpriveColors.inkSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 12,
            letterSpacing: 0.4,
          ),
        ),
      ),
      cardTheme: const CardThemeData(
        color: EnpriveColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          side: BorderSide(color: Color(0xFFEAE7E1), width: 1),
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
