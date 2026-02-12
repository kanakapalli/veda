import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../design_system/veda_colors.dart';
import '../models/course_models.dart';
import 'file_item.dart';

class KnowledgeBasePanel extends StatelessWidget {
  final List<KnowledgeFile> files;
  final bool isUploadingFile;
  final VoidCallback onAddFile;
  final VoidCallback onCreateFile;
  final void Function(String id) onRemoveFile;

  const KnowledgeBasePanel({
    super.key,
    required this.files,
    this.isUploadingFile = false,
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
          _buildHeader(context),
          Expanded(child: _buildFilesList()),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: VedaColors.zinc800, width: 1),
        ),
      ),
      child: Row(
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: VedaColors.zinc900,
                  border: Border.all(color: VedaColors.zinc800, width: 1),
                ),
                child: const Icon(
                  Icons.arrow_back,
                  size: 18,
                  color: VedaColors.zinc500,
                ),
              ),
            ),
          ),
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
        if (isUploadingFile)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _UploadingShimmerItem(),
          ),
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

/// Shimmer placeholder shown while a file is being uploaded to S3
class _UploadingShimmerItem extends StatefulWidget {
  @override
  State<_UploadingShimmerItem> createState() => _UploadingShimmerItemState();
}

class _UploadingShimmerItemState extends State<_UploadingShimmerItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final opacity = _animation.value;
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: VedaColors.zinc800.withValues(alpha: opacity),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 1,
                  valueColor:
                      AlwaysStoppedAnimation(VedaColors.accent.withValues(alpha: opacity)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // File name shimmer bar
                    Container(
                      height: 10,
                      width: 120,
                      decoration: BoxDecoration(
                        color: VedaColors.zinc800.withValues(alpha: opacity * 0.6),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // "UPLOADING..." label
                    Text(
                      'UPLOADING...',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9,
                        color: VedaColors.zinc700.withValues(alpha: opacity),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
