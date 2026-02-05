import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../design_system/veda_colors.dart';
import '../models/course_models.dart';
import 'file_item.dart';

class KnowledgeBasePanel extends StatelessWidget {
  final List<KnowledgeFile> files;
  final VoidCallback onAddFile;
  final void Function(String id) onRemoveFile;
  final double storageUsedPercent;

  const KnowledgeBasePanel({
    super.key,
    required this.files,
    required this.onAddFile,
    required this.onRemoveFile,
    this.storageUsedPercent = 0.45,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: VedaColors.black,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildFilesList()),
          _buildStorageMeter(),
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
    return InkWell(
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
    );
  }

  Widget _buildStorageMeter() {
    final percent = (storageUsedPercent * 100).toInt();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: VedaColors.zinc800, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'STORAGE',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  color: VedaColors.zinc700,
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                '$percent%',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  color: VedaColors.zinc500,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 4,
            decoration: BoxDecoration(
              border: Border.all(color: VedaColors.zinc800, width: 1),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: storageUsedPercent,
                child: Container(color: VedaColors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
