import 'package:flutter/material.dart';

/// Veda color palette following Stark Minimalist design guidelines.
///
/// High-contrast monochrome palette with minimal accent use.
class VedaColors {
  VedaColors._();

  // Core colors
  static const black = Color(0xFF000000);
  static const white = Color(0xFFFFFFFF);

  // Stark gray (for subtle backgrounds)
  static const starkGray = Color(0xFF1A1A1A);

  // Grey scale (zinc tones)
  static const zinc500 = Color(0xFF71717A);
  static const zinc600 = Color(0xFF52525B);
  static const zinc700 = Color(0xFF3F3F46);
  static const zinc800 = Color(0xFF27272A);
  static const zinc900 = Color(0xFF18181B);

  // Legacy grey aliases for backwards compatibility
  static const grey500 = zinc500;
  static const grey700 = zinc700;
  static const grey800 = zinc800;
  static const grey900 = zinc900;

  // Accent (used sparingly)
  static const accent = Color(0xFF4A90E2);

  // Error
  static const error = Color(0xFFEF5350);
}
