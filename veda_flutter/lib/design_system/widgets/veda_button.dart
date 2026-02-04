import 'package:flutter/material.dart';
import '../veda_colors.dart';
import '../veda_spacing.dart';
import '../veda_text_styles.dart';

/// Primary action button following Neo-Minimalist design guidelines.
///
/// - 56px fixed height
/// - 1pt border, transparent background
/// - Hover: white border, grey[900] background
/// - No border radius (square corners)
class VedaButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final VedaButtonStyle style;

  const VedaButton({
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.style = VedaButtonStyle.primary,
    super.key,
  });

  @override
  State<VedaButton> createState() => _VedaButtonState();
}

class _VedaButtonState extends State<VedaButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: isDisabled ? null : widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          height: VedaSpacing.buttonHeight,
          padding: const EdgeInsets.symmetric(
            horizontal: VedaSpacing.lg,
          ),
          decoration: BoxDecoration(
            color: _getBackgroundColor(isDisabled),
            border: Border.all(
              color: _getBorderColor(isDisabled),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 1,
                    valueColor: AlwaysStoppedAnimation(VedaColors.accent),
                  ),
                )
              else ...[
                if (widget.icon != null) ...[
                  Icon(
                    widget.icon,
                    size: 18,
                    color: _getTextColor(isDisabled),
                  ),
                  const SizedBox(width: VedaSpacing.base),
                ],
                Text(
                  widget.label,
                  style: VedaTextStyles.button.copyWith(
                    color: _getTextColor(isDisabled),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor(bool isDisabled) {
    if (isDisabled) return Colors.transparent;
    if (_isHovered) return VedaColors.grey900;
    return Colors.transparent;
  }

  Color _getBorderColor(bool isDisabled) {
    if (isDisabled) return VedaColors.grey900;
    if (_isHovered) return VedaColors.white;
    return VedaColors.grey800;
  }

  Color _getTextColor(bool isDisabled) {
    if (isDisabled) return VedaColors.white.withAlpha(128);
    return VedaColors.white;
  }
}

/// Text button with blue accent color.
class VedaTextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const VedaTextButton({
    required this.label,
    this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: VedaSpacing.md),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: VedaColors.accent,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}

enum VedaButtonStyle {
  primary,
  secondary,
  text,
}
