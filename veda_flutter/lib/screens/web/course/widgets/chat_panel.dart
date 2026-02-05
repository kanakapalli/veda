import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../design_system/veda_colors.dart';
import '../models/course_models.dart';
import 'chat_bubble.dart';
import 'mode_button.dart';

class ChatPanel extends StatelessWidget {
  final ChatMode chatMode;
  final List<ChatMessage> messages;
  final TextEditingController messageController;
  final ScrollController scrollController;
  final int activeFilesCount;
  final VoidCallback onSendMessage;
  final void Function(ChatMode) onModeChanged;
  final VoidCallback? onExport;

  const ChatPanel({
    super.key,
    required this.chatMode,
    required this.messages,
    required this.messageController,
    required this.scrollController,
    required this.activeFilesCount,
    required this.onSendMessage,
    required this.onModeChanged,
    this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: VedaColors.black,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildMessagesList()),
          _buildInputArea(),
        ],
      ),
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
                        border: Border.all(color: VedaColors.accent, width: 1),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      chatMode == ChatMode.create
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
                ModeButton(
                  label: 'CREATE',
                  isActive: chatMode == ChatMode.create,
                  onTap: () => onModeChanged(ChatMode.create),
                ),
                Container(width: 1, height: 32, color: VedaColors.zinc800),
                ModeButton(
                  label: 'TEST',
                  isActive: chatMode == ChatMode.test,
                  onTap: () => onModeChanged(ChatMode.test),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Export button
          InkWell(
            onTap: onExport,
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
                  const Icon(
                    Icons.arrow_forward,
                    size: 14,
                    color: VedaColors.white,
                  ),
                ],
              ),
            ),
          ),
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
                    hintText: chatMode == ChatMode.create
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
