import 'package:flutter/material.dart';
import 'veda_colors.dart';

/// Veda typography system following Stark Minimalist design guidelines.
///
/// Uses monospace fonts (JetBrains Mono style) with uppercase text.
/// Bold/black weights for titles, regular for labels.
class VedaTextStyles {
  VedaTextStyles._();

  // Font families
  static const String monoFamily = 'JetBrains Mono';
  static const String sansFamily = 'Inter';

  // Display (Large Titles) - Ultra bold, tight tracking
  static const displayLarge = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w900,
    color: VedaColors.white,
    letterSpacing: -2.0,
    height: 0.9,
  );

  // Headings - Bold uppercase
  static const headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w900,
    color: VedaColors.white,
    letterSpacing: -1.5,
    height: 0.95,
  );

  static const headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w900,
    color: VedaColors.white,
    letterSpacing: -1.0,
    height: 1.0,
  );

  static const headlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: VedaColors.white,
    letterSpacing: 0.2,
  );

  // System labels (monospace, uppercase, small)
  static TextStyle get systemLabel => const TextStyle(
        fontFamily: monoFamily,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: VedaColors.zinc500,
        letterSpacing: 2.5,
      );

  static TextStyle get systemLabelSmall => const TextStyle(
        fontFamily: monoFamily,
        fontSize: 8,
        fontWeight: FontWeight.w400,
        color: VedaColors.zinc800,
        letterSpacing: 3.0,
      );

  // Input text (monospace)
  static TextStyle get inputText => const TextStyle(
        fontFamily: monoFamily,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: VedaColors.white,
        letterSpacing: 0.5,
      );

  static TextStyle get inputPlaceholder => const TextStyle(
        fontFamily: monoFamily,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: VedaColors.zinc800,
        letterSpacing: 0.5,
      );

  // Buttons (uppercase, tracked)
  static const buttonPrimary = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w900,
    color: VedaColors.black,
    letterSpacing: 3.0,
  );

  static const buttonSecondary = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: VedaColors.white,
    letterSpacing: 3.0,
  );

  // Body text
  static const bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: VedaColors.zinc500,
    letterSpacing: 0.5,
  );

  static const bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: VedaColors.white,
    letterSpacing: 0.3,
  );

  // Small / Legal text
  static const bodySmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: VedaColors.zinc700,
    letterSpacing: 0.2,
    height: 1.6,
  );

  // Legacy aliases
  static const labelLarge = buttonSecondary;
  static const labelMedium = bodySmall;
  static const button = buttonPrimary;

  // Tags/chips (for onboarding)
  static TextStyle get tagText => const TextStyle(
        fontFamily: monoFamily,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: VedaColors.white,
        letterSpacing: 2.0,
      );

  static TextStyle get tagTextSelected => const TextStyle(
        fontFamily: monoFamily,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: VedaColors.black,
        letterSpacing: 2.0,
      );
}
