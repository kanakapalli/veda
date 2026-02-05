import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../design_system/veda_colors.dart';

class TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const TabButton({
    super.key,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? VedaColors.white : VedaColors.zinc800,
                width: 1,
              ),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: isActive ? VedaColors.white : VedaColors.zinc700,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
