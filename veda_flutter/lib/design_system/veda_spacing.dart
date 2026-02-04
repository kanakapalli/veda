/// Veda spacing system following the 12px base unit.
///
/// All spacing must be multiples of 12px for Swiss grid alignment.
class VedaSpacing {
  VedaSpacing._();

  // Micro spacing (within components)
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;

  // Component spacing
  static const double base = 16;
  static const double lg = 24;
  static const double xl = 32;

  // Section spacing
  static const double xxl = 48;
  static const double xxxl = 72;
  static const double huge = 96;

  // Page spacing
  static const double massive = 120;
  static const double giant = 144;

  // Grid system
  static const double baselineGrid = 48;
  static const int columnCount = 4;

  // Layout constraints
  static const double maxContentWidth = 440;
  static const double minScreenWidth = 320;
  static const double screenPaddingDesktop = 48;
  static const double screenPaddingMobile = 24;

  // Component heights
  static const double buttonHeight = 56;
  static const double inputHeight = 56;
  static const double minTouchTarget = 56;
}
