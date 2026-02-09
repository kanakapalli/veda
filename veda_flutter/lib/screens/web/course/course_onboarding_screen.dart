import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:veda_client/veda_client.dart';

import '../../../design_system/veda_colors.dart';
import '../../../main.dart';
import '../../../services/upload_service.dart';
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

  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  bool _isSubmitting = false;
  bool _isLoadingCourses = true;
  List<Course> _courses = [];

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    try {
      final courses = await client.lms.listMyCourses();
      if (mounted) {
        setState(() {
          _courses = courses;
          _isLoadingCourses = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingCourses = false);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.bytes == null) return;

    setState(() {
      _selectedImageBytes = file.bytes;
      _selectedImageName = file.name;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'IMAGE SELECTED: ${file.name}',
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
      _selectedImageBytes = null;
      _selectedImageName = null;
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      print('🚀 [Onboarding] Creating course...');

      // Create the course via API with draft visibility
      // Note: creatorId uses a placeholder - server will set the actual value from authenticated user
      final course = Course(
        creatorId: UuidValue.fromString('00000000-0000-0000-0000-000000000000'), // Placeholder - server will override
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        visibility: CourseVisibility.draft,
        systemPrompt: 'Topic: ${_topicController.text.trim()}',
      );

      var createdCourse = await client.lms.createCourse(course);
      print('✅ [Onboarding] Course created with ID: ${createdCourse.id}');

      // Upload image if one was picked (needs courseId from creation)
      if (_selectedImageBytes != null && _selectedImageName != null) {
        print('📤 [Onboarding] Uploading course image: $_selectedImageName');
        print('📤 [Onboarding] Image size: ${_selectedImageBytes!.length} bytes');

        final uploadResult = await UploadService.instance.uploadCourseImageBytes(
          createdCourse.id!,
          _selectedImageBytes!,
          _selectedImageName!,
        );

        print('📤 [Onboarding] Upload result - success: ${uploadResult.success}');
        print('📤 [Onboarding] Upload result - URL: ${uploadResult.publicUrl}');
        print('📤 [Onboarding] Upload result - error: ${uploadResult.error}');

        if (uploadResult.success && uploadResult.publicUrl != null) {
          createdCourse = createdCourse.copyWith(
            courseImageUrl: uploadResult.publicUrl,
          );
          print('📤 [Onboarding] Updating course with image URL...');
          await client.lms.updateCourse(createdCourse);
          print('✅ [Onboarding] Course updated with image URL: ${createdCourse.courseImageUrl}');
        } else {
          print('⚠️ [Onboarding] Image upload failed, continuing without image');
        }
      } else {
        print('ℹ️ [Onboarding] No image selected, skipping upload');
      }

      if (!mounted) return;

      print('🎯 [Onboarding] Navigating to CourseCreationScreen with course:');
      print('🎯 [Onboarding]   - ID: ${createdCourse.id}');
      print('🎯 [Onboarding]   - Title: ${createdCourse.title}');
      print('🎯 [Onboarding]   - courseImageUrl: ${createdCourse.courseImageUrl}');

      // Navigate to course creation screen with the created course
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              CourseCreationScreen(course: createdCourse),
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
    } catch (e) {
      if (!mounted) return;

      setState(() => _isSubmitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'FAILED TO CREATE COURSE: ${e.toString()}',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: VedaColors.white,
              letterSpacing: 1.0,
            ),
          ),
          backgroundColor: VedaColors.error,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
      );
    }
  }

  void _navigateToCourse(Course course) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            CourseCreationScreen(course: course),
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

  String _getVisibilityLabel(CourseVisibility visibility) {
    switch (visibility) {
      case CourseVisibility.draft:
        return 'DRAFT';
      case CourseVisibility.public:
        return 'PUBLIC';
      case CourseVisibility.private:
        return 'PRIVATE';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final showCoursesPanel = screenWidth >= 900;

    if (!showCoursesPanel) {
      // Mobile: show only the form
      return _buildFormScaffold();
    }

    // Desktop: two-panel layout
    return Scaffold(
      backgroundColor: VedaColors.black,
      body: SafeArea(
        child: Row(
          children: [
            // Left panel: Form
            Expanded(
              flex: 3,
              child: _buildFormPanel(),
            ),
            // Divider
            Container(width: 1, color: VedaColors.zinc800),
            // Right panel: Courses list
            Expanded(
              flex: 2,
              child: _buildCoursesPanel(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormScaffold() {
    return Scaffold(
      backgroundColor: VedaColors.black,
      body: SafeArea(
        child: CustomPaint(
          painter: _GridPainter(),
          child: _buildFormPanel(),
        ),
      ),
    );
  }

  Widget _buildFormPanel() {
    return Center(
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
    );
  }

  Widget _buildCoursesPanel() {
    return Container(
      color: VedaColors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: VedaColors.zinc800, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'YOUR COURSES',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: VedaColors.zinc500,
                    letterSpacing: 2.0,
                  ),
                ),
                Text(
                  '${_courses.length}',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: VedaColors.zinc700,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
          // Courses list
          Expanded(
            child: _isLoadingCourses
                ? const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 1,
                        valueColor: AlwaysStoppedAnimation(VedaColors.accent),
                      ),
                    ),
                  )
                : _courses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.school_outlined,
                          size: 48,
                          color: VedaColors.zinc800,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'NO COURSES YET',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: VedaColors.zinc700,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create your first course',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: VedaColors.zinc700,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _courses.length,
                    itemBuilder: (context, index) {
                      final course = _courses[index];
                      return _CourseCard(
                        course: course,
                        statusLabel: _getVisibilityLabel(course.visibility),
                        onTap: () => _navigateToCourse(course),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageUploadArea() {
    final hasImage = _selectedImageBytes != null;
    return Container(
      height: 240,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(
          color: hasImage ? VedaColors.accent : VedaColors.zinc800,
          width: 1,
        ),
      ),
      child: hasImage
          ? Stack(
              children: [
                // Image preview
                Positioned.fill(
                  child: Image.memory(
                    _selectedImageBytes!,
                    fit: BoxFit.cover,
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    color: VedaColors.accent,
                    child: Text(
                      _selectedImageName ?? 'IMAGE SELECTED',
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
                    'JPG, PNG, WEBP (MAX 10MB)',
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
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
// COURSE CARD
// ---------------------------------------------------------------------------

class _CourseCard extends StatefulWidget {
  final Course course;
  final String statusLabel;
  final VoidCallback onTap;

  const _CourseCard({
    required this.course,
    required this.statusLabel,
    required this.onTap,
  });

  @override
  State<_CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<_CourseCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: _isHovered ? VedaColors.zinc900 : Colors.transparent,
              border: Border.all(
                color: _isHovered ? VedaColors.zinc700 : VedaColors.zinc800,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Course image
                if (widget.course.courseImageUrl != null &&
                    widget.course.courseImageUrl!.isNotEmpty)
                  SizedBox(
                    height: 120,
                    width: double.infinity,
                    child: Image.network(
                      widget.course.courseImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 120,
                        color: VedaColors.zinc900,
                        child: const Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            size: 24,
                            color: VedaColors.zinc800,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    height: 72,
                    width: double.infinity,
                    color: VedaColors.zinc900,
                    child: const Center(
                      child: Icon(
                        Icons.school_outlined,
                        size: 24,
                        color: VedaColors.zinc800,
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: widget.statusLabel == 'DRAFT'
                                ? VedaColors.zinc700
                                : widget.statusLabel == 'PUBLIC'
                                ? VedaColors.accent
                                : VedaColors.zinc700,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          widget.statusLabel,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 9,
                            fontWeight: FontWeight.w400,
                            color: widget.statusLabel == 'DRAFT'
                                ? VedaColors.zinc500
                                : widget.statusLabel == 'PUBLIC'
                                ? VedaColors.accent
                                : VedaColors.zinc500,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Course title
                      Text(
                        widget.course.title,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: VedaColors.white,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.course.description != null &&
                          widget.course.description!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          widget.course.description!,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: VedaColors.zinc600,
                            letterSpacing: 0.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 12),
                      // Arrow indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            Icons.arrow_forward,
                            size: 16,
                            color: _isHovered
                                ? VedaColors.white
                                : VedaColors.zinc700,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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
