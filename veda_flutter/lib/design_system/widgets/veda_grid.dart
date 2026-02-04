import 'package:flutter/material.dart';
import '../veda_colors.dart';
import '../veda_spacing.dart';

/// Swiss grid system painter with 4 vertical columns and 48px baseline.
///
/// - 0.5pt stroke width
/// - Grey[900] color
/// - Decorative only (non-interactive)
class VedaGridPainter extends CustomPainter {
  final bool showVertical;
  final bool showHorizontal;

  const VedaGridPainter({
    this.showVertical = true,
    this.showHorizontal = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = VedaColors.grey900
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Vertical grid lines (4 columns)
    if (showVertical) {
      final columnWidth = size.width / VedaSpacing.columnCount;
      for (int i = 1; i < VedaSpacing.columnCount; i++) {
        canvas.drawLine(
          Offset(columnWidth * i, 0),
          Offset(columnWidth * i, size.height),
          paint,
        );
      }
    }

    // Horizontal baseline grid (48px)
    if (showHorizontal) {
      for (double y = VedaSpacing.baselineGrid;
          y < size.height;
          y += VedaSpacing.baselineGrid) {
        canvas.drawLine(
          Offset(0, y),
          Offset(size.width, y),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Wrapper widget that adds the Veda grid as background.
class VedaGridBackground extends StatelessWidget {
  final Widget child;
  final bool showGrid;
  final bool showVertical;
  final bool showHorizontal;

  const VedaGridBackground({
    required this.child,
    this.showGrid = true,
    this.showVertical = true,
    this.showHorizontal = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (!showGrid) return child;

    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: VedaGridPainter(
              showVertical: showVertical,
              showHorizontal: showHorizontal,
            ),
          ),
        ),
        child,
      ],
    );
  }
}
