import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:veda_client/veda_client.dart' as veda;

import '../../../../design_system/veda_colors.dart';
import '../../../../services/upload_service.dart';
import '../models/course_models.dart';
import 'tab_button.dart';

class CourseTocPanel extends StatefulWidget {
  final String activeTab;
  final List<veda.Module> serverModules;
  final Set<int> expandedModuleIds;
  final bool isGeneratingToc;
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
  final void Function(String) onTopicToggle;
  final void Function(bool) onVisibilityChanged;
  final VoidCallback? onAddModule;
  final VoidCallback? onDeleteCourse;
  final VoidCallback? onGenerateToc;
  final VoidCallback? onEditCourseImage;
  final VoidCallback? onEditBannerImage;
  final void Function(String)? onTitleChanged;
  final void Function(String)? onDescriptionChanged;
  final void Function(String)? onVideoUrlChanged;
  final void Function(String)? onSystemPromptChanged;
  final VoidCallback? onSaveSettings;
  final Future<void> Function(veda.Module)? onUpdateModule;
  final Future<void> Function(veda.Topic)? onUpdateTopic;

  const CourseTocPanel({
    super.key,
    required this.activeTab,
    required this.serverModules,
    required this.expandedModuleIds,
    this.isGeneratingToc = false,
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
    required this.onTopicToggle,
    required this.onVisibilityChanged,
    this.onAddModule,
    this.onDeleteCourse,
    this.onGenerateToc,
    this.onEditCourseImage,
    this.onEditBannerImage,
    this.onTitleChanged,
    this.onDescriptionChanged,
    this.onVideoUrlChanged,
    this.onSystemPromptChanged,
    this.onSaveSettings,
    this.onUpdateModule,
    this.onUpdateTopic,
  });

  @override
  State<CourseTocPanel> createState() => _CourseTocPanelState();
}

class _CourseTocPanelState extends State<CourseTocPanel> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _videoUrlController;
  late final TextEditingController _systemPromptController;

  // Detail view state
  veda.Module? _selectedModuleForDetail;

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
  void didUpdateWidget(covariant CourseTocPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
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
            child: widget.activeTab == 'toc'
                ? _buildTocContent()
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
          label: 'TOC',
          isActive: widget.activeTab == 'toc',
          onTap: () => widget.onTabChanged('toc'),
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

  // ---------------------------------------------------------------------------
  // TOC TAB - Timeline-style table of contents
  // ---------------------------------------------------------------------------

  Widget _buildTocContent() {
    // Show detail view if a module is selected
    if (_selectedModuleForDetail != null) {
      return _buildModuleDetailView(_selectedModuleForDetail!);
    }

    // Show TOC list
    final totalTopics = widget.serverModules.fold(
      0,
      (sum, m) => sum + (m.items?.length ?? 0),
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Course header with image
        _buildCourseHeader(),
        const SizedBox(height: 16),

        // Generate Index button
        _buildGenerateTocButton(),
        const SizedBox(height: 16),

        // Stats bar
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: VedaColors.zinc800, width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${widget.serverModules.length} MODULES',
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
                  '$totalTopics TOPICS',
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
        const SizedBox(height: 24),

        // Syllabus header
        if (widget.serverModules.isNotEmpty) ...[
          Row(
            children: [
              Container(width: 2, height: 16, color: VedaColors.white),
              const SizedBox(width: 12),
              Text(
                'TABLE_OF_CONTENTS',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: VedaColors.white,
                  letterSpacing: 2.0,
                ),
              ),
              const Spacer(),
              Text(
                '${widget.serverModules.length} PARTS',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 9,
                  color: VedaColors.zinc700,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Timeline modules
          _buildTimeline(),
        ],

        // Empty state
        if (widget.serverModules.isEmpty && !widget.isGeneratingToc)
          _buildEmptyState(),
      ],
    );
  }

  Widget _buildTimeline() {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Column(
        children: List.generate(widget.serverModules.length, (index) {
          final module = widget.serverModules[index];
          final isExpanded = widget.expandedModuleIds.contains(module.id);
          final isLast = index == widget.serverModules.length - 1;
          final moduleNumber =
              (index + 1).toString().padLeft(2, '0');
          final topics = module.items ?? [];

          // Debug: Print topics info
          print('Module ${module.title}: topics count = ${topics.length}, isExpanded = $isExpanded');
          if (topics.isNotEmpty) {
            print('  First topic: ${topics.first.topic?.title ?? "null"}');
          }

          return _TimelineModuleItem(
            moduleNumber: moduleNumber,
            module: module,
            topics: topics,
            isExpanded: isExpanded,
            isLast: isLast,
            onToggle: () => widget.onModuleToggle(module.id?.toString() ?? ''),
            onViewMore: () {
              setState(() => _selectedModuleForDetail = module);
            },
          );
        }),
      ),
    );
  }

  Widget _buildModuleDetailView(veda.Module module) {
    return _ModuleDetailView(
      module: module,
      onBack: () {
        setState(() => _selectedModuleForDetail = null);
      },
      onUpdateModule: widget.onUpdateModule,
      onUpdateTopic: widget.onUpdateTopic,
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              border: Border.all(color: VedaColors.zinc800, width: 1),
            ),
            child: const Icon(
              Icons.menu_book_outlined,
              size: 24,
              color: VedaColors.zinc700,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'NO TOC GENERATED',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: VedaColors.zinc700,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload knowledge files and generate\na table of contents for your course',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: VedaColors.zinc700,
            ),
          ),
        ],
      ),
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.courseStatus != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: widget.courseStatus == 'PUBLIC'
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
                        color: widget.courseStatus == 'PUBLIC'
                            ? VedaColors.accent
                            : VedaColors.zinc500,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
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

  Widget _buildGenerateTocButton() {
    return InkWell(
      onTap: widget.isGeneratingToc ? null : widget.onGenerateToc,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          border: Border.all(
            color: widget.isGeneratingToc
                ? VedaColors.zinc700
                : VedaColors.accent,
            width: 1,
          ),
        ),
        child: Center(
          child: widget.isGeneratingToc
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 1,
                        valueColor:
                            AlwaysStoppedAnimation(VedaColors.accent),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'GENERATING...',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: VedaColors.zinc500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.auto_awesome_outlined,
                      size: 16,
                      color: VedaColors.accent,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.serverModules.isEmpty
                          ? 'GENERATE TOC'
                          : 'REGENERATE TOC',
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

  // ---------------------------------------------------------------------------
  // SETTINGS TAB (unchanged)
  // ---------------------------------------------------------------------------

  Widget _buildSettingsContent(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildSettingsLabel('COURSE TITLE'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _titleController,
          hint: 'Enter course title',
          onChanged: widget.onTitleChanged,
        ),
        const SizedBox(height: 24),
        _buildSettingsLabel('DESCRIPTION'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _descriptionController,
          hint: 'Enter course description',
          maxLines: 3,
          onChanged: widget.onDescriptionChanged,
        ),
        const SizedBox(height: 24),
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
        _buildSettingsLabel('COURSE IMAGE'),
        const SizedBox(height: 8),
        _buildImageField(
          imageUrl: widget.courseImageUrl,
          onTap: widget.onEditCourseImage,
          placeholder: 'Thumbnail image',
        ),
        const SizedBox(height: 24),
        _buildSettingsLabel('BANNER IMAGE'),
        const SizedBox(height: 8),
        _buildImageField(
          imageUrl: widget.bannerImageUrl,
          onTap: widget.onEditBannerImage,
          placeholder: 'Banner image',
        ),
        const SizedBox(height: 24),
        _buildSettingsLabel('VIDEO URL'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _videoUrlController,
          hint: 'https://...',
          onChanged: widget.onVideoUrlChanged,
        ),
        const SizedBox(height: 24),
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
        _buildSettingsLabel('KNOWLEDGE FILES'),
        const SizedBox(height: 8),
        _buildKnowledgeFilesOverview(),
        const SizedBox(height: 24),
        _buildSettingsLabel('TIMESTAMPS'),
        const SizedBox(height: 8),
        _buildTimestampsInfo(),
        const SizedBox(height: 32),
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
            const Icon(Icons.folder_outlined, size: 16, color: VedaColors.zinc700),
            const SizedBox(width: 8),
            Text(
              'No files uploaded yet',
              style: GoogleFonts.inter(fontSize: 12, color: VedaColors.zinc700),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: VedaColors.zinc800, width: 1),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.folder_outlined, size: 14, color: VedaColors.zinc500),
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
          ...widget.knowledgeFiles.take(5).map((file) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: VedaColors.zinc900, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(_getFileIcon(file.type), size: 14, color: VedaColors.zinc600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        file.name,
                        style: GoogleFonts.inter(fontSize: 11, color: VedaColors.zinc500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      file.size,
                      style: GoogleFonts.jetBrainsMono(fontSize: 9, color: VedaColors.zinc700),
                    ),
                  ],
                ),
              )),
          if (widget.knowledgeFiles.length > 5)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                '+${widget.knowledgeFiles.length - 5} more files',
                style: GoogleFonts.inter(fontSize: 10, color: VedaColors.zinc600),
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
              const Icon(Icons.calendar_today_outlined, size: 14, color: VedaColors.zinc600),
              const SizedBox(width: 8),
              Text('CREATED', style: GoogleFonts.jetBrainsMono(fontSize: 9, color: VedaColors.zinc600, letterSpacing: 1.0)),
              const Spacer(),
              Text(
                widget.createdAt != null ? _formatDateTime(widget.createdAt!) : '-',
                style: GoogleFonts.inter(fontSize: 11, color: VedaColors.zinc500),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.update_outlined, size: 14, color: VedaColors.zinc600),
              const SizedBox(width: 8),
              Text('UPDATED', style: GoogleFonts.jetBrainsMono(fontSize: 9, color: VedaColors.zinc600, letterSpacing: 1.0)),
              const Spacer(),
              Text(
                widget.updatedAt != null ? _formatDateTime(widget.updatedAt!) : '-',
                style: GoogleFonts.inter(fontSize: 11, color: VedaColors.zinc500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
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
        style: GoogleFonts.inter(fontSize: 12, color: VedaColors.white, letterSpacing: 0.2),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: GoogleFonts.inter(fontSize: 12, color: VedaColors.zinc700, letterSpacing: 0.2),
          contentPadding: EdgeInsets.symmetric(vertical: maxLines > 1 ? 12 : 8),
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
                  SizedBox(
                    width: 80,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: VedaColors.zinc900,
                        child: const Icon(Icons.broken_image_outlined, color: VedaColors.zinc700),
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
                            child: Text('Image uploaded', style: GoogleFonts.inter(fontSize: 12, color: VedaColors.zinc500)),
                          ),
                          const Icon(Icons.edit_outlined, size: 16, color: VedaColors.zinc700),
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
                    const Icon(Icons.add_photo_alternate_outlined, size: 20, color: VedaColors.zinc700),
                    const SizedBox(width: 8),
                    Text(placeholder, style: GoogleFonts.inter(fontSize: 12, color: VedaColors.zinc700)),
                  ],
                ),
              ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TIMELINE MODULE ITEM - Single module in the timeline
// ---------------------------------------------------------------------------

class _TimelineModuleItem extends StatefulWidget {
  final String moduleNumber;
  final veda.Module module;
  final List<veda.ModuleItem> topics;
  final bool isExpanded;
  final bool isLast;
  final VoidCallback onToggle;
  final VoidCallback onViewMore;

  const _TimelineModuleItem({
    required this.moduleNumber,
    required this.module,
    required this.topics,
    required this.isExpanded,
    required this.isLast,
    required this.onToggle,
    required this.onViewMore,
  });

  @override
  State<_TimelineModuleItem> createState() => _TimelineModuleItemState();
}

class _TimelineModuleItemState extends State<_TimelineModuleItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onToggle,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline column (number + line)
            Column(
              children: [
                // Module number box
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: widget.isExpanded
                        ? VedaColors.white
                        : VedaColors.black,
                    border: Border.all(
                      color: _isHovered || widget.isExpanded
                          ? VedaColors.white
                          : VedaColors.zinc700,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      widget.moduleNumber,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: widget.isExpanded
                            ? VedaColors.black
                            : VedaColors.white,
                      ),
                    ),
                  ),
                ),
                // Vertical line
                if (!widget.isLast)
                  Container(
                    width: 1,
                    height: 24,
                    color: VedaColors.zinc800,
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // Module content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    decoration: BoxDecoration(
                      color: widget.isExpanded
                          ? VedaColors.white
                          : _isHovered
                              ? VedaColors.zinc900
                              : Colors.transparent,
                      border: Border.all(
                        color: widget.isExpanded
                            ? VedaColors.white
                            : _isHovered
                                ? VedaColors.zinc700
                                : VedaColors.zinc800,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Module header
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Tag line
                              Text(
                                '${ widget.moduleNumber} : ${widget.module.description != null && widget.module.description!.length > 20 ? widget.module.description!.substring(0, 20).toUpperCase() : (widget.module.description ?? "MODULE").toUpperCase()}',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w400,
                                  color: widget.isExpanded
                                      ? VedaColors.black.withValues(alpha: 0.5)
                                      : VedaColors.zinc600,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Module title
                              Text(
                                widget.module.title.toUpperCase(),
                                style: GoogleFonts.inter(
                                  fontSize: widget.isExpanded ? 16 : 13,
                                  fontWeight: widget.isExpanded
                                      ? FontWeight.w500
                                      : FontWeight.w400,
                                  color: widget.isExpanded
                                      ? VedaColors.black
                                      : VedaColors.white,
                                  letterSpacing: -0.3,
                                  height: 1.2,
                                ),
                              ),
                              // Module description (when expanded)
                              if (widget.isExpanded &&
                                  widget.module.description != null &&
                                  widget.module.description!.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Text(
                                  widget.module.description!,
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w300,
                                    color: VedaColors.black.withValues(alpha: 0.6),
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        // Expanded content
                        if (widget.isExpanded) ...[
                          // Topics list (only if topics exist)
                          if (widget.topics.isNotEmpty) ...[
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border(
                                  left: BorderSide(
                                    color: VedaColors.black.withValues(alpha: 0.2),
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: widget.topics
                                    .map((item) => Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 8),
                                          child: Text(
                                            '> ${item.topic?.title ?? item.contextualDescription ?? 'Topic'}',
                                            style: GoogleFonts.jetBrainsMono(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w400,
                                              color: VedaColors.black
                                                  .withValues(alpha: 0.7),
                                              letterSpacing: 0.3,
                                              height: 1.5,
                                            ),
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                              child: Text(
                                '${widget.topics.length} TOPICS',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 9,
                                  color: VedaColors.black.withValues(alpha: 0.5),
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                          ],

                          // Empty state for no topics
                          if (widget.topics.isEmpty)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                              child: Text(
                                'NO TOPICS IN THIS MODULE',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 9,
                                  color: VedaColors.black.withValues(alpha: 0.4),
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),

                          // Action buttons (always shown when expanded)
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // View More button
                                Expanded(
                                  child: InkWell(
                                    onTap: widget.onViewMore,
                                    child: Container(
                                      height: 48,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: VedaColors.black
                                              .withValues(alpha: 0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.info_outline,
                                            size: 16,
                                            color: VedaColors.black
                                                .withValues(alpha: 0.7),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'VIEW MORE',
                                            style: GoogleFonts.inter(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w400,
                                              color: VedaColors.black
                                                  .withValues(alpha: 0.7),
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Learn button
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      // TODO: Navigate to module learning view
                                    },
                                    child: Container(
                                      height: 48,
                                      decoration: const BoxDecoration(
                                        color: VedaColors.black,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.play_arrow,
                                            size: 20,
                                            color: VedaColors.white,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'LEARN',
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                              color: VedaColors.white,
                                              letterSpacing: 0.8,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        // Collapsed indicator
                        if (!widget.isExpanded && widget.topics.isNotEmpty)
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(16, 0, 16, 12),
                            child: Row(
                              children: [
                                Text(
                                  '${widget.topics.length} TOPICS',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 9,
                                    color: VedaColors.zinc600,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 16,
                                  color: _isHovered
                                      ? VedaColors.white
                                      : VedaColors.zinc700,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

}

// ---------------------------------------------------------------------------
// UPDATE BUTTON
// ---------------------------------------------------------------------------

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
            border: Border.all(color: VedaColors.accent, width: 1),
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

// ---------------------------------------------------------------------------
// MODULE DETAIL VIEW - Detailed editing view for a single module
// ---------------------------------------------------------------------------

class _ModuleDetailView extends StatefulWidget {
  final veda.Module module;
  final VoidCallback onBack;
  final Future<void> Function(veda.Module)? onUpdateModule;
  final Future<void> Function(veda.Topic)? onUpdateTopic;

  const _ModuleDetailView({
    required this.module,
    required this.onBack,
    this.onUpdateModule,
    this.onUpdateTopic,
  });

  @override
  State<_ModuleDetailView> createState() => _ModuleDetailViewState();
}

class _ModuleDetailViewState extends State<_ModuleDetailView> {
  // Module controllers
  late final TextEditingController _moduleDescController;
  late final TextEditingController _moduleImageController;
  late final TextEditingController _moduleBannerController;
  late final TextEditingController _moduleVideoController;

  // Topic controllers (map of topicId -> controllers)
  final Map<int, TextEditingController> _topicDescControllers = {};
  final Map<int, TextEditingController> _topicImageControllers = {};
  final Map<int, TextEditingController> _topicBannerControllers = {};
  final Map<int, TextEditingController> _topicVideoControllers = {};

  // Loading states
  bool _isSavingModule = false;
  final Map<int, bool> _isSavingTopic = {};

  // Upload states for module
  bool _isUploadingModuleImage = false;
  bool _isUploadingModuleBanner = false;
  bool _isUploadingModuleVideo = false;

  // Upload states for topics (map of topicId -> upload states)
  final Map<int, bool> _isUploadingTopicImage = {};
  final Map<int, bool> _isUploadingTopicBanner = {};
  final Map<int, bool> _isUploadingTopicVideo = {};

  // Expanded topics
  final Set<int> _expandedTopicIds = {};

  @override
  void initState() {
    super.initState();

    // Initialize module controllers
    _moduleDescController =
        TextEditingController(text: widget.module.description ?? '');
    _moduleImageController =
        TextEditingController(text: widget.module.imageUrl ?? '');
    _moduleBannerController =
        TextEditingController(text: widget.module.bannerImageUrl ?? '');
    _moduleVideoController =
        TextEditingController(text: widget.module.videoUrl ?? '');

    // Initialize topic controllers
    for (final item in widget.module.items ?? []) {
      final topic = item.topic;
      if (topic != null && topic.id != null) {
        final topicId = topic.id!;
        _topicDescControllers[topicId] =
            TextEditingController(text: topic.description ?? '');
        _topicImageControllers[topicId] =
            TextEditingController(text: topic.imageUrl ?? '');
        _topicBannerControllers[topicId] =
            TextEditingController(text: topic.bannerImageUrl ?? '');
        _topicVideoControllers[topicId] =
            TextEditingController(text: topic.videoUrl ?? '');
        _isSavingTopic[topicId] = false;
      }
    }
  }

  @override
  void dispose() {
    _moduleDescController.dispose();
    _moduleImageController.dispose();
    _moduleBannerController.dispose();
    _moduleVideoController.dispose();

    for (final controller in _topicDescControllers.values) {
      controller.dispose();
    }
    for (final controller in _topicImageControllers.values) {
      controller.dispose();
    }
    for (final controller in _topicBannerControllers.values) {
      controller.dispose();
    }
    for (final controller in _topicVideoControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  Future<void> _saveModule() async {
    if (widget.onUpdateModule == null) return;

    setState(() => _isSavingModule = true);

    try {
      final updatedModule = widget.module.copyWith(
        description: _moduleDescController.text.isEmpty
            ? null
            : _moduleDescController.text,
        imageUrl:
            _moduleImageController.text.isEmpty ? null : _moduleImageController.text,
        bannerImageUrl: _moduleBannerController.text.isEmpty
            ? null
            : _moduleBannerController.text,
        videoUrl:
            _moduleVideoController.text.isEmpty ? null : _moduleVideoController.text,
      );

      await widget.onUpdateModule!(updatedModule);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Module updated successfully',
              style: GoogleFonts.inter(fontSize: 12, color: VedaColors.white),
            ),
            backgroundColor: VedaColors.black,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update module: $e',
              style: GoogleFonts.inter(fontSize: 12, color: VedaColors.white),
            ),
            backgroundColor: VedaColors.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSavingModule = false);
      }
    }
  }

  Future<void> _saveTopic(veda.Topic topic) async {
    if (widget.onUpdateTopic == null || topic.id == null) return;

    final topicId = topic.id!;
    setState(() => _isSavingTopic[topicId] = true);

    try {
      final updatedTopic = topic.copyWith(
        description: _topicDescControllers[topicId]!.text.isEmpty
            ? null
            : _topicDescControllers[topicId]!.text,
        imageUrl: _topicImageControllers[topicId]!.text.isEmpty
            ? null
            : _topicImageControllers[topicId]!.text,
        bannerImageUrl: _topicBannerControllers[topicId]!.text.isEmpty
            ? null
            : _topicBannerControllers[topicId]!.text,
        videoUrl: _topicVideoControllers[topicId]!.text.isEmpty
            ? null
            : _topicVideoControllers[topicId]!.text,
      );

      await widget.onUpdateTopic!(updatedTopic);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Topic updated successfully',
              style: GoogleFonts.inter(fontSize: 12, color: VedaColors.white),
            ),
            backgroundColor: VedaColors.black,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update topic: $e',
              style: GoogleFonts.inter(fontSize: 12, color: VedaColors.white),
            ),
            backgroundColor: VedaColors.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSavingTopic[topicId] = false);
      }
    }
  }

  // Upload methods for module media
  Future<void> _uploadModuleImage() async {
    if (widget.module.id == null || widget.module.courseId == null) return;

    setState(() => _isUploadingModuleImage = true);

    try {
      final result = await UploadService.instance.pickAndUploadModuleImage(
        widget.module.courseId,
        widget.module.id!,
      );

      if (result != null && result.success && result.publicUrl != null) {
        _moduleImageController.text = result.publicUrl!;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Image uploaded successfully',
                style: GoogleFonts.inter(fontSize: 12, color: VedaColors.white),
              ),
              backgroundColor: VedaColors.black,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Upload failed: $e',
              style: GoogleFonts.inter(fontSize: 12, color: VedaColors.white),
            ),
            backgroundColor: VedaColors.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingModuleImage = false);
      }
    }
  }

  Future<void> _uploadModuleBanner() async {
    if (widget.module.id == null || widget.module.courseId == null) return;

    setState(() => _isUploadingModuleBanner = true);

    try {
      final result = await UploadService.instance.pickAndUploadModuleBanner(
        widget.module.courseId,
        widget.module.id!,
      );

      if (result != null && result.success && result.publicUrl != null) {
        _moduleBannerController.text = result.publicUrl!;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Banner uploaded successfully',
                style: GoogleFonts.inter(fontSize: 12, color: VedaColors.white),
              ),
              backgroundColor: VedaColors.black,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Upload failed: $e',
              style: GoogleFonts.inter(fontSize: 12, color: VedaColors.white),
            ),
            backgroundColor: VedaColors.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingModuleBanner = false);
      }
    }
  }

  Future<void> _uploadModuleVideo() async {
    if (widget.module.id == null || widget.module.courseId == null) return;

    setState(() => _isUploadingModuleVideo = true);

    try {
      final result = await UploadService.instance.pickAndUploadModuleVideo(
        widget.module.courseId,
        widget.module.id!,
      );

      if (result != null && result.success && result.publicUrl != null) {
        _moduleVideoController.text = result.publicUrl!;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Video uploaded successfully',
                style: GoogleFonts.inter(fontSize: 12, color: VedaColors.white),
              ),
              backgroundColor: VedaColors.black,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Upload failed: $e',
              style: GoogleFonts.inter(fontSize: 12, color: VedaColors.white),
            ),
            backgroundColor: VedaColors.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingModuleVideo = false);
      }
    }
  }

  // Upload methods for topic media
  Future<void> _uploadTopicImage(int topicId) async {
    setState(() => _isUploadingTopicImage[topicId] = true);

    try {
      final result = await UploadService.instance.pickAndUploadTopicImage(topicId);

      if (result != null && result.success && result.publicUrl != null) {
        _topicImageControllers[topicId]!.text = result.publicUrl!;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Image uploaded successfully',
                style: GoogleFonts.inter(fontSize: 12, color: VedaColors.white),
              ),
              backgroundColor: VedaColors.black,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Upload failed: $e',
              style: GoogleFonts.inter(fontSize: 12, color: VedaColors.white),
            ),
            backgroundColor: VedaColors.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingTopicImage[topicId] = false);
      }
    }
  }

  Future<void> _uploadTopicBanner(int topicId) async {
    setState(() => _isUploadingTopicBanner[topicId] = true);

    try {
      final result = await UploadService.instance.pickAndUploadTopicBanner(topicId);

      if (result != null && result.success && result.publicUrl != null) {
        _topicBannerControllers[topicId]!.text = result.publicUrl!;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Banner uploaded successfully',
                style: GoogleFonts.inter(fontSize: 12, color: VedaColors.white),
              ),
              backgroundColor: VedaColors.black,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Upload failed: $e',
              style: GoogleFonts.inter(fontSize: 12, color: VedaColors.white),
            ),
            backgroundColor: VedaColors.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingTopicBanner[topicId] = false);
      }
    }
  }

  Future<void> _uploadTopicVideo(int topicId) async {
    setState(() => _isUploadingTopicVideo[topicId] = true);

    try {
      final result = await UploadService.instance.pickAndUploadTopicVideo(topicId);

      if (result != null && result.success && result.publicUrl != null) {
        _topicVideoControllers[topicId]!.text = result.publicUrl!;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Video uploaded successfully',
                style: GoogleFonts.inter(fontSize: 12, color: VedaColors.white),
              ),
              backgroundColor: VedaColors.black,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Upload failed: $e',
              style: GoogleFonts.inter(fontSize: 12, color: VedaColors.white),
            ),
            backgroundColor: VedaColors.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingTopicVideo[topicId] = false);
      }
    }
  }

  // Handle reorder for topics
  void _onReorderTopics(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final items = List<veda.ModuleItem>.from(widget.module.items!);
      final item = items.removeAt(oldIndex);
      items.insert(newIndex, item);

      // Update sortOrder for all items
      for (int i = 0; i < items.length; i++) {
        items[i] = items[i].copyWith(sortOrder: i);
      }

      widget.module.items = items;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Topics reordered. Save module to persist changes.',
          style: GoogleFonts.inter(fontSize: 12, color: VedaColors.white),
        ),
        backgroundColor: VedaColors.zinc800,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Back button
        InkWell(
          onTap: widget.onBack,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: VedaColors.zinc800, width: 1),
            ),
            child: Row(
              children: [
                const Icon(Icons.arrow_back, size: 16, color: VedaColors.white),
                const SizedBox(width: 12),
                Text(
                  'BACK TO TOC',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: VedaColors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Module header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: VedaColors.zinc800, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MODULE DETAILS',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: VedaColors.zinc500,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.module.title.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: VedaColors.white,
                  letterSpacing: 0.2,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Module editing section
        Text(
          'MODULE INFORMATION',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: VedaColors.zinc700,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 12),

        _buildEditField(
          label: 'DESCRIPTION',
          controller: _moduleDescController,
          maxLines: 4,
          hint: 'Enter module description...',
        ),
        const SizedBox(height: 16),

        _buildEditField(
          label: 'IMAGE URL',
          controller: _moduleImageController,
          hint: 'https://...',
          onUpload: _uploadModuleImage,
          isUploading: _isUploadingModuleImage,
        ),
        const SizedBox(height: 16),

        _buildEditField(
          label: 'BANNER IMAGE URL',
          controller: _moduleBannerController,
          hint: 'https://...',
          onUpload: _uploadModuleBanner,
          isUploading: _isUploadingModuleBanner,
        ),
        const SizedBox(height: 16),

        _buildEditField(
          label: 'VIDEO URL',
          controller: _moduleVideoController,
          hint: 'https://...',
          onUpload: _uploadModuleVideo,
          isUploading: _isUploadingModuleVideo,
        ),
        const SizedBox(height: 20),

        // Save module button
        InkWell(
          onTap: _isSavingModule ? null : _saveModule,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: _isSavingModule
                  ? VedaColors.zinc800
                  : VedaColors.accent,
              border: Border.all(
                color: _isSavingModule
                    ? VedaColors.zinc700
                    : VedaColors.accent,
                width: 1,
              ),
            ),
            child: Center(
              child: _isSavingModule
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        valueColor: AlwaysStoppedAnimation(VedaColors.white),
                      ),
                    )
                  : Text(
                      'SAVE MODULE',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: VedaColors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Topics section
        if (widget.module.items != null && widget.module.items!.isNotEmpty) ...[
          Container(height: 1, color: VedaColors.zinc800),
          const SizedBox(height: 24),

          Row(
            children: [
              Container(width: 2, height: 16, color: VedaColors.white),
              const SizedBox(width: 12),
              Text(
                'TOPICS (${widget.module.items!.length})',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: VedaColors.white,
                  letterSpacing: 2.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Topics list (timeline style with drag-to-reorder)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.module.items!.length,
              onReorder: _onReorderTopics,
              proxyDecorator: (child, index, animation) {
                return Material(
                  color: Colors.transparent,
                  child: child,
                );
              },
              itemBuilder: (context, index) {
                final item = widget.module.items![index];
                final topic = item.topic;

                if (topic == null || topic.id == null) {
                  return const SizedBox.shrink(key: ValueKey('empty'));
                }

                final topicId = topic.id!;
                final isExpanded = _expandedTopicIds.contains(topicId);
                final isSaving = _isSavingTopic[topicId] ?? false;
                final isLast = index == widget.module.items!.length - 1;
                final topicNumber = (index + 1).toString().padLeft(2, '0');

                return _TopicTimelineItem(
                  key: ValueKey('topic-$topicId'),
                  topicNumber: topicNumber,
                  topic: topic,
                  item: item,
                  isExpanded: isExpanded,
                  isLast: isLast,
                  isSaving: isSaving,
                  descController: _topicDescControllers[topicId]!,
                  imageController: _topicImageControllers[topicId]!,
                  bannerController: _topicBannerControllers[topicId]!,
                  videoController: _topicVideoControllers[topicId]!,
                  onToggle: () {
                    setState(() {
                      if (isExpanded) {
                        _expandedTopicIds.remove(topicId);
                      } else {
                        _expandedTopicIds.add(topicId);
                      }
                    });
                  },
                  onSave: () => _saveTopic(topic),
                  onUploadImage: () => _uploadTopicImage(topicId),
                  onUploadBanner: () => _uploadTopicBanner(topicId),
                  onUploadVideo: () => _uploadTopicVideo(topicId),
                  isUploadingImage: _isUploadingTopicImage[topicId] ?? false,
                  isUploadingBanner: _isUploadingTopicBanner[topicId] ?? false,
                  isUploadingVideo: _isUploadingTopicVideo[topicId] ?? false,
                  buildEditField: _buildEditField,
                );
              },
            ),
          ),
        ],

        // Empty state for no topics
        if (widget.module.items == null || widget.module.items!.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Column(
              children: [
                const Icon(
                  Icons.list_outlined,
                  size: 32,
                  color: VedaColors.zinc700,
                ),
                const SizedBox(height: 16),
                Text(
                  'NO TOPICS IN THIS MODULE',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    color: VedaColors.zinc700,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildEditField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    Future<void> Function()? onUpload,
    bool isUploading = false,
  }) {
    // If it's a file upload field, use custom UI
    if (onUpload != null) {
      return _buildFileUploadField(
        label: label,
        controller: controller,
        onUpload: onUpload,
        isUploading: isUploading,
      );
    }

    // Regular text field for non-upload fields
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 9,
            fontWeight: FontWeight.w400,
            color: VedaColors.zinc600,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
              isDense: true,
              contentPadding: EdgeInsets.zero,
              hintText: hint,
              hintStyle: GoogleFonts.inter(
                fontSize: 12,
                color: VedaColors.zinc700,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFileUploadField({
    required String label,
    required TextEditingController controller,
    required Future<void> Function() onUpload,
    required bool isUploading,
  }) {
    final hasFile = controller.text.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 9,
            fontWeight: FontWeight.w400,
            color: VedaColors.zinc600,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 6),

        // Upload area
        InkWell(
          onTap: isUploading ? null : onUpload,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: hasFile ? VedaColors.white : VedaColors.zinc800,
                width: 1,
              ),
              color: isUploading
                  ? VedaColors.zinc900
                  : (hasFile ? VedaColors.zinc900 : VedaColors.black),
            ),
            child: Column(
              children: [
                if (isUploading) ...[
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      valueColor: AlwaysStoppedAnimation(VedaColors.white),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'UPLOADING...',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 9,
                      color: VedaColors.zinc500,
                      letterSpacing: 1.5,
                    ),
                  ),
                ] else if (hasFile) ...[
                  // Image preview for IMAGE fields
                  if (label.contains('IMAGE') && controller.text.isNotEmpty) ...[
                    ClipRect(
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        color: VedaColors.black,
                        child: Image.network(
                          controller.text,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.broken_image_outlined,
                                    size: 32,
                                    color: VedaColors.zinc700,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'FAILED TO LOAD IMAGE',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 8,
                                      color: VedaColors.zinc600,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  valueColor: const AlwaysStoppedAnimation(
                                      VedaColors.zinc500),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Video preview placeholder for VIDEO fields
                  if (label.contains('VIDEO') && controller.text.isNotEmpty) ...[
                    Container(
                      height: 120,
                      width: double.infinity,
                      color: VedaColors.black,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.play_circle_outline,
                              size: 40,
                              color: VedaColors.zinc600,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'VIDEO FILE',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 9,
                                color: VedaColors.zinc600,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  Row(
                    children: [
                      Icon(
                        label.contains('IMAGE')
                            ? Icons.image_outlined
                            : label.contains('VIDEO')
                                ? Icons.videocam_outlined
                                : Icons.panorama_outlined,
                        size: 16,
                        color: VedaColors.white,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _getFileName(controller.text),
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: VedaColors.white,
                            letterSpacing: 0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () {
                          controller.clear();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          child: const Icon(
                            Icons.close,
                            size: 14,
                            color: VedaColors.zinc500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 1,
                    color: VedaColors.zinc800,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.upload_file,
                        size: 12,
                        color: VedaColors.zinc500,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'UPLOAD NEW FILE',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 8,
                          color: VedaColors.zinc500,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  const Icon(
                    Icons.cloud_upload_outlined,
                    size: 24,
                    color: VedaColors.zinc700,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'CLICK TO UPLOAD',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 9,
                      color: VedaColors.zinc600,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label.contains('IMAGE')
                        ? 'JPG, PNG, WEBP'
                        : label.contains('VIDEO')
                            ? 'MP4, MOV, WEBM'
                            : 'SELECT FILE',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      color: VedaColors.zinc700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getFileName(String url) {
    if (url.isEmpty) return 'No file';
    final uri = Uri.tryParse(url);
    if (uri == null) return url;
    final segments = uri.pathSegments;
    if (segments.isEmpty) return url;
    return segments.last;
  }
}

// ---------------------------------------------------------------------------
// TOPIC TIMELINE ITEM - Timeline-style topic display with editing
// ---------------------------------------------------------------------------

class _TopicTimelineItem extends StatefulWidget {
  final String topicNumber;
  final veda.Topic topic;
  final veda.ModuleItem item;
  final bool isExpanded;
  final bool isLast;
  final bool isSaving;
  final TextEditingController descController;
  final TextEditingController imageController;
  final TextEditingController bannerController;
  final TextEditingController videoController;
  final VoidCallback onToggle;
  final VoidCallback onSave;
  final Future<void> Function() onUploadImage;
  final Future<void> Function() onUploadBanner;
  final Future<void> Function() onUploadVideo;
  final bool isUploadingImage;
  final bool isUploadingBanner;
  final bool isUploadingVideo;
  final Widget Function({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines,
    Future<void> Function()? onUpload,
    bool isUploading,
  }) buildEditField;

  const _TopicTimelineItem({
    super.key,
    required this.topicNumber,
    required this.topic,
    required this.item,
    required this.isExpanded,
    required this.isLast,
    required this.isSaving,
    required this.descController,
    required this.imageController,
    required this.bannerController,
    required this.videoController,
    required this.onToggle,
    required this.onSave,
    required this.onUploadImage,
    required this.onUploadBanner,
    required this.onUploadVideo,
    required this.isUploadingImage,
    required this.isUploadingBanner,
    required this.isUploadingVideo,
    required this.buildEditField,
  });

  @override
  State<_TopicTimelineItem> createState() => _TopicTimelineItemState();
}

class _TopicTimelineItemState extends State<_TopicTimelineItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline column (number + line)
          Column(
            children: [
              // Topic number box
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: widget.isExpanded ? VedaColors.white : VedaColors.black,
                  border: Border.all(
                    color: _isHovered || widget.isExpanded
                        ? VedaColors.white
                        : VedaColors.zinc700,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    widget.topicNumber,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: widget.isExpanded
                          ? VedaColors.black
                          : VedaColors.white,
                    ),
                  ),
                ),
              ),
              // Vertical line
              if (!widget.isLast)
                Container(
                  width: 1,
                  height: 24,
                  color: VedaColors.zinc800,
                ),
            ],
          ),
          const SizedBox(width: 12),
          // Topic content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: GestureDetector(
                onTap: widget.onToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  decoration: BoxDecoration(
                    color: widget.isExpanded
                        ? VedaColors.white
                        : _isHovered
                            ? VedaColors.zinc900
                            : Colors.transparent,
                    border: Border.all(
                      color: widget.isExpanded
                          ? VedaColors.white
                          : _isHovered
                              ? VedaColors.zinc700
                              : VedaColors.zinc800,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Topic header
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Tag line
                                  Text(
                                    'TOPIC ${widget.topicNumber}',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w400,
                                      color: widget.isExpanded
                                          ? VedaColors.black.withValues(alpha: 0.4)
                                          : VedaColors.zinc600,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  // Topic title
                                  Text(
                                    widget.topic.title.toUpperCase(),
                                    style: GoogleFonts.inter(
                                      fontSize: widget.isExpanded ? 14 : 12,
                                      fontWeight: FontWeight.w400,
                                      color: widget.isExpanded
                                          ? VedaColors.black
                                          : VedaColors.white,
                                      letterSpacing: 0.2,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Drag handle (for reordering)
                            if (!widget.isExpanded)
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Icon(
                                  Icons.drag_indicator,
                                  size: 16,
                                  color: _isHovered
                                      ? VedaColors.white
                                      : VedaColors.zinc700,
                                ),
                              ),
                            // Expand/collapse icon
                            Icon(
                              widget.isExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              size: 18,
                              color: widget.isExpanded
                                  ? VedaColors.black.withValues(alpha: 0.5)
                                  : _isHovered
                                      ? VedaColors.white
                                      : VedaColors.zinc700,
                            ),
                          ],
                        ),
                      ),

                      // Expanded: Edit fields
                      if (widget.isExpanded) ...[
                        Container(
                          height: 1,
                          color: VedaColors.black.withValues(alpha: 0.1),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Context description (read-only)
                              if (widget.item.contextualDescription != null &&
                                  widget.item.contextualDescription!.isNotEmpty) ...[
                                Text(
                                  'CONTEXT (READ-ONLY)',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 8,
                                    color: VedaColors.black.withValues(alpha: 0.4),
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: VedaColors.black.withValues(alpha: 0.03),
                                    border: Border.all(
                                      color: VedaColors.black.withValues(alpha: 0.1),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    widget.item.contextualDescription!,
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: VedaColors.black.withValues(alpha: 0.6),
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],

                              // Editable fields
                              widget.buildEditField(
                                label: 'DESCRIPTION',
                                controller: widget.descController,
                                maxLines: 4,
                                hint: 'Enter topic description...',
                              ),
                              const SizedBox(height: 16),

                              widget.buildEditField(
                                label: 'IMAGE URL',
                                controller: widget.imageController,
                                hint: 'https://...',
                                onUpload: widget.onUploadImage,
                                isUploading: widget.isUploadingImage,
                              ),
                              const SizedBox(height: 16),

                              widget.buildEditField(
                                label: 'BANNER IMAGE URL',
                                controller: widget.bannerController,
                                hint: 'https://...',
                                onUpload: widget.onUploadBanner,
                                isUploading: widget.isUploadingBanner,
                              ),
                              const SizedBox(height: 16),

                              widget.buildEditField(
                                label: 'VIDEO URL',
                                controller: widget.videoController,
                                hint: 'https://...',
                                onUpload: widget.onUploadVideo,
                                isUploading: widget.isUploadingVideo,
                              ),
                              const SizedBox(height: 20),

                              // Save button
                              InkWell(
                                onTap: widget.isSaving ? null : widget.onSave,
                                child: Container(
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: widget.isSaving
                                        ? VedaColors.black.withValues(alpha: 0.3)
                                        : VedaColors.black,
                                  ),
                                  child: Center(
                                    child: widget.isSaving
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 1.5,
                                              valueColor: AlwaysStoppedAnimation(
                                                  VedaColors.white),
                                            ),
                                          )
                                        : Text(
                                            'SAVE TOPIC',
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w400,
                                              color: VedaColors.white,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
