import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:veda_client/veda_client.dart';

import '../design_system/veda_colors.dart';
import '../main.dart';
import 'coach_screen.dart';
import 'course_detail_screen.dart';

enum SearchFilter { courses, coaches, topics }

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  Timer? _searchTimer;

  List<String> _searchHistory = [];
  List<VedaUserProfile> _recentCoaches = [];
  List<Course> _recentCourses = [];
  List<VedaUserProfile> _creatorResults = [];
  List<Course> _courseResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;
  String _currentQuery = '';
  SearchFilter _activeFilter = SearchFilter.coaches;

  static const String _historyKey = 'search_history';
  static const String _recentCoachesKey = 'recent_coaches';
  static const String _recentCoursesKey = 'recent_courses';
  static const int _maxHistoryItems = 3;

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
    _loadRecentItems();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(_historyKey) ?? [];
      if (mounted) {
        setState(() {
          _searchHistory = history.take(_maxHistoryItems).toList();
        });
      }
    } catch (e) {
      print('Error loading search history: $e');
    }
  }

  Future<void> _saveSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_historyKey, _searchHistory);
    } catch (e) {
      print('Error saving search history: $e');
    }
  }

  Future<void> _loadRecentItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load recent coaches
      final coachesJson = prefs.getStringList(_recentCoachesKey) ?? [];
      final coaches = coachesJson
          .map((json) => VedaUserProfile.fromJson(jsonDecode(json)))
          .toList();

      // Load recent courses
      final coursesJson = prefs.getStringList(_recentCoursesKey) ?? [];
      final courses = coursesJson
          .map((json) => Course.fromJson(jsonDecode(json)))
          .toList();

      if (mounted) {
        setState(() {
          _recentCoaches = coaches.take(_maxHistoryItems).toList();
          _recentCourses = courses.take(_maxHistoryItems).toList();
        });
      }
    } catch (e) {
      print('Error loading recent items: $e');
    }
  }

  Future<void> _saveRecentCoach(VedaUserProfile coach) async {
    try {
      setState(() {
        // Remove if already exists
        _recentCoaches.removeWhere((c) => c.id == coach.id);
        // Add to front
        _recentCoaches.insert(0, coach);
        // Keep only last 3
        if (_recentCoaches.length > _maxHistoryItems) {
          _recentCoaches = _recentCoaches.take(_maxHistoryItems).toList();
        }
      });

      final prefs = await SharedPreferences.getInstance();
      final jsonList = _recentCoaches
          .map((c) => jsonEncode(c.toJson()))
          .toList();
      await prefs.setStringList(_recentCoachesKey, jsonList);
    } catch (e) {
      print('Error saving recent coach: $e');
    }
  }

  Future<void> _saveRecentCourse(Course course) async {
    try {
      setState(() {
        // Remove if already exists
        _recentCourses.removeWhere((c) => c.id == course.id);
        // Add to front
        _recentCourses.insert(0, course);
        // Keep only last 3
        if (_recentCourses.length > _maxHistoryItems) {
          _recentCourses = _recentCourses.take(_maxHistoryItems).toList();
        }
      });

      final prefs = await SharedPreferences.getInstance();
      final jsonList = _recentCourses
          .map((c) => jsonEncode(c.toJson()))
          .toList();
      await prefs.setStringList(_recentCoursesKey, jsonList);
    } catch (e) {
      print('Error saving recent course: $e');
    }
  }

  void _clearRecentCoaches() {
    setState(() {
      _recentCoaches.clear();
    });
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove(_recentCoachesKey);
    });
  }

  void _clearRecentCourses() {
    setState(() {
      _recentCourses.clear();
    });
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove(_recentCoursesKey);
    });
  }

  void _addToHistory(String query) {
    if (query.trim().isEmpty) return;

    setState(() {
      _searchHistory.remove(query);
      _searchHistory.insert(0, query);
      if (_searchHistory.length > _maxHistoryItems) {
        _searchHistory = _searchHistory.take(_maxHistoryItems).toList();
      }
    });

    _saveSearchHistory();
  }

  void _removeHistoryItem(int index) {
    setState(() {
      _searchHistory.removeAt(index);
    });
    _saveSearchHistory();
  }

  void _clearAllHistory() {
    setState(() {
      _searchHistory.clear();
    });
    _saveSearchHistory();
  }

  void _onCoachTap(VedaUserProfile coach) {
    _saveRecentCoach(coach);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CoachScreen(coach: coach),
      ),
    );
  }

  void _onCourseTap(Course course) {
    _saveRecentCourse(course);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CourseDetailScreen(course: course),
      ),
    );
  }

  void _onSearchChanged() {
    _searchTimer?.cancel();

    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      final query = _searchController.text.trim();
      if (query.isNotEmpty && query != _currentQuery) {
        _performSearch(query);
      } else if (query.isEmpty) {
        setState(() {
          _hasSearched = false;
          _creatorResults = [];
          _courseResults = [];
          _currentQuery = '';
        });
      }
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isSearching = true;
      _currentQuery = query;
    });

    try {
      print('🔍 Searching for: $query');

      final results = await Future.wait([
        client.vedaUserProfile.listCreators(username: query),
        client.lms.listCourses(keyword: query, visibility: CourseVisibility.public),
      ]);

      final creators = results[0] as List<VedaUserProfile>;
      final courses = results[1] as List<Course>;

      print('✅ Found ${creators.length} creators and ${courses.length} courses');

      if (mounted) {
        setState(() {
          _creatorResults = creators;
          _courseResults = courses;
          _isSearching = false;
          _hasSearched = true;
        });

        if (creators.isNotEmpty || courses.isNotEmpty) {
          _addToHistory(query);
        }
      }
    } catch (e) {
      print('❌ Search error: $e');
      if (mounted) {
        setState(() {
          _isSearching = false;
          _hasSearched = true;
        });
      }
    }
  }

  void _searchFromHistory(String query) {
    _searchController.text = query;
    _performSearch(query);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Top bar
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.arrow_back, color: VedaColors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'RETURN',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: VedaColors.white,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
                Text(
                  'SEARCH_MODE: ACTIVE',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: VedaColors.zinc500,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),

          // Search input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                border: Border.all(color: VedaColors.white, width: 2),
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Icon(Icons.search, color: VedaColors.white, size: 24),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _searchController,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: VedaColors.white,
                          letterSpacing: -0.3,
                        ),
                        decoration: InputDecoration(
                          hintText: 'NEURAL NET',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: VedaColors.zinc700,
                            letterSpacing: -0.3,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                      ),
                    ),
                  ),
                  if (_isSearching)
                    const Padding(
                      padding: EdgeInsets.only(right: 20),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(VedaColors.accent),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Filter tabs (only show when searching)
          if (_hasSearched) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: _FilterTab(
                      label: 'COURSES',
                      isActive: _activeFilter == SearchFilter.courses,
                      onTap: () => setState(() => _activeFilter = SearchFilter.courses),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _FilterTab(
                      label: 'COACHES',
                      isActive: _activeFilter == SearchFilter.coaches,
                      onTap: () => setState(() => _activeFilter = SearchFilter.coaches),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _FilterTab(
                      label: 'TOPICS',
                      isActive: _activeFilter == SearchFilter.topics,
                      onTap: () => setState(() => _activeFilter = SearchFilter.topics),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Show search history and recent items when not searching
                  if (!_hasSearched) ...[
                    // Search History
                    if (_searchHistory.isNotEmpty) ...[
                      _buildSectionHeader('SEARCH HISTORY', onClear: _clearAllHistory),
                      const SizedBox(height: 8),
                      Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: VedaColors.zinc800, width: 1),
                          ),
                        ),
                        child: Column(
                          children: _searchHistory.asMap().entries.map((entry) {
                            return _HistoryItem(
                              text: entry.value,
                              onTap: () => _searchFromHistory(entry.value),
                              onRemove: () => _removeHistoryItem(entry.key),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],

                    // Recent Coaches
                    if (_recentCoaches.isNotEmpty) ...[
                      _buildSectionHeader('RECENT COACHES', onClear: _clearRecentCoaches),
                      const SizedBox(height: 16),
                      ...List.generate(_recentCoaches.length, (index) {
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index < _recentCoaches.length - 1 ? 16 : 0,
                          ),
                          child: _CoachCard(
                            creator: _recentCoaches[index],
                            onTap: () => _onCoachTap(_recentCoaches[index]),
                          ),
                        );
                      }),
                      const SizedBox(height: 32),
                    ],

                    // Recent Courses
                    if (_recentCourses.isNotEmpty) ...[
                      _buildSectionHeader('RECENT COURSES', onClear: _clearRecentCourses),
                      const SizedBox(height: 16),
                      ...List.generate(_recentCourses.length, (index) {
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index < _recentCourses.length - 1 ? 16 : 0,
                          ),
                          child: _CourseCard(
                            course: _recentCourses[index],
                            onTap: () => _onCourseTap(_recentCourses[index]),
                          ),
                        );
                      }),
                      const SizedBox(height: 32),
                    ],
                  ],

                  // Search Results
                  if (_hasSearched && !_isSearching) ...[
                    // Show coaches
                    if (_activeFilter == SearchFilter.coaches) ...[
                      if (_creatorResults.isNotEmpty)
                        ...List.generate(_creatorResults.length, (index) {
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index < _creatorResults.length - 1 ? 16 : 0,
                            ),
                            child: _CoachCard(
                              creator: _creatorResults[index],
                              onTap: () => _onCoachTap(_creatorResults[index]),
                            ),
                          );
                        })
                      else
                        _buildNoResults(),
                    ],

                    // Show courses
                    if (_activeFilter == SearchFilter.courses) ...[
                      if (_courseResults.isNotEmpty)
                        ...List.generate(_courseResults.length, (index) {
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index < _courseResults.length - 1 ? 16 : 0,
                            ),
                            child: _CourseCard(
                              course: _courseResults[index],
                              onTap: () => _onCourseTap(_courseResults[index]),
                            ),
                          );
                        })
                      else
                        _buildNoResults(),
                    ],

                    // Topics (not implemented)
                    if (_activeFilter == SearchFilter.topics) _buildNoResults(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onClear}) {
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
        if (onClear != null)
          GestureDetector(
            onTap: onClear,
            child: Text(
              'CLEAR ALL',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: VedaColors.zinc700,
                letterSpacing: 1.0,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNoResults() {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.search_off, size: 64, color: VedaColors.zinc800),
            const SizedBox(height: 24),
            Text(
              'NO RESULTS FOUND',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: VedaColors.zinc600,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search term',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: VedaColors.zinc700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// FILTER TAB
// ---------------------------------------------------------------------------
class _FilterTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: isActive ? VedaColors.white : Colors.transparent,
          border: Border.all(
            color: isActive ? VedaColors.white : VedaColors.zinc700,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isActive ? VedaColors.black : VedaColors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// HISTORY ITEM
// ---------------------------------------------------------------------------
class _HistoryItem extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _HistoryItem({
    required this.text,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: VedaColors.zinc800, width: 1),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.history, color: VedaColors.zinc700, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: VedaColors.white,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            GestureDetector(
              onTap: onRemove,
              child: const Icon(Icons.close, color: VedaColors.zinc700, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// COACH CARD (Creator) - Matches design
// ---------------------------------------------------------------------------
class _CoachCard extends StatelessWidget {
  final VedaUserProfile creator;
  final VoidCallback? onTap;

  const _CoachCard({required this.creator, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CoachScreen(coach: creator),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: VedaColors.white, width: 1),
        ),
        child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Large square avatar (left side)
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: VedaColors.zinc800,
              border: Border(
                right: BorderSide(color: VedaColors.white, width: 1),
              ),
            ),
            child: creator.profileImageUrl != null
                ? Image.network(
                    creator.profileImageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.person,
                      color: VedaColors.zinc500,
                      size: 48,
                    ),
                  )
                : const Icon(
                    Icons.person,
                    color: VedaColors.zinc500,
                    size: 48,
                  ),
          ),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          creator.fullName?.toUpperCase() ?? 'UNNAMED',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: VedaColors.white,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          border: Border.all(color: VedaColors.white, width: 1),
                        ),
                        child: Text(
                          'EXPERT',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: VedaColors.white,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (creator.expertise != null && creator.expertise!.isNotEmpty)
                    Text(
                      'SPECIALIST: ${creator.expertise!.first.toUpperCase()}',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9,
                        fontWeight: FontWeight.w400,
                        color: VedaColors.zinc500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Rating
                      Row(
                        children: [
                          const Icon(Icons.star, color: VedaColors.white, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            '4.9',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: VedaColors.white,
                            ),
                          ),
                        ],
                      ),
                      // View profile button
                      Row(
                        children: [
                          Text(
                            'VIEW PROFILE',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: VedaColors.white,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward, color: VedaColors.white, size: 14),
                        ],
                      ),
                    ],
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

// ---------------------------------------------------------------------------
// COURSE CARD - Matches design
// ---------------------------------------------------------------------------
class _CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback? onTap;

  const _CourseCard({required this.course, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: VedaColors.white, width: 1),
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course image with badge and arrow
          Stack(
            children: [
              Container(
                height: 180,
                width: double.infinity,
                color: VedaColors.zinc800,
                child: course.courseImageUrl != null
                    ? Image.network(
                        course.courseImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Center(
                          child: Icon(
                            Icons.school_outlined,
                            color: VedaColors.zinc500,
                            size: 48,
                          ),
                        ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.school_outlined,
                          color: VedaColors.zinc500,
                          size: 48,
                        ),
                      ),
              ),
              // COURSE badge
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  color: VedaColors.white,
                  child: Text(
                    'COURSE',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: VedaColors.black,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
              // Arrow button
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: VedaColors.zinc700,
                    border: Border.all(color: VedaColors.white, width: 1),
                  ),
                  child: const Icon(Icons.arrow_forward, color: VedaColors.white, size: 16),
                ),
              ),
            ],
          ),
          // Course info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: VedaColors.white, width: 1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: VedaColors.white,
                    letterSpacing: -0.5,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                // Bottom row with creator info and module count
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Creator avatar placeholder
                    Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: VedaColors.zinc700,
                            border: Border.all(color: VedaColors.white, width: 1),
                          ),
                          child: const Icon(Icons.person, color: VedaColors.white, size: 12),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'DR. THORNE',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: VedaColors.zinc500,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    // Module count
                    Text(
                      '12',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: VedaColors.white,
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
    );
  }
}
