import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../design_system/veda_colors.dart';

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
  String _activeTab = 'index'; // 'index' or 'settings'
  bool _isPublic = false;

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

  final List<ChatMessage> _messages = [
    ChatMessage(
      id: '1',
      sender: MessageSender.ai,
      text:
          'Hello! I am your course assistant. Upload your knowledge files on the left, and I can help you structure your course or generate content. What shall we work on today?',
    ),
    ChatMessage(
      id: '2',
      sender: MessageSender.user,
      text: 'I need to create a module about React Performance.',
    ),
    ChatMessage(
      id: '3',
      sender: MessageSender.ai,
      text:
          'Great. Based on the "Advanced_Hooks_Guide.docx" you uploaded, I suggest covering useMemo, useCallback, and React.memo. Shall I add these to the Course Index?',
    ),
  ];

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
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        id: DateTime.now().toString(),
        sender: MessageSender.user,
        text: _messageController.text,
      ));
    });

    final userText = _messageController.text;
    _messageController.clear();

    // Mock AI response
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(
          id: DateTime.now().toString(),
          sender: MessageSender.ai,
          text:
              'I\'ve noted that: "$userText". I\'ll update the course structure accordingly.',
        ));
      });
      _scrollToBottom();
    });

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
        body: _buildChatPanel(),
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
            child: _buildKnowledgeBasePanel(),
          ),
          // Vertical divider
          Container(width: 1, color: VedaColors.zinc800),
          // Center panel: Chat
          Expanded(
            child: _buildChatPanel(),
          ),
          // Vertical divider
          Container(width: 1, color: VedaColors.zinc800),
          // Right panel: Course Index
          SizedBox(
            width: 384,
            child: _buildCourseIndexPanel(),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // KNOWLEDGE BASE PANEL
  // ---------------------------------------------------------------------------
  Widget _buildKnowledgeBasePanel() {
    return Container(
      color: VedaColors.black,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: VedaColors.zinc800, width: 1),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.folder_outlined,
                    size: 20, color: VedaColors.white),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: VedaColors.white, width: 1),
                  ),
                  child: Text(
                    '${_files.length}',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: VedaColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Files list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Upload area
                InkWell(
                  onTap: _addFile,
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
                            border:
                                Border.all(color: VedaColors.zinc800, width: 1),
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
                const SizedBox(height: 24),
                // Files label
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
                // File items
                ..._files.map((file) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _FileItem(
                        file: file,
                        onRemove: () => _removeFile(file.id),
                      ),
                    )),
              ],
            ),
          ),
          // Storage meter
          Container(
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
                      '45%',
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
                      widthFactor: 0.45,
                      child: Container(color: VedaColors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CHAT PANEL
  // ---------------------------------------------------------------------------
  Widget _buildChatPanel() {
    return Container(
      color: VedaColors.black,
      child: Column(
        children: [
          // Header
          Container(
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: VedaColors.zinc800, width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'COURSE ARCHITECT',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                          color: VedaColors.white,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: VedaColors.accent, width: 1),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _chatMode == ChatMode.create
                                ? 'CREATION MODE'
                                : 'TESTING MODE',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              color: VedaColors.zinc500,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Mode toggle
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: VedaColors.zinc800, width: 1),
                  ),
                  child: Row(
                    children: [
                      _ModeButton(
                        label: 'CREATE',
                        isActive: _chatMode == ChatMode.create,
                        onTap: () => setState(() => _chatMode = ChatMode.create),
                      ),
                      Container(width: 1, height: 32, color: VedaColors.zinc800),
                      _ModeButton(
                        label: 'TEST',
                        isActive: _chatMode == ChatMode.test,
                        onTap: () => setState(() => _chatMode = ChatMode.test),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Export button
                InkWell(
                  onTap: () {},
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: VedaColors.white, width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'EXPORT',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: VedaColors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward,
                            size: 14, color: VedaColors.white),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(24),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: _ChatBubble(message: msg),
                );
              },
            ),
          ),
          // Input area
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: VedaColors.zinc800, width: 1),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        maxLines: 3,
                        minLines: 1,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: VedaColors.white,
                          letterSpacing: 0.2,
                        ),
                        decoration: InputDecoration(
                          hintText: _chatMode == ChatMode.create
                              ? 'Generate module, quiz, or summary...'
                              : 'Enter test scenario...',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 13,
                            color: VedaColors.zinc700,
                            letterSpacing: 0.2,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: _sendMessage,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border.all(color: VedaColors.white, width: 1),
                        ),
                        child: const Icon(
                          Icons.arrow_upward,
                          size: 16,
                          color: VedaColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${_files.length} FILES ACTIVE',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      color: VedaColors.zinc700,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // COURSE INDEX PANEL
  // ---------------------------------------------------------------------------
  Widget _buildCourseIndexPanel() {
    return Container(
      color: VedaColors.black,
      child: Column(
        children: [
          // Tabs
          Row(
            children: [
              _TabButton(
                label: 'INDEX',
                isActive: _activeTab == 'index',
                onTap: () => setState(() => _activeTab = 'index'),
              ),
              Container(width: 1, height: 48, color: VedaColors.zinc800),
              _TabButton(
                label: 'SETTINGS',
                isActive: _activeTab == 'settings',
                onTap: () => setState(() => _activeTab = 'settings'),
              ),
            ],
          ),
          // Content
          Expanded(
            child: _activeTab == 'index'
                ? _buildCourseIndexContent()
                : _buildSettingsContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseIndexContent() {
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
                      'REACT MASTERY',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: VedaColors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  const Icon(Icons.more_horiz,
                      size: 16, color: VedaColors.zinc700),
                ],
              ),
              const SizedBox(height: 16),
              // Public/Private toggle
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: VedaColors.zinc800, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isPublic ? Icons.public_outlined : Icons.lock_outline,
                      size: 16,
                      color: VedaColors.zinc500,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _isPublic ? 'PUBLIC' : 'PRIVATE',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: VedaColors.zinc500,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => setState(() => _isPublic = !_isPublic),
                      child: Container(
                        width: 40,
                        height: 20,
                        decoration: BoxDecoration(
                          border: Border.all(color: VedaColors.zinc800, width: 1),
                        ),
                        padding: const EdgeInsets.all(2),
                        child: Align(
                          alignment: _isPublic
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            width: 16,
                            height: 16,
                            color: _isPublic
                                ? VedaColors.white
                                : VedaColors.zinc700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${_modules.length} MODULES • ${_modules.fold(0, (sum, m) => sum + m.lessons.length)} LESSONS',
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
        ..._modules.map((module) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ModuleCard(
                module: module,
                onToggle: () => _toggleModule(module.id),
              ),
            )),
        // Add module button
        InkWell(
          onTap: () {},
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
            value: 'Private',
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
                  value: 'Organization', child: Text('Organization Only')),
            ],
            onChanged: (_) {},
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
          onTap: () {},
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

// ---------------------------------------------------------------------------
// WIDGETS
// ---------------------------------------------------------------------------

class _FileItem extends StatelessWidget {
  final KnowledgeFile file;
  final VoidCallback onRemove;

  const _FileItem({required this.file, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: VedaColors.zinc800, width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.insert_drive_file_outlined,
              size: 16, color: VedaColors.zinc700),
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

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == MessageSender.user;

    return Row(
      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isUser) ...[
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              border: Border.all(color: VedaColors.white, width: 1),
            ),
            child: const Icon(Icons.smart_toy_outlined,
                size: 16, color: VedaColors.white),
          ),
          const SizedBox(width: 12),
        ],
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(16),
            constraints: const BoxConstraints(maxWidth: 600),
            decoration: BoxDecoration(
              border: Border.all(color: VedaColors.zinc800, width: 1),
            ),
            child: Text(
              message.text,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: VedaColors.white,
                letterSpacing: 0.2,
                height: 1.6,
              ),
            ),
          ),
        ),
        if (isUser) ...[
          const SizedBox(width: 12),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              border: Border.all(color: VedaColors.zinc800, width: 1),
            ),
          ),
        ],
      ],
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ModeButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: isActive ? VedaColors.white : Colors.transparent,
        child: Text(
          label,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: isActive ? VedaColors.black : VedaColors.zinc700,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? VedaColors.white : VedaColors.zinc800,
                width: 1,
              ),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: isActive ? VedaColors.white : VedaColors.zinc700,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final CourseModule module;
  final VoidCallback onToggle;

  const _ModuleCard({required this.module, required this.onToggle});

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
                    module.expanded
                        ? Icons.remove
                        : Icons.add,
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                  ...module.lessons.map((lesson) => InkWell(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                  color: VedaColors.zinc900, width: 0.5),
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
                      )),
                  // Add lesson button
                  InkWell(
                    onTap: () {},
                    child: Container(
                      height: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 36),
                      child: Row(
                        children: [
                          const Icon(Icons.add, size: 12, color: VedaColors.zinc700),
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

// ---------------------------------------------------------------------------
// MODELS
// ---------------------------------------------------------------------------

enum ChatMode { create, test }

enum MessageSender { user, ai }

class KnowledgeFile {
  final String id;
  final String name;
  final String size;
  final String type;

  KnowledgeFile({
    required this.id,
    required this.name,
    required this.size,
    required this.type,
  });
}

class ChatMessage {
  final String id;
  final MessageSender sender;
  final String text;

  ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
  });
}

class CourseModule {
  final String id;
  final String title;
  final bool expanded;
  final List<Lesson> lessons;

  CourseModule({
    required this.id,
    required this.title,
    required this.expanded,
    required this.lessons,
  });

  CourseModule copyWith({
    String? id,
    String? title,
    bool? expanded,
    List<Lesson>? lessons,
  }) {
    return CourseModule(
      id: id ?? this.id,
      title: title ?? this.title,
      expanded: expanded ?? this.expanded,
      lessons: lessons ?? this.lessons,
    );
  }
}

class Lesson {
  final String id;
  final String title;
  final String duration;

  Lesson({
    required this.id,
    required this.title,
    required this.duration,
  });
}
