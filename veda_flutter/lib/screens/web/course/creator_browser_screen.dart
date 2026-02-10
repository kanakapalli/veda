import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:veda_client/veda_client.dart';

import '../../../design_system/veda_colors.dart';
import '../../../main.dart';

/// Creator Browser Screen - Tests new API endpoints
/// Lists creators, shows profiles, and displays their courses
class CreatorBrowserScreen extends StatefulWidget {
  const CreatorBrowserScreen({super.key});

  @override
  State<CreatorBrowserScreen> createState() => _CreatorBrowserScreenState();
}

class _CreatorBrowserScreenState extends State<CreatorBrowserScreen> {
  final _usernameController = TextEditingController();
  final _topicController = TextEditingController();

  List<VedaUserProfile> _creators = [];
  VedaUserProfile? _selectedCreator;
  VedaUserProfileWithEmail? _creatorDetails;
  List<Course> _creatorCourses = [];

  bool _isLoadingCreators = false;
  bool _isLoadingDetails = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCreators();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _loadCreators() async {
    setState(() {
      _isLoadingCreators = true;
      _error = null;
    });

    try {
      final username = _usernameController.text.trim();
      final topic = _topicController.text.trim();

      print('🔍 Loading creators with filters:');
      print('  - Username: ${username.isEmpty ? "none" : username}');
      print('  - Topic: ${topic.isEmpty ? "none" : topic}');

      final creators = await client.vedaUserProfile.listCreators(
        username: username.isEmpty ? null : username,
        topic: topic.isEmpty ? null : topic,
      );

      print('✅ Loaded ${creators.length} creators');

      if (mounted) {
        setState(() {
          _creators = creators;
          _isLoadingCreators = false;
        });
      }
    } catch (e) {
      print('❌ Error loading creators: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoadingCreators = false;
        });
      }
    }
  }

  Future<void> _loadCreatorDetails(VedaUserProfile creator) async {
    setState(() {
      _selectedCreator = creator;
      _isLoadingDetails = true;
      _error = null;
    });

    try {
      print('📋 Loading details for creator: ${creator.authUserId}');

      // Load creator profile with email
      final details = await client.vedaUserProfile.getUserProfileById(
        creator.authUserId,
      );

      print('✅ Loaded profile: ${details?.profile?.fullName}');
      print('  - Email: ${details?.email}');

      // Load creator's courses
      final courses = await client.lms.getCoursesByCreator(
        creator.authUserId,
      );

      print('✅ Loaded ${courses.length} courses');

      if (mounted) {
        setState(() {
          _creatorDetails = details;
          _creatorCourses = courses;
          _isLoadingDetails = false;
        });
      }
    } catch (e) {
      print('❌ Error loading creator details: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoadingDetails = false;
        });
      }
    }
  }

  void _clearSelection() {
    setState(() {
      _selectedCreator = null;
      _creatorDetails = null;
      _creatorCourses = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final showThreePanel = screenWidth >= 1200;

    return Scaffold(
      backgroundColor: VedaColors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const Divider(height: 1, color: VedaColors.zinc800),
            Expanded(
              child: showThreePanel
                  ? _buildThreePanelLayout()
                  : _buildSinglePanelLayout(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: VedaColors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 16),
          Text(
            'CREATOR BROWSER',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: VedaColors.white,
              letterSpacing: 2.0,
            ),
          ),
          const Spacer(),
          Text(
            '${_creators.length} CREATORS',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: VedaColors.zinc500,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThreePanelLayout() {
    return Row(
      children: [
        // Left: Filters
        SizedBox(
          width: 320,
          child: _buildFiltersPanel(),
        ),
        Container(width: 1, color: VedaColors.zinc800),
        // Center: Creators list
        Expanded(
          child: _buildCreatorsPanel(),
        ),
        if (_selectedCreator != null) ...[
          Container(width: 1, color: VedaColors.zinc800),
          // Right: Creator details
          SizedBox(
            width: 400,
            child: _buildDetailsPanel(),
          ),
        ],
      ],
    );
  }

  Widget _buildSinglePanelLayout() {
    if (_selectedCreator != null) {
      return _buildDetailsPanel();
    }
    return Column(
      children: [
        _buildFiltersPanel(),
        const Divider(height: 1, color: VedaColors.zinc800),
        Expanded(child: _buildCreatorsPanel()),
      ],
    );
  }

  Widget _buildFiltersPanel() {
    return Container(
      color: VedaColors.black,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FILTERS',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: VedaColors.zinc500,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 24),
          // Username filter
          Text(
            'NAME',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: VedaColors.zinc600,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _usernameController,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: VedaColors.white,
            ),
            decoration: InputDecoration(
              hintText: 'Filter by name...',
              hintStyle: GoogleFonts.inter(
                fontSize: 14,
                color: VedaColors.zinc700,
              ),
              filled: false,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
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
            ),
            onSubmitted: (_) => _loadCreators(),
          ),
          const SizedBox(height: 24),
          // Topic filter
          Text(
            'EXPERTISE',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: VedaColors.zinc600,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _topicController,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: VedaColors.white,
            ),
            decoration: InputDecoration(
              hintText: 'Filter by topic...',
              hintStyle: GoogleFonts.inter(
                fontSize: 14,
                color: VedaColors.zinc700,
              ),
              filled: false,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
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
            ),
            onSubmitted: (_) => _loadCreators(),
          ),
          const SizedBox(height: 24),
          // Search button
          SizedBox(
            height: 48,
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _isLoadingCreators ? null : _loadCreators,
              style: OutlinedButton.styleFrom(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                side: const BorderSide(color: VedaColors.accent, width: 1),
                backgroundColor: Colors.transparent,
              ),
              child: _isLoadingCreators
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 1,
                        valueColor: AlwaysStoppedAnimation(VedaColors.accent),
                      ),
                    )
                  : Text(
                      'SEARCH',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: VedaColors.white,
                        letterSpacing: 1.0,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          // Clear button
          SizedBox(
            height: 48,
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                _usernameController.clear();
                _topicController.clear();
                _loadCreators();
              },
              style: OutlinedButton.styleFrom(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                side: const BorderSide(color: VedaColors.zinc800, width: 1),
                backgroundColor: Colors.transparent,
              ),
              child: Text(
                'CLEAR',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: VedaColors.zinc500,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreatorsPanel() {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: VedaColors.error),
            const SizedBox(height: 16),
            Text(
              'ERROR',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                color: VedaColors.error,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                _error!,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: VedaColors.zinc500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    if (_isLoadingCreators) {
      return const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 1,
            valueColor: AlwaysStoppedAnimation(VedaColors.accent),
          ),
        ),
      );
    }

    if (_creators.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.person_search_outlined,
              size: 64,
              color: VedaColors.zinc800,
            ),
            const SizedBox(height: 24),
            Text(
              'NO CREATORS FOUND',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                color: VedaColors.zinc600,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: VedaColors.zinc700,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _creators.length,
      itemBuilder: (context, index) {
        final creator = _creators[index];
        final isSelected = _selectedCreator?.authUserId == creator.authUserId;
        return _CreatorCard(
          creator: creator,
          isSelected: isSelected,
          onTap: () => _loadCreatorDetails(creator),
        );
      },
    );
  }

  Widget _buildDetailsPanel() {
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
              children: [
                if (MediaQuery.of(context).size.width < 1200)
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: VedaColors.white, size: 20),
                    onPressed: _clearSelection,
                  ),
                Text(
                  'CREATOR DETAILS',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: VedaColors.zinc500,
                    letterSpacing: 2.0,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: _isLoadingDetails
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
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile section
                        if (_creatorDetails?.profile != null) ...[
                          _buildProfileSection(),
                          const SizedBox(height: 32),
                        ],
                        // Courses section
                        _buildCoursesSection(),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    final profile = _creatorDetails!.profile!;
    final email = _creatorDetails!.email;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile image
        if (profile.profileImageUrl != null) ...[
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: VedaColors.zinc800, width: 1),
            ),
            child: Image.network(
              profile.profileImageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: VedaColors.zinc900,
                child: const Center(
                  child: Icon(Icons.person, size: 48, color: VedaColors.zinc700),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
        // Name
        Text(
          profile.fullName ?? 'Unnamed Creator',
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.w300,
            color: VedaColors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        // Email
        if (email != null) ...[
          Row(
            children: [
              const Icon(Icons.email_outlined, size: 16, color: VedaColors.zinc600),
              const SizedBox(width: 8),
              Text(
                email,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: VedaColors.zinc500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        // Website
        if (profile.websiteUrl != null) ...[
          Row(
            children: [
              const Icon(Icons.language, size: 16, color: VedaColors.zinc600),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  profile.websiteUrl!,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: VedaColors.accent,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        const SizedBox(height: 24),
        // Bio
        if (profile.bio != null && profile.bio!.isNotEmpty) ...[
          Text(
            'BIO',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: VedaColors.zinc600,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            profile.bio!,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: VedaColors.zinc500,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
        ],
        // Expertise
        if (profile.expertise != null && profile.expertise!.isNotEmpty) ...[
          Text(
            'EXPERTISE',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: VedaColors.zinc600,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: profile.expertise!.map((exp) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: VedaColors.accent, width: 1),
                ),
                child: Text(
                  exp,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: VedaColors.accent,
                    letterSpacing: 0.5,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildCoursesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'COURSES',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: VedaColors.zinc600,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              '${_creatorCourses.length}',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                color: VedaColors.zinc700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_creatorCourses.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                children: [
                  const Icon(
                    Icons.school_outlined,
                    size: 48,
                    color: VedaColors.zinc800,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No courses yet',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: VedaColors.zinc600,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ..._creatorCourses.map((course) => _CourseListItem(course: course)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// CREATOR CARD
// ---------------------------------------------------------------------------

class _CreatorCard extends StatefulWidget {
  final VedaUserProfile creator;
  final bool isSelected;
  final VoidCallback onTap;

  const _CreatorCard({
    required this.creator,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_CreatorCard> createState() => _CreatorCardState();
}

class _CreatorCardState extends State<_CreatorCard> {
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? VedaColors.zinc900
                  : _isHovered
                      ? VedaColors.zinc900.withValues(alpha: 0.5)
                      : Colors.transparent,
              border: Border.all(
                color: widget.isSelected
                    ? VedaColors.accent
                    : _isHovered
                        ? VedaColors.zinc700
                        : VedaColors.zinc800,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    border: Border.all(color: VedaColors.zinc700, width: 1),
                  ),
                  child: widget.creator.profileImageUrl != null
                      ? Image.network(
                          widget.creator.profileImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                            Icons.person,
                            size: 24,
                            color: VedaColors.zinc700,
                          ),
                        )
                      : const Icon(
                          Icons.person,
                          size: 24,
                          color: VedaColors.zinc700,
                        ),
                ),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.creator.fullName ?? 'Unnamed Creator',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: VedaColors.white,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.creator.expertise != null &&
                          widget.creator.expertise!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.creator.expertise!.take(2).join(', '),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: VedaColors.zinc600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: widget.isSelected || _isHovered
                      ? VedaColors.white
                      : VedaColors.zinc700,
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
// COURSE LIST ITEM
// ---------------------------------------------------------------------------

class _CourseListItem extends StatelessWidget {
  final Course course;

  const _CourseListItem({required this.course});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: VedaColors.zinc800, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course image
          if (course.courseImageUrl != null) ...[
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: VedaColors.zinc800, width: 1),
              ),
              child: Image.network(
                course.courseImageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: VedaColors.zinc900,
                  child: const Center(
                    child: Icon(
                      Icons.school_outlined,
                      size: 32,
                      color: VedaColors.zinc700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          // Title
          Text(
            course.title,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: VedaColors.white,
              letterSpacing: 0.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (course.description != null && course.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              course.description!,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: VedaColors.zinc600,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),
          // Visibility badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(
                color: course.visibility == CourseVisibility.public
                    ? VedaColors.accent
                    : VedaColors.zinc700,
                width: 1,
              ),
            ),
            child: Text(
              course.visibility.name.toUpperCase(),
              style: GoogleFonts.jetBrainsMono(
                fontSize: 9,
                color: course.visibility == CourseVisibility.public
                    ? VedaColors.accent
                    : VedaColors.zinc600,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
