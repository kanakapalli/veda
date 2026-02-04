import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../design_system/veda_colors.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomScrollView(
      slivers: [
        _DashboardHeader(),
        SliverToBoxAdapter(child: _DashboardBody()),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// HEADER (pinned)
// ---------------------------------------------------------------------------
class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();

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
                            'VEDA OS // V.1',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              color: VedaColors.zinc500,
                              letterSpacing: 2.0,
                            ),
                          ),
                          const SizedBox(height: 4),
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
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      border: Border.all(color: VedaColors.white, width: 2),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
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
// BODY
// ---------------------------------------------------------------------------
class _DashboardBody extends StatelessWidget {
  const _DashboardBody();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          // Continue Learning
          _buildSectionHeader('CONTINUE LEARNING', trailing: _liveBadge()),
          const SizedBox(height: 16),
          const _ContinueLearningCard(),
          const SizedBox(height: 40),

          // Mentor Sessions
          _buildSectionHeader('MENTOR SESSIONS',
              trailing: _navArrows()),
          const SizedBox(height: 16),
          const _MentorSessionsList(),
          const SizedBox(height: 40),

          // Explore by Topic
          _buildSectionHeader('EXPLORE BY TOPIC'),
          const SizedBox(height: 16),
          const _TopicGrid(),
          const SizedBox(height: 40),

          // Popular Coaches
          _buildSectionHeader('POPULAR COACHES'),
          const SizedBox(height: 16),
          const _CoachesList(),
          const SizedBox(height: 40),

          // New Arrivals
          _buildSectionHeader('NEW ARRIVALS'),
          const SizedBox(height: 16),
          const _NewArrivalsList(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

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
        ?trailing,
      ],
    );
  }

  static Widget _liveBadge() {
    return Text(
      '/// LIVE CONNECTION',
      style: GoogleFonts.jetBrainsMono(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF22C55E),
        letterSpacing: 0.5,
      ),
    );
  }

  static Widget _navArrows() {
    return Row(
      children: const [
        Icon(Icons.chevron_left, size: 16, color: VedaColors.white),
        SizedBox(width: 4),
        Icon(Icons.chevron_right, size: 16, color: VedaColors.white),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// CONTINUE LEARNING CARD
// ---------------------------------------------------------------------------
class _ContinueLearningCard extends StatelessWidget {
  const _ContinueLearningCard();

  @override
  Widget build(BuildContext context) {
    return Container(
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
                // Placeholder image
                Positioned.fill(
                  child: Container(
                    color: VedaColors.zinc800,
                    child: Center(
                      child: Icon(
                        Icons.auto_stories,
                        size: 64,
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
                          VedaColors.black.withValues(alpha: 0.9),
                        ],
                      ),
                    ),
                  ),
                ),
                // Module label + title
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        color: VedaColors.white,
                        child: Text(
                          'MODULE 04',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: VedaColors.black,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'STRUCTURAL INTEGRITY\nIN RAG SYSTEMS',
                        style: GoogleFonts.inter(
                          fontSize: 20,
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
                      'PROGRESS: 72%',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        color: VedaColors.zinc500,
                        letterSpacing: 1.0,
                      ),
                    ),
                    Text(
                      '12M REMAINING',
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
                      widthFactor: 0.72,
                      child: Container(color: VedaColors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Resume button
                Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    color: VedaColors.white,
                    border: Border.all(color: Colors.transparent, width: 2),
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
    );
  }
}

// ---------------------------------------------------------------------------
// MENTOR SESSIONS
// ---------------------------------------------------------------------------
class _MentorSessionsList extends StatelessWidget {
  const _MentorSessionsList();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: const [
          _MentorCard(
            time: '14:00',
            status: 'LIVE',
            isLive: true,
            title: 'NEURAL SYNC STRATEGIES',
            mentor: 'Dr. Aris',
            duration: '45m',
            buttonLabel: 'JOIN ROOM',
          ),
          SizedBox(width: 16),
          _MentorCard(
            time: '16:30',
            status: 'SCHED',
            isLive: false,
            title: 'PROMPT ENGINEERING V2',
            mentor: 'Kai.09',
            duration: '60m',
            buttonLabel: 'REMIND ME',
          ),
          SizedBox(width: 16),
          _MentorCard(
            time: '19:00',
            status: 'SCHED',
            isLive: false,
            title: 'RECURSIVE LOGIC LAB',
            mentor: 'Lina_X',
            duration: '30m',
            buttonLabel: 'REMIND ME',
          ),
        ],
      ),
    );
  }
}

class _MentorCard extends StatelessWidget {
  final String time;
  final String status;
  final bool isLive;
  final String title;
  final String mentor;
  final String duration;
  final String buttonLabel;

  const _MentorCard({
    required this.time,
    required this.status,
    required this.isLive,
    required this.title,
    required this.mentor,
    required this.duration,
    required this.buttonLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: VedaColors.white, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Time + status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isLive ? VedaColors.white : VedaColors.zinc700,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  time,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isLive ? VedaColors.white : VedaColors.zinc500,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                color: VedaColors.zinc800,
                child: Text(
                  status,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9,
                    fontWeight: FontWeight.w400,
                    color: isLive ? VedaColors.white : VedaColors.zinc500,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          // Title + mentor
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: VedaColors.white,
                  letterSpacing: 0.2,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$mentor \u2022 $duration'.toUpperCase(),
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  color: VedaColors.zinc500,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          // Action button
          Container(
            width: double.infinity,
            height: 32,
            decoration: BoxDecoration(
              border: Border.all(
                color: isLive ? VedaColors.white : VedaColors.zinc700,
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                buttonLabel,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: isLive ? VedaColors.white : VedaColors.zinc500,
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

// ---------------------------------------------------------------------------
// EXPLORE BY TOPIC
// ---------------------------------------------------------------------------
class _TopicGrid extends StatelessWidget {
  const _TopicGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        _TopicCard(
          icon: Icons.psychology_outlined,
          title: 'PSYCH',
          subtitle: 'Human Behavior',
          isInverted: false,
        ),
        _TopicCard(
          icon: Icons.architecture,
          title: 'ARCH',
          subtitle: 'System Design',
          isInverted: true,
        ),
        _TopicCard(
          icon: Icons.smart_toy_outlined,
          title: 'AI STRAT',
          subtitle: 'Future Logic',
          isInverted: false,
        ),
        _TopicCard(
          icon: Icons.terminal,
          title: 'CODE',
          subtitle: 'Implementation',
          isInverted: false,
        ),
      ],
    );
  }
}

class _TopicCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isInverted;

  const _TopicCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isInverted,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isInverted ? VedaColors.white : VedaColors.black;
    final fg = isInverted ? VedaColors.black : VedaColors.white;

    return Container(
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
              if (isInverted)
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
    );
  }
}

// ---------------------------------------------------------------------------
// POPULAR COACHES
// ---------------------------------------------------------------------------
class _CoachesList extends StatelessWidget {
  const _CoachesList();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: const [
          _CoachAvatar(name: 'DR. ARIS', icon: Icons.person),
          SizedBox(width: 24),
          _CoachAvatar(name: 'KAI.09', icon: Icons.person),
          SizedBox(width: 24),
          _CoachAvatar(name: 'LINA_X', icon: Icons.person),
          SizedBox(width: 24),
          _CoachAvatar(name: 'VEX', icon: Icons.person),
          SizedBox(width: 24),
          _CoachAddMore(),
        ],
      ),
    );
  }
}

class _CoachAvatar extends StatelessWidget {
  final String name;
  final IconData icon;

  const _CoachAvatar({required this.name, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: VedaColors.white, width: 2),
          ),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: VedaColors.zinc800,
            ),
            child: Icon(icon, color: VedaColors.zinc500, size: 24),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: VedaColors.white,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _CoachAddMore extends StatelessWidget {
  const _CoachAddMore();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: VedaColors.zinc700, width: 2),
          ),
          child: const Icon(Icons.add, color: VedaColors.zinc500, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          'VIEW ALL',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: VedaColors.zinc500,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// NEW ARRIVALS
// ---------------------------------------------------------------------------
class _NewArrivalsList extends StatelessWidget {
  const _NewArrivalsList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _ArrivalCard(
          title: 'NON-LINEAR SYSTEMS',
          subtitle: 'ADDED TODAY \u2022 8 MODULES',
          icon: Icons.auto_stories,
          isLocked: false,
        ),
        SizedBox(height: 16),
        _ArrivalCard(
          title: 'ETHICS IN AUTOMATION',
          subtitle: 'YESTERDAY \u2022 12 MODULES',
          icon: Icons.balance,
          isLocked: false,
        ),
        SizedBox(height: 16),
        _ArrivalCard(
          title: 'ADVANCED ALGORITHMS',
          subtitle: 'COMING SOON',
          icon: Icons.lock_outline,
          isLocked: true,
        ),
      ],
    );
  }
}

class _ArrivalCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isLocked;

  const _ArrivalCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isLocked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            child: Center(
              child: Icon(
                icon,
                size: 28,
                color: isLocked ? VedaColors.zinc500 : VedaColors.zinc500,
              ),
            ),
          ),
          // Content
          Expanded(
            child: Opacity(
              opacity: isLocked ? 0.6 : 1.0,
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
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: VedaColors.white,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 9,
                              color: VedaColors.zinc500,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isLocked)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: VedaColors.zinc700, width: 1),
                        ),
                        child: Text(
                          'LOCKED',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 8,
                            color: VedaColors.zinc500,
                            letterSpacing: 0.5,
                          ),
                        ),
                      )
                    else
                      const Icon(
                        Icons.arrow_forward,
                        size: 18,
                        color: VedaColors.white,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
