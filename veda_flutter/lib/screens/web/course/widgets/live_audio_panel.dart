import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../design_system/veda_colors.dart';
import '../../../../services/audio_player_service.dart';
import '../../../../services/audio_recorder_service.dart';
import '../../../../services/gemini_live_service.dart';

/// Live audio conversation panel — teaching & listening states
/// Matches the design from couse_teachingState and course_listeningState
class LiveAudioPanel extends StatefulWidget {
  final int courseId;
  final String? moduleTitle;

  const LiveAudioPanel({
    super.key,
    required this.courseId,
    this.moduleTitle,
  });

  @override
  State<LiveAudioPanel> createState() => _LiveAudioPanelState();
}

class _LiveAudioPanelState extends State<LiveAudioPanel>
    with TickerProviderStateMixin {
  final _live = GeminiLiveService.instance;
  final _recorder = AudioRecorderService();
  final _audioPlayer = AudioPlayerService.instance;
  final _scrollController = ScrollController();
  final _textController = TextEditingController();

  late AnimationController _pulseController;
  late AnimationController _spinController;

  LiveSessionState _state = LiveSessionState.idle;
  List<TranscriptEntry> _transcript = [];
  String? _errorMessage;
  bool _isMuted = false;
  late AnimationController _expandController;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    // Set up callbacks
    _live.onStateChanged = (state) {
      debugPrint('[LiveAudioPanel] State changed: $_state -> $state');
      if (!mounted) return;
      setState(() => _state = state);
    };

    _live.onTranscriptUpdated = (transcript) {
      debugPrint('[LiveAudioPanel] Transcript updated: ${transcript.length} entries');
      if (!mounted) return;
      setState(() => _transcript = List.from(transcript));
      _scrollToBottom();
    };

    _live.onAudioReceived = (audioData) {
      debugPrint('[LiveAudioPanel] Audio received: ${audioData.length} bytes');
      // Play the audio (AudioPlayerService handles mute internally)
      _audioPlayer.playAudio(audioData);
    };

    _live.onError = (error) {
      debugPrint('[LiveAudioPanel] ERROR: $error');
      if (!mounted) return;
      setState(() => _errorMessage = error);
    };

    _live.onSessionEnding = () {
      debugPrint('[LiveAudioPanel] Session ending (AI completed explanation)');
      if (!mounted) return;
      // Show a brief message that the session is ending
      setState(() => _errorMessage = 'Session completed');
      // Disconnect after a delay to allow final audio to play
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          _endSession();
        }
      });
    };

    // Set up audio recorder
    _recorder.onAudioData = (data) {
      _live.sendAudio(data);
    };
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _spinController.dispose();
    _expandController.dispose();
    _scrollController.dispose();
    _textController.dispose();
    _recorder.dispose();
    // Stop audio and disconnect when disposing
    _audioPlayer.stop();
    _live.disconnect();
    _live.onStateChanged = null;
    _live.onTranscriptUpdated = null;
    _live.onAudioReceived = null;
    _live.onError = null;
    _live.onSessionEnding = null;
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _startSession() async {
    debugPrint('[LiveAudioPanel] _startSession() courseId=${widget.courseId}');
    setState(() => _errorMessage = null);
    await _live.connect(courseId: widget.courseId);
  }

  Future<void> _endSession() async {
    debugPrint('[LiveAudioPanel] _endSession()');
    await _recorder.stopRecording();
    _audioPlayer.stop();
    await _live.disconnect();
  }

  Future<void> _toggleMicrophone() async {
    if (_recorder.isRecording) {
      // Stop recording, send audio turn to Gemini, wait for AI to respond
      await _recorder.stopRecording();
      setState(() {}); // Refresh UI — _isListening becomes false, shows teaching button
      _live.endAudioTurn();
    } else {
      // Interrupt AI if teaching/processing, start recording
      if (_state == LiveSessionState.teaching ||
          _state == LiveSessionState.processing) {
        _audioPlayer.stop(); // Stop playing audio immediately
        _live.interrupt();
      }
      try {
        await _recorder.startRecording();
        setState(() {}); // Refresh UI — _isListening becomes true, shows stop button
      } catch (e) {
        setState(() => _errorMessage = 'Microphone error: $e');
      }
    }
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _audioPlayer.muted = _isMuted;
    });
  }

  void _sendTextMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _textController.clear();

    if (_state == LiveSessionState.teaching) {
      _live.interrupt();
    }
    _live.sendText(text);
  }

  bool get _isActive =>
      _state == LiveSessionState.connecting ||
      _state == LiveSessionState.teaching ||
      _state == LiveSessionState.listening ||
      _state == LiveSessionState.processing;

  bool get _isListening => _recorder.isRecording;

  bool get _isConnecting => _state == LiveSessionState.connecting;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: VedaColors.black,
      child: Stack(
        children: [
          // Grid background
          Positioned.fill(child: _buildGridBackground()),

          // Vertical guide lines
          Positioned(
            top: 0,
            bottom: 0,
            left: 24,
            child: Container(width: 1, color: VedaColors.white.withValues(alpha: 0.1)),
          ),
          Positioned(
            top: 0,
            bottom: 0,
            right: 24,
            child: Container(width: 1, color: VedaColors.white.withValues(alpha: 0.1)),
          ),

          // Status indicator (top right)
          Positioned(
            top: 16,
            right: 16,
            child: _buildStatusIndicator(),
          ),

          // Main content
          Column(
            children: [
              // Header: Module title
              _buildHeader(),

              // Audio visualization
              _buildAudioVisualization(),

              // Transcript
              Expanded(child: _buildTranscript()),

              // Footer: Controls
              _buildFooter(),
            ],
          ),

          // Corner marks
          Positioned(
            bottom: 128,
            left: 16,
            child: _buildCornerMark(),
          ),
          Positioned(
            bottom: 128,
            right: 16,
            child: _buildCornerMark(flipped: true),
          ),
        ],
      ),
    );
  }

  Widget _buildGridBackground() {
    return CustomPaint(
      painter: _GridPainter(),
    );
  }

  Widget _buildStatusIndicator() {
    if (!_isActive) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          _isListening ? 'SYS.AUDIO.IN' : 'SYS.AUDIO.OUT',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 8,
            fontWeight: FontWeight.w700,
            color: VedaColors.white.withValues(alpha: 0.4),
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          _isListening ? 'LISTENING' : 'REC_ACTIVE',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 8,
            fontWeight: FontWeight.w700,
            color: _isListening
                ? VedaColors.white
                : const Color(0xFF10B981), // emerald-500
            letterSpacing: 2.0,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 32, left: 24, right: 24),
      child: Column(
        children: [
          if (widget.moduleTitle != null)
            Text(
              'MODULE',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: VedaColors.white.withValues(alpha: 0.4),
                letterSpacing: 4.0,
              ),
            ),
          if (widget.moduleTitle != null) const SizedBox(height: 4),
          Text(
            (widget.moduleTitle ?? 'AI TUTOR').toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: VedaColors.white,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            width: 32,
            height: 1,
            color: _isActive
                ? (_isListening
                    ? VedaColors.white.withValues(alpha: 0.2)
                    : const Color(0xFF10B981).withValues(alpha: 0.5))
                : VedaColors.white.withValues(alpha: 0.2),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioVisualization() {
    return SizedBox(
      height: 200,
      child: Center(
        child: _isActive
            ? (_isListening
                ? _buildListeningOrb()
                : _buildTeachingOrb())
            : _buildIdleOrb(),
      ),
    );
  }

  Widget _buildTeachingOrb() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Expanding ring animation (goes outward and fades)
        AnimatedBuilder(
          animation: _expandController,
          builder: (context, child) {
            final scale = 1.0 + (_expandController.value * 0.8);
            final opacity = (1.0 - _expandController.value) * 0.4;
            return Transform.scale(
              scale: scale,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: VedaColors.white.withValues(alpha: opacity),
                    width: 2,
                  ),
                ),
              ),
            );
          },
        ),
        // Outermost spinning ring
        AnimatedBuilder(
          animation: _spinController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _spinController.value * 2 * math.pi,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: VedaColors.white.withValues(alpha: 0.1),
                    width: 1,
                    strokeAlign: BorderSide.strokeAlignCenter,
                  ),
                ),
              ),
            );
          },
        ),
        // Third ring
        Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: VedaColors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
        ),
        // Second ring
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: VedaColors.white.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
        ),
        // Inner ring
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: VedaColors.white.withValues(alpha: 0.8),
              width: 1,
            ),
          ),
        ),
        // Center orb (white filled)
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: VedaColors.white,
            boxShadow: [
              BoxShadow(
                color: VedaColors.white.withValues(alpha: 0.3),
                blurRadius: 50,
                spreadRadius: 10,
              ),
            ],
          ),
          child: const Icon(
            Icons.graphic_eq,
            size: 28,
            color: VedaColors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildListeningOrb() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outermost spinning dashed ring
        AnimatedBuilder(
          animation: _spinController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _spinController.value * 2 * math.pi,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: VedaColors.white.withValues(alpha: 0.05),
                    width: 1,
                  ),
                ),
              ),
            );
          },
        ),
        // Rings
        Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: VedaColors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
        ),
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: VedaColors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final scale = 1.0 + (_pulseController.value * 0.05);
            return Transform.scale(
              scale: scale,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: VedaColors.white.withValues(alpha: 0.6),
                    width: 1,
                  ),
                ),
              ),
            );
          },
        ),
        // Center orb (outlined, with audio bars)
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: VedaColors.black,
            border: Border.all(color: VedaColors.white, width: 1),
            boxShadow: [
              BoxShadow(
                color: VedaColors.white.withValues(alpha: 0.15),
                blurRadius: 30,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              return AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final heights = [18.0, 28.0, 36.0, 24.0, 16.0];
                  final offsets = [0.0, 0.2, 0.1, 0.3, 0.15];
                  final phase = (_pulseController.value + offsets[i]) % 1.0;
                  final h = heights[i] * (0.4 + 0.6 * math.sin(phase * math.pi));
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                    width: 3,
                    height: h,
                    decoration: BoxDecoration(
                      color: VedaColors.white,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                },
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildIdleOrb() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: VedaColors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Icon(
            Icons.headset_mic_outlined,
            size: 32,
            color: VedaColors.white.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 16),
        if (_state == LiveSessionState.connecting)
          Text(
            'CONNECTING...',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              color: VedaColors.white.withValues(alpha: 0.5),
              letterSpacing: 2.0,
            ),
          ),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _errorMessage!,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 9,
                color: VedaColors.error,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  Widget _buildTranscript() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Transcript header
          Row(
            children: [
              Text(
                'LIVE_TRANSCRIPT',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: VedaColors.white.withValues(alpha: 0.6),
                  letterSpacing: 2.0,
                ),
              ),
              const Spacer(),
              if (_isActive) ...[
                Text(
                  _isListening ? 'USER.IN.01' : 'TXT.STRM.01',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 8,
                    color: VedaColors.white.withValues(alpha: 0.3),
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isListening
                            ? VedaColors.white
                                .withValues(alpha: 0.5 + _pulseController.value * 0.5)
                            : const Color(0xFF10B981)
                                .withValues(alpha: 0.5 + _pulseController.value * 0.5),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
          Container(
            height: 1,
            color: VedaColors.white.withValues(alpha: 0.2),
            margin: const EdgeInsets.only(top: 8, bottom: 12),
          ),

          // Transcript content
          Expanded(
            child: ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    VedaColors.black,
                    VedaColors.black,
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.05, 0.9, 1.0],
                ).createShader(bounds);
              },
              blendMode: BlendMode.dstIn,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(bottom: 32),
                itemCount: _transcript.length,
                itemBuilder: (context, index) {
                  final entry = _transcript[index];
                  final isOld = index < _transcript.length - 2;

                  if (entry.isUser) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '> ',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: VedaColors.white,
                              ),
                            ),
                            TextSpan(
                              text: entry.text,
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: VedaColors.white,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // AI text
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isOld)
                          Padding(
                            padding: const EdgeInsets.only(right: 4, top: 2),
                            child: Text(
                              '>',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 13,
                                color: const Color(0xFF10B981),
                              ),
                            ),
                          ),
                        Expanded(
                          child: Text(
                            entry.text,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 13,
                              color: isOld
                                  ? VedaColors.white.withValues(alpha: 0.4)
                                  : VedaColors.white.withValues(alpha: 0.8),
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        children: [
          // Text input (always available as fallback)
          if (_isActive)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: VedaColors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 12,
                        color: VedaColors.white,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: GoogleFonts.jetBrainsMono(
                          fontSize: 12,
                          color: VedaColors.white.withValues(alpha: 0.3),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onSubmitted: (_) => _sendTextMessage(),
                    ),
                  ),
                  GestureDetector(
                    onTap: _sendTextMessage,
                    child: Icon(
                      Icons.arrow_upward,
                      size: 18,
                      color: VedaColors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),

          // Main action button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Mute button (left)
              if (_isActive)
                Column(
                  children: [
                    Text(
                      _isMuted ? 'UNMUTE' : 'MUTE',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 7,
                        fontWeight: FontWeight.w700,
                        color: VedaColors.white.withValues(alpha: 0.3),
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: _toggleMute,
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _isMuted
                                ? VedaColors.error.withValues(alpha: 0.5)
                                : VedaColors.white.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          _isMuted ? Icons.volume_off : Icons.volume_up,
                          size: 16,
                          color: _isMuted
                              ? VedaColors.error
                              : VedaColors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ),

              if (_isActive) const SizedBox(width: 32),

              // Center button
              _buildMainButton(),

              if (_isActive) const SizedBox(width: 32),

              // End session button (right)
              if (_isActive)
                Column(
                  children: [
                    Text(
                      'END',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 7,
                        fontWeight: FontWeight.w700,
                        color: VedaColors.white.withValues(alpha: 0.3),
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: _endSession,
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: VedaColors.error.withValues(alpha: 0.5),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.call_end,
                          size: 16,
                          color: VedaColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainButton() {
    // Idle/Disconnected state - Show START SESSION
    if (!_isActive) {
      return GestureDetector(
        onTap: _startSession,
        child: Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: VedaColors.white, width: 2),
            color: VedaColors.black,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.headset_mic_outlined,
                size: 28,
                color: VedaColors.white,
              ),
              const SizedBox(height: 4),
              Text(
                'START\nSESSION',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  color: VedaColors.white,
                  letterSpacing: 1.0,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Connecting state - Show spinner
    if (_isConnecting) {
      return Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: VedaColors.white.withValues(alpha: 0.5), width: 2),
          color: VedaColors.black,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: VedaColors.white.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'CONNECTING',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 8,
                fontWeight: FontWeight.w700,
                color: VedaColors.white.withValues(alpha: 0.7),
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      );
    }

    // Listening state (recording) — white filled mic button, tap to STOP
    if (_isListening) {
      return GestureDetector(
        onTap: _toggleMicrophone, // This will stop recording
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: VedaColors.white, width: 2),
                color: VedaColors.white,
                boxShadow: [
                  BoxShadow(
                    color: VedaColors.white.withValues(
                        alpha: 0.1 + _pulseController.value * 0.2),
                    blurRadius: 40,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.stop, size: 32, color: VedaColors.black),
                  const SizedBox(height: 2),
                  Text(
                    'STOP',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: VedaColors.black,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    // Teaching state — outlined hand/interrupt button
    return GestureDetector(
      onTap: _toggleMicrophone, // This will interrupt AI and start recording
      child: Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: VedaColors.white, width: 2),
          color: VedaColors.black,
          boxShadow: [
            BoxShadow(
              color: VedaColors.white.withValues(alpha: 0.1),
              blurRadius: 30,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.pan_tool, size: 28, color: VedaColors.white),
            const SizedBox(height: 4),
            Text(
              'INTERRUPT\nTO SPEAK',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 8,
                fontWeight: FontWeight.w700,
                color: VedaColors.white,
                letterSpacing: 1.0,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCornerMark({bool flipped = false}) {
    return SizedBox(
      width: 12,
      height: 12,
      child: CustomPaint(
        painter: _CornerMarkPainter(flipped: flipped),
      ),
    );
  }
}

/// Paints the subtle grid pattern background
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 1;

    const spacing = 40.0;

    for (var x = 0.0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Paints the corner crosshair marks
class _CornerMarkPainter extends CustomPainter {
  final bool flipped;

  _CornerMarkPainter({this.flipped = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = 1;

    if (flipped) {
      canvas.drawLine(
          Offset(size.width - 12, size.height / 2),
          Offset(size.width, size.height / 2),
          paint);
      canvas.drawLine(
          Offset(size.width - 6, 0),
          Offset(size.width - 6, 12),
          paint);
    } else {
      canvas.drawLine(
          Offset(0, size.height / 2), Offset(12, size.height / 2), paint);
      canvas.drawLine(Offset(6, 0), Offset(6, 12), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
