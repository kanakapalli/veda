import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Stark design system colors
class StarkColors {
  static const black = Color(0xFF000000);
  static const white = Color(0xFFFFFFFF);
  static const gray = Color(0xFF1A1A1A);
  static const zinc500 = Color(0xFF71717A);
  static const zinc600 = Color(0xFF52525B);
  static const zinc700 = Color(0xFF3F3F46);
  static const zinc800 = Color(0xFF27272A);
  static const zinc900 = Color(0xFF18181B);
  static const error = Color(0xFFEF5350);
}

/// Primary button - white bg, black text, inverts on hover
class StarkPrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool showArrow;

  const StarkPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.showArrow = true,
  });

  @override
  State<StarkPrimaryButton> createState() => _StarkPrimaryButtonState();
}

class _StarkPrimaryButtonState extends State<StarkPrimaryButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;
    final showInverted = _isHovered && !isDisabled;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: isDisabled ? null : widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: showInverted ? StarkColors.black : StarkColors.white,
            border: Border.all(color: StarkColors.white, width: 2),
          ),
          child: widget.isLoading
              ? const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: StarkColors.black,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.label.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: showInverted ? StarkColors.white : StarkColors.black,
                        letterSpacing: 3.0,
                      ),
                    ),
                    if (widget.showArrow) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward,
                        size: 14,
                        color: showInverted ? StarkColors.white : StarkColors.black,
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}

/// Secondary button - transparent bg, white border, fills on hover
class StarkSecondaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const StarkSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  State<StarkSecondaryButton> createState() => _StarkSecondaryButtonState();
}

class _StarkSecondaryButtonState extends State<StarkSecondaryButton> {
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
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: _isHovered && !isDisabled ? StarkColors.zinc900 : StarkColors.black,
            border: Border.all(color: StarkColors.white, width: 2),
          ),
          child: widget.isLoading
              ? const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: StarkColors.white,
                    ),
                  ),
                )
              : Center(
                  child: Text(
                    widget.label.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: StarkColors.white,
                      letterSpacing: 3.0,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

/// Text field with stark styling
class StarkTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String placeholder;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? errorText;
  final Widget? suffixIcon;

  const StarkTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.placeholder,
    this.keyboardType,
    this.obscureText = false,
    this.errorText,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 8),
          child: Text(
            label.toUpperCase(),
            style: GoogleFonts.jetBrainsMono(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: StarkColors.zinc500,
              letterSpacing: 2.0,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: errorText != null ? StarkColors.error : StarkColors.white,
              width: 2,
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: StarkColors.white,
              letterSpacing: 0.5,
            ),
            decoration: InputDecoration(
              hintText: placeholder.toUpperCase(),
              hintStyle: GoogleFonts.jetBrainsMono(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: StarkColors.zinc800,
                letterSpacing: 0.5,
              ),
              contentPadding: const EdgeInsets.all(16),
              border: InputBorder.none,
              suffixIcon: suffixIcon,
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 2, top: 4),
            child: Text(
              errorText!,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 9,
                color: StarkColors.error,
                letterSpacing: 1.0,
              ),
            ),
          ),
      ],
    );
  }
}

/// Interest tag chip
class StarkInterestTag extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const StarkInterestTag({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<StarkInterestTag> createState() => _StarkInterestTagState();
}

class _StarkInterestTagState extends State<StarkInterestTag> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? StarkColors.white
                : (_isHovered ? StarkColors.zinc900 : StarkColors.black),
            border: Border.all(color: StarkColors.white, width: 1),
          ),
          child: Text(
            widget.label.toUpperCase(),
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: widget.isSelected ? StarkColors.black : StarkColors.white,
              letterSpacing: 2.0,
            ),
          ),
        ),
      ),
    );
  }
}

/// Goal selection card
class StarkGoalCard extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const StarkGoalCard({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<StarkGoalCard> createState() => _StarkGoalCardState();
}

class _StarkGoalCardState extends State<StarkGoalCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? StarkColors.white
                : (_isHovered ? StarkColors.zinc900 : StarkColors.black),
            border: Border.all(color: StarkColors.white, width: 1),
          ),
          child: Center(
            child: Text(
              widget.label.toUpperCase(),
              textAlign: TextAlign.center,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: widget.isSelected ? StarkColors.black : StarkColors.white,
                letterSpacing: 1.5,
                height: 1.4,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Top-left branding widget
class StarkBranding extends StatelessWidget {
  final String label;

  const StarkBranding({super.key, this.label = 'VEDA SYSTEM // V.1'});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          color: StarkColors.white,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: StarkColors.zinc500,
            letterSpacing: 2.0,
          ),
        ),
      ],
    );
  }
}

/// Bottom footer with dots and encrypted text
class StarkFooter extends StatelessWidget {
  const StarkFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: List.generate(
            3,
            (i) => Container(
              width: 2,
              height: 2,
              margin: const EdgeInsets.only(right: 8),
              color: StarkColors.zinc700,
            ),
          ),
        ),
        Text(
          'ENCRYPTED CONNECTION',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 8,
            fontWeight: FontWeight.w400,
            color: StarkColors.zinc800,
            letterSpacing: 2.0,
          ),
        ),
      ],
    );
  }
}

/// Right side rotated badge
class StarkBadge extends StatelessWidget {
  final String label;

  const StarkBadge({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 1.5708, // 90 degrees
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        color: StarkColors.white,
        child: Text(
          label,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 8,
            fontWeight: FontWeight.w700,
            color: StarkColors.black,
            letterSpacing: 3.0,
          ),
        ),
      ),
    );
  }
}

/// Link text with underline
class StarkLink extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const StarkLink({super.key, required this.label, required this.onTap});

  @override
  State<StarkLink> createState() => _StarkLinkState();
}

class _StarkLinkState extends State<StarkLink> {

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.only(bottom: 2),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color:  StarkColors.white ,
                width: 1,
              ),
            ),
          ),
          child: Text(
            widget.label.toUpperCase(),
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: StarkColors.white ,
              letterSpacing: 3.0,
            ),
          ),
        ),
      );
  }
}
