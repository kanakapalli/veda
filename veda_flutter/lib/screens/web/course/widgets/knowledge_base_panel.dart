import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../design_system/veda_colors.dart';
import '../models/course_models.dart';
import 'file_item.dart';

class KnowledgeBasePanel extends StatelessWidget {
  final List<KnowledgeFile> files;
  final VoidCallback onAddFile;
  final VoidCallback onCreateFile;
  final void Function(String id) onRemoveFile;

  const KnowledgeBasePanel({
    super.key,
    required this.files,
    required this.onAddFile,
    required this.onCreateFile,
    required this.onRemoveFile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: VedaColors.black,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildFilesList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: VedaColors.zinc800, width: 1),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.folder_outlined, size: 20, color: VedaColors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'KNOWLEDGE BASE',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: VedaColors.white,
                letterSpacing: 1.5,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: VedaColors.white, width: 1),
            ),
            child: Text(
              '${files.length}',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: VedaColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilesList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildUploadArea(),
        const SizedBox(height: 24),
        Text(
          'UPLOADED',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: VedaColors.zinc700,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 12),
        ...files.map((file) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: FileItem(
                file: file,
                onRemove: () => onRemoveFile(file.id),
              ),
            )),
      ],
    );
  }

  Widget _buildUploadArea() {
    return Column(
      children: [
        // Upload Files Button
        InkWell(
          onTap: onAddFile,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border.all(color: VedaColors.zinc800, width: 1),
            ),
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    border: Border.all(color: VedaColors.zinc800, width: 1),
                  ),
                  child: const Icon(
                    Icons.upload_file_outlined,
                    size: 20,
                    color: VedaColors.zinc700,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'UPLOAD FILES',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: VedaColors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'PDF, DOCX, TXT',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    color: VedaColors.zinc700,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Create File with AI Button
        InkWell(
          onTap: onCreateFile,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: VedaColors.accent, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.auto_awesome_outlined,
                  size: 16,
                  color: VedaColors.accent,
                ),
                const SizedBox(width: 8),
                Text(
                  'CREATE FILE WITH AI',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: VedaColors.accent,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
