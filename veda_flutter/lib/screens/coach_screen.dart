import 'package:flutter/material.dart';
import 'package:veda_client/veda_client.dart';

import '../design_system/veda_colors.dart';
import '../main.dart';
import 'course_detail_screen.dart';

/// Coach/Creator profile screen showing their details and courses
class CoachScreen extends StatefulWidget {
  final VedaUserProfile coach;

  const CoachScreen({
    super.key,
    required this.coach,
  });

  @override
  State<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends State<CoachScreen> {
  bool _isLoading = true;
  String? _email;
  List<Course> _courses = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCoachData();
  }

  Future<void> _loadCoachData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Fetch coach details and courses in parallel
      final results = await Future.wait([
        client.vedaUserProfile.getUserProfileById(widget.coach.authUserId),
        client.lms.getCoursesByCreator(widget.coach.authUserId),
      ]);

      final profileWithEmail = results[0] as VedaUserProfileWithEmail?;
      final courses = results[1] as List<Course>;

      setState(() {
        _email = profileWithEmail?.email;
        _courses = courses;
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

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
                              constraints: BoxConstraints(
                                maxWidth: isMobile ? double.infinity : 440,
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const SizedBox(height: 24),

                                  // Profile Card
                                  _buildProfileCard(),

                                  const SizedBox(height: 36),

                                  // Expert Profile Section
                                  _buildExpertProfile(),

                                  const SizedBox(height: 36),

                                  // Constructed Courses Section
                                  _buildConstructedCourses(),

                                  const SizedBox(height: 36),

                                  // Contact Button
                                  _buildContactButton(),

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
              'COACH',
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

  Widget _buildProfileCard() {
    final name = widget.coach.fullName?.toUpperCase() ?? 'UNKNOWN';
    final expertise = widget.coach.interests?.isNotEmpty == true
        ? 'SPECIALIST - ${widget.coach.interests!.first.toUpperCase()}'
        : 'SPECIALIST';

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: VedaColors.white, width: 0.5),
      ),
      child: Column(
        children: [
          // Profile Image
          AspectRatio(
            aspectRatio: 1,
            child: widget.coach.profileImageUrl != null
                ? Image.network(
                    widget.coach.profileImageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholderImage();
                    },
                  )
                : _buildPlaceholderImage(),
          ),

          // Name and Expertise
          Container(
            padding: const EdgeInsets.all(16),
            color: VedaColors.black,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: VedaColors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  expertise,
                  style: const TextStyle(
                    color: VedaColors.zinc500,
                    fontSize: 11,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: VedaColors.zinc900,
      child: const Center(
        child: Icon(
          Icons.person_outline,
          size: 80,
          color: VedaColors.zinc700,
        ),
      ),
    );
  }

  Widget _buildExpertProfile() {
    final bio = widget.coach.bio ?? 'No bio available.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: VedaColors.white, width: 0.5),
          ),
          child: const Text(
            'EXPERT PROFILE',
            style: TextStyle(
              color: VedaColors.white,
              fontSize: 10,
              fontWeight: FontWeight.w400,
              letterSpacing: 1,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Bio
        Text(
          bio,
          style: const TextStyle(
            color: VedaColors.zinc500,
            fontSize: 14,
            fontWeight: FontWeight.w300,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildConstructedCourses() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'CONSTRUCTED_COURSES',
              style: TextStyle(
                color: VedaColors.white,
                fontSize: 12,
                fontWeight: FontWeight.w400,
                letterSpacing: 1,
              ),
            ),
            Text(
              '${_courses.length.toString().padLeft(2, '0')}_ENTRIES',
              style: const TextStyle(
                color: VedaColors.zinc500,
                fontSize: 10,
                fontWeight: FontWeight.w300,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Course Cards
        if (_courses.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border.all(color: VedaColors.zinc800, width: 0.5),
            ),
            child: const Center(
              child: Text(
                'No courses created yet',
                style: TextStyle(
                  color: VedaColors.zinc600,
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          )
        else
          ...List.generate(_courses.length, (index) {
            final course = _courses[index];
            return Padding(
              padding: EdgeInsets.only(bottom: index < _courses.length - 1 ? 12 : 0),
              child: _buildCourseCard(course),
            );
          }),
      ],
    );
  }

  Widget _buildCourseCard(Course course) {
    // TODO: Fetch real stats from database when available
    // For now using placeholder data
    final enrolledLearners = '1,249'; // Placeholder
    final avgScore = '86.4-5'; // Placeholder

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CourseDetailScreen(course: course),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: VedaColors.white, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course Title
            Text(
              course.title.toUpperCase(),
              style: const TextStyle(
                color: VedaColors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            // Stats Row
            Row(
              children: [
                // Enrolled Learners
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ENROLLED LEARNERS:',
                        style: TextStyle(
                          color: VedaColors.zinc500,
                          fontSize: 9,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        enrolledLearners,
                        style: const TextStyle(
                          color: VedaColors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Avg Score
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AVG_SCORE:',
                        style: TextStyle(
                          color: VedaColors.zinc500,
                          fontSize: 9,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        avgScore,
                        style: const TextStyle(
                          color: VedaColors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow Icon
                const Icon(
                  Icons.arrow_forward,
                  color: VedaColors.white,
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: () {
          // TODO: Implement contact functionality
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Contact: ${_email ?? 'No email available'}'),
              backgroundColor: VedaColors.zinc900,
              duration: const Duration(seconds: 2),
            ),
          );
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: VedaColors.white,
          side: const BorderSide(color: VedaColors.white, width: 0.5),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          padding: EdgeInsets.zero,
        ),
        child: const Text(
          'CONTACT_AGENT',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
