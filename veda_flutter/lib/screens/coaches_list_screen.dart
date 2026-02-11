import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:veda_client/veda_client.dart';

import '../design_system/veda_colors.dart';
import '../main.dart';
import 'coach_screen.dart';

/// Screen that lists all coaches/creators fetched from the API.
class CoachesListScreen extends StatefulWidget {
  const CoachesListScreen({super.key});

  @override
  State<CoachesListScreen> createState() => _CoachesListScreenState();
}

class _CoachesListScreenState extends State<CoachesListScreen> {
  bool _isLoading = true;
  String? _error;
  List<VedaUserProfile> _coaches = [];

  @override
  void initState() {
    super.initState();
    _loadCoaches();
  }

  Future<void> _loadCoaches() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final coaches = await client.vedaUserProfile.listCreators();

      if (mounted) {
        setState(() {
          _coaches = coaches;
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

  void _openCoach(VedaUserProfile coach) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CoachScreen(coach: coach)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VedaColors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: VedaColors.white, width: 2),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(color: VedaColors.white, width: 2),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: VedaColors.white,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'EXPLORE_COACHES',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: VedaColors.white,
                letterSpacing: -1.0,
                height: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: VedaColors.white,
          strokeWidth: 1,
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
              onTap: _loadCoaches,
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
      );
    }

    if (_coaches.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(color: VedaColors.zinc700, width: 2),
              ),
              child: const Icon(
                Icons.person_search_outlined,
                color: VedaColors.zinc600,
                size: 36,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'NO_COACHES_FOUND',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: VedaColors.white,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCoaches,
      color: VedaColors.white,
      backgroundColor: VedaColors.zinc900,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        itemCount: _coaches.length,
        itemBuilder: (context, index) {
          final coach = _coaches[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _CoachListCard(
              coach: coach,
              onTap: () => _openCoach(coach),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// COACH LIST CARD
// ---------------------------------------------------------------------------
class _CoachListCard extends StatelessWidget {
  final VedaUserProfile coach;
  final VoidCallback onTap;

  const _CoachListCard({required this.coach, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = (coach.fullName ?? 'COACH').toUpperCase();
    final expertise = coach.expertise;
    final expertiseLabel = expertise != null && expertise.isNotEmpty
        ? expertise.take(3).join(' \u2022 ').toUpperCase()
        : 'CREATOR';
    final bio = coach.bio;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: VedaColors.white, width: 2),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: VedaColors.zinc800,
                border: Border(
                  right: BorderSide(color: VedaColors.white, width: 2),
                ),
              ),
              child: coach.profileImageUrl != null
                  ? Image.network(
                      coach.profileImageUrl!,
                      fit: BoxFit.cover,
                      color: Colors.white.withValues(alpha: 0.8),
                      colorBlendMode: BlendMode.saturation,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.person,
                            size: 36, color: VedaColors.zinc500),
                      ),
                    )
                  : const Center(
                      child: Icon(Icons.person,
                          size: 36, color: VedaColors.zinc500),
                    ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: VedaColors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      expertiseLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9,
                        color: VedaColors.zinc500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (bio != null && bio.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        bio,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: VedaColors.zinc500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // Arrow
            Container(
              width: 44,
              height: 88,
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(color: VedaColors.white, width: 2),
                ),
              ),
              child: const Icon(
                Icons.arrow_forward,
                size: 18,
                color: VedaColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
