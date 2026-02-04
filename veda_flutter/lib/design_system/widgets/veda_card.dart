import 'package:flutter/material.dart';
import '../veda_colors.dart';
import '../veda_spacing.dart';

/// Minimalist card with 1pt border, no fill.
///
/// - Transparent background
/// - Grey[800] border
/// - Square corners
/// - Hover: white border, grey[900] background
class VedaCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  const VedaCard({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(VedaSpacing.lg),
    super.key,
  });

  @override
  State<VedaCard> createState() => _VedaCardState();
}

class _VedaCardState extends State<VedaCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: widget.padding,
          decoration: BoxDecoration(
            color: _isHovered ? VedaColors.grey900 : Colors.transparent,
            border: Border.all(
              color: _isHovered ? VedaColors.white : VedaColors.grey800,
              width: 1,
            ),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Divider with 1pt grey line.
class VedaDivider extends StatelessWidget {
  final Color? color;

  const VedaDivider({
    this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 1,
      color: color ?? VedaColors.grey900,
    );
  }
}
