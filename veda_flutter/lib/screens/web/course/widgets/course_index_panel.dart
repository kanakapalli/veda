import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../design_system/veda_colors.dart';
import '../models/course_models.dart';
import 'module_card.dart';
import 'tab_button.dart';

class CourseIndexPanel extends StatelessWidget {
  final String activeTab;
  final List<CourseModule> modules;
  final String courseTitle;
  final bool isPublic;
  final void Function(String) onTabChanged;
  final void Function(String) onModuleToggle;
  final void Function(bool) onVisibilityChanged;
  final VoidCallback? onAddModule;
  final VoidCallback? onDeleteCourse;

  const CourseIndexPanel({
    super.key,
    required this.activeTab,
    required this.modules,
    required this.courseTitle,
    required this.isPublic,
    required this.onTabChanged,
    required this.onModuleToggle,
    required this.onVisibilityChanged,
    this.onAddModule,
    this.onDeleteCourse,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: VedaColors.black,
      child: Column(
        children: [
          _buildTabs(),
          Expanded(
            child: activeTab == 'index'
                ? _buildIndexContent()
                : _buildSettingsContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      children: [
        TabButton(
          label: 'INDEX',
          isActive: activeTab == 'index',
          onTap: () => onTabChanged('index'),
        ),
        Container(width: 1, height: 48, color: VedaColors.zinc800),
        TabButton(
          label: 'SETTINGS',
          isActive: activeTab == 'settings',
          onTap: () => onTabChanged('settings'),
        ),
      ],
    );
  }

  Widget _buildIndexContent() {
    final totalLessons = modules.fold(0, (sum, m) => sum + m.lessons.length);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Course title block
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: VedaColors.zinc800, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      courseTitle.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: VedaColors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.more_horiz,
                    size: 16,
                    color: VedaColors.zinc700,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Public/Private toggle
              _buildVisibilityToggle(),
              const SizedBox(height: 12),
              Text(
                '${modules.length} MODULES • $totalLessons LESSONS',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  color: VedaColors.zinc700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Modules
        ...modules.map((module) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ModuleCard(
                module: module,
                onToggle: () => onModuleToggle(module.id),
              ),
            )),
        // Add module button
        InkWell(
          onTap: onAddModule,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(color: VedaColors.zinc800, width: 1),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add, size: 16, color: VedaColors.zinc700),
                  const SizedBox(width: 8),
                  Text(
                    'NEW MODULE',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: VedaColors.zinc700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVisibilityToggle() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: VedaColors.zinc800, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            isPublic ? Icons.public_outlined : Icons.lock_outline,
            size: 16,
            color: VedaColors.zinc500,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isPublic ? 'PUBLIC' : 'PRIVATE',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: VedaColors.zinc500,
                letterSpacing: 1.0,
              ),
            ),
          ),
          InkWell(
            onTap: () => onVisibilityChanged(!isPublic),
            child: Container(
              width: 40,
              height: 20,
              decoration: BoxDecoration(
                border: Border.all(color: VedaColors.zinc800, width: 1),
              ),
              padding: const EdgeInsets.all(2),
              child: Align(
                alignment:
                    isPublic ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 16,
                  height: 16,
                  color: isPublic ? VedaColors.white : VedaColors.zinc700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsContent() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'VISIBILITY',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: VedaColors.zinc700,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: VedaColors.zinc800, width: 1),
          ),
          child: DropdownButton<String>(
            value: isPublic ? 'Public' : 'Private',
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: VedaColors.black,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: VedaColors.white,
              letterSpacing: 0.2,
            ),
            items: const [
              DropdownMenuItem(value: 'Private', child: Text('Private')),
              DropdownMenuItem(value: 'Public', child: Text('Public')),
              DropdownMenuItem(
                value: 'Organization',
                child: Text('Organization Only'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                onVisibilityChanged(value == 'Public');
              }
            },
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'LANGUAGE',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: VedaColors.zinc700,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: VedaColors.zinc800, width: 1),
          ),
          child: DropdownButton<String>(
            value: 'English',
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: VedaColors.black,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: VedaColors.white,
              letterSpacing: 0.2,
            ),
            items: const [
              DropdownMenuItem(value: 'English', child: Text('English (US)')),
              DropdownMenuItem(value: 'Spanish', child: Text('Spanish')),
              DropdownMenuItem(value: 'French', child: Text('French')),
            ],
            onChanged: (_) {},
          ),
        ),
        const SizedBox(height: 32),
        Container(height: 1, color: VedaColors.zinc800),
        const SizedBox(height: 16),
        InkWell(
          onTap: onDeleteCourse,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'DELETE COURSE',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: VedaColors.zinc700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
