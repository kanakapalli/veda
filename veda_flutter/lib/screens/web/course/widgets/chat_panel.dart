import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:veda_client/veda_client.dart' as veda;

import '../../../../design_system/veda_colors.dart';
import '../models/course_models.dart';
import 'chat_bubble.dart';
import 'mode_button.dart';
import 'teaching_panel.dart';

class ChatPanel extends StatelessWidget {
  final ChatMode chatMode;
  final List<ChatMessage> messages;
  final TextEditingController messageController;
  final ScrollController scrollController;
  final int activeFilesCount;
  final VoidCallback onSendMessage;
  final void Function(ChatMode) onModeChanged;
  final String? courseTitle;
  final String? courseStatus;
  final String? courseImageUrl;
  final VoidCallback? onEditCourseImage;
  final int? courseId;
  final veda.Course? course;
  final List<veda.Module>? modules;

  const ChatPanel({
    super.key,
    required this.chatMode,
    required this.messages,
    required this.messageController,
    required this.scrollController,
    required this.activeFilesCount,
    required this.onSendMessage,
    required this.onModeChanged,
    this.courseTitle,
    this.courseStatus,
    this.courseImageUrl,
    this.onEditCourseImage,
    this.courseId,
    this.course,
    this.modules,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: VedaColors.black,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: chatMode == ChatMode.create
                ? _buildCreateModeContent()
                : _buildTeachModeContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateModeContent() {
    return Column(
      children: [
        Expanded(child: _buildMessagesList()),
        _buildInputArea(),
      ],
    );
  }

  Widget _buildTeachModeContent() {
    if (courseId == null || course == null) {
      return Center(
        child: Text(
          'Save the course first to start teaching mode.',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 11,
            color: VedaColors.zinc500,
          ),
        ),
      );
    }

    // TEACH mode: Interactive teaching with TTS and STT
    return TeachingPanel(
      course: course!,
      modules: modules ?? [],
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: VedaColors.zinc800, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Course image or add icon
          GestureDetector(
            onTap: onEditCourseImage,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                border: Border.all(color: VedaColors.zinc800, width: 1),
              ),
              child: courseImageUrl != null && courseImageUrl!.isNotEmpty
                  ? Image.network(
                      courseImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.broken_image_outlined,
                        size: 18,
                        color: VedaColors.zinc700,
                      ),
                    )
                  : const Icon(
                      Icons.add,
                      size: 20,
                      color: VedaColors.zinc700,
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  courseTitle?.toUpperCase() ?? 'COURSE ARCHITECT',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: VedaColors.white,
                    letterSpacing: 0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (courseStatus != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: courseStatus == 'DRAFT'
                                ? VedaColors.zinc700
                                : courseStatus == 'PUBLIC'
                                    ? VedaColors.accent
                                    : VedaColors.zinc700,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          courseStatus!,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 9,
                            fontWeight: FontWeight.w400,
                            color: courseStatus == 'DRAFT'
                                ? VedaColors.zinc500
                                : courseStatus == 'PUBLIC'
                                    ? VedaColors.accent
                                    : VedaColors.zinc500,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        border: Border.all(color: VedaColors.accent, width: 1),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      chatMode == ChatMode.create
                          ? 'CREATION MODE'
                          : 'TEACHING MODE',
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
                ModeButton(
                  label: 'CREATE',
                  isActive: chatMode == ChatMode.create,
                  onTap: () => onModeChanged(ChatMode.create),
                ),
                Container(width: 1, height: 32, color: VedaColors.zinc800),
                ModeButton(
                  label: 'TEACH',
                  isActive: chatMode == ChatMode.teach,
                  onTap: () => onModeChanged(ChatMode.teach),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
  ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(24),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: ChatBubble(message: msg),
        );
      },
    );
  }

  Widget _buildInputArea() {
    return Container(
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
                  controller: messageController,
                  maxLines: 3,
                  minLines: 1,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: VedaColors.white,
                    letterSpacing: 0.2,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Generate module, quiz, or summary...',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 13,
                      color: VedaColors.zinc700,
                      letterSpacing: 0.2,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onSubmitted: (_) => onSendMessage(),
                ),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: onSendMessage,
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
              '$activeFilesCount FILES ACTIVE',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                color: VedaColors.zinc700,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
