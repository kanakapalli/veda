import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:veda_client/veda_client.dart' as veda;

import '../../../design_system/veda_colors.dart';
import '../../../main.dart';
import '../../../services/gemini_service.dart';
import '../../../services/upload_service.dart';
import 'models/course_models.dart';
import 'widgets/chat_panel.dart';
import 'widgets/course_index_panel.dart';
import 'widgets/knowledge_base_panel.dart';

/// Course Creation Screen - AI-powered course architect
/// Follows Neo-Minimalist Line Art aesthetic with Swiss grid system
class CourseCreationScreen extends StatefulWidget {
  final veda.Course course;

  const CourseCreationScreen({super.key, required this.course});

  @override
  State<CourseCreationScreen> createState() => _CourseCreationScreenState();
}

class _CourseCreationScreenState extends State<CourseCreationScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  ChatMode _chatMode = ChatMode.create;
  String _activeTab = 'index';
  bool _isLoading = false;

  // Knowledge files loaded from server
  final List<KnowledgeFile> _files = [];

  final List<ChatMessage> _messages = [];

  // Modules loaded from server
  final List<CourseModule> _modules = [];

  // Track the current course state (may be updated by AI tools)
  late veda.Course _course;

  // Get visibility status from course
  bool get _isPublic => _course.visibility == veda.CourseVisibility.public;

  String get _courseStatus {
    switch (_course.visibility) {
      case veda.CourseVisibility.draft:
        return 'DRAFT';
      case veda.CourseVisibility.public:
        return 'PUBLIC';
      case veda.CourseVisibility.private:
        return 'PRIVATE';
    }
  }

  @override
  void initState() {
    super.initState();
    _course = widget.course;

    print('🎨 [CourseCreation] initState called');
    print('🎨 [CourseCreation] Course ID: ${_course.id}');
    print('🎨 [CourseCreation] Course Title: ${_course.title}');
    print('🎨 [CourseCreation] Course Image URL: ${_course.courseImageUrl}');
    print('🎨 [CourseCreation] Banner Image URL: ${_course.bannerImageUrl}');

    _initializeChat();
    _loadKnowledgeFiles();
  }

  Future<void> _loadKnowledgeFiles() async {
    if (_course.id == null) return;
    try {
      final serverFiles = await client.lms.getFilesForCourse(_course.id!);
      if (!mounted) return;
      setState(() {
        _files.clear();
        for (final f in serverFiles) {
          _files.add(
            KnowledgeFile(
              id: f.id.toString(),
              name: f.fileName,
              size: _formatBytes(f.fileSize),
              type: f.fileType ?? '',
              fileUrl: f.fileUrl,
              serverId: f.id,
            ),
          );
        }
      });
    } catch (_) {}
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _initializeChat() {
    // Add initial AI greeting with course context
    _messages.add(
      ChatMessage(
        id: '1',
        sender: MessageSender.ai,
        text:
            'Hello! I am your course assistant powered by Gemini. I see you\'re working on "${_course.title}". Upload your knowledge files on the left, and I can help you structure your course or generate content.\n\nI can also help you:\n• Update course title, description, and visibility\n• Set video URLs\n• Create modules\n• Generate course and banner images\n\nJust ask me to make changes and I\'ll update the course directly!',
      ),
    );

    // Initialize Gemini chat session with course ID for tool calling
    GeminiService.instance.startChatSession(
      systemInstruction: _buildSystemInstruction(),
      courseId: _course.id,
    );
  }

  String _buildSystemInstruction() {
    final fileNames = _files.map((f) => f.name).join(', ');
    return '''
You are a Course Architect AI assistant for Veda, an educational platform. Your role is to help instructors create well-structured online courses.

Current knowledge files uploaded: $fileNames

Your capabilities:
1. Analyze uploaded knowledge files to understand the content
2. Suggest course structures with modules and lessons
3. Generate lesson outlines, quizzes, and summaries
4. Help organize content in a logical learning progression

Guidelines:
- Keep responses concise and actionable
- Suggest specific module and lesson titles
- When asked to add content to the course index, provide structured suggestions
- Focus on educational best practices
- Ask clarifying questions when the instructor's intent is unclear

Reference specific files when making suggestions based on their content.
''';
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _isLoading) return;

    final userText = _messageController.text;
    _messageController.clear();

    setState(() {
      _messages.add(
        ChatMessage(
          id: DateTime.now().toString(),
          sender: MessageSender.user,
          text: userText,
        ),
      );
      _isLoading = true;
      // Add loading message
      _messages.add(
        ChatMessage(
          id: 'loading',
          sender: MessageSender.ai,
          text: '',
          isLoading: true,
        ),
      );
    });

    _scrollToBottom();

    try {
      // Use course chat with tool calling support
      final result = await GeminiService.instance.sendCourseMessage(
        userText,
        courseId: _course.id,
      );

      if (!mounted) return;

      setState(() {
        // Remove loading message
        _messages.removeWhere((m) => m.id == 'loading');

        if (result.hasError) {
          _messages.add(
            ChatMessage(
              id: DateTime.now().toString(),
              sender: MessageSender.ai,
              text: 'Error: ${result.error}',
            ),
          );
        } else {
          // Add AI response
          _messages.add(
            ChatMessage(
              id: DateTime.now().toString(),
              sender: MessageSender.ai,
              text: result.text,
            ),
          );

          // If course was updated by tools, refresh our local state
          if (result.updatedCourse != null) {
            _course = result.updatedCourse!;
          }

          // Show snackbar if tools were executed
          if (result.hasUpdates) {
            _showSuccessSnackBar(
              'COURSE UPDATED: ${result.toolsExecuted.join(", ")}',
            );
          }
        }

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _messages.removeWhere((m) => m.id == 'loading');
        _messages.add(
          ChatMessage(
            id: DateTime.now().toString(),
            sender: MessageSender.ai,
            text: 'Sorry, I encountered an error. Please try again.',
          ),
        );
        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _addFile() async {
    if (_course.id == null) return;

    // Pick and upload the file
    final result = await UploadService.instance.pickAndUploadKnowledgeFile(
      _course.id!,
    );
    if (result == null) return; // user cancelled picker

    if (!result.success) {
      if (!mounted) return;
      _showErrorSnackBar(result.error ?? 'UPLOAD FAILED');
      return;
    }

    // Save file record to server
    try {
      final serverFile = await client.lms.addFileToCourse(
        veda.KnowledgeFile(
          courseId: _course.id!,
          fileName: result.fileName ?? 'unknown',
          fileSize: result.fileSize ?? 0,
          fileType: result.fileType,
          fileUrl: result.publicUrl ?? '',
        ),
      );

      if (!mounted) return;
      setState(() {
        _files.add(
          KnowledgeFile(
            id: serverFile.id.toString(),
            name: serverFile.fileName,
            size: _formatBytes(serverFile.fileSize),
            type: serverFile.fileType ?? '',
            fileUrl: serverFile.fileUrl,
            serverId: serverFile.id,
          ),
        );
      });

      // Update Gemini context with new files
      GeminiService.instance.startChatSession(
        systemInstruction: _buildSystemInstruction(),
        courseId: _course.id,
      );

      _showSuccessSnackBar('FILE UPLOADED');
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('FAILED TO SAVE FILE RECORD');
    }
  }

  Future<void> _removeFile(String id) async {
    final file = _files.firstWhere((f) => f.id == id);
    if (file.serverId != null) {
      try {
        await client.lms.deleteFile(file.serverId!);
      } catch (_) {
        if (!mounted) return;
        _showErrorSnackBar('FAILED TO DELETE FILE');
        return;
      }
    }
    setState(() {
      _files.removeWhere((f) => f.id == id);
    });
  }

  void _toggleModule(String id) {
    setState(() {
      final index = _modules.indexWhere((m) => m.id == id);
      if (index != -1) {
        _modules[index] = _modules[index].copyWith(
          expanded: !_modules[index].expanded,
        );
      }
    });
  }

  Future<void> _updateVisibility(bool isPublic) async {
    try {
      final newVisibility = isPublic
          ? veda.CourseVisibility.public
          : veda.CourseVisibility.private;

      final updatedCourse = _course.copyWith(
        visibility: newVisibility,
      );

      await client.lms.updateCourse(updatedCourse);
      setState(() {
        _course = updatedCourse;
      });
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('FAILED TO UPDATE VISIBILITY');
    }
  }

  void _generateIndex() {
    // Send a message to AI to generate course index
    _messageController.text =
        'Please generate a course index/outline for "${_course.title}" based on the uploaded knowledge files.';
    _sendMessage();
  }

  Future<void> _editCourseImage() async {
    if (_course.id == null) return;

    final result = await UploadService.instance.pickAndUploadCourseImage(
      _course.id!,
    );
    if (result == null) return;

    if (!result.success) {
      if (!mounted) return;
      _showErrorSnackBar(result.error ?? 'UPLOAD FAILED');
      return;
    }

    try {
      final updated = _course.copyWith(courseImageUrl: result.publicUrl);
      await client.lms.updateCourse(updated);
      if (!mounted) return;
      setState(() => _course = updated);
      _showSuccessSnackBar('COURSE IMAGE UPDATED');
    } catch (_) {
      if (!mounted) return;
      _showErrorSnackBar('FAILED TO UPDATE COURSE IMAGE');
    }
  }

  Future<void> _editBannerImage() async {
    if (_course.id == null) return;

    final result = await UploadService.instance.pickAndUploadBannerImage(
      _course.id!,
    );
    if (result == null) return;

    if (!result.success) {
      if (!mounted) return;
      _showErrorSnackBar(result.error ?? 'UPLOAD FAILED');
      return;
    }

    try {
      final updated = _course.copyWith(bannerImageUrl: result.publicUrl);
      await client.lms.updateCourse(updated);
      if (!mounted) return;
      setState(() => _course = updated);
      _showSuccessSnackBar('BANNER IMAGE UPDATED');
    } catch (_) {
      if (!mounted) return;
      _showErrorSnackBar('FAILED TO UPDATE BANNER IMAGE');
    }
  }

  Future<void> _updateTitle(String title) async {
    if (title.trim().isEmpty) return;
    try {
      final updatedCourse = _course.copyWith(title: title.trim());
      await client.lms.updateCourse(updatedCourse);
      setState(() {
        _course = updatedCourse;
      });
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('FAILED TO UPDATE TITLE');
    }
  }

  Future<void> _updateDescription(String description) async {
    try {
      final updatedCourse = _course.copyWith(description: description);
      await client.lms.updateCourse(updatedCourse);
      setState(() {
        _course = updatedCourse;
      });
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('FAILED TO UPDATE DESCRIPTION');
    }
  }

  Future<void> _updateVideoUrl(String videoUrl) async {
    try {
      final updatedCourse = _course.copyWith(videoUrl: videoUrl);
      await client.lms.updateCourse(updatedCourse);
      setState(() {
        _course = updatedCourse;
      });
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('FAILED TO UPDATE VIDEO URL');
    }
  }

  Future<void> _updateSystemPrompt(String systemPrompt) async {
    try {
      final updatedCourse = _course.copyWith(systemPrompt: systemPrompt);
      await client.lms.updateCourse(updatedCourse);
      setState(() {
        _course = updatedCourse;
      });
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('FAILED TO UPDATE SYSTEM PROMPT');
    }
  }

  Future<void> _deleteCourse() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: VedaColors.zinc900,
        title: Text(
          'DELETE COURSE',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: VedaColors.white,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${_course.title}"? This action cannot be undone.',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: VedaColors.zinc500,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'CANCEL',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: VedaColors.zinc500,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'DELETE',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: VedaColors.error,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await client.lms.deleteCourse(_course.id!);
        if (!mounted) return;
        Navigator.of(context).pop();
      } catch (e) {
        if (!mounted) return;
        _showErrorSnackBar('FAILED TO DELETE COURSE');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: VedaColors.white,
            letterSpacing: 1.0,
          ),
        ),
        backgroundColor: VedaColors.error,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: VedaColors.black,
            letterSpacing: 1.0,
          ),
        ),
        backgroundColor: VedaColors.white,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _saveAllSettings() async {
    try {
      await client.lms.updateCourse(_course);
      if (!mounted) return;
      _showSuccessSnackBar('COURSE UPDATED SUCCESSFULLY');
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('FAILED TO UPDATE COURSE');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    if (isMobile) {
      return Scaffold(
        backgroundColor: VedaColors.black,
        appBar: AppBar(
          backgroundColor: VedaColors.black,
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _course.title.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: VedaColors.white,
                  letterSpacing: 0.2,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                _courseStatus,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: VedaColors.zinc500,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              height: 1,
              color: VedaColors.zinc800,
            ),
          ),
        ),
        body: ChatPanel(
          chatMode: _chatMode,
          messages: _messages,
          messageController: _messageController,
          scrollController: _scrollController,
          activeFilesCount: _files.length,
          onSendMessage: _sendMessage,
          onModeChanged: (mode) => setState(() => _chatMode = mode),
          courseTitle: _course.title,
          courseStatus: _courseStatus,
          courseImageUrl: _course.courseImageUrl,
          onEditCourseImage: _editCourseImage,
          courseId: _course.id,
        ),
      );
    }

    // Desktop: Three-panel layout
    return Scaffold(
      backgroundColor: VedaColors.black,
      body: Row(
        children: [
          // Left panel: Knowledge Base
          SizedBox(
            width: 288,
            child: KnowledgeBasePanel(
              files: _files,
              onAddFile: _addFile,
              onRemoveFile: _removeFile,
            ),
          ),
          // Vertical divider
          Container(width: 1, color: VedaColors.zinc800),
          // Center panel: Chat
          Expanded(
            child: ChatPanel(
              chatMode: _chatMode,
              messages: _messages,
              messageController: _messageController,
              scrollController: _scrollController,
              activeFilesCount: _files.length,
              onSendMessage: _sendMessage,
              onModeChanged: (mode) => setState(() => _chatMode = mode),
              courseTitle: _course.title,
              courseStatus: _courseStatus,
              courseImageUrl: _course.courseImageUrl,
              onEditCourseImage: _editCourseImage,
              courseId: _course.id,
            ),
          ),
          // Vertical divider
          Container(width: 1, color: VedaColors.zinc800),
          // Right panel: Course Index
          SizedBox(
            width: 384,
            child: CourseIndexPanel(
              activeTab: _activeTab,
              modules: _modules,
              courseTitle: _course.title,
              courseDescription: _course.description,
              courseStatus: _courseStatus,
              courseImageUrl: _course.courseImageUrl,
              bannerImageUrl: _course.bannerImageUrl,
              videoUrl: _course.videoUrl,
              systemPrompt: _course.systemPrompt,
              createdAt: _course.createdAt,
              updatedAt: _course.updatedAt,
              knowledgeFiles: _files,
              isPublic: _isPublic,
              onTabChanged: (tab) => setState(() => _activeTab = tab),
              onModuleToggle: _toggleModule,
              onVisibilityChanged: _updateVisibility,
              onGenerateIndex: _generateIndex,
              onEditCourseImage: _editCourseImage,
              onEditBannerImage: _editBannerImage,
              onTitleChanged: _updateTitle,
              onDescriptionChanged: _updateDescription,
              onVideoUrlChanged: _updateVideoUrl,
              onSystemPromptChanged: _updateSystemPrompt,
              onDeleteCourse: _deleteCourse,
              onSaveSettings: _saveAllSettings,
            ),
          ),
        ],
      ),
    );
  }
}
