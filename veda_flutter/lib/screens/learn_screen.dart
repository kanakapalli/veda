import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:veda_client/veda_client.dart';

import '../design_system/veda_colors.dart';
import '../main.dart';
import 'enrolled_course_screen.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  bool _isLoading = true;
  List<Enrollment> _enrollments = [];
  String? _error;
  // courseId -> progress percent (0.0 – 1.0)
  Map<int, double> _progressMap = {};

  @override
  void initState() {
    super.initState();
    _loadEnrollments();
  }

  Future<void> _loadEnrollments() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final enrollments = await client.lms.getMyEnrollments();

      // Fetch progress for each enrolled course in parallel
      final progressFutures = <Future<MapEntry<int, double>>>[];
      for (final enrollment in enrollments) {
        final courseId = enrollment.courseId;
        progressFutures.add(
          client.lms
              .getCourseProgress(courseId)
              .then((p) => MapEntry(courseId, p))
              .catchError((_) => MapEntry(courseId, 0.0)),
        );
      }
      final progressEntries = await Future.wait(progressFutures);

      setState(() {
        _enrollments = enrollments;
        _progressMap = Map.fromEntries(progressEntries);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadEnrollments,
      color: VedaColors.white,
      backgroundColor: VedaColors.zinc900,
      child: CustomScrollView(
        slivers: [
          const _LearnHeader(),
          SliverToBoxAdapter(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 120),
        child: Center(
          child: CircularProgressIndicator(
            color: VedaColors.white,
            strokeWidth: 1,
          ),
        ),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 120),
        child: Center(
          child: Column(
            children: [
              Text(
                'SYNC_FAILED',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: VedaColors.error,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _error!,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                  color: VedaColors.zinc500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (_enrollments.isEmpty) {
      return _buildEmptyState();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),

          // Most recent enrollment as "current session"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CURRENT_SESSION',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: VedaColors.zinc500,
                  letterSpacing: 3.0,
                ),
              ),
              Text(
                'Last Sync: now',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 9,
                  color: VedaColors.zinc700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // First enrollment as the featured card
          _CurrentCourseCard(
            enrollment: _enrollments.first,
            progress: _progressMap[_enrollments.first.courseId] ?? 0.0,
            onTap: () => _openCourse(_enrollments.first),
          ),

          // Remaining enrollments
          if (_enrollments.length > 1) ...[
            const SizedBox(height: 40),
            Text(
              'ALL_ENROLLED',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: VedaColors.zinc500,
                letterSpacing: 3.0,
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(_enrollments.length - 1, (index) {
              final enrollment = _enrollments[index + 1];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _EnrolledCourseCard(
                  enrollment: enrollment,
                  progress: _progressMap[enrollment.courseId] ?? 0.0,
                  onTap: () => _openCourse(enrollment),
                ),
              );
            }),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 80),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              border: Border.all(color: VedaColors.zinc700, width: 1),
            ),
            child: const Icon(
              Icons.school_outlined,
              color: VedaColors.zinc600,
              size: 36,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'NO_ENROLLMENTS',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: VedaColors.white,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Browse courses and enroll to start learning.',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w300,
              color: VedaColors.zinc500,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _openCourse(Enrollment enrollment) {
    if (enrollment.course == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EnrolledCourseScreen(course: enrollment.course!),
      ),
    ).then((_) => _loadEnrollments()); // Refresh on return
  }
}

// ---------------------------------------------------------------------------
// HEADER
// ---------------------------------------------------------------------------
class _LearnHeader extends StatelessWidget {
  const _LearnHeader();

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      toolbarHeight: 72,
      backgroundColor: VedaColors.black,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: VedaColors.white, width: 2),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'VEDA_OS // MY_LEARNING',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: VedaColors.zinc500,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ENROLLED_COURSES',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: VedaColors.white,
                        letterSpacing: -1.5,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'STATUS:',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 8,
                        color: VedaColors.zinc700,
                        letterSpacing: 1.0,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF22C55E),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'SYNCING',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF22C55E),
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ],
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
// CURRENT COURSE CARD (featured)
// ---------------------------------------------------------------------------
class _CurrentCourseCard extends StatelessWidget {
  final Enrollment enrollment;
  final double progress;
  final VoidCallback onTap;

  const _CurrentCourseCard({
    required this.enrollment,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final course = enrollment.course;
    final title = course?.title.toUpperCase() ?? 'UNTITLED';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: VedaColors.white, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area with gradient overlay
            Container(
              height: 160,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: VedaColors.zinc800,
              ),
              child: Stack(
                children: [
                  // Course image or placeholder
                  Positioned.fill(
                    child: course?.courseImageUrl != null
                        ? Image.network(
                            course!.courseImageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: VedaColors.zinc800,
                              child: const Center(
                                child: Icon(
                                  Icons.auto_stories,
                                  size: 48,
                                  color: VedaColors.zinc700,
                                ),
                              ),
                            ),
                          )
                        : Container(
                            color: VedaColors.zinc800,
                            child: const Center(
                              child: Icon(
                                Icons.auto_stories,
                                size: 48,
                                color: VedaColors.zinc700,
                              ),
                            ),
                          ),
                  ),
                  // Gradient overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            VedaColors.black.withValues(alpha: 0.95),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Content
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF22C55E),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'CONTINUE_LEARNING',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 9,
                                color: VedaColors.zinc500,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: VedaColors.white,
                            letterSpacing: -1.0,
                            height: 0.95,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Progress bar
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 3,
                                color: VedaColors.zinc800,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: FractionallySizedBox(
                                    widthFactor: progress.clamp(0.0, 1.0),
                                    child: Container(color: VedaColors.white),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${(progress * 100).round()}%',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 9,
                                color: VedaColors.zinc500,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Resume button
            Container(
              width: double.infinity,
              height: 52,
              decoration: const BoxDecoration(
                color: VedaColors.white,
                border: Border(
                  top: BorderSide(color: VedaColors.white, width: 2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.play_arrow, size: 18, color: VedaColors.black),
                  const SizedBox(width: 8),
                  Text(
                    'RESUME_SESSION',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: VedaColors.black,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ENROLLED COURSE CARD
// ---------------------------------------------------------------------------
class _EnrolledCourseCard extends StatelessWidget {
  final Enrollment enrollment;
  final double progress;
  final VoidCallback onTap;

  const _EnrolledCourseCard({
    required this.enrollment,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final course = enrollment.course;
    final title = course?.title.toUpperCase() ?? 'UNTITLED';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: VedaColors.zinc700, width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: VedaColors.zinc800,
                border: Border.all(color: VedaColors.zinc700, width: 1),
              ),
              child: course?.courseImageUrl != null
                  ? ClipRect(
                      child: Image.network(
                        course!.courseImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.play_circle_outline,
                          color: VedaColors.zinc500,
                          size: 24,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.play_circle_outline,
                      color: VedaColors.zinc500,
                      size: 24,
                    ),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: VedaColors.white,
                      letterSpacing: -0.3,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ENROLLED: ${_formatDate(enrollment.enrolledAt)}',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 9,
                      color: VedaColors.zinc500,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Progress bar
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 3,
                          color: VedaColors.zinc800,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: progress.clamp(0.0, 1.0),
                              child: Container(color: VedaColors.white),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(progress * 100).round()}%',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 9,
                          color: VedaColors.zinc500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Arrow button
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                border: Border.all(color: VedaColors.zinc700, width: 1),
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: VedaColors.white,
                size: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
}