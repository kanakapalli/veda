import 'package:flutter/material.dart';
import '../veda_colors.dart';
import '../veda_spacing.dart';

/// Input field following Neo-Minimalist design guidelines.
///
/// - 1pt border, no fill
/// - Square corners (no border radius)
/// - 56px height
/// - Grey[800] border, blue accent on focus
class VedaInput extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int? maxLines;

  const VedaInput({
    this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: VedaColors.grey500,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: VedaSpacing.sm),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          maxLines: obscureText ? 1 : maxLines,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: VedaColors.white,
            letterSpacing: 0.3,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: VedaColors.grey500,
              fontSize: 15,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.3,
            ),
            filled: false,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: VedaSpacing.lg,
              vertical: VedaSpacing.base,
            ),
            border: const OutlineInputBorder(
              borderSide: BorderSide(color: VedaColors.grey800, width: 1),
              borderRadius: BorderRadius.zero,
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: VedaColors.grey800, width: 1),
              borderRadius: BorderRadius.zero,
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: VedaColors.accent, width: 1),
              borderRadius: BorderRadius.zero,
            ),
            errorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: VedaColors.error, width: 1),
              borderRadius: BorderRadius.zero,
            ),
            focusedErrorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: VedaColors.error, width: 1),
              borderRadius: BorderRadius.zero,
            ),
          ),
        ),
      ],
    );
  }
}
