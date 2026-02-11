import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:veda_client/veda_client.dart';

import '../design_system/veda_colors.dart';
import '../main.dart';
import 'coach_screen.dart';
import 'enrolled_course_screen.dart';

/// Course detail screen showing course information and table of contents
class CourseDetailScreen extends StatefulWidget {
  final Course course;

  const CourseDetailScreen({
    super.key,
    required this.course,
  });

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  bool _isLoading = true;
  List<Module> _modules = [];
  VedaUserProfile? _creator;
  String? _error;

  // Enrollment state
  bool _isEnrolled = false;
  bool _isEnrolling = false;
  int _enrollmentCount = 0;

  // Track expanded state for modules and topics
  final Set<int> _expandedModuleIds = {};
  final Set<int> _expandedTopicIds = {};

  @override
  void initState() {
    super.initState();
    _loadCourseData();
  }

  Future<void> _loadCourseData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Fetch modules, creator info, and enrollment status in parallel
      final results = await Future.wait([
        client.lms.getModules(widget.course.id!),
        client.vedaUserProfile.getUserProfileById(widget.course.creatorId),
        client.lms.isEnrolled(widget.course.id!),
        client.lms.getEnrollmentCount(widget.course.id!),
      ]);

      final modules = results[0] as List<Module>;
      final creatorProfile = results[1] as VedaUserProfileWithEmail?;
      final isEnrolled = results[2] as bool;
      final enrollmentCount = results[3] as int;

      setState(() {
        _modules = modules;
        _creator = creatorProfile?.profile;
        _isEnrolled = isEnrolled;
        _enrollmentCount = enrollmentCount;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _handleEnroll() async {
    if (_isEnrolling) return;

    setState(() => _isEnrolling = true);

    try {
      if (_isEnrolled) {
        // Unenroll
        await client.lms.unenrollFromCourse(widget.course.id!);
        setState(() {
          _isEnrolled = false;
          _enrollmentCount = (_enrollmentCount - 1).clamp(0, 999999);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unenrolled from course'),
              backgroundColor: VedaColors.zinc900,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Enroll
        await client.lms.enrollInCourse(widget.course.id!);
        setState(() {
          _isEnrolled = true;
          _enrollmentCount += 1;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Successfully enrolled!'),
              backgroundColor: VedaColors.zinc900,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: VedaColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isEnrolling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VedaColors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: VedaColors.white,
                        strokeWidth: 1,
                      ),
                    )
                  : _error != null
                      ? Center(
                          child: Text(
                            'Error: $_error',
                            style: const TextStyle(
                              color: VedaColors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          child: Center(
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 440),
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const SizedBox(height: 24),

                                  // Video Player
                                  _buildVideoPlayer(),

                                  const SizedBox(height: 36),

                                  // Course Title
                                  _buildCourseTitle(),

                                  const SizedBox(height: 24),

                                  // Coach Section
                                  if (_creator != null) ...[                                    _buildCoachSection(),
                                    const SizedBox(height: 36),
                                  ],

                                  // Course Topics
                                  if (_getCourseTopics().isNotEmpty) ...[
                                    _buildCourseTopics(),
                                    const SizedBox(height: 36),
                                  ],

                                  // Course Synopsis
                                  if (widget.course.description != null) ...[
                                    _buildCourseSynopsis(),
                                    const SizedBox(height: 36),
                                  ],

                                  // Table of Contents
                                  _buildTableOfContents(),

                                  const SizedBox(height: 36),

                                  // Enroll Button
                                  _buildEnrollButton(),

                                  const SizedBox(height: 24),
                                ],
                              ),
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: VedaColors.zinc800, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Back button
          IconButton(
            icon: const Icon(Icons.arrow_back, color: VedaColors.white, size: 20),
            onPressed: () => Navigator.of(context).pop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),

          const SizedBox(width: 12),

          // Title
          const Expanded(
            child: Text(
              'COURSE',
              style: TextStyle(
                color: VedaColors.white,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                letterSpacing: 1,
              ),
            ),
          ),

          // Menu button
          IconButton(
            icon: const Icon(Icons.more_vert, color: VedaColors.white, size: 20),
            onPressed: () {
              // TODO: Implement menu
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        border: Border.all(color: VedaColors.white, width: 1),
        color: VedaColors.black,
      ),
      child: Stack(
        children: [
          // Video thumbnail or player
          if (widget.course.courseImageUrl != null)
            Positioned.fill(
              child: Image.network(
                widget.course.courseImageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: VedaColors.zinc900,
                ),
              ),
            )
          else
            Container(color: VedaColors.zinc900),

          // Play button overlay
          Center(
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: VedaColors.white,
                border: Border.all(color: VedaColors.white, width: 1),
              ),
              child: const Icon(
                Icons.play_arrow,
                color: VedaColors.black,
                size: 36,
              ),
            ),
          ),

          // Top overlay with label and close button
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  color: VedaColors.white,
                  child: Text(
                    'REC_0X_004',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: VedaColors.black,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    border: Border.all(color: VedaColors.white, width: 1),
                    color: Colors.transparent,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: VedaColors.white,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseTitle() {
    return Text(
      widget.course.title.toUpperCase(),
      style: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w900,
        color: VedaColors.white,
        letterSpacing: 0.5,
        height: 1.2,
      ),
    );
  }

  Widget _buildCoachSection() {
    final coach = _creator!;
    final name = coach.fullName?.toUpperCase() ?? 'UNKNOWN';
    final expertise = coach.interests?.isNotEmpty == true
        ? coach.interests!.first.toUpperCase()
        : null;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CoachScreen(coach: coach),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: VedaColors.white, width: 1),
        ),
        child: Row(
          children: [
            // Coach avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                border: Border.all(color: VedaColors.zinc700, width: 0.5),
                color: VedaColors.zinc900,
              ),
              child: coach.profileImageUrl != null
                  ? Image.network(
                      coach.profileImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.person_outline,
                        color: VedaColors.zinc600,
                        size: 24,
                      ),
                    )
                  : const Icon(
                      Icons.person_outline,
                      color: VedaColors.zinc600,
                      size: 24,
                    ),
            ),

            const SizedBox(width: 16),

            // Coach info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'COACH',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 9,
                      fontWeight: FontWeight.w400,
                      color: VedaColors.zinc500,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    name,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: VedaColors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                  if (expertise != null) ...[                    const SizedBox(height: 2),
                    Text(
                      expertise,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: VedaColors.zinc500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Arrow
            const Icon(
              Icons.arrow_forward,
              color: VedaColors.white,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getCourseTopics() {
    return widget.course.courseTopics ?? [];
  }

  Widget _buildCourseTopics() {
    final topics = _getCourseTopics();
    if (topics.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'COURSE_TOPICS',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: VedaColors.white,
                letterSpacing: 1,
              ),
            ),
            Text(
              '${topics.length.toString().padLeft(2, '0')}_TAGS',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 9,
                fontWeight: FontWeight.w400,
                color: VedaColors.zinc600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Topics as chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: topics.map((topic) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: VedaColors.white, width: 0.5),
              ),
              child: Text(
                topic.toUpperCase(),
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: VedaColors.white,
                  letterSpacing: 1,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCourseSynopsis() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'COURSE_SYNOPSIS',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: VedaColors.white,
                letterSpacing: 1,
              ),
            ),
            Text(
              'DESC_01',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 9,
                fontWeight: FontWeight.w400,
                color: VedaColors.zinc600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Description
        Text(
          widget.course.description ?? '',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w300,
            color: VedaColors.white,
            height: 1.6,
            letterSpacing: 0.2,
          ),
        ),


      ],
    );
  }

  Widget _buildTableOfContents() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'TABLE_OF_CONTENTS',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: VedaColors.white,
                letterSpacing: 1,
              ),
            ),
            Text(
              'IDX: ${_modules.length.toString().padLeft(3, '0')}_MODS',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 9,
                fontWeight: FontWeight.w400,
                color: VedaColors.zinc600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Module list
        if (_modules.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border.all(color: VedaColors.zinc800, width: 1),
            ),
            child: Center(
              child: Text(
                'No modules available',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w300,
                  color: VedaColors.zinc600,
                ),
              ),
            ),
          )
        else
          Column(
            children: List.generate(_modules.length, (index) {
              final module = _modules[index];
              return Padding(
                padding: EdgeInsets.only(bottom: index < _modules.length - 1 ? 12 : 0),
                child: _buildModuleCard(module, index),
              );
            }),
          ),
      ],
    );
  }

  Widget _buildModuleCard(Module module, int index) {
    final isExpanded = module.id != null && _expandedModuleIds.contains(module.id);
    final topics = module.items?.map((item) => item.topic).whereType<Topic>().toList() ?? [];
    final hasDescription = module.description != null && module.description!.isNotEmpty;

    return Column(
      children: [
        // Module card
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: VedaColors.white, width: 1),
            color: isExpanded ? VedaColors.zinc900 : Colors.transparent,
          ),
          child: Column(
            children: [
              // Module header
              GestureDetector(
                onTap: () {
                  if (module.id != null) {
                    setState(() {
                      if (_expandedModuleIds.contains(module.id)) {
                        _expandedModuleIds.remove(module.id);
                      } else {
                        _expandedModuleIds.add(module.id!);
                      }
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.transparent,
                  child: Row(
                    children: [
                      // Expand/collapse icon
                      Icon(
                        isExpanded ? Icons.remove : Icons.add,
                        color: VedaColors.white,
                        size: 16,
                      ),

                      const SizedBox(width: 12),

                      // Module content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Module number and label
                            Text(
                              '${(index + 1).toString().padLeft(2, '0')} : ${topics.length} TOPICS',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                                color: VedaColors.zinc500,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Module title
                            Text(
                              module.title.toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: VedaColors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Module description (when expanded)
              if (isExpanded && hasDescription) ...[
                Container(
                  padding: const EdgeInsets.fromLTRB(40, 0, 16, 16),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: VedaColors.zinc800, width: 0.5),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      module.description!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        color: VedaColors.zinc500,
                        height: 1.6,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        // Topics as separate cards (when expanded)
        if (isExpanded && topics.isNotEmpty) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Column(
              children: topics.asMap().entries.map((entry) {
                final topicIndex = entry.key;
                final topic = entry.value;
                final isLastTopic = topicIndex == topics.length - 1;
                return Padding(
                  padding: EdgeInsets.only(bottom: isLastTopic ? 0 : 12),
                  child: _buildTopicCard(topic, topicIndex),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTopicCard(Topic topic, int index) {
    final isExpanded = topic.id != null && _expandedTopicIds.contains(topic.id);
    final hasDescription = topic.description != null && topic.description!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isExpanded ? VedaColors.white : VedaColors.zinc700,
          width: 1,
        ),
        color: isExpanded ? VedaColors.zinc900 : Colors.transparent,
      ),
      child: Column(
        children: [
          // Topic header
          GestureDetector(
            onTap: hasDescription
                ? () {
                    if (topic.id != null) {
                      setState(() {
                        if (_expandedTopicIds.contains(topic.id)) {
                          _expandedTopicIds.remove(topic.id);
                        } else {
                          _expandedTopicIds.add(topic.id!);
                        }
                      });
                    }
                  }
                : null,
            child: Container(
              padding: const EdgeInsets.all(12),
              color: Colors.transparent,
              child: Row(
                children: [
                  // Expand icon if has description
                  if (hasDescription)
                    Icon(
                      isExpanded ? Icons.remove : Icons.add,
                      color: isExpanded ? VedaColors.white : VedaColors.zinc600,
                      size: 14,
                    )
                  else
                    const SizedBox(width: 14),

                  const SizedBox(width: 12),

                  // Topic content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Topic number
                        Text(
                          '${(index + 1).toString().padLeft(2, '0')} : TOPIC',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 9,
                            fontWeight: FontWeight.w400,
                            color: VedaColors.zinc600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Topic title
                        Text(
                          topic.title,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: VedaColors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Topic description (when expanded)
          if (isExpanded && hasDescription) ...[
            Container(
              padding: const EdgeInsets.fromLTRB(38, 0, 12, 12),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: VedaColors.zinc800, width: 0.5),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  topic.description!,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w300,
                    color: VedaColors.zinc500,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEnrollButton() {
    return Column(
      children: [
        // Enrollment count
        if (_enrollmentCount > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              '$_enrollmentCount ${_enrollmentCount == 1 ? 'STUDENT' : 'STUDENTS'} ENROLLED',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 9,
                fontWeight: FontWeight.w400,
                color: VedaColors.zinc500,
                letterSpacing: 1,
              ),
            ),
          ),

        if (_isEnrolled) ...[
          // Go to enrolled course button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        EnrolledCourseScreen(course: widget.course),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: VedaColors.white,
                foregroundColor: VedaColors.black,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                elevation: 0,
                padding: EdgeInsets.zero,
              ),
              child: Text(
                'GO_TO_COURSE',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Unenroll button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: _isEnrolling ? null : _handleEnroll,
              style: OutlinedButton.styleFrom(
                foregroundColor: VedaColors.zinc500,
                side: const BorderSide(color: VedaColors.zinc700, width: 0.5),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                padding: EdgeInsets.zero,
              ),
              child: _isEnrolling
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 1,
                        color: VedaColors.zinc500,
                      ),
                    )
                  : Text(
                      'UNENROLL',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1.5,
                      ),
                    ),
            ),
          ),
        ] else ...[
          // Enroll button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isEnrolling ? null : _handleEnroll,
              style: ElevatedButton.styleFrom(
                backgroundColor: VedaColors.white,
                foregroundColor: VedaColors.black,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                elevation: 0,
                padding: EdgeInsets.zero,
                disabledBackgroundColor: VedaColors.zinc800,
              ),
              child: _isEnrolling
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: VedaColors.black,
                      ),
                    )
                  : Text(
                      'ENROLL_NOW',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
            ),
          ),
        ],
      ],
    );
  }
}
