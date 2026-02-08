import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:veda_client/veda_client.dart' as veda;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:just_audio/just_audio.dart';

import '../../../../design_system/veda_colors.dart';
import '../../../../main.dart';

/// Interactive teaching panel with TTS and STT
class TeachingPanel extends StatefulWidget {
  final veda.Course course;
  final List<veda.Module> modules;

  const TeachingPanel({
    super.key,
    required this.course,
    required this.modules,
  });

  @override
  State<TeachingPanel> createState() => _TeachingPanelState();
}

class _TeachingPanelState extends State<TeachingPanel> {
  // Selected module for teaching
  veda.Module? _selectedModule;
  int _minWords = 100;
  int _maxWords = 500;

  // Teaching state
  bool _isTeaching = false;
  String _teachingContent = ''; // Original content with audio tags
  String _cleanContent = ''; // Content without audio tags for display
  String _displayedContent = '';
  int _currentWordIndex = -1;
  List<String> _words = []; // Words without audio tags

  // Chat history for questions and answers
  final List<Map<String, String>> _chatHistory = [];

  // TTS state (ElevenLabs + just_audio)
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isSpeaking = false;
  bool _isPaused = false;
  bool _ttsCompleted = false;
  bool _isGeneratingAudio = false; // Loading state for audio generation
  StreamSubscription<Duration>? _positionSubscription;

  // STT state
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isListening = false;
  String _spokenText = '';

  @override
  void initState() {
    super.initState();
    _initializeAudio();
    _initializeStt();
  }

  Future<void> _initializeAudio() async {
    // Listen to player state changes
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        setState(() {
          _isSpeaking = false;
          _isPaused = false;
          _ttsCompleted = true;
          // Don't reset word index - keep all words visible
          if (_words.isNotEmpty) {
            _currentWordIndex = _words.length - 1;
          }
        });
        _positionSubscription?.cancel();
      }
    });
  }

  Future<void> _initializeStt() async {
    await _speechToText.initialize(
      onError: (error) => print('STT Error: $error'),
      onStatus: (status) => print('STT Status: $status'),
    );
  }

  /// Remove audio tags from text for display
  String _stripAudioTags(String text) {
    // Remove all [tag] patterns
    return text.replaceAll(RegExp(r'\[.*?\]'), '').trim();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _positionSubscription?.cancel();
    _speechToText.stop();
    super.dispose();
  }

  Future<void> _showModuleSelectionDialog() async {
    if (widget.modules.isEmpty) {
      _showMessage('No modules found. Generate table of contents first.');
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => _ModuleSelectionDialog(
        course: widget.course,
        modules: widget.modules,
        initialModule: _selectedModule,
        initialMinWords: _minWords,
        initialMaxWords: _maxWords,
        onConfirm: (module, minWords, maxWords) {
          setState(() {
            _selectedModule = module;
            _minWords = minWords;
            _maxWords = maxWords;
          });
          _startTeaching();
        },
      ),
    );
  }

  Future<void> _startTeaching() async {
    if (_selectedModule == null) return;

    setState(() {
      _isTeaching = true;
      _teachingContent = '';
      _cleanContent = '';
      _displayedContent = '';
      _currentWordIndex = -1;
      _ttsCompleted = false;
      _words = [];
      _chatHistory.clear(); // Clear previous history
    });

    try {
      final systemPrompt = _buildTeachingSystemPrompt();
      final userMessage = _buildTeachingUserMessage();

      final response = await client.gemini.startTeachingChat(
        widget.course.id!,
        systemPrompt: systemPrompt,
        firstMessage: userMessage,
        minWords: _minWords,
        maxWords: _maxWords,
      );

      if (!mounted) return;

      _chatHistory.add({'role': 'user', 'content': userMessage});
      _chatHistory.add({'role': 'model', 'content': response});

      // Strip audio tags from display
      final cleanText = _stripAudioTags(response);

      setState(() {
        _teachingContent = response; // Keep tags for TTS
        _cleanContent = cleanText; // Remove tags for display
        _words = cleanText.split(RegExp(r'\s+'));
        _currentWordIndex = -1; // Reset word index
        _displayedContent = ''; // No typing effect needed
      });

      // Start TTS immediately (no typing effect)
      await _speakContent();
    } catch (e) {
      print('❌ [Teaching] Error: $e');
      _showMessage('Failed to start teaching: $e');
      setState(() => _isTeaching = false);
    }
  }

  String _buildTeachingSystemPrompt() {
    final module = _selectedModule!;
    final course = widget.course;

    // Get all topics in this module
    final topics = module.items?.map((item) => item.topic).whereType<veda.Topic>().toList() ?? [];

    return '''
You are an expert lecturer for the course "${course.title}".

COURSE CONTEXT:
${course.description ?? 'No description'}

${course.systemPrompt != null ? 'TEACHING FOCUS:\n${course.systemPrompt}\n' : ''}

MODULE TO TEACH:
Title: ${module.title}
Description: ${module.description ?? 'No description'}

TOPICS IN THIS MODULE (in order):
${topics.asMap().entries.map((e) => '${e.key + 1}. ${e.value.title}${e.value.description != null ? ' - ${e.value.description}' : ''}').join('\n')}

YOUR ROLE:
You are delivering an informative lecture. Present this module and its topics in a clear, structured, educational format.
Structure your lecture as follows:
1. Brief introduction to the module and its importance
2. Systematic coverage of each topic with detailed explanations
3. Concrete examples and real-world applications for each concept
4. Key takeaways and summary of what was covered

TEACHING STYLE:
- Deliver information directly and authoritatively
- Present facts, concepts, and principles clearly
- Use specific examples and case studies
- Explain the "what", "why", and "how" of each topic
- Build knowledge progressively from fundamentals to advanced concepts
- End with a comprehensive summary of the key points covered
- DO NOT ask open-ended questions or prompt for discussion
- DO NOT use conversational phrases like "What do you think?" or "Can you imagine?"
- Focus on information delivery, not interaction

Ensure your response is between $_minWords and $_maxWords words.

AUDIO TAGS FOR EXPRESSIVENESS:
Your response will be converted to speech using ElevenLabs TTS with audio tag support.
Use square bracket tags [like this] to make your lecture more engaging:

EMOTIONAL TONE (use at sentence start):
- [excited] for introducing fascinating new concepts
- [serious] for critical or important points
- [emphasizes] before key terms and definitions

DELIVERY CONTROL:
- [pauses] for dramatic effect or to let important information sink in
- [softly] for nuanced points or caveats

Example usage:
"[excited] This module introduces a fundamental concept in computer science. [pauses] [emphasizes] Variables are containers that store data values. They form the foundation of all programming logic. [serious] Understanding variables is essential because every program you write will use them extensively."

IMPORTANT:
- Maintain a professional, educational tone throughout
- Use "you" to address the student directly, but minimize casual language
- Present information systematically and thoroughly
- Use audio tags naturally (2-3 tags per paragraph)
- End with a clear, concise summary that reinforces the main concepts
- Never end with questions - always end with statements and summaries
''';
  }

  String _buildTeachingUserMessage() {
    return 'Deliver a comprehensive lecture on the "${_selectedModule!.title}" module. Cover all topics in order with detailed explanations, examples, and key takeaways. Present the material in a structured, informative format.';
  }

  /// Generate speech using ElevenLabs API and play it
  Future<void> _speakContent() async {
    if (_teachingContent.isEmpty) return;

    setState(() {
      _isGeneratingAudio = true; // Show loading animation
      _isSpeaking = false;
      _isPaused = false;
    });

    try {
      final audioBytes = await client.gemini.generateSpeech(_teachingContent);

      if (!mounted) return;

      setState(() {
        _isGeneratingAudio = false; // Hide loading animation
        _isSpeaking = true; // Start showing progressive words
        _currentWordIndex = 0; // Reset to first word when audio starts
      });

      // Load audio from bytes
      await _audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.dataFromBytes(
            audioBytes,
            mimeType: 'audio/mpeg',
          ),
        ),
      );

      // Start playback (don't await - we want to continue immediately)
      _audioPlayer.play();

      // Start word highlighting immediately while audio is playing
      _startWordHighlighting();
    } catch (e) {
      print('❌ [ElevenLabs] Error: $e');
      _showMessage('Failed to generate speech: $e');
      setState(() {
        _isGeneratingAudio = false;
        _isSpeaking = false;
        _ttsCompleted = true;
      });
    }
  }

  /// Pause TTS playback
  Future<void> _pauseSpeaking() async {
    _positionSubscription?.cancel();
    setState(() {
      _isPaused = true;
      _isSpeaking = false;
    });
    await _audioPlayer.pause();
  }

  /// Resume TTS playback
  Future<void> _resumeSpeaking() async {
    setState(() {
      _isPaused = false;
      _isSpeaking = true;
    });
    _audioPlayer.play();
    _startWordHighlighting();
  }

  /// Sync word highlighting with actual audio playback position
  void _startWordHighlighting() {
    _positionSubscription?.cancel();
    if (_words.isEmpty) return;

    _positionSubscription = _audioPlayer.positionStream.listen(
      (position) {
        if (!_isSpeaking || _isPaused || !mounted) {
          _positionSubscription?.cancel();
          return;
        }

        final duration = _audioPlayer.duration;
        if (duration == null || duration.inMilliseconds == 0) return;

        final progress = position.inMilliseconds / duration.inMilliseconds;
        final newWordIndex = (progress * _words.length).floor();
        final clampedIndex = newWordIndex.clamp(0, _words.length - 1);

        if (clampedIndex != _currentWordIndex) {
          setState(() {
            _currentWordIndex = clampedIndex;
          });
        }

        if (position >= duration) {
          _positionSubscription?.cancel();
        }
      },
      cancelOnError: false,
    );
  }

  Future<void> _startListening() async {
    if (!_ttsCompleted) return;

    final available = await _speechToText.initialize();
    if (!available) {
      _showMessage('Speech recognition not available');
      return;
    }

    setState(() {
      _isListening = true;
      _spokenText = '';
    });

    await _speechToText.listen(
      onResult: (result) {
        setState(() {
          _spokenText = result.recognizedWords;
        });
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      listenOptions: stt.SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
        listenMode: stt.ListenMode.confirmation,
      ),
    );
  }

  Future<void> _stopListening() async {
    await _speechToText.stop();
    setState(() => _isListening = false);

    if (_spokenText.isNotEmpty) {
      // Send question to AI
      await _askQuestion(_spokenText);
    }
  }

  Future<void> _askQuestion(String question) async {
    // Add user question to history
    _chatHistory.add({'role': 'user', 'content': question});

    // Don't clear words yet - keep them visible until new audio starts
    setState(() {
      _ttsCompleted = false;
    });

    try {
      final response = await client.gemini.answerTeachingQuestion(
        widget.course.id!,
        moduleTitle: _selectedModule!.title,
        question: question,
        history: _chatHistory,
      );

      if (!mounted) return;

      // Add AI response to history
      _chatHistory.add({'role': 'model', 'content': response});

      // Strip audio tags from display
      final cleanText = _stripAudioTags(response);

      // Store new content but don't update display yet
      final newWords = cleanText.split(RegExp(r'\s+'));

      setState(() {
        _teachingContent = response; // Keep tags for TTS
        _cleanContent = cleanText; // Remove tags for display
        _words = newWords;
        // Keep current word index until audio starts
        _displayedContent = ''; // No typing effect needed
      });

      // Speak response immediately - will reset word index when audio starts
      await _speakContent();
    } catch (e) {
      print('❌ [Teaching] Error answering question: $e');
      _showMessage('Failed to answer question: $e');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message.toUpperCase(),
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            color: VedaColors.white,
            letterSpacing: 1.0,
          ),
        ),
        backgroundColor: VedaColors.zinc900,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: VedaColors.zinc800, width: 1),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isTeaching && _displayedContent.isEmpty) {
      // Initial state - show start button
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'INTERACTIVE TEACHING MODE',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w300,
                color: VedaColors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 24),
            InkWell(
              onTap: _showModuleSelectionDialog,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: VedaColors.white, width: 1),
                ),
                child: Text(
                  'START TEACHING SESSION',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: VedaColors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Teaching in progress - show content with highlighted words
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(48),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Module title
                    if (_selectedModule != null) ...[
                      Text(
                        _selectedModule!.title.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w300,
                          color: VedaColors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(height: 1, color: VedaColors.zinc800),
                      const SizedBox(height: 36),
                    ],

                    // Teaching content with word highlighting
                    _buildHighlightedText(),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Bottom controls
        _buildControls(),
      ],
    );
  }

  Widget _buildHighlightedText() {
    if (_words.isEmpty) {
      return const SizedBox.shrink();
    }

    // Show loading indicator if audio is being generated
    if (_isGeneratingAudio) {
      return _buildLoadingAnimation();
    }

    // SHOW ALL WORDS - Highlight current word + adjacent words
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: _words.asMap().entries.map((entry) {
        final index = entry.key;
        final word = entry.value;

        // Highlight current word (strongest), previous and next words (subtle)
        final isCurrent = _isSpeaking && index == _currentWordIndex;
        final isAdjacent = _isSpeaking &&
                          (index == _currentWordIndex - 1 || index == _currentWordIndex + 1);

        return Text(
          word,
          style: GoogleFonts.inter(
            fontSize: 16,
            height: 1.8,
            fontWeight: isCurrent ? FontWeight.w600 : (isAdjacent ? FontWeight.w400 : FontWeight.w300),
            color: isCurrent ? VedaColors.accent : (isAdjacent ? VedaColors.zinc500 : VedaColors.white),
            letterSpacing: 0.3,
            backgroundColor: isCurrent ? VedaColors.zinc900 : Colors.transparent,
          ),
        );
      }).toList(),
    );
  }

  /// Loading animation while audio is being generated
  Widget _buildLoadingAnimation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Animated shimmer bars
        for (int i = 0; i < 3; i++) ...[
          _AnimatedShimmerBar(delay: i * 150),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: VedaColors.zinc800, width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main controls row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Speaking indicator with pause button
              if (_isSpeaking) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: VedaColors.accent, width: 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          border: Border.all(color: VedaColors.accent, width: 1),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'SPEAKING...',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          color: VedaColors.accent,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Pause button
                InkWell(
                  onTap: _pauseSpeaking,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: VedaColors.white, width: 1),
                    ),
                    child: const Icon(Icons.pause, size: 16, color: VedaColors.white),
                  ),
                ),
                const SizedBox(width: 24),
              ],

              // Paused indicator with resume button
              if (_isPaused) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: VedaColors.zinc700, width: 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          border: Border.all(color: VedaColors.zinc700, width: 1),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'PAUSED',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          color: VedaColors.zinc500,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Resume button
                InkWell(
                  onTap: _resumeSpeaking,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: VedaColors.white, width: 1),
                    ),
                    child: const Icon(Icons.play_arrow, size: 16, color: VedaColors.white),
                  ),
                ),
                const SizedBox(width: 24),
              ],

              // Ask question button - always visible but disabled when not ready
              if (!_isListening)
                Opacity(
                  opacity: _ttsCompleted ? 1.0 : 0.4,
                  child: InkWell(
                    onTap: _ttsCompleted ? _startListening : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _ttsCompleted ? VedaColors.white : VedaColors.zinc700,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.mic_outlined,
                            size: 16,
                            color: _ttsCompleted ? VedaColors.white : VedaColors.zinc700,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'ASK A QUESTION',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: _ttsCompleted ? VedaColors.white : VedaColors.zinc700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Stop listening button
              if (_isListening)
                InkWell(
                  onTap: _stopListening,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: VedaColors.accent, width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.stop, size: 16, color: VedaColors.accent),
                        const SizedBox(width: 12),
                        Text(
                          'STOP LISTENING',
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
            ],
          ),

          // Transcript - show only when listening
          if (_isListening && _spokenText.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: VedaColors.zinc800, width: 1),
              ),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      border: Border.all(color: VedaColors.accent, width: 1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '"$_spokenText"',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        color: VedaColors.white,
                        letterSpacing: 0.3,
                        fontStyle: FontStyle.italic,
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

/// Animated shimmer bar for loading state
class _AnimatedShimmerBar extends StatefulWidget {
  final int delay;

  const _AnimatedShimmerBar({required this.delay});

  @override
  State<_AnimatedShimmerBar> createState() => _AnimatedShimmerBarState();
}

class _AnimatedShimmerBarState extends State<_AnimatedShimmerBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Delay before starting animation
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
          height: 8,
          decoration: BoxDecoration(
            border: Border.all(
              color: VedaColors.zinc800.withOpacity(_animation.value),
              width: 1,
            ),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: 0.7 + (_animation.value * 0.3),
            child: Container(
              color: VedaColors.zinc900.withOpacity(_animation.value * 0.5),
            ),
          ),
        );
      },
    );
  }
}

/// Dialog for selecting module and word count
class _ModuleSelectionDialog extends StatefulWidget {
  final veda.Course course;
  final List<veda.Module> modules;
  final veda.Module? initialModule;
  final int initialMinWords;
  final int initialMaxWords;
  final void Function(veda.Module module, int minWords, int maxWords) onConfirm;

  const _ModuleSelectionDialog({
    required this.course,
    required this.modules,
    this.initialModule,
    required this.initialMinWords,
    required this.initialMaxWords,
    required this.onConfirm,
  });

  @override
  State<_ModuleSelectionDialog> createState() => _ModuleSelectionDialogState();
}

class _ModuleSelectionDialogState extends State<_ModuleSelectionDialog> {
  veda.Module? _selectedModule;
  late int _minWords;
  late int _maxWords;

  @override
  void initState() {
    super.initState();
    _selectedModule = widget.initialModule ?? widget.modules.first;
    _minWords = widget.initialMinWords;
    _maxWords = widget.initialMaxWords;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: VedaColors.black,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        decoration: BoxDecoration(
          border: Border.all(color: VedaColors.white, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: VedaColors.zinc800, width: 1),
                ),
              ),
              child: Text(
                'START TEACHING SESSION',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: VedaColors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course name
                  Text(
                    'COURSE',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      color: VedaColors.zinc500,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.course.title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      color: VedaColors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Module selection
                  Text(
                    'SELECT MODULE',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      color: VedaColors.zinc500,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: VedaColors.zinc800, width: 1),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<veda.Module>(
                        value: _selectedModule,
                        isExpanded: true,
                        dropdownColor: VedaColors.black,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: VedaColors.white,
                          letterSpacing: 0.3,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        items: widget.modules.map((module) {
                          return DropdownMenuItem(
                            value: module,
                            child: Text(
                              module.title,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w300,
                                color: VedaColors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (module) {
                          setState(() => _selectedModule = module);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Word count range
                  Text(
                    'WORD COUNT RANGE',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      color: VedaColors.zinc500,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'MIN',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 9,
                                color: VedaColors.zinc600,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: VedaColors.zinc800, width: 1),
                              ),
                              child: TextField(
                                controller: TextEditingController(text: _minWords.toString()),
                                keyboardType: TextInputType.number,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: VedaColors.white,
                                  letterSpacing: 0.3,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  hintText: '100',
                                  hintStyle: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: VedaColors.zinc700,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                onChanged: (value) {
                                  final parsed = int.tryParse(value);
                                  if (parsed != null) {
                                    setState(() => _minWords = parsed);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'MAX',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 9,
                                color: VedaColors.zinc600,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: VedaColors.zinc800, width: 1),
                              ),
                              child: TextField(
                                controller: TextEditingController(text: _maxWords.toString()),
                                keyboardType: TextInputType.number,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: VedaColors.white,
                                  letterSpacing: 0.3,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  hintText: '500',
                                  hintStyle: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: VedaColors.zinc700,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                onChanged: (value) {
                                  final parsed = int.tryParse(value);
                                  if (parsed != null) {
                                    setState(() => _maxWords = parsed);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Footer buttons
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: VedaColors.zinc800, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: VedaColors.zinc700, width: 1),
                      ),
                      child: Text(
                        'CANCEL',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: VedaColors.zinc500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: () {
                      if (_selectedModule != null) {
                        Navigator.of(context).pop();
                        widget.onConfirm(_selectedModule!, _minWords, _maxWords);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: VedaColors.white, width: 1),
                      ),
                      child: Text(
                        'START TEACHING',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: VedaColors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
