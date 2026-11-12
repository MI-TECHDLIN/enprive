import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'enprive_colors.dart';

abstract final class EnpriveTheme {
  static ThemeData get lightTheme {
    final baseTextTheme = Typography.material2021().black;

    return ThemeData(
      useMaterial3: true,
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
        displayLarge: GoogleFonts.sourceSerif4(
          textStyle: baseTextTheme.displayLarge?.copyWith(
            color: EnpriveColors.ink,
            fontWeight: FontWeight.w700,
            fontSize: 32,
            height: 1.2,
          ),
        ),
        headlineLarge: GoogleFonts.sourceSerif4(
          textStyle: baseTextTheme.headlineLarge?.copyWith(
            color: EnpriveColors.ink,
            fontWeight: FontWeight.w700,
            fontSize: 26,
            height: 1.25,
          ),
        ),
        headlineMedium: GoogleFonts.figtree(
          textStyle: baseTextTheme.headlineMedium?.copyWith(
            color: EnpriveColors.ink,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            height: 1.3,
          ),
        ),
        titleMedium: GoogleFonts.figtree(
          textStyle: baseTextTheme.titleMedium?.copyWith(
            color: EnpriveColors.ink,
            fontWeight: FontWeight.w600,
            fontSize: 17,
            height: 1.4,
          ),
        ),
        bodyLarge: GoogleFonts.figtree(
          textStyle: baseTextTheme.bodyLarge?.copyWith(
            color: EnpriveColors.ink,
            fontWeight: FontWeight.w400,
            fontSize: 15,
            height: 1.5,
          ),
        ),
        bodyMedium: GoogleFonts.figtree(
          textStyle: baseTextTheme.bodyMedium?.copyWith(
            color: EnpriveColors.inkSecondary,
            fontWeight: FontWeight.w400,
            fontSize: 14,
            height: 1.45,
          ),
        ),
        labelLarge: GoogleFonts.figtree(
          textStyle: baseTextTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        labelSmall: GoogleFonts.figtree(
          textStyle: baseTextTheme.labelSmall?.copyWith(
            color: EnpriveColors.inkSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 12,
            letterSpacing: 0.5,
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
