import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../design_system/veda_colors.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomScrollView(
      slivers: [
        _LearnHeader(),
        SliverToBoxAdapter(child: _LearnBody()),
      ],
    );
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
// BODY
// ---------------------------------------------------------------------------
class _LearnBody extends StatelessWidget {
  const _LearnBody();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          // Current Session header
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
                'Last Sync: 2m ago',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 9,
                  color: VedaColors.zinc700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Current course card
          const _CurrentCourseCard(),
          const SizedBox(height: 40),

          // All Enrolled
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
          const _EnrolledCourseCard(
            title: 'NEURAL SYNC\nSTRATEGIES',
            coach: 'DR. ARIS',
            moduleProgress: '02 / 12',
            percentComplete: 68,
          ),
          const SizedBox(height: 12),
          const _EnrolledCourseCard(
            title: 'PROMPT ENGINEERING\nV2',
            coach: 'KAI.09',
            moduleProgress: '08 / 10',
            percentComplete: 85,
          ),
          const SizedBox(height: 12),
          const _EnrolledCourseCard(
            title: 'RECURSIVE LOGIC LAB',
            coach: 'LINA_X',
            moduleProgress: '01 / 06',
            percentComplete: 12,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// CURRENT COURSE CARD
// ---------------------------------------------------------------------------
class _CurrentCourseCard extends StatelessWidget {
  const _CurrentCourseCard();

  @override
  Widget build(BuildContext context) {
    return Container(
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
                // Placeholder background
                Positioned.fill(
                  child: Container(
                    color: VedaColors.zinc800,
                    child: Center(
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
                            'CONTINUE MODULE_04',
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
                        'STRUCTURAL\nINTEGRITY',
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: VedaColors.white,
                          letterSpacing: -1.0,
                          height: 0.95,
                        ),
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
    );
  }
}

// ---------------------------------------------------------------------------
// ENROLLED COURSE CARD
// ---------------------------------------------------------------------------
class _EnrolledCourseCard extends StatelessWidget {
  final String title;
  final String coach;
  final String moduleProgress;
  final int percentComplete;

  const _EnrolledCourseCard({
    required this.title,
    required this.coach,
    required this.moduleProgress,
    required this.percentComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: VedaColors.zinc700, width: 1),
      ),
      child: Column(
        children: [
          Row(
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
                child: const Icon(
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
                      'COACH: $coach',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9,
                        color: VedaColors.zinc500,
                        letterSpacing: 1.0,
                      ),
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
          const SizedBox(height: 16),
          // Progress row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MODULE $moduleProgress',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 9,
                  color: VedaColors.zinc500,
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                '$percentComplete% COMPLETE',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 9,
                  color: VedaColors.zinc500,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Progress bar
          Container(
            height: 4,
            width: double.infinity,
            color: VedaColors.zinc800,
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: percentComplete / 100,
                child: Container(color: VedaColors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
