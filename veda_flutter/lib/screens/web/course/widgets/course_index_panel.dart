import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../design_system/veda_colors.dart';
import '../models/course_models.dart';
import 'module_card.dart';
import 'tab_button.dart';

class CourseIndexPanel extends StatefulWidget {
  final String activeTab;
  final List<CourseModule> modules;
  final String courseTitle;
  final String? courseDescription;
  final String? courseStatus;
  final String? courseImageUrl;
  final String? bannerImageUrl;
  final String? videoUrl;
  final String? systemPrompt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<KnowledgeFile> knowledgeFiles;
  final bool isPublic;
  final void Function(String) onTabChanged;
  final void Function(String) onModuleToggle;
  final void Function(bool) onVisibilityChanged;
  final VoidCallback? onAddModule;
  final VoidCallback? onDeleteCourse;
  final VoidCallback? onGenerateIndex;
  final VoidCallback? onEditCourseImage;
  final VoidCallback? onEditBannerImage;
  final void Function(String)? onTitleChanged;
  final void Function(String)? onDescriptionChanged;
  final void Function(String)? onVideoUrlChanged;
  final void Function(String)? onSystemPromptChanged;
  final VoidCallback? onSaveSettings;

  const CourseIndexPanel({
    super.key,
    required this.activeTab,
    required this.modules,
    required this.courseTitle,
    this.courseDescription,
    this.courseStatus,
    this.courseImageUrl,
    this.bannerImageUrl,
    this.videoUrl,
    this.systemPrompt,
    this.createdAt,
    this.updatedAt,
    this.knowledgeFiles = const [],
    required this.isPublic,
    required this.onTabChanged,
    required this.onModuleToggle,
    required this.onVisibilityChanged,
    this.onAddModule,
    this.onDeleteCourse,
    this.onGenerateIndex,
    this.onEditCourseImage,
    this.onEditBannerImage,
    this.onTitleChanged,
    this.onDescriptionChanged,
    this.onVideoUrlChanged,
    this.onSystemPromptChanged,
    this.onSaveSettings,
  });

  @override
  State<CourseIndexPanel> createState() => _CourseIndexPanelState();
}

class _CourseIndexPanelState extends State<CourseIndexPanel> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _videoUrlController;
  late final TextEditingController _systemPromptController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.courseTitle);
    _descriptionController =
        TextEditingController(text: widget.courseDescription ?? '');
    _videoUrlController = TextEditingController(text: widget.videoUrl ?? '');
    _systemPromptController =
        TextEditingController(text: widget.systemPrompt ?? '');
  }

  @override
  void didUpdateWidget(covariant CourseIndexPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update controllers when external value changes AND differs from
    // the current controller text. This handles external updates (e.g. AI
    // changing the title) without fighting user edits.
    if (widget.courseTitle != oldWidget.courseTitle &&
        widget.courseTitle != _titleController.text) {
      _titleController.text = widget.courseTitle;
    }
    if (widget.courseDescription != oldWidget.courseDescription &&
        (widget.courseDescription ?? '') != _descriptionController.text) {
      _descriptionController.text = widget.courseDescription ?? '';
    }
    if (widget.videoUrl != oldWidget.videoUrl &&
        (widget.videoUrl ?? '') != _videoUrlController.text) {
      _videoUrlController.text = widget.videoUrl ?? '';
    }
    if (widget.systemPrompt != oldWidget.systemPrompt &&
        (widget.systemPrompt ?? '') != _systemPromptController.text) {
      _systemPromptController.text = widget.systemPrompt ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _videoUrlController.dispose();
    _systemPromptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: VedaColors.black,
      child: Column(
        children: [
          _buildTabs(),
          Expanded(
            child: widget.activeTab == 'index'
                ? _buildIndexContent()
                : _buildSettingsContent(context),
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
          isActive: widget.activeTab == 'index',
          onTap: () => widget.onTabChanged('index'),
        ),
        Container(width: 1, height: 48, color: VedaColors.zinc800),
        TabButton(
          label: 'SETTINGS',
          isActive: widget.activeTab == 'settings',
          onTap: () => widget.onTabChanged('settings'),
        ),
      ],
    );
  }

  Widget _buildIndexContent() {
    final totalLessons =
        widget.modules.fold(0, (sum, m) => sum + m.lessons.length);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Course image with title overlay
        _buildCourseHeader(),
        const SizedBox(height: 16),
        // Generate Index button
        _buildGenerateIndexButton(),
        const SizedBox(height: 16),
        // Stats
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: VedaColors.zinc800, width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${widget.modules.length} MODULES',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    color: VedaColors.zinc500,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(width: 1, height: 16, color: VedaColors.zinc800),
              Expanded(
                child: Text(
                  '$totalLessons LESSONS',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    color: VedaColors.zinc500,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Modules
        ...widget.modules.map((module) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ModuleCard(
                module: module,
                onToggle: () => widget.onModuleToggle(module.id),
              ),
            )),
        // Add module button
        InkWell(
          onTap: widget.onAddModule,
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

  Widget _buildCourseHeader() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: VedaColors.zinc800, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course image area
          InkWell(
            onTap: widget.onEditCourseImage,
            child: Container(
              height: 120,
              width: double.infinity,
              color: VedaColors.zinc900,
              child: widget.courseImageUrl != null &&
                      widget.courseImageUrl!.isNotEmpty
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          widget.courseImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildImagePlaceholder(),
                        ),
                        // Edit overlay on hover
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: VedaColors.black.withValues(alpha: 0.7),
                              border: Border.all(
                                color: VedaColors.zinc700,
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.edit_outlined,
                              size: 14,
                              color: VedaColors.white,
                            ),
                          ),
                        ),
                      ],
                    )
                  : _buildImagePlaceholder(),
            ),
          ),
          // Title and status
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status badge
                if (widget.courseStatus != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: widget.courseStatus == 'DRAFT'
                            ? VedaColors.zinc700
                            : widget.courseStatus == 'PUBLIC'
                                ? VedaColors.accent
                                : VedaColors.zinc700,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      widget.courseStatus!,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9,
                        fontWeight: FontWeight.w400,
                        color: widget.courseStatus == 'DRAFT'
                            ? VedaColors.zinc500
                            : widget.courseStatus == 'PUBLIC'
                                ? VedaColors.accent
                                : VedaColors.zinc500,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                // Course title
                Text(
                  widget.courseTitle.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: VedaColors.white,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 12),
                // Visibility toggle
                _buildVisibilityToggle(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: VedaColors.zinc800, width: 1),
            ),
            child: const Icon(
              Icons.add_photo_alternate_outlined,
              size: 24,
              color: VedaColors.zinc700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ADD IMAGE',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: VedaColors.zinc700,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateIndexButton() {
    return InkWell(
      onTap: widget.onGenerateIndex,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          border: Border.all(color: VedaColors.accent, width: 1),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.auto_awesome_outlined,
                size: 16,
                color: VedaColors.accent,
              ),
              const SizedBox(width: 8),
              Text(
                'GENERATE INDEX',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: VedaColors.accent,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
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
            widget.isPublic ? Icons.public_outlined : Icons.lock_outline,
            size: 16,
            color: VedaColors.zinc500,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.isPublic ? 'PUBLIC' : 'PRIVATE',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: VedaColors.zinc500,
                letterSpacing: 1.0,
              ),
            ),
          ),
          InkWell(
            onTap: () => widget.onVisibilityChanged(!widget.isPublic),
            child: Container(
              width: 40,
              height: 20,
              decoration: BoxDecoration(
                border: Border.all(color: VedaColors.zinc800, width: 1),
              ),
              padding: const EdgeInsets.all(2),
              child: Align(
                alignment: widget.isPublic
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  width: 16,
                  height: 16,
                  color:
                      widget.isPublic ? VedaColors.white : VedaColors.zinc700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsContent(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Course Title
        _buildSettingsLabel('COURSE TITLE'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _titleController,
          hint: 'Enter course title',
          onChanged: widget.onTitleChanged,
        ),
        const SizedBox(height: 24),

        // Course Description
        _buildSettingsLabel('DESCRIPTION'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _descriptionController,
          hint: 'Enter course description',
          maxLines: 3,
          onChanged: widget.onDescriptionChanged,
        ),
        const SizedBox(height: 24),

        // System Prompt (AI Instructions)
        _buildSettingsLabel('SYSTEM PROMPT'),
        const SizedBox(height: 4),
        Text(
          'Instructions for AI course generation',
          style: GoogleFonts.inter(
            fontSize: 10,
            color: VedaColors.zinc700,
          ),
        ),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _systemPromptController,
          hint: 'e.g., Topic: Web Development, Focus on practical examples...',
          maxLines: 4,
          onChanged: widget.onSystemPromptChanged,
        ),
        const SizedBox(height: 24),

        // Course Image
        _buildSettingsLabel('COURSE IMAGE'),
        const SizedBox(height: 8),
        _buildImageField(
          imageUrl: widget.courseImageUrl,
          onTap: widget.onEditCourseImage,
          placeholder: 'Thumbnail image',
        ),
        const SizedBox(height: 24),

        // Banner Image
        _buildSettingsLabel('BANNER IMAGE'),
        const SizedBox(height: 8),
        _buildImageField(
          imageUrl: widget.bannerImageUrl,
          onTap: widget.onEditBannerImage,
          placeholder: 'Banner image',
        ),
        const SizedBox(height: 24),

        // Video URL
        _buildSettingsLabel('VIDEO URL'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _videoUrlController,
          hint: 'https://...',
          onChanged: widget.onVideoUrlChanged,
        ),
        const SizedBox(height: 24),

        // Visibility
        _buildSettingsLabel('VISIBILITY'),
        const SizedBox(height: 8),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: VedaColors.zinc800, width: 1),
          ),
          child: DropdownButton<String>(
            value: widget.isPublic ? 'Public' : 'Private',
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
            ],
            onChanged: (value) {
              if (value != null) {
                widget.onVisibilityChanged(value == 'Public');
              }
            },
          ),
        ),
        const SizedBox(height: 24),

        // Knowledge Files Overview
        _buildSettingsLabel('KNOWLEDGE FILES'),
        const SizedBox(height: 8),
        _buildKnowledgeFilesOverview(),
        const SizedBox(height: 24),

        // Timestamps (read-only)
        _buildSettingsLabel('TIMESTAMPS'),
        const SizedBox(height: 8),
        _buildTimestampsInfo(),

        const SizedBox(height: 32),
        // Update button
        _UpdateButton(onTap: widget.onSaveSettings),
        const SizedBox(height: 24),
        Container(height: 1, color: VedaColors.zinc800),
        const SizedBox(height: 16),
        InkWell(
          onTap: widget.onDeleteCourse,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'DELETE COURSE',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: VedaColors.error,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKnowledgeFilesOverview() {
    if (widget.knowledgeFiles.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: VedaColors.zinc800, width: 1),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.folder_outlined,
              size: 16,
              color: VedaColors.zinc700,
            ),
            const SizedBox(width: 8),
            Text(
              'No files uploaded yet',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: VedaColors.zinc700,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: VedaColors.zinc800, width: 1),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: VedaColors.zinc800, width: 1),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.folder_outlined,
                  size: 14,
                  color: VedaColors.zinc500,
                ),
                const SizedBox(width: 8),
                Text(
                  '${widget.knowledgeFiles.length} FILE${widget.knowledgeFiles.length == 1 ? '' : 'S'}',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    color: VedaColors.zinc500,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
          // File list
          ...widget.knowledgeFiles.take(5).map((file) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: VedaColors.zinc900, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getFileIcon(file.type),
                      size: 14,
                      color: VedaColors.zinc600,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        file.name,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: VedaColors.zinc500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      file.size,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9,
                        color: VedaColors.zinc700,
                      ),
                    ),
                  ],
                ),
              )),
          if (widget.knowledgeFiles.length > 5)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                '+${widget.knowledgeFiles.length - 5} more files',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: VedaColors.zinc600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf_outlined;
      case 'docx':
      case 'doc':
        return Icons.description_outlined;
      case 'txt':
        return Icons.text_snippet_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  Widget _buildTimestampsInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: VedaColors.zinc800, width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: VedaColors.zinc600,
              ),
              const SizedBox(width: 8),
              Text(
                'CREATED',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 9,
                  color: VedaColors.zinc600,
                  letterSpacing: 1.0,
                ),
              ),
              const Spacer(),
              Text(
                widget.createdAt != null
                    ? _formatDateTime(widget.createdAt!)
                    : '-',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: VedaColors.zinc500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.update_outlined,
                size: 14,
                color: VedaColors.zinc600,
              ),
              const SizedBox(width: 8),
              Text(
                'UPDATED',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 9,
                  color: VedaColors.zinc600,
                  letterSpacing: 1.0,
                ),
              ),
              const Spacer(),
              Text(
                widget.updatedAt != null
                    ? _formatDateTime(widget.updatedAt!)
                    : '-',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: VedaColors.zinc500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} at $hour:$minute $amPm';
  }

  Widget _buildSettingsLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.jetBrainsMono(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        color: VedaColors.zinc700,
        letterSpacing: 2.0,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    void Function(String)? onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: VedaColors.zinc800, width: 1),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: GoogleFonts.inter(
          fontSize: 12,
          color: VedaColors.white,
          letterSpacing: 0.2,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: GoogleFonts.inter(
            fontSize: 12,
            color: VedaColors.zinc700,
            letterSpacing: 0.2,
          ),
          contentPadding: EdgeInsets.symmetric(
            vertical: maxLines > 1 ? 12 : 8,
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildImageField({
    String? imageUrl,
    VoidCallback? onTap,
    required String placeholder,
  }) {
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return InkWell(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          border: Border.all(color: VedaColors.zinc800, width: 1),
        ),
        child: hasImage
            ? Row(
                children: [
                  // Image preview
                  SizedBox(
                    width: 80,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: VedaColors.zinc900,
                        child: const Icon(
                          Icons.broken_image_outlined,
                          color: VedaColors.zinc700,
                        ),
                      ),
                    ),
                  ),
                  Container(width: 1, color: VedaColors.zinc800),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Image uploaded',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: VedaColors.zinc500,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.edit_outlined,
                            size: 16,
                            color: VedaColors.zinc700,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 20,
                      color: VedaColors.zinc700,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      placeholder,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: VedaColors.zinc700,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _UpdateButton extends StatefulWidget {
  final VoidCallback? onTap;

  const _UpdateButton({this.onTap});

  @override
  State<_UpdateButton> createState() => _UpdateButtonState();
}

class _UpdateButtonState extends State<_UpdateButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 48,
          decoration: BoxDecoration(
            color: _isHovered ? VedaColors.accent : Colors.transparent,
            border: Border.all(
              color: VedaColors.accent,
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              'UPDATE COURSE',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: _isHovered ? VedaColors.white : VedaColors.accent,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
