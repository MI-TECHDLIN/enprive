import 'package:flutter/material.dart';

/// Contrast-checked WCAG AAA/AA tokens for Enprive.
abstract final class EnpriveColors {
  // Base backgrounds
  static const Color paper = Color(0xFFFAF8F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF3F1EC);
  static const Color quoteSurface = Color(0xFFF6F1E7);

  // Typography & ink
  static const Color ink = Color(0xFF1C2333);
  static const Color inkSecondary = Color(0xFF5B6475);
  static const Color inkDisabled = Color(0xFF8A8F99);

  // Tactile button ink
  static const Color ctaInk = Color(0xFF1F2A44);
  static const Color ctaLip = Color(0xFF10172A);

  // Brand teal
  static const Color teal = Color(0xFF1E9E8F);
  static const Color tealStrong = Color(0xFF137A6F);

  // Review states (Foreground + Background)
  static const Color stateNoConcernFg = Color(0xFF1F6B45);
  static const Color stateNoConcernBg = Color(0xFFE7F3EC);

  static const Color stateReviewRecommendedFg = Color(0xFF8A4B00);
  static const Color stateReviewRecommendedBg = Color(0xFFFFF1DB);

  static const Color stateInsufficientEvidenceFg = Color(0xFF4A5263);
  static const Color stateInsufficientEvidenceBg = Color(0xFFEEF0F4);

  // Provenance Chips
  static const Color chipOnDeviceFg = Color(0xFF0F6158);
  static const Color chipOnDeviceBg = Color(0xFFE3F4F1);

  static const Color chipInCloudFg = Color(0xFF2B4C8C);
  static const Color chipInCloudBg = Color(0xFFE6EEFB);

  static const Color chipUnknownFg = Color(0xFF4A5263);
  static const Color chipUnknownBg = Color(0xFFEEF0F4);
}
