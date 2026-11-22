import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_3_expressive/material_3_expressive.dart'
    show M3EColorScheme;

import 'enprive_m3e_theme.dart';
import 'enprive_tokens.dart';

export 'enprive_m3e_theme.dart';
export 'enprive_tokens.dart';

/// Enprive Material 3 Expressive Theme Foundation (Single Source of Truth),
/// Direction A "Calm evidence":
/// - Color: every role comes from [EnpriveM3ETheme.colorSchemeFor], generated
///   from Deni's body teal. Light is warm paper (`surface` `#FFF8F4`) with a
///   teal primary; dark is warm charcoal with the same teal hue.
/// - Elevation: tonal surface steps only, no outlines or drop shadows.
/// - Typography:
///   - Brand Font (display, headline, title large): `Nunito`
///   - Plain Font (title medium/small, body, label): `Inter`
///   - Verbatim Policy Quote Font: `SourceSerif4`
abstract final class EnpriveTheme {
  static const String primaryDisplayFontFamily = 'Nunito';
  static const String secondaryFontBaseFamily = 'Inter';
  static const String quoteFontFamily = 'SourceSerif4';

  /// Light framework [ColorScheme] at standard contrast.
  static ColorScheme get lightColorScheme =>
      colorSchemeFrom(EnpriveM3ETheme.lightColorScheme);

  /// Dark framework [ColorScheme] at standard contrast.
  static ColorScheme get darkColorScheme =>
      colorSchemeFrom(EnpriveM3ETheme.darkColorScheme);

  /// Mirrors an [M3EColorScheme] into the framework [ColorScheme] so legacy
  /// widgets and M3E components read identical roles.
  static ColorScheme colorSchemeFrom(M3EColorScheme s) {
    return ColorScheme(
      brightness: s.brightness,
      primary: s.primary,
      onPrimary: s.onPrimary,
      primaryContainer: s.primaryContainer,
      onPrimaryContainer: s.onPrimaryContainer,
      secondary: s.secondary,
      onSecondary: s.onSecondary,
      secondaryContainer: s.secondaryContainer,
      onSecondaryContainer: s.onSecondaryContainer,
      tertiary: s.tertiary,
      onTertiary: s.onTertiary,
      tertiaryContainer: s.tertiaryContainer,
      onTertiaryContainer: s.onTertiaryContainer,
      error: s.error,
      onError: s.onError,
      errorContainer: s.errorContainer,
      onErrorContainer: s.onErrorContainer,
      surface: s.surface,
      onSurface: s.onSurface,
      surfaceDim: s.surfaceDim,
      surfaceBright: s.surfaceBright,
      surfaceContainerLowest: s.surfaceContainerLowest,
      surfaceContainerLow: s.surfaceContainerLow,
      surfaceContainer: s.surfaceContainer,
      surfaceContainerHigh: s.surfaceContainerHigh,
      surfaceContainerHighest: s.surfaceContainerHighest,
      onSurfaceVariant: s.onSurfaceVariant,
      outline: s.outline,
      outlineVariant: s.outlineVariant,
      shadow: s.shadow,
      scrim: s.scrim,
      inverseSurface: s.inverseSurface,
      onInverseSurface: s.onInverseSurface,
      inversePrimary: s.inversePrimary,
      surfaceTint: Colors.transparent,
    );
  }

  static final ThemeData _light = themeFor(Brightness.light);
  static final ThemeData _dark = themeFor(Brightness.dark);

  static ThemeData get lightTheme => _light;

  static ThemeData get darkTheme => _dark;

  /// Framework [ThemeData] (with Enprive's `ThemeExtension`s) for
  /// [brightness] at [contrastLevel].
  static ThemeData themeFor(
    Brightness brightness, {
    double contrastLevel = EnpriveM3ETheme.standardContrast,
  }) {
    return _themeCache.putIfAbsent(
      (brightness, contrastLevel),
      () => _themeFor(brightness, contrastLevel),
    );
  }

  static final Map<(Brightness, double), ThemeData> _themeCache = {};

  static ThemeData _themeFor(Brightness brightness, double contrastLevel) {
    final colorScheme = colorSchemeFrom(
      EnpriveM3ETheme.colorSchemeFor(brightness, contrastLevel: contrastLevel),
    );
    return _buildTheme(
      colorScheme: colorScheme,
      surfaces: EnpriveSurfaceTokens.fromColorScheme(colorScheme),
      semantics: EnpriveSemanticColors.fromColorScheme(
        colorScheme,
        contrastLevel: contrastLevel,
      ),
      categories: EnpriveCategoryColors.forBrightness(
        brightness,
        contrastLevel: contrastLevel,
      ),
    );
  }

  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required EnpriveSurfaceTokens surfaces,
    required EnpriveSemanticColors semantics,
    required EnpriveCategoryColors categories,
  }) {
    final brightness = colorScheme.brightness;
    final isDark = brightness == Brightness.dark;
    final primaryInk = colorScheme.onSurface;
    final secondaryInk = colorScheme.onSurfaceVariant;
    final baseTextTheme = isDark
        ? Typography.material2021().white
        : Typography.material2021().black;

    TextStyle? brand(
      TextStyle? base,
      double size,
      double height, {
      double letterSpacing = 0,
    }) {
      return base?.copyWith(
        fontFamily: primaryDisplayFontFamily,
        color: primaryInk,
        fontWeight: FontWeight.w700,
        fontSize: size,
        height: height,
        letterSpacing: letterSpacing,
      );
    }

    final textTheme = TextTheme(
      displayLarge: brand(
        baseTextTheme.displayLarge,
        32,
        1.18,
        letterSpacing: -0.4,
      ),
      displayMedium: brand(
        baseTextTheme.displayMedium,
        28,
        1.2,
        letterSpacing: -0.35,
      ),
      displaySmall: brand(
        baseTextTheme.displaySmall,
        24,
        1.22,
        letterSpacing: -0.3,
      ),
      headlineLarge: brand(
        baseTextTheme.headlineLarge,
        26,
        1.22,
        letterSpacing: -0.3,
      ),
      headlineMedium: brand(
        baseTextTheme.headlineMedium,
        20,
        1.28,
        letterSpacing: -0.2,
      ),
      headlineSmall: brand(
        baseTextTheme.headlineSmall,
        18,
        1.3,
        letterSpacing: -0.15,
      ),
      titleLarge: brand(baseTextTheme.titleLarge, 19, 1.32),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        fontFamily: secondaryFontBaseFamily,
        letterSpacing: 0,
        color: primaryInk,
        fontWeight: FontWeight.w600,
        fontSize: 16,
        height: 1.4,
      ),
      titleSmall: baseTextTheme.titleSmall?.copyWith(
        fontFamily: secondaryFontBaseFamily,
        letterSpacing: 0,
        color: primaryInk,
        fontWeight: FontWeight.w600,
        fontSize: 14,
        height: 1.4,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        fontFamily: secondaryFontBaseFamily,
        letterSpacing: 0,
        color: primaryInk,
        fontWeight: FontWeight.w400,
        fontSize: 15,
        height: 1.5,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        fontFamily: secondaryFontBaseFamily,
        letterSpacing: 0,
        color: secondaryInk,
        fontWeight: FontWeight.w400,
        fontSize: 14,
        height: 1.45,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        fontFamily: secondaryFontBaseFamily,
        letterSpacing: 0.1,
        color: secondaryInk,
        fontWeight: FontWeight.w400,
        fontSize: 12.5,
        height: 1.4,
      ),
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        fontFamily: secondaryFontBaseFamily,
        letterSpacing: 0,
        color: primaryInk,
        fontWeight: FontWeight.w500,
        fontSize: 14,
        height: 1.3,
      ),
      labelMedium: baseTextTheme.labelMedium?.copyWith(
        fontFamily: secondaryFontBaseFamily,
        color: secondaryInk,
        fontWeight: FontWeight.w500,
        fontSize: 12.5,
        height: 1.3,
        letterSpacing: 0.15,
      ),
      labelSmall: baseTextTheme.labelSmall?.copyWith(
        fontFamily: secondaryFontBaseFamily,
        color: secondaryInk,
        fontWeight: FontWeight.w500,
        fontSize: 11.5,
        height: 1.3,
        letterSpacing: 0.2,
      ),
    );

    const buttonLabel = TextStyle(
      fontFamily: secondaryFontBaseFamily,
      fontSize: 14,
      fontWeight: FontWeight.w600,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: secondaryFontBaseFamily,
      scaffoldBackgroundColor: surfaces.canvas,
      colorScheme: colorScheme,
      textTheme: textTheme,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      splashFactory: InkSparkle.splashFactory,
      extensions: <ThemeExtension<dynamic>>[
        semantics,
        surfaces,
        categories,
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
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(EnpriveRadii.card)),
        ),
      ),
      appBarTheme: AppBarTheme(
        // Flat at rest; fills with surfaceContainer once content scrolls under.
        backgroundColor: WidgetStateColor.resolveWith(
          (states) => states.contains(WidgetState.scrolledUnder)
              ? colorScheme.surfaceContainer
              : colorScheme.surface,
        ),
        foregroundColor: primaryInk,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: EnpriveSpacing.md,
        titleTextStyle: textTheme.titleLarge,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surfaceContainer,
        indicatorColor: colorScheme.secondaryContainer,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 72,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontFamily: secondaryFontBaseFamily,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
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
        backgroundColor: colorScheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(EnpriveRadii.sheet)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
        selectedColor: colorScheme.secondaryContainer,
        checkmarkColor: colorScheme.onSecondaryContainer,
        side: BorderSide(color: colorScheme.outlineVariant),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(EnpriveRadii.chip)),
        ),
        labelStyle: TextStyle(
          fontFamily: secondaryFontBaseFamily,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: primaryInk,
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
          shape: const WidgetStatePropertyAll(StadiumBorder()),
          side: WidgetStatePropertyAll(BorderSide(color: colorScheme.outline)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: surfaces.disabledBg,
          disabledForegroundColor: surfaces.disabledFg,
          minimumSize: const Size(64, EnpriveSpacing.minTouchTarget),
          shape: const StadiumBorder(),
          textStyle: buttonLabel,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurfaceVariant,
          minimumSize: const Size(64, EnpriveSpacing.minTouchTarget),
          side: BorderSide(color: colorScheme.outlineVariant),
          shape: const StadiumBorder(),
          textStyle: buttonLabel,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          minimumSize: const Size(48, EnpriveSpacing.minTouchTarget),
          shape: const StadiumBorder(),
          textStyle: buttonLabel,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(
            EnpriveSpacing.minTouchTarget,
            EnpriveSpacing.minTouchTarget,
          ),
          foregroundColor: colorScheme.onSurfaceVariant,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        hintStyle: TextStyle(
          fontFamily: secondaryFontBaseFamily,
          fontSize: 14,
          color: secondaryInk,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(EnpriveRadii.field),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(EnpriveRadii.field),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(EnpriveRadii.field),
          borderSide: BorderSide(color: colorScheme.primary, width: 2.0),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1.0,
        space: 1.0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface,
        actionTextColor: colorScheme.inversePrimary,
        contentTextStyle: TextStyle(
          fontFamily: secondaryFontBaseFamily,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: colorScheme.onInverseSurface,
        ),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(EnpriveRadii.xs)),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.secondaryContainer,
      ),
      switchTheme: SwitchThemeData(
        thumbIcon: WidgetStateProperty.resolveWith(
          (states) => Icon(
            states.contains(WidgetState.selected) ? Icons.check : Icons.close,
          ),
        ),
      ),
    );
  }
}
