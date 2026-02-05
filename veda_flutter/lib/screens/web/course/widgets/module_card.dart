import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../design_system/veda_colors.dart';
import '../models/course_models.dart';

class ModuleCard extends StatelessWidget {
  final CourseModule module;
  final VoidCallback onToggle;
  final VoidCallback? onAddLesson;
  final void Function(Lesson)? onLessonTap;

  const ModuleCard({
    super.key,
    required this.module,
    required this.onToggle,
    this.onAddLesson,
    this.onLessonTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: VedaColors.zinc800, width: 1),
      ),
      child: Column(
        children: [
          // Module header
          InkWell(
            onTap: onToggle,
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    module.expanded ? Icons.remove : Icons.add,
                    size: 14,
                    color: VedaColors.zinc700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      module.title.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: VedaColors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      border: Border.all(color: VedaColors.zinc800, width: 1),
                    ),
                    child: Text(
                      '${module.lessons.length}',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9,
                        color: VedaColors.zinc500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Lessons (if expanded)
          if (module.expanded) ...[
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: VedaColors.zinc800, width: 1),
                ),
              ),
              child: Column(
                children: [
                  ...module.lessons.map((lesson) => _LessonItem(
                        lesson: lesson,
                        onTap: () => onLessonTap?.call(lesson),
                      )),
                  // Add lesson button
                  InkWell(
                    onTap: onAddLesson,
                    child: Container(
                      height: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 36),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.add,
                            size: 12,
                            color: VedaColors.zinc700,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'ADD LESSON',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              color: VedaColors.zinc700,
                              letterSpacing: 1.0,
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
        ],
      ),
    );
  }
}

class _LessonItem extends StatelessWidget {
  final Lesson lesson;
  final VoidCallback? onTap;

  const _LessonItem({required this.lesson, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: VedaColors.zinc900, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.drag_indicator,
              size: 12,
              color: VedaColors.zinc800,
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.article_outlined,
              size: 12,
              color: VedaColors.zinc700,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                lesson.title,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: VedaColors.white,
                  letterSpacing: 0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              lesson.duration,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 9,
                color: VedaColors.zinc700,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
