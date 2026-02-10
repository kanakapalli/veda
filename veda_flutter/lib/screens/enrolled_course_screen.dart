import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:veda_client/veda_client.dart';

import '../design_system/veda_colors.dart';
import '../main.dart';
import 'module_teach_screen.dart';

/// Screen displayed when a user taps on an enrolled course.
/// Shows a timeline-based syllabus with per-module progress states.
class EnrolledCourseScreen extends StatefulWidget {
  final Course course;

  const EnrolledCourseScreen({super.key, required this.course});

  @override
  State<EnrolledCourseScreen> createState() => _EnrolledCourseScreenState();
}

enum TeachingMode { quick, explanative, lecture }

class _EnrolledCourseScreenState extends State<EnrolledCourseScreen> {
  List<Module> _modules = [];
  List<ModuleProgress> _progress = [];
  double _progressPercent = 0.0;
  bool _isLoading = true;
  String? _error;
  TeachingMode _teachingMode = TeachingMode.explanative;
  final Set<int> _expandedModules = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final courseId = widget.course.id!;
      final results = await Future.wait([
        client.lms.getModules(courseId),
        client.lms.getMyProgress(courseId),
        client.lms.getCourseProgress(courseId),
      ]);

      if (!mounted) return;

      setState(() {
        _modules = (results[0] as List<Module>)
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        _progress = results[1] as List<ModuleProgress>;
        _progressPercent = results[2] as double;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Check if a specific module has been completed.
  bool _isModuleCompleted(int moduleId) {
    return _progress.any((p) => p.moduleId == moduleId && p.completed);
  }

  /// Find the index of the first incomplete module (the "current" module).
  int _currentModuleIndex() {
    for (var i = 0; i < _modules.length; i++) {
      if (!_isModuleCompleted(_modules[i].id!)) {
        return i;
      }
    }
    return _modules.length; // all done
  }

  int get _minWords {
    switch (_teachingMode) {
      case TeachingMode.quick:
        return 50;
      case TeachingMode.explanative:
        return 100;
      case TeachingMode.lecture:
        return 300;
    }
  }

  int get _maxWords {
    switch (_teachingMode) {
      case TeachingMode.quick:
        return 150;
      case TeachingMode.explanative:
        return 500;
      case TeachingMode.lecture:
        return 1000;
    }
  }

  void _openModule(Module module) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (_) => ModuleTeachScreen(
          course: widget.course,
          module: module,
          modules: _modules,
          minWords: _minWords,
          maxWords: _maxWords,
        ),
      ),
    )
        .then((_) => _loadData()); // Refresh progress on return
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VedaColors.black,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: VedaColors.white,
                strokeWidth: 1,
              ),
            )
          : _error != null
              ? _buildError()
              : CustomScrollView(
                  slivers: [
                    _buildHeader(),
                    SliverToBoxAdapter(child: _buildBody()),
                  ],
                ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // HEADER
  // ─────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return SliverAppBar(
      pinned: true,
      toolbarHeight: 160,
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
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(
                        Icons.arrow_back,
                        color: VedaColors.white,
                        size: 22,
                      ),
                    ),
                    // Dots indicator
                    Row(
                      children: [
                        Container(width: 6, height: 6, color: VedaColors.white),
                        const SizedBox(width: 4),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            border: Border.all(color: VedaColors.white, width: 1),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            border: Border.all(color: VedaColors.white, width: 1),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Breadcrumb
                Text(
                  'VEDA_OS / LEARNING_PATH',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: VedaColors.white.withValues(alpha: 0.6),
                    letterSpacing: 3.0,
                  ),
                ),
                const SizedBox(height: 6),

                // Course title with icon
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        border: Border.all(color: VedaColors.white, width: 2),
                      ),
                      child: const Icon(Icons.domain, size: 18, color: VedaColors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.course.title.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: VedaColors.white,
                          letterSpacing: -0.5,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Tags
                Row(
                  children: [
                    if (widget.course.courseTopics != null)
                      ...widget.course.courseTopics!.take(2).map(
                        (tag) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              border: Border.all(color: VedaColors.white, width: 1),
                            ),
                            child: Text(
                              tag.toUpperCase(),
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: VedaColors.white,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      color: VedaColors.white,
                      child: Text(
                        _progressPercent >= 1.0 ? 'COMPLETED' : 'IN PROGRESS',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: VedaColors.black,
                          letterSpacing: 1.0,
                        ),
                      ),
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

  // ─────────────────────────────────────────────────────────────
  // BODY
  // ─────────────────────────────────────────────────────────────
  Widget _buildBody() {
    final currentIndex = _currentModuleIndex();
    final percent = (_progressPercent * 100).round();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Progress circle + stats ──
          _buildProgressSection(percent),
          const SizedBox(height: 24),

          // ── Teaching mode selector ──
          _buildTeachingModeSelector(),
          const SizedBox(height: 32),

          // ── Section title ──
          Row(
            children: [
              Container(width: 2, height: 18, color: VedaColors.white),
              const SizedBox(width: 12),
              Text(
                'SYLLABUS_INDEX',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: VedaColors.white,
                  letterSpacing: 2.0,
                ),
              ),
              const Spacer(),
              Text(
                '${_modules.length} MODULES',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  color: VedaColors.white.withValues(alpha: 0.7),
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Timeline modules ──
          _buildTimeline(currentIndex),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // PROGRESS CIRCLE
  // ─────────────────────────────────────────────────────────────
  Widget _buildProgressSection(int percent) {
    final completedCount = _progress.where((p) => p.completed).length;

    return Row(
      children: [
        // SVG-style progress circle
        SizedBox(
          width: 80,
          height: 80,
          child: CustomPaint(
            painter: _ProgressCirclePainter(percent / 100),
            child: Center(
              child: Text(
                '$percent%',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: VedaColors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TOTAL_PROGRESS',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: VedaColors.white,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$completedCount / ${_modules.length} MODULES_COMPLETE',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  color: VedaColors.white.withValues(alpha: 0.7),
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              // Progress bar
              Container(
                height: 4,
                width: 140,
                color: VedaColors.zinc800,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: _progressPercent.clamp(0.0, 1.0),
                    child: Container(color: VedaColors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // TEACHING MODE SELECTOR
  // ─────────────────────────────────────────────────────────────
  Widget _buildTeachingModeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TEACHING_MODE',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: VedaColors.white,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: TeachingMode.values.map((mode) {
            final isSelected = _teachingMode == mode;
            final label = switch (mode) {
              TeachingMode.quick => 'QUICK',
              TeachingMode.explanative => 'EXPLANATIVE',
              TeachingMode.lecture => 'LECTURE',
            };
            final wordRange = switch (mode) {
              TeachingMode.quick => '50–150 words',
              TeachingMode.explanative => '100–500 words',
              TeachingMode.lecture => '300–1000 words',
            };

            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _teachingMode = mode),
                child: Container(
                  margin: EdgeInsets.only(
                    right: mode != TeachingMode.lecture ? 8 : 0,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? VedaColors.white : Colors.transparent,
                    border: Border.all(
                      color: VedaColors.white,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? VedaColors.black : VedaColors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        wordRange,
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          color: isSelected
                              ? VedaColors.black.withValues(alpha: 0.6)
                              : VedaColors.white.withValues(alpha: 0.6),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // TIMELINE
  // ─────────────────────────────────────────────────────────────
  Widget _buildTimeline(int currentIndex) {
    return Column(
      children: List.generate(_modules.length, (index) {
        final module = _modules[index];
        final isCompleted = _isModuleCompleted(module.id!);
        final isCurrent = index == currentIndex;
        final isLocked = index > currentIndex;

        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline left column (circle + line)
              SizedBox(
                width: 48,
                child: Column(
                  children: [
                    // Connection line from above (except first item)
                    if (index > 0)
                      Container(
                        width: 2,
                        height: 12,
                        color: isCompleted || isCurrent
                            ? VedaColors.white
                            : VedaColors.zinc800,
                      ),
                    // Circle / icon
                    _buildTimelineIcon(index, isCompleted, isCurrent, isLocked),
                    // Connection line below (except last item)
                    if (index < _modules.length - 1)
                      Container(
                        width: 2,
                        height: isCurrent ? 120 : 12,
                        color: isCompleted
                            ? VedaColors.white
                            : VedaColors.zinc800.withValues(alpha: 0.3),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Module card
              Expanded(
                child: isCurrent
                    ? _buildCurrentModuleCard(module, index)
                    : _buildModuleCard(module, index, isCompleted, isLocked),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTimelineIcon(
      int index, bool isCompleted, bool isCurrent, bool isLocked) {
    if (isCompleted) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          border: Border.all(color: VedaColors.white, width: 2),
        ),
        child: const Icon(Icons.check, color: VedaColors.white, size: 20),
      );
    }

    if (isCurrent) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: VedaColors.white,
          border: Border.all(color: VedaColors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: VedaColors.white.withValues(alpha: 0.3),
              blurRadius: 15,
            ),
          ],
        ),
        child: Center(
          child: Text(
            (index + 1).toString().padLeft(2, '0'),
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: VedaColors.black,
            ),
          ),
        ),
      );
    }

    // Locked
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        border: Border.all(
          color: VedaColors.white,
          width: 2,
          strokeAlign: BorderSide.strokeAlignCenter,
        ),
      ),
      child: Center(
        child: Text(
          (index + 1).toString().padLeft(2, '0'),
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: VedaColors.white,
          ),
        ),
      ),
    );
  }

  // ── Completed / Upcoming module card ──
  Widget _buildModuleCard(Module module, int index, bool isCompleted, bool isLocked) {
    final topicCount = module.items?.length ?? 0;
    final isExpanded = _expandedModules.contains(index);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isExpanded) {
            _expandedModules.remove(index);
          } else {
            _expandedModules.add(index);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: VedaColors.white,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(index + 1).toString().padLeft(2, '0')} : ${module.title.split(' ').first.toUpperCase()}',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: VedaColors.white,
                    letterSpacing: 2.0,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isCompleted)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        color: VedaColors.white,
                        child: Text(
                          'COMPLETED',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: VedaColors.black,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    Icon(
                      isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: VedaColors.white,
                      size: 18,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              module.title.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: VedaColors.white,
                letterSpacing: 0.5,
              ),
            ),
            if (isExpanded && topicCount > 0) ...[
                const SizedBox(height: 8),
                Text(
                  '$topicCount TOPICS',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9,
                    color: VedaColors.white.withValues(alpha: 0.7),
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 6),
                ...module.items!.map((item) {
                  final topic = item.topic;
                  if (topic == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            border: Border.all(color: VedaColors.white.withValues(alpha: 0.5), width: 1),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            topic.title,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w300,
                              color: VedaColors.white.withValues(alpha: 0.7),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),
                // Action button
                GestureDetector(
                  onTap: () => _openModule(module),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: VedaColors.white, width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isCompleted ? Icons.replay : Icons.play_arrow,
                          size: 16,
                          color: VedaColors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isCompleted ? 'REDO' : 'START',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: VedaColors.white,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
  }

  // ── Currently active module card (expanded) ──
  Widget _buildCurrentModuleCard(Module module, int index) {
    final topicCount = module.items?.length ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: VedaColors.white,
        border: Border.all(color: VedaColors.white, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label
                Container(
                  padding: const EdgeInsets.only(bottom: 4),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: VedaColors.black, width: 1),
                    ),
                  ),
                  child: Text(
                    'CURRENT_LESSON',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: VedaColors.black,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Title
                Text(
                  module.title.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: VedaColors.black,
                    letterSpacing: -0.5,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 12),

                // Description
                if (module.description != null)
                  Container(
                    padding: const EdgeInsets.only(left: 12),
                    decoration: const BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: Color(0x33000000),
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      '> ${module.description}',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        color: VedaColors.black.withValues(alpha: 0.7),
                        height: 1.5,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // Topics list
                Text(
                  '$topicCount TOPICS',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: VedaColors.black.withValues(alpha: 0.7),
                    letterSpacing: 1.0,
                  ),
                ),
                if (module.items != null) ...[
                  const SizedBox(height: 8),
                  ...module.items!.map((item) {
                    final topic = item.topic;
                    if (topic == null) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 4,
                            color: VedaColors.black.withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              topic.title,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                color: VedaColors.black.withValues(alpha: 0.7),
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
                const SizedBox(height: 16),

                // Start / Resume button
                GestureDetector(
                  onTap: () => _openModule(module),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    color: VedaColors.black,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.play_arrow,
                          size: 20,
                          color: VedaColors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'START SESSION',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: VedaColors.white,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'LOAD_FAILED',
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
              color: VedaColors.white.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _loadData,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: VedaColors.white, width: 1),
              ),
              child: Text(
                'RETRY',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  color: VedaColors.white,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// PROGRESS CIRCLE PAINTER
// ─────────────────────────────────────────────────────────────
class _ProgressCirclePainter extends CustomPainter {
  final double progress; // 0.0 – 1.0

  _ProgressCirclePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) - 4;

    // Background ring
    final bgPaint = Paint()
      ..color = VedaColors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = VedaColors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, // start from top
      2 * pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressCirclePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
