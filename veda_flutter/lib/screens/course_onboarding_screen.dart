import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';

import '../design_system/veda_colors.dart';
import 'course_creation_screen.dart';

/// Course Onboarding Screen - Collects initial course details
/// Follows Neo-Minimalist Line Art aesthetic with Swiss grid system
class CourseOnboardingScreen extends StatefulWidget {
  const CourseOnboardingScreen({super.key});

  @override
  State<CourseOnboardingScreen> createState() => _CourseOnboardingScreenState();
}

class _CourseOnboardingScreenState extends State<CourseOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _topicController = TextEditingController();

  String? _selectedImagePath;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _topicController.dispose();
    super.dispose();
  }

  void _pickImage() {
    // Mock image selection - in production, use image_picker package
    setState(() {
      _selectedImagePath = 'assets/course_placeholder.jpg';
    });

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'IMAGE SELECTED',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: VedaColors.black,
            letterSpacing: 1.0,
          ),
        ),
        backgroundColor: VedaColors.white,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
    );
  }

  void _removeImage() {
    setState(() {
      _selectedImagePath = null;
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedImagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'PLEASE SELECT A COURSE IMAGE',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: VedaColors.white,
              letterSpacing: 1.0,
            ),
          ),
          backgroundColor: VedaColors.error,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    // Navigate to course creation screen with the collected data
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const CourseCreationScreen(),
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VedaColors.black,
      body: SafeArea(
        child: CustomPaint(
          painter: _GridPainter(),
          child: Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Padding(
                  padding: const EdgeInsets.all(48.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          'CREATE COURSE',
                          style: GoogleFonts.inter(
                            fontSize: 52,
                            fontWeight: FontWeight.w300,
                            color: VedaColors.white,
                            letterSpacing: -1.2,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Define your course structure',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: VedaColors.zinc500,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 72),

                        // Image Upload Section
                        Text(
                          'COURSE IMAGE',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: VedaColors.zinc500,
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildImageUploadArea(),
                        const SizedBox(height: 48),

                        // Title Field
                        Text(
                          'COURSE TITLE',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: VedaColors.zinc500,
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _MinimalistTextField(
                          controller: _titleController,
                          hintText: 'e.g. Advanced React Patterns',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'TITLE IS REQUIRED';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 48),

                        // Description Field
                        Text(
                          'DESCRIPTION',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: VedaColors.zinc500,
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _MinimalistTextField(
                          controller: _descriptionController,
                          hintText: 'Brief overview of your course content...',
                          maxLines: 4,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'DESCRIPTION IS REQUIRED';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 48),

                        // Topic Field
                        Text(
                          'PRIMARY TOPIC',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: VedaColors.zinc500,
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _MinimalistTextField(
                          controller: _topicController,
                          hintText: 'e.g. Web Development, AI, Design',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'TOPIC IS REQUIRED';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 96),

                        // Submit Button
                        _MinimalistButton(
                          label: _isSubmitting ? 'CREATING...' : 'CONTINUE',
                          onPressed: _isSubmitting ? null : _submitForm,
                          isLoading: _isSubmitting,
                        ),
                        const SizedBox(height: 120),

                        // Footer
                        Text(
                          'All fields are required to proceed',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: VedaColors.zinc700,
                            letterSpacing: 0.2,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageUploadArea() {
    return Container(
      height: 240,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(
          color: _selectedImagePath != null
              ? VedaColors.accent
              : VedaColors.zinc800,
          width: 1,
        ),
      ),
      child: _selectedImagePath != null
          ? Stack(
              children: [
                // Image preview area
                Center(
                  child: Icon(
                    Icons.image_outlined,
                    size: 64,
                    color: VedaColors.zinc700,
                  ),
                ),
                // Remove button
                Positioned(
                  top: 12,
                  right: 12,
                  child: InkWell(
                    onTap: _removeImage,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: VedaColors.black,
                        border: Border.all(color: VedaColors.white, width: 1),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: VedaColors.white,
                      ),
                    ),
                  ),
                ),
                // Selected label
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    color: VedaColors.accent,
                    child: Text(
                      'IMAGE SELECTED',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: VedaColors.white,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : InkWell(
              onTap: _pickImage,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      border: Border.all(color: VedaColors.zinc800, width: 1),
                    ),
                    child: const Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 24,
                      color: VedaColors.zinc700,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'UPLOAD IMAGE',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: VedaColors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'PNG, JPG (MAX 10MB)',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: VedaColors.zinc700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// MINIMALIST COMPONENTS
// ---------------------------------------------------------------------------

class _MinimalistTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? Function(String?)? validator;
  final int maxLines;

  const _MinimalistTextField({
    required this.controller,
    required this.hintText,
    this.validator,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: VedaColors.white,
        letterSpacing: 0.3,
      ),
      decoration: InputDecoration(
        filled: false,
        hintText: hintText,
        hintStyle: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: VedaColors.zinc700,
          letterSpacing: 0.3,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: VedaColors.zinc800, width: 1),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: VedaColors.zinc800, width: 1),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: VedaColors.accent, width: 1),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: VedaColors.error, width: 1),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: VedaColors.error, width: 1),
        ),
        errorStyle: GoogleFonts.jetBrainsMono(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: VedaColors.error,
          letterSpacing: 0.5,
        ),
      ),
      validator: validator,
    );
  }
}

class _MinimalistButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _MinimalistButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  State<_MinimalistButton> createState() => _MinimalistButtonState();
}

class _MinimalistButtonState extends State<_MinimalistButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          height: 56,
          width: double.infinity,
          decoration: BoxDecoration(
            color: _isHovered && !isDisabled
                ? VedaColors.zinc900
                : Colors.transparent,
            border: Border.all(
              color: isDisabled
                  ? VedaColors.zinc900
                  : _isHovered
                      ? VedaColors.white
                      : VedaColors.zinc800,
              width: 1,
            ),
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 1,
                      valueColor: AlwaysStoppedAnimation(VedaColors.accent),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.label,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: isDisabled
                              ? VedaColors.white.withValues(alpha: 0.5)
                              : VedaColors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                      if (!isDisabled) ...[
                        const SizedBox(width: 16),
                        Icon(
                          Icons.arrow_forward,
                          size: 18,
                          color: _isHovered
                              ? VedaColors.white
                              : VedaColors.zinc700,
                        ),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// GRID PAINTER (Swiss Design Grid System)
// ---------------------------------------------------------------------------

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = VedaColors.zinc900
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Vertical columns (4-column grid)
    final columnWidth = size.width / 4;
    for (int i = 1; i < 4; i++) {
      final x = columnWidth * i;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Horizontal baseline (48px grid)
    const baseline = 48.0;
    for (double y = baseline; y < size.height; y += baseline) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
