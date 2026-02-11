import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:veda_client/veda_client.dart' as veda;

import '../design_system/veda_colors.dart';
import '../main.dart';

/// Full-screen teaching screen for a single module.
///
/// Auto-starts the TTS lecture on open. When the module finishes speaking the
/// user can ask questions via STT. When the user navigates back the module is
/// marked complete via the backend.
class ModuleTeachScreen extends StatefulWidget {
  final veda.Course course;
  final veda.Module module;
  final List<veda.Module> modules;
  final int minWords;
  final int maxWords;

  const ModuleTeachScreen({
    super.key,
    required this.course,
    required this.module,
    required this.modules,
    this.minWords = 100,
    this.maxWords = 500,
  });

  @override
  State<ModuleTeachScreen> createState() => _ModuleTeachScreenState();
}

class _ModuleTeachScreenState extends State<ModuleTeachScreen> {
  // Teaching state
  String _teachingContent = '';
  int _currentWordIndex = -1;
  List<String> _words = [];

  // Chat history
  final List<Map<String, String>> _chatHistory = [];

  // TTS
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isSpeaking = false;
  bool _isPaused = false;
  bool _ttsCompleted = false;
  bool _isGeneratingAudio = false;
  bool _isGeneratingContent = false;
  StreamSubscription<Duration>? _positionSubscription;

  // STT
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isListening = false;
  String _spokenText = '';

  // Completion
  bool _moduleMarkedComplete = false;

  @override
  void initState() {
    super.initState();
    _initializeAudio();
    _initializeStt();
    // Auto-start teaching
    Future.microtask(() => _startTeaching());
  }

  Future<void> _initializeAudio() async {
    // Audio player is managed per-chunk in _speakContent.
    // No global listener needed.
  }

  Future<void> _initializeStt() async {
    try {
      await _speechToText.initialize(
        onError: (error) => debugPrint('STT Error: $error'),
        onStatus: (status) => debugPrint('STT Status: $status'),
      );
    } catch (e) {
      debugPrint('⚠️ STT initialization failed (may not be available): $e');
    }
  }

  String _stripAudioTags(String text) {
    return text.replaceAll(RegExp(r'\[.*?\]'), '').trim();
  }

  @override
  void dispose() {
    _cancelChunkedPlayback = true;
    _audioPlayer.dispose();
    _positionSubscription?.cancel();
    _speechToText.stop();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────
  // TEACHING
  // ─────────────────────────────────────────────────────────────
  Future<void> _startTeaching() async {
    setState(() {
      _isGeneratingContent = true;
      _teachingContent = '';
      _currentWordIndex = -1;
      _ttsCompleted = false;
      _words = [];
      _chatHistory.clear();
    });

    try {
      final systemPrompt = _buildSystemPrompt();
      final userMessage = _buildUserMessage();

      final response = await client.gemini.startTeachingChat(
        widget.course.id!,
        systemPrompt: systemPrompt,
        firstMessage: userMessage,
        minWords: widget.minWords,
        maxWords: widget.maxWords,
      );

      if (!mounted) return;

      _chatHistory.add({'role': 'user', 'content': userMessage});
      _chatHistory.add({'role': 'model', 'content': response});

      final cleanText = _stripAudioTags(response);

      setState(() {
        _isGeneratingContent = false;
        _teachingContent = response;
        _words = cleanText.split(RegExp(r'\s+'));
        _currentWordIndex = -1;
      });

      await _speakContent();
    } catch (e) {
      debugPrint('❌ [Teaching] Error: $e');
      _showMsg('Failed to start teaching: $e');
      setState(() {
        _isGeneratingContent = false;
      });
    }
  }

  String _buildSystemPrompt() {
    final module = widget.module;
    final course = widget.course;
    final topics = module.items
            ?.map((item) => item.topic)
            .whereType<veda.Topic>()
            .toList() ??
        [];

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

Ensure your response is between ${widget.minWords} and ${widget.maxWords} words.

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

IMPORTANT:
- Maintain a professional, educational tone throughout
- Use "you" to address the student directly, but minimize casual language
- Present information systematically and thoroughly
- Use audio tags naturally (2-3 tags per paragraph)
- End with a clear, concise summary that reinforces the main concepts
- Never end with questions - always end with statements and summaries
''';
  }

  String _buildUserMessage() {
    return 'Deliver a comprehensive lecture on the "${widget.module.title}" module. Cover all topics in order with detailed explanations, examples, and key takeaways. Present the material in a structured, informative format.';
  }

  // ─────────────────────────────────────────────────────────────
  // TTS – Chunked paragraph-by-paragraph playback
  // ─────────────────────────────────────────────────────────────

  /// Chunk boundaries: for each chunk we store the word-index range it covers.
  final List<_ChunkMeta> _chunkMetas = [];
  int _currentChunkIndex = 0;
  bool _cancelChunkedPlayback = false;

  /// Split text into chunks by double-newline (paragraph) boundaries.
  /// Each chunk is small enough for ElevenLabs to respond in 2-4 seconds.
  List<String> _splitIntoChunks(String text) {
    // Split on paragraph boundaries
    final paragraphs = text
        .split(RegExp(r'\n\s*\n'))
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    if (paragraphs.isEmpty) return [text];

    // Merge very short paragraphs together, split very long ones
    final chunks = <String>[];
    var buffer = '';
    for (final para in paragraphs) {
      if (buffer.isEmpty) {
        buffer = para;
      } else if ((buffer.length + para.length) < 600) {
        buffer = '$buffer\n\n$para';
      } else {
        chunks.add(buffer);
        buffer = para;
      }
    }
    if (buffer.isNotEmpty) chunks.add(buffer);
    return chunks;
  }

  /// Build word-index ranges for each chunk so we can highlight the right
  /// words during playback of that chunk.
  void _buildChunkMetas(List<String> chunks) {
    _chunkMetas.clear();
    int wordOffset = 0;
    for (final chunk in chunks) {
      final cleanChunk = _stripAudioTags(chunk);
      final chunkWords = cleanChunk.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
      _chunkMetas.add(_ChunkMeta(
        startWordIndex: wordOffset,
        endWordIndex: wordOffset + chunkWords.length - 1,
        wordCount: chunkWords.length,
      ));
      wordOffset += chunkWords.length;
    }
  }

  Future<void> _speakContent() async {
    if (_teachingContent.isEmpty) return;

    _cancelChunkedPlayback = false;

    final chunks = _splitIntoChunks(_teachingContent);
    _buildChunkMetas(chunks);

    setState(() {
      _isGeneratingAudio = true;
      _isSpeaking = false;
      _isPaused = false;
      _currentChunkIndex = 0;
    });

    debugPrint('🎵 Split content into ${chunks.length} chunks for TTS');

    // Pre-fetch first chunk, then play chunks sequentially.
    // While chunk N plays, chunk N+1 is being fetched in parallel.
    Uint8List? nextAudioBytes;
    Future<Uint8List?>? prefetchFuture;

    for (int i = 0; i < chunks.length; i++) {
      if (_cancelChunkedPlayback || !mounted) break;

      _currentChunkIndex = i;
      final meta = _chunkMetas[i];

      // Get audio for this chunk (either from prefetch or fetch now)
      Uint8List? audioBytes;
      if (nextAudioBytes != null) {
        audioBytes = nextAudioBytes;
        nextAudioBytes = null;
      }

      // If no prefetched audio, fetch now
      if (audioBytes == null) {
        try {
          setState(() => _isGeneratingAudio = true);
          final bytes = await client.gemini.generateSpeech(chunks[i]);
          audioBytes = Uint8List.fromList(bytes);
        } catch (e) {
          debugPrint('❌ [ElevenLabs] Chunk $i error: $e');
          if (i == 0) {
            _showMsg('Failed to generate speech: $e');
            setState(() {
              _isGeneratingAudio = false;
              _isSpeaking = false;
              _ttsCompleted = true;
            });
            return;
          }
          continue; // Skip failed chunk, try next
        }
      }

      if (_cancelChunkedPlayback || !mounted) break;

      // Start prefetching next chunk while this one plays
      if (i + 1 < chunks.length) {
        prefetchFuture = _fetchChunkAudio(chunks[i + 1]);
      }

      // Play this chunk
      setState(() {
        _isGeneratingAudio = false;
        _isSpeaking = true;
        _currentWordIndex = meta.startWordIndex;
      });

      try {
        // Write to temp file — iOS can't play large data URIs
        final tempDir = Directory.systemTemp;
        final tempFile = File('${tempDir.path}/veda_tts_chunk_$i.mp3');
        await tempFile.writeAsBytes(audioBytes);

        await _audioPlayer.setAudioSource(
          AudioSource.file(tempFile.path),
        );

        _startWordHighlighting(meta);
        _audioPlayer.play();

        // Wait for this chunk to finish playing
        await _audioPlayer.playerStateStream.firstWhere(
          (state) => state.processingState == ProcessingState.completed,
        );

        // Clean up temp file
        tempFile.deleteSync();
      } catch (e) {
        debugPrint('❌ Playback error chunk $i: $e');
      }

      // Collect prefetched next chunk
      if (prefetchFuture != null) {
        nextAudioBytes = await prefetchFuture;
        prefetchFuture = null;
      }
    }

    if (mounted) {
      _positionSubscription?.cancel();
      setState(() {
        _isSpeaking = false;
        _isPaused = false;
        _ttsCompleted = true;
        if (_words.isNotEmpty) _currentWordIndex = _words.length - 1;
      });

      if (!_moduleMarkedComplete) _markComplete();
    }
  }

  Future<Uint8List?> _fetchChunkAudio(String chunkText) async {
    try {
      final bytes = await client.gemini.generateSpeech(chunkText);
      return Uint8List.fromList(bytes);
    } catch (e) {
      debugPrint('⚠️ Prefetch failed: $e');
      return null;
    }
  }

  void _startWordHighlighting(_ChunkMeta meta) {
    _positionSubscription?.cancel();
    if (_words.isEmpty) return;

    _positionSubscription = _audioPlayer.positionStream.listen(
      (position) {
        if (!_isSpeaking || _isPaused || !mounted) return;
        final duration = _audioPlayer.duration;
        if (duration == null || duration.inMilliseconds == 0) return;

        final progress = position.inMilliseconds / duration.inMilliseconds;
        final wordInChunk = (progress * meta.wordCount).floor().clamp(0, meta.wordCount - 1);
        final newIdx = meta.startWordIndex + wordInChunk;
        if (newIdx != _currentWordIndex) {
          setState(() => _currentWordIndex = newIdx);
        }
      },
      cancelOnError: false,
    );
  }

  Future<void> _pauseSpeaking() async {
    _positionSubscription?.cancel();
    setState(() {
      _isPaused = true;
      _isSpeaking = false;
    });
    await _audioPlayer.pause();
  }

  Future<void> _resumeSpeaking() async {
    setState(() {
      _isPaused = false;
      _isSpeaking = true;
    });
    final meta = _chunkMetas[_currentChunkIndex];
    _audioPlayer.play();
    _startWordHighlighting(meta);
  }

  // ─────────────────────────────────────────────────────────────
  // STT  (ask a question)
  // ─────────────────────────────────────────────────────────────
  Future<void> _startListening() async {
    if (!_ttsCompleted) return;

    final available = await _speechToText.initialize();
    if (!available) {
      _showMsg('Speech recognition not available');
      return;
    }

    setState(() {
      _isListening = true;
      _spokenText = '';
    });

    await _speechToText.listen(
      onResult: (result) {
        setState(() => _spokenText = result.recognizedWords);
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
      await _askQuestion(_spokenText);
    }
  }

  Future<void> _askQuestion(String question) async {
    _chatHistory.add({'role': 'user', 'content': question});
    setState(() => _ttsCompleted = false);

    try {
      final response = await client.gemini.answerTeachingQuestion(
        widget.course.id!,
        moduleTitle: widget.module.title,
        question: question,
        history: _chatHistory,
      );
      if (!mounted) return;

      _chatHistory.add({'role': 'model', 'content': response});
      final cleanText = _stripAudioTags(response);

      setState(() {
        _teachingContent = response;
        _words = cleanText.split(RegExp(r'\s+'));
      });

      await _speakContent();
    } catch (e) {
      debugPrint('❌ [Teaching] Error answering question: $e');
      _showMsg('Failed to answer question: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────
  // MARK MODULE COMPLETE
  // ─────────────────────────────────────────────────────────────
  Future<void> _markComplete() async {
    try {
      await client.lms.markModuleComplete(widget.course.id!, widget.module.id!);
      _moduleMarkedComplete = true;
      debugPrint('✅ Module "${widget.module.title}" marked complete');
    } catch (e) {
      debugPrint('⚠️ Failed to mark module complete: $e');
    }
  }

  void _showMsg(String message) {
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

  // ─────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VedaColors.black,
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: _isGeneratingContent
                ? _buildLoadingState()
                : _words.isEmpty
                    ? _buildIdleState()
                    : _buildTeachingContent(),
          ),
          _buildControls(),
        ],
      ),
    );
  }

  // ── App bar ──
  Widget _buildAppBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: VedaColors.zinc800, width: 1),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    border: Border.all(color: VedaColors.zinc700, width: 1),
                  ),
                  child: const Icon(Icons.arrow_back, size: 16, color: VedaColors.white),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.module.title.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: VedaColors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
              // Completion badge
              if (_moduleMarkedComplete)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  color: VedaColors.white,
                  child: Text(
                    'DONE',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: VedaColors.black,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Loading shimmer ──
  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'GENERATING LECTURE...',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                color: VedaColors.zinc500,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 32),
            for (int i = 0; i < 4; i++) ...[
              _ShimmerBar(delay: i * 150),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }

  // ── Idle (shouldn't normally appear) ──
  Widget _buildIdleState() {
    return Center(
      child: Text(
        'Preparing...',
        style: GoogleFonts.inter(
          fontSize: 14,
          color: VedaColors.zinc500,
        ),
      ),
    );
  }

  // ── Teaching content with highlighted words ──
  Widget _buildTeachingContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Module title
          Text(
            widget.module.title.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w300,
              color: VedaColors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: VedaColors.zinc800),
          const SizedBox(height: 28),

          // Generating audio indicator
          if (_isGeneratingAudio) ...[
            for (int i = 0; i < 3; i++) ...[
              _ShimmerBar(delay: i * 150),
              const SizedBox(height: 12),
            ],
          ] else ...[
            // Word-highlighted text
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: _words.asMap().entries.map((entry) {
                final idx = entry.key;
                final word = entry.value;
                final isCurrent = _isSpeaking && idx == _currentWordIndex;
                final isAdjacent = _isSpeaking &&
                    (idx == _currentWordIndex - 1 ||
                        idx == _currentWordIndex + 1);

                return Text(
                  word,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    height: 1.8,
                    fontWeight: isCurrent
                        ? FontWeight.w600
                        : (isAdjacent ? FontWeight.w400 : FontWeight.w300),
                    color: isCurrent
                        ? VedaColors.accent
                        : (isAdjacent
                            ? VedaColors.zinc500
                            : VedaColors.white),
                    letterSpacing: 0.3,
                    backgroundColor:
                        isCurrent ? VedaColors.zinc900 : Colors.transparent,
                  ),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ── Bottom controls ──
  Widget _buildControls() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        16 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: VedaColors.zinc800, width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Speaking state
              if (_isSpeaking) ...[
                _StatusChip(
                  label: 'SPEAKING...',
                  color: VedaColors.accent,
                ),
                const SizedBox(width: 12),
                _ControlButton(
                  icon: Icons.pause,
                  onTap: _pauseSpeaking,
                ),
                const SizedBox(width: 24),
              ],

              // Paused state
              if (_isPaused) ...[
                _StatusChip(
                  label: 'PAUSED',
                  color: VedaColors.zinc500,
                ),
                const SizedBox(width: 12),
                _ControlButton(
                  icon: Icons.play_arrow,
                  onTap: _resumeSpeaking,
                ),
                const SizedBox(width: 24),
              ],

              // Ask question button
              if (!_isListening)
                Opacity(
                  opacity: _ttsCompleted ? 1.0 : 0.4,
                  child: GestureDetector(
                    onTap: _ttsCompleted ? _startListening : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _ttsCompleted
                              ? VedaColors.white
                              : VedaColors.zinc700,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.mic_outlined,
                            size: 16,
                            color: _ttsCompleted
                                ? VedaColors.white
                                : VedaColors.zinc700,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'ASK A QUESTION',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: _ttsCompleted
                                  ? VedaColors.white
                                  : VedaColors.zinc700,
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
                GestureDetector(
                  onTap: _stopListening,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: VedaColors.accent, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.stop,
                            size: 16, color: VedaColors.accent),
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

          // Transcript
          if (_isListening && _spokenText.isNotEmpty) ...[
            const SizedBox(height: 12),
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
                      border:
                          Border.all(color: VedaColors.accent, width: 1),
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

// ─────────────────────────────────────────────────────────────
// REUSABLE WIDGETS
// ─────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              border: Border.all(color: color, width: 1),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              color: color,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ControlButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: VedaColors.white, width: 1),
        ),
        child: Icon(icon, size: 16, color: VedaColors.white),
      ),
    );
  }
}

class _ChunkMeta {
  final int startWordIndex;
  final int endWordIndex;
  final int wordCount;

  const _ChunkMeta({
    required this.startWordIndex,
    required this.endWordIndex,
    required this.wordCount,
  });
}

class _ShimmerBar extends StatefulWidget {
  final int delay;
  const _ShimmerBar({required this.delay});

  @override
  State<_ShimmerBar> createState() => _ShimmerBarState();
}

class _ShimmerBarState extends State<_ShimmerBar>
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
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat(reverse: true);
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
              color: VedaColors.zinc800.withValues(alpha: _animation.value),
              width: 1,
            ),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: 0.7 + (_animation.value * 0.3),
            child: Container(
              color: VedaColors.zinc900.withValues(alpha: _animation.value * 0.5),
            ),
          ),
        );
      },
    );
  }
}
