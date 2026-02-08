import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../design_system/veda_colors.dart';
import '../models/course_models.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

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
            child: const Icon(
              Icons.smart_toy_outlined,
              size: 16,
              color: VedaColors.white,
            ),
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
            child: message.isLoading
                ? _buildLoadingIndicator()
                : MarkdownBody(
                    data: message.text,
                    selectable: true,
                    styleSheet: MarkdownStyleSheet(
                      p: GoogleFonts.inter(
                        fontSize: 13,
                        color: VedaColors.white,
                        letterSpacing: 0.2,
                        height: 1.6,
                      ),
                      code: GoogleFonts.jetBrainsMono(
                        fontSize: 12,
                        color: VedaColors.accent,
                        backgroundColor: VedaColors.zinc900,
                      ),
                      codeblockDecoration: BoxDecoration(
                        color: VedaColors.zinc900,
                        border: Border.all(color: VedaColors.zinc800, width: 1),
                      ),
                      codeblockPadding: const EdgeInsets.all(12),
                      h1: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w300,
                        color: VedaColors.white,
                      ),
                      h2: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                        color: VedaColors.white,
                      ),
                      h3: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        color: VedaColors.white,
                      ),
                      listBullet: GoogleFonts.inter(
                        fontSize: 13,
                        color: VedaColors.accent,
                      ),
                      blockquote: GoogleFonts.inter(
                        fontSize: 13,
                        color: VedaColors.zinc500,
                        fontStyle: FontStyle.italic,
                      ),
                      blockquoteDecoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(color: VedaColors.accent, width: 2),
                        ),
                      ),
                      strong: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: VedaColors.white,
                      ),
                      em: GoogleFonts.inter(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: VedaColors.white,
                      ),
                      a: GoogleFonts.inter(
                        fontSize: 13,
                        color: VedaColors.accent,
                        decoration: TextDecoration.underline,
                      ),
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

  Widget _buildLoadingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LoadingDot(delay: 0),
        const SizedBox(width: 4),
        _LoadingDot(delay: 150),
        const SizedBox(width: 4),
        _LoadingDot(delay: 300),
      ],
    );
  }
}

class _LoadingDot extends StatefulWidget {
  final int delay;

  const _LoadingDot({required this.delay});

  @override
  State<_LoadingDot> createState() => _LoadingDotState();
}

class _LoadingDotState extends State<_LoadingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
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
      builder: (context, child) {
        return Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: VedaColors.zinc500.withAlpha((_animation.value * 255).toInt()),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
