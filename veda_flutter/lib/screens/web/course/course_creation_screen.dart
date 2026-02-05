import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../design_system/veda_colors.dart';
import '../../../services/gemini_service.dart';
import 'models/course_models.dart';
import 'widgets/chat_panel.dart';
import 'widgets/course_index_panel.dart';
import 'widgets/knowledge_base_panel.dart';

/// Course Creation Screen - AI-powered course architect
/// Follows Neo-Minimalist Line Art aesthetic with Swiss grid system
class CourseCreationScreen extends StatefulWidget {
  const CourseCreationScreen({super.key});

  @override
  State<CourseCreationScreen> createState() => _CourseCreationScreenState();
}

class _CourseCreationScreenState extends State<CourseCreationScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  ChatMode _chatMode = ChatMode.create;
  String _activeTab = 'index';
  bool _isPublic = false;
  bool _isLoading = false;

  final List<KnowledgeFile> _files = [
    KnowledgeFile(
      id: '1',
      name: 'Introduction_to_React.pdf',
      size: '2.4 MB',
      type: 'pdf',
    ),
    KnowledgeFile(
      id: '2',
      name: 'Advanced_Hooks_Guide.docx',
      size: '1.1 MB',
      type: 'doc',
    ),
    KnowledgeFile(
      id: '3',
      name: 'Project_Assets.zip',
      size: '15 MB',
      type: 'zip',
    ),
  ];

  final List<ChatMessage> _messages = [];

  final List<CourseModule> _modules = [
    CourseModule(
      id: 'mod-1',
      title: 'Module 1: Fundamentals',
      expanded: true,
      lessons: [
        Lesson(id: 'les-1-1', title: 'What is React?', duration: '5:00'),
        Lesson(id: 'les-1-2', title: 'JSX & Rendering', duration: '10:00'),
      ],
    ),
    CourseModule(
      id: 'mod-2',
      title: 'Module 2: State Management',
      expanded: false,
      lessons: [
        Lesson(id: 'les-2-1', title: 'useState Hook', duration: '8:30'),
        Lesson(id: 'les-2-2', title: 'useReducer Hook', duration: '12:00'),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  void _initializeChat() {
    // Add initial AI greeting
    _messages.add(ChatMessage(
      id: '1',
      sender: MessageSender.ai,
      text:
          'Hello! I am your course assistant powered by Gemini. Upload your knowledge files on the left, and I can help you structure your course or generate content. What shall we work on today?',
    ));

    // Initialize Gemini chat session with system instruction
    GeminiService.instance.startChatSession(
      systemInstruction: _buildSystemInstruction(),
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
      _messages.add(ChatMessage(
        id: DateTime.now().toString(),
        sender: MessageSender.user,
        text: userText,
      ));
      _isLoading = true;
      // Add loading message
      _messages.add(ChatMessage(
        id: 'loading',
        sender: MessageSender.ai,
        text: '',
        isLoading: true,
      ));
    });

    _scrollToBottom();

    try {
      final response = await GeminiService.instance.sendMessage(userText);

      if (!mounted) return;

      setState(() {
        // Remove loading message
        _messages.removeWhere((m) => m.id == 'loading');
        // Add AI response
        _messages.add(ChatMessage(
          id: DateTime.now().toString(),
          sender: MessageSender.ai,
          text: response,
        ));
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _messages.removeWhere((m) => m.id == 'loading');
        _messages.add(ChatMessage(
          id: DateTime.now().toString(),
          sender: MessageSender.ai,
          text: 'Sorry, I encountered an error. Please try again.',
        ));
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

  void _addFile() {
    setState(() {
      _files.add(KnowledgeFile(
        id: DateTime.now().toString(),
        name: 'New_Knowledge_Base_${_files.length + 1}.pdf',
        size: '1.2 MB',
        type: 'pdf',
      ));
    });
    // Update Gemini context with new files
    GeminiService.instance.startChatSession(
      systemInstruction: _buildSystemInstruction(),
    );
  }

  void _removeFile(String id) {
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

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    if (isMobile) {
      return Scaffold(
        backgroundColor: VedaColors.black,
        appBar: AppBar(
          backgroundColor: VedaColors.black,
          elevation: 0,
          title: Text(
            'COURSE ARCHITECT',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w300,
              color: VedaColors.white,
              letterSpacing: -0.5,
            ),
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
              courseTitle: 'React Mastery',
              isPublic: _isPublic,
              onTabChanged: (tab) => setState(() => _activeTab = tab),
              onModuleToggle: _toggleModule,
              onVisibilityChanged: (value) =>
                  setState(() => _isPublic = value),
            ),
          ),
        ],
      ),
    );
  }
}
