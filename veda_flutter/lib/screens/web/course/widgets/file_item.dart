import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../design_system/veda_colors.dart';
import '../models/course_models.dart';

class FileItem extends StatelessWidget {
  final KnowledgeFile file;
  final VoidCallback onRemove;

  const FileItem({
    super.key,
    required this.file,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: VedaColors.zinc800, width: 1),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.insert_drive_file_outlined,
            size: 16,
            color: VedaColors.zinc700,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: VedaColors.white,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  file.size,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9,
                    color: VedaColors.zinc700,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              child: const Icon(Icons.close, size: 14, color: VedaColors.zinc700),
            ),
          ),
        ],
      ),
    );
  }
}
