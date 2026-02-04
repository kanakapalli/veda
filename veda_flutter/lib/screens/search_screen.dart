import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../design_system/veda_colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final List<String> _searchHistory = [
    'NEURAL NETWORK OPTIMIZATION',
    'RAG ARCHITECTURE BASICS',
    'DR. ARIS RECURSIVE LOGIC',
  ];

  final List<String> _trendingTopics = [
    '#RAG_SYSTEMS',
    '#VECTOR_EMBEDDINGS',
    '#AI_ETHICS',
    '#PYTHON_API',
    '#DEEP_LEARNING',
  ];

  final List<_SuggestedMentor> _suggestions = [
    _SuggestedMentor(
      name: 'DR. ARIS',
      specialty: 'RECURSIVE LOGIC',
      matchPercent: 98,
    ),
    _SuggestedMentor(
      name: 'LINA_X',
      specialty: 'SYSTEM INTEGRITY',
      matchPercent: 94,
    ),
    _SuggestedMentor(
      name: 'KAI.09',
      specialty: 'DATA SECURITY',
      matchPercent: 89,
    ),
  ];

  void _removeHistoryItem(int index) {
    setState(() {
      _searchHistory.removeAt(index);
    });
  }

  void _clearAllHistory() {
    setState(() {
      _searchHistory.clear();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                    const Icon(
                      Icons.arrow_back,
                      color: VedaColors.white,
                      size: 18,
                    ),
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
          // Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search input
                  Container(
                    height: 64,
                    decoration: BoxDecoration(
                      border: Border.all(color: VedaColors.white, width: 2),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: TextField(
                              controller: _searchController,
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: VedaColors.white,
                                letterSpacing: -0.3,
                              ),
                              decoration: InputDecoration(
                                hintText: 'SEARCH DATABASE...',
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
                        Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: Icon(
                            Icons.search,
                            color: VedaColors.zinc500,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

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
                            onRemove: () => _removeHistoryItem(entry.key),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Advanced Filters
                  _buildSectionLabel('ADVANCED FILTERS'),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 44,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: const [
                        _FilterChip(label: 'DURATION'),
                        SizedBox(width: 12),
                        _FilterChip(label: 'EXPERTISE LEVEL'),
                        SizedBox(width: 12),
                        _FilterChip(label: 'FORMAT'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Trending Topics
                  _buildSectionLabel('TRENDING TOPICS'),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _trendingTopics.map((topic) {
                      return _TopicTag(label: topic);
                    }).toList(),
                  ),
                  const SizedBox(height: 32),

                  // Suggested for You
                  _buildSectionHeader(
                    'SUGGESTED FOR YOU',
                    subtitle: 'BASED ON RECENT ACTIVITY',
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(_suggestions.length, (index) {
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index < _suggestions.length - 1 ? 12 : 0,
                      ),
                      child: _SuggestionCard(mentor: _suggestions[index]),
                    );
                  }),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String title) {
    return Text(
      title,
      style: GoogleFonts.jetBrainsMono(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        color: VedaColors.zinc500,
        letterSpacing: 3.0,
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onClear, String? subtitle}) {
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
        if (subtitle != null)
          Text(
            subtitle,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 9,
              fontWeight: FontWeight.w400,
              color: VedaColors.zinc700,
              letterSpacing: 1.0,
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// HISTORY ITEM
// ---------------------------------------------------------------------------
class _HistoryItem extends StatelessWidget {
  final String text;
  final VoidCallback onRemove;

  const _HistoryItem({required this.text, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: VedaColors.zinc800, width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.history,
            color: VedaColors.zinc700,
            size: 18,
          ),
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
            child: Icon(
              Icons.close,
              color: VedaColors.zinc700,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// FILTER CHIP
// ---------------------------------------------------------------------------
class _FilterChip extends StatelessWidget {
  final String label;

  const _FilterChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: VedaColors.zinc700, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: VedaColors.white,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.keyboard_arrow_down,
            color: VedaColors.white,
            size: 16,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TOPIC TAG
// ---------------------------------------------------------------------------
class _TopicTag extends StatelessWidget {
  final String label;

  const _TopicTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: VedaColors.zinc700, width: 1),
      ),
      child: Text(
        label,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: VedaColors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SUGGESTION CARD
// ---------------------------------------------------------------------------
class _SuggestedMentor {
  final String name;
  final String specialty;
  final int matchPercent;

  const _SuggestedMentor({
    required this.name,
    required this.specialty,
    required this.matchPercent,
  });
}

class _SuggestionCard extends StatelessWidget {
  final _SuggestedMentor mentor;

  const _SuggestionCard({required this.mentor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: VedaColors.zinc700, width: 1),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: VedaColors.zinc800,
              border: Border.all(color: VedaColors.zinc700, width: 1),
            ),
            child: const Icon(
              Icons.person,
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
                  mentor.name,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: VedaColors.white,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${mentor.specialty} \u2022 ${mentor.matchPercent}% MATCH',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    color: VedaColors.zinc500,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          // Arrow
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              border: Border.all(color: VedaColors.zinc700, width: 1),
            ),
            child: const Icon(
              Icons.arrow_forward,
              color: VedaColors.white,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}
