import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:veda_client/veda_client.dart';

import '../design_system/veda_colors.dart';
import '../main.dart';
import 'coach_screen.dart';
import 'coaches_list_screen.dart';
import 'course_detail_screen.dart';
import 'enrolled_course_screen.dart';
import 'search_screen.dart';

// ---------------------------------------------------------------------------
// Callback type for navigating to search with a pre-filled query + tab
// ---------------------------------------------------------------------------
typedef SearchWithQueryCallback = void Function(String query,
    {SearchFilter? filter});

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onSearchTap;
  final SearchWithQueryCallback? onSearchWithQuery;

  const DashboardScreen({super.key, this.onSearchTap, this.onSearchWithQuery});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  String? _error;

  // Real data
  List<Enrollment> _enrollments = [];
  Map<int, double> _progressMap = {};
  List<VedaUserProfile> _coaches = [];
  List<Course> _discoverCourses = [];

  // Creator name cache for course cards
  final Map<String, String> _creatorNameCache = {};

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Fetch in parallel: enrollments, coaches, public courses
      final results = await Future.wait([
        client.lms.getMyEnrollments(),
        client.vedaUserProfile.listCreators(),
        client.lms.listCourses(visibility: CourseVisibility.public),
      ]);

      final enrollments = results[0] as List<Enrollment>;
      final coaches = results[1] as List<VedaUserProfile>;
      final courses = results[2] as List<Course>;

      // Fetch progress for each enrolled course in parallel
      final progressFutures = <Future<MapEntry<int, double>>>[];
      for (final enrollment in enrollments) {
        progressFutures.add(
          client.lms
              .getCourseProgress(enrollment.courseId)
              .then((p) => MapEntry(enrollment.courseId, p))
              .catchError((_) => MapEntry(enrollment.courseId, 0.0)),
        );
      }
      final progressEntries = await Future.wait(progressFutures);

      // Resolve creator names for public courses
      final creatorIds = courses
          .map((c) => c.creatorId.toString())
          .where((id) => !_creatorNameCache.containsKey(id))
          .toSet();
      if (creatorIds.isNotEmpty) {
        await Future.wait(creatorIds.map((id) async {
          try {
            final profile = await client.vedaUserProfile
                .getUserProfileById(UuidValue.fromString(id));
            if (profile?.profile?.fullName != null) {
              _creatorNameCache[id] = profile!.profile!.fullName!;
            }
          } catch (_) {}
        }));
      }

      // Filter out enrolled course IDs from discover list
      final enrolledCourseIds = enrollments.map((e) => e.courseId).toSet();
      final discover = courses
          .where((c) => c.id != null && !enrolledCourseIds.contains(c.id))
          .toList();

      if (mounted) {
        setState(() {
          _enrollments = enrollments;
          _progressMap = Map.fromEntries(progressEntries);
          _coaches = coaches;
          _discoverCourses = discover;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  // ── Navigation helpers ────────────────────────────────────────────────────

  void _openEnrolledCourse(Enrollment enrollment) {
    if (enrollment.course == null) return;
    Navigator.of(context)
        .push(MaterialPageRoute(
          builder: (_) => EnrolledCourseScreen(course: enrollment.course!),
        ))
        .then((_) => _loadDashboardData());
  }

  void _openCourseDetail(Course course) {
    Navigator.of(context)
        .push(MaterialPageRoute(
          builder: (_) => CourseDetailScreen(course: course),
        ))
        .then((_) => _loadDashboardData());
  }

  void _openCoach(VedaUserProfile coach) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CoachScreen(coach: coach)),
    );
  }

  void _goToSearchWithQuery(String query, {SearchFilter? filter}) {
    widget.onSearchWithQuery?.call(query, filter: filter);
  }

  void _openCoachesList() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CoachesListScreen()),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      color: VedaColors.white,
      backgroundColor: VedaColors.zinc900,
      child: CustomScrollView(
        slivers: [
          _DashboardHeader(onSearchTap: widget.onSearchTap),
          SliverToBoxAdapter(child: _buildBody()),
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
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: VedaColors.error,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _loadDashboardData,
                child: Text(
                  'TAP TO RETRY',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    color: VedaColors.zinc500,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),

          // ── Banner 1: Explore AI Courses ──────────────────────────────────
          _PromoBanner(
            title: 'EXPLORE AI COURSES',
            subtitle: 'DISCOVER NEW LEARNING PATHS',
            icon: Icons.smart_toy_outlined,
            onTap: () =>
                _goToSearchWithQuery('AI', filter: SearchFilter.courses),
          ),
          const SizedBox(height: 24),

          // ── Continue Learning (enrolled courses) ──────────────────────────
          if (_enrollments.isNotEmpty) ...[
            _buildSectionHeader('CONTINUE LEARNING'),
            const SizedBox(height: 16),
            _ContinueLearningCard(
              enrollment: _enrollments.first,
              progress: _progressMap[_enrollments.first.courseId] ?? 0.0,
              onTap: () => _openEnrolledCourse(_enrollments.first),
            ),
            if (_enrollments.length > 1) ...[
              const SizedBox(height: 16),
              ..._enrollments.skip(1).take(3).map(
                    (enrollment) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _EnrolledCourseRow(
                        enrollment: enrollment,
                        progress: _progressMap[enrollment.courseId] ?? 0.0,
                        onTap: () => _openEnrolledCourse(enrollment),
                      ),
                    ),
                  ),
            ],
            const SizedBox(height: 40),
          ],

          // ── Banner 2: Explore Coach ───────────────────────────────────────
          _PromoBanner(
            title: 'EXPLORE COACH',
            subtitle: 'CONNECT WITH EXPERT COACHES',
            icon: Icons.person_search_outlined,
            isInverted: true,
            onTap: () => _openCoachesList(),
          ),
          const SizedBox(height: 40),

          // ── Explore by Topic ──────────────────────────────────────────────
          _buildSectionHeader('EXPLORE BY TOPIC'),
          const SizedBox(height: 16),
          _TopicGrid(onTopicTap: (query) {
            _goToSearchWithQuery(query, filter: SearchFilter.topics);
          }),
          const SizedBox(height: 40),

          // ── Popular Coaches ───────────────────────────────────────────────
          if (_coaches.isNotEmpty) ...[
            _buildSectionHeader('POPULAR COACHES'),
            const SizedBox(height: 16),
            _CoachesList(
              coaches: _coaches,
              onCoachTap: _openCoach,
            ),
            const SizedBox(height: 40),
          ],

          // ── Discover Courses (new arrivals) ───────────────────────────────
          if (_discoverCourses.isNotEmpty) ...[
            _buildSectionHeader('DISCOVER COURSES'),
            const SizedBox(height: 16),
            ..._discoverCourses.take(5).map(
                  (course) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _DiscoverCourseCard(
                      course: course,
                      creatorName:
                          _creatorNameCache[course.creatorId.toString()],
                      onTap: () => _openCourseDetail(course),
                    ),
                  ),
                ),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Shared helpers ────────────────────────────────────────────────────────

  static Widget _buildSectionHeader(String title, {Widget? trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: VedaColors.zinc500,
            letterSpacing: 3.0,
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

}

// ---------------------------------------------------------------------------
// HEADER (pinned)
// ---------------------------------------------------------------------------
class _DashboardHeader extends StatelessWidget {
  final VoidCallback? onSearchTap;

  const _DashboardHeader({this.onSearchTap});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 140,
      backgroundColor: VedaColors.black,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            color: VedaColors.black,
            border: Border(
              bottom: BorderSide(color: VedaColors.white, width: 2),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: branding + notification
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'VEDA_DASHBOARD',
                            style: GoogleFonts.inter(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: VedaColors.white,
                              letterSpacing: -1.5,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border.all(color: VedaColors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.notifications_outlined,
                          color: VedaColors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Search bar
                  GestureDetector(
                    onTap: onSearchTap,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        border: Border.all(color: VedaColors.white, width: 2),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'SEARCH DATABASE...',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: VedaColors.zinc700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                    color: VedaColors.white, width: 2),
                              ),
                            ),
                            child: const Icon(
                              Icons.search,
                              color: VedaColors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      toolbarHeight: 140,
      automaticallyImplyLeading: false,
    );
  }
}

// ---------------------------------------------------------------------------
// PROMO BANNER
// ---------------------------------------------------------------------------
class _PromoBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isInverted;
  final VoidCallback onTap;

  const _PromoBanner({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isInverted = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isInverted ? VedaColors.white : VedaColors.black;
    final fg = isInverted ? VedaColors.black : VedaColors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: VedaColors.white, width: 2),
        ),
        child: Row(
          children: [
            Icon(icon, size: 36, color: fg),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: fg,
                      letterSpacing: -0.5,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 9,
                      color: fg.withValues(alpha: 0.6),
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward, size: 20, color: fg),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// CONTINUE LEARNING CARD (featured enrolled course)
// ---------------------------------------------------------------------------
class _ContinueLearningCard extends StatelessWidget {
  final Enrollment enrollment;
  final double progress;
  final VoidCallback onTap;

  const _ContinueLearningCard({
    required this.enrollment,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final course = enrollment.course;
    final title = course?.title.toUpperCase() ?? 'UNTITLED';
    final pct = (progress * 100).round();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: VedaColors.white, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area with overlay
            Container(
              height: 180,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: VedaColors.zinc800,
                border: Border(
                  bottom: BorderSide(color: VedaColors.white, width: 2),
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: course?.courseImageUrl != null
                        ? Image.network(
                            course!.courseImageUrl!,
                            fit: BoxFit.cover,
                            color: Colors.white.withValues(alpha: 0.8),
                            colorBlendMode: BlendMode.saturation,
                            errorBuilder: (_, __, ___) => _imagePlaceholder(),
                          )
                        : _imagePlaceholder(),
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
                            VedaColors.black.withValues(alpha: 0.9),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Label + title
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
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
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: VedaColors.white,
                            letterSpacing: -0.5,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Progress area
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'PROGRESS: $pct%',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          color: VedaColors.zinc500,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Text(
                        '${course?.modules?.length ?? '—'} MODULES',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          color: VedaColors.zinc500,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Progress bar
                  Container(
                    height: 12,
                    decoration: BoxDecoration(
                      border: Border.all(color: VedaColors.white, width: 2),
                    ),
                    padding: const EdgeInsets.all(2),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: progress.clamp(0.0, 1.0),
                        child: Container(color: VedaColors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Resume button
                  Container(
                    width: double.infinity,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: VedaColors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.play_arrow,
                            size: 18, color: VedaColors.black),
                        const SizedBox(width: 8),
                        Text(
                          'RESUME SESSION',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
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
          ],
        ),
      ),
    );
  }

  static Widget _imagePlaceholder() {
    return Container(
      color: VedaColors.zinc800,
      child: const Center(
        child: Icon(Icons.auto_stories, size: 64, color: VedaColors.zinc700),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ENROLLED COURSE ROW (compact, for additional enrolled courses)
// ---------------------------------------------------------------------------
class _EnrolledCourseRow extends StatelessWidget {
  final Enrollment enrollment;
  final double progress;
  final VoidCallback onTap;

  const _EnrolledCourseRow({
    required this.enrollment,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final course = enrollment.course;
    final title = course?.title.toUpperCase() ?? 'UNTITLED';
    final pct = (progress * 100).round();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          border: Border.all(color: VedaColors.zinc700, width: 1),
        ),
        child: Row(
          children: [
            // Thumbnail
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: VedaColors.zinc800,
                border: Border(
                  right: BorderSide(color: VedaColors.zinc700, width: 1),
                ),
              ),
              child: course?.courseImageUrl != null
                  ? Image.network(
                      course!.courseImageUrl!,
                      fit: BoxFit.cover,
                      color: Colors.white.withValues(alpha: 0.8),
                      colorBlendMode: BlendMode.saturation,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.play_circle_outline,
                        color: VedaColors.zinc500,
                        size: 24,
                      ),
                    )
                  : const Icon(
                      Icons.play_circle_outline,
                      color: VedaColors.zinc500,
                      size: 24,
                    ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: VedaColors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
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
                          '$pct%',
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
            ),
            // Arrow
            Container(
              width: 40,
              height: 72,
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(color: VedaColors.zinc700, width: 1),
                ),
              ),
              child: const Icon(
                Icons.arrow_forward,
                size: 16,
                color: VedaColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// EXPLORE BY TOPIC
// ---------------------------------------------------------------------------
class _TopicGrid extends StatelessWidget {
  final void Function(String query) onTopicTap;

  const _TopicGrid({required this.onTopicTap});

  static const _topics = [
    _TopicData(
        Icons.psychology_outlined, 'PSYCH', 'Human Behavior', 'Psychology'),
    _TopicData(
        Icons.architecture, 'ARCH', 'System Design', 'System Design'),
    _TopicData(Icons.smart_toy_outlined, 'AI STRAT', 'Future Logic',
        'Artificial Intelligence'),
    _TopicData(Icons.terminal, 'CODE', 'Implementation', 'Programming'),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: _topics.map((topic) {
        final isInverted = topic.title == 'ARCH';
        return _TopicCard(
          icon: topic.icon,
          title: topic.title,
          subtitle: topic.subtitle,
          isInverted: isInverted,
          onTap: () => onTopicTap(topic.searchQuery),
        );
      }).toList(),
    );
  }
}

class _TopicData {
  final IconData icon;
  final String title;
  final String subtitle;
  final String searchQuery;

  const _TopicData(this.icon, this.title, this.subtitle, this.searchQuery);
}

class _TopicCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isInverted;
  final VoidCallback onTap;

  const _TopicCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isInverted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isInverted ? VedaColors.white : VedaColors.black;
    final fg = isInverted ? VedaColors.black : VedaColors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: VedaColors.white, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 32, color: fg),
                Icon(Icons.arrow_outward, size: 16, color: fg),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: fg,
                    letterSpacing: -0.5,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9,
                    color: fg.withValues(alpha: 0.6),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// POPULAR COACHES
// ---------------------------------------------------------------------------
class _CoachesList extends StatelessWidget {
  final List<VedaUserProfile> coaches;
  final void Function(VedaUserProfile coach) onCoachTap;

  const _CoachesList({
    required this.coaches,
    required this.onCoachTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ...coaches.take(6).map((coach) => Padding(
                padding: const EdgeInsets.only(right: 24),
                child: _CoachAvatar(
                  name: (coach.fullName ?? 'COACH').toUpperCase(),
                  imageUrl: coach.profileImageUrl,
                  onTap: () => onCoachTap(coach),
                ),
              )),
        ],
      ),
    );
  }
}

class _CoachAvatar extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final VoidCallback onTap;

  const _CoachAvatar({
    required this.name,
    this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: VedaColors.white, width: 2),
            ),
            child: ClipOval(
              child: imageUrl != null
                  ? Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      color: Colors.white.withValues(alpha: 0.8),
                      colorBlendMode: BlendMode.saturation,
                      errorBuilder: (_, __, ___) => Container(
                        color: VedaColors.zinc800,
                        child: const Icon(Icons.person,
                            color: VedaColors.zinc500, size: 24),
                      ),
                    )
                  : Container(
                      color: VedaColors.zinc800,
                      child: const Icon(Icons.person,
                          color: VedaColors.zinc500, size: 24),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 64,
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: VedaColors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// DISCOVER COURSES (New Arrivals)
// ---------------------------------------------------------------------------
class _DiscoverCourseCard extends StatelessWidget {
  final Course course;
  final String? creatorName;
  final VoidCallback onTap;

  const _DiscoverCourseCard({
    required this.course,
    this.creatorName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final title = course.title.toUpperCase();
    final topics = course.courseTopics;
    final hasImage = course.courseImageUrl != null;
    final topicLabel = topics != null && topics.isNotEmpty
        ? topics.take(2).join(' \u2022 ').toUpperCase()
        : 'COURSE';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          border: Border.all(color: VedaColors.white, width: 2),
        ),
        child: Row(
          children: [
            // Thumbnail
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: VedaColors.zinc800,
                border: Border(
                  right: BorderSide(color: VedaColors.white, width: 2),
                ),
              ),
              child: hasImage
                  ? Image.network(
                      course.courseImageUrl!,
                      fit: BoxFit.cover,
                      color: Colors.white.withValues(alpha: 0.8),
                      colorBlendMode: BlendMode.saturation,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.auto_stories,
                            size: 28, color: VedaColors.zinc500),
                      ),
                    )
                  : const Center(
                      child: Icon(Icons.auto_stories,
                          size: 28, color: VedaColors.zinc500),
                    ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: VedaColors.white,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            creatorName != null
                                ? '${creatorName!.toUpperCase()} \u2022 $topicLabel'
                                : topicLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 9,
                              color: VedaColors.zinc500,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward,
                      size: 18,
                      color: VedaColors.white,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
