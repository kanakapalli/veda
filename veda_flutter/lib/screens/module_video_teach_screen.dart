import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:veda_client/veda_client.dart' as veda;
import 'package:video_player/video_player.dart';

import '../design_system/veda_colors.dart';
import '../main.dart';

/// A video item to play – either from a module or a topic.
class _VideoEntry {
  final String url;
  final String title;
  final String? subtitle;
  final bool isModule;

  const _VideoEntry({
    required this.url,
    required this.title,
    this.subtitle,
    this.isModule = false,
  });
}

/// Full-screen video teaching screen for a module.
///
/// Plays the module's video first, then each topic's video in sort-order.
/// When all videos finish the module is marked complete.
class ModuleVideoTeachScreen extends StatefulWidget {
  final veda.Course course;
  final veda.Module module;

  const ModuleVideoTeachScreen({
    super.key,
    required this.course,
    required this.module,
  });

  @override
  State<ModuleVideoTeachScreen> createState() => _ModuleVideoTeachScreenState();
}

class _ModuleVideoTeachScreenState extends State<ModuleVideoTeachScreen> {
  // Playlist
  final List<_VideoEntry> _playlist = [];
  int _currentIndex = 0;

  // Player
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  String? _errorMessage;
  bool _moduleMarkedComplete = false;
  bool _allDone = false;

  // STT (ask a question)
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isListening = false;
  String _spokenText = '';
  bool _isAskingQuestion = false;
  String? _answerText;
  final List<Map<String, String>> _chatHistory = [];

  @override
  void initState() {
    super.initState();
    _buildPlaylist();
    _initializeStt();
    if (_playlist.isNotEmpty) {
      _initPlayer(_currentIndex);
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'No videos found for this module.';
      });
    }
  }

  /// Builds an ordered playlist: module video first, then topic videos by
  /// sort order.
  void _buildPlaylist() {
    final module = widget.module;

    // 1. Module-level video
    if (module.videoUrl != null && module.videoUrl!.trim().isNotEmpty) {
      _playlist.add(_VideoEntry(
        url: module.videoUrl!.trim(),
        title: module.title,
        subtitle: 'Module introduction',
        isModule: true,
      ));
    }

    // 2. Topic videos in sort order
    final items = module.items?.toList() ?? [];
    items.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    for (final item in items) {
      final topic = item.topic;
      if (topic != null &&
          topic.videoUrl != null &&
          topic.videoUrl!.trim().isNotEmpty) {
        _playlist.add(_VideoEntry(
          url: topic.videoUrl!.trim(),
          title: topic.title,
          subtitle: item.contextualDescription ?? topic.description,
        ));
      }
    }
  }

  Future<void> _initPlayer(int index) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Dispose previous controllers
    await _disposeControllers();

    final entry = _playlist[index];
    debugPrint('▶️ Loading video $index: ${entry.title} — ${entry.url}');

    try {
      final uri = Uri.parse(entry.url);
      final vc = VideoPlayerController.networkUrl(uri);
      await vc.initialize();

      if (!mounted) {
        vc.dispose();
        return;
      }

      final cc = ChewieController(
        videoPlayerController: vc,
        autoPlay: true,
        allowFullScreen: true,
        allowMuting: true,
        showControlsOnInitialize: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: VedaColors.white,
          handleColor: VedaColors.white,
          bufferedColor: VedaColors.zinc700,
          backgroundColor: VedaColors.zinc900,
        ),
      );

      // Listen for completion to auto-advance
      vc.addListener(_onVideoStateChanged);

      setState(() {
        _videoController = vc;
        _chewieController = cc;
        _currentIndex = index;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Video init error: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load video: $e';
      });
    }
  }

  void _onVideoStateChanged() {
    final vc = _videoController;
    if (vc == null) return;

    if (vc.value.position >= vc.value.duration &&
        vc.value.duration > Duration.zero &&
        !vc.value.isPlaying) {
      _onVideoCompleted();
    }
  }

  void _onVideoCompleted() {
    // Remove listener to avoid double-fires
    _videoController?.removeListener(_onVideoStateChanged);

    if (_currentIndex < _playlist.length - 1) {
      // Play next
      _initPlayer(_currentIndex + 1);
    } else {
      // All videos done — go back to portrait
      _exitLandscape();
      setState(() => _allDone = true);
      if (!_moduleMarkedComplete) _markComplete();
    }
  }

  Future<void> _disposeControllers() async {
    _videoController?.removeListener(_onVideoStateChanged);
    _chewieController?.dispose();
    _chewieController = null;
    await _videoController?.dispose();
    _videoController = null;
  }

  @override
  void dispose() {
    _videoController?.removeListener(_onVideoStateChanged);
    _chewieController?.dispose();
    _videoController?.dispose();
    _speechToText.stop();
    // Restore portrait orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  // ── Navigation ──

  void _playPrevious() {
    if (_currentIndex > 0) {
      _initPlayer(_currentIndex - 1);
    }
  }

  void _playNext() {
    if (_currentIndex < _playlist.length - 1) {
      _initPlayer(_currentIndex + 1);
    }
  }

  void _playAtIndex(int index) {
    if (index >= 0 && index < _playlist.length && index != _currentIndex) {
      _initPlayer(index);
    }
  }

  // ── Mark complete ──

  Future<void> _markComplete() async {
    try {
      await client.lms
          .markModuleComplete(widget.course.id!, widget.module.id!);
      _moduleMarkedComplete = true;
      debugPrint('✅ Module "${widget.module.title}" marked complete');
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('⚠️ Failed to mark module complete: $e');
    }
  }

  // ── STT / Ask a question ──

  Future<void> _initializeStt() async {
    try {
      await _speechToText.initialize(
        onError: (error) => debugPrint('STT Error: $error'),
        onStatus: (status) => debugPrint('STT Status: $status'),
      );
    } catch (e) {
      debugPrint('⚠️ STT initialization failed: $e');
    }
  }

  Future<void> _startListening() async {
    // Pause video while listening
    _videoController?.pause();

    final available = await _speechToText.initialize();
    if (!available) {
      _showMsg('Speech recognition not available');
      return;
    }

    setState(() {
      _isListening = true;
      _spokenText = '';
      _answerText = null;
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
    setState(() {
      _isAskingQuestion = true;
      _answerText = null;
    });

    try {
      final response = await client.gemini.answerTeachingQuestion(
        widget.course.id!,
        moduleTitle: widget.module.title,
        question: question,
        history: _chatHistory,
      );
      if (!mounted) return;

      _chatHistory.add({'role': 'model', 'content': response});

      setState(() {
        _isAskingQuestion = false;
        _answerText = response;
      });
    } catch (e) {
      debugPrint('❌ Error answering question: $e');
      _showMsg('Failed to get answer: $e');
      setState(() => _isAskingQuestion = false);
    }
  }

  void _dismissAnswer() {
    setState(() => _answerText = null);
    // Resume video playback
    _videoController?.play();
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

  /// Restart the entire playlist from the beginning.
  void _rewatch() {
    setState(() {
      _allDone = false;
      _currentIndex = 0;
    });
    _initPlayer(0);
  }

  /// Enter landscape fullscreen mode for video playback.
  void _enterLandscape() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  /// Exit landscape and return to portrait.
  void _exitLandscape() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  // ─────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        final isLandscape = orientation == Orientation.landscape;

        // In landscape: fullscreen video only
        if (isLandscape && _chewieController != null && !_allDone) {
          return Scaffold(
            backgroundColor: VedaColors.black,
            body: Stack(
              children: [
                Center(
                  child: Chewie(controller: _chewieController!),
                ),
                // Exit fullscreen button
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 16,
                  child: GestureDetector(
                    onTap: _exitLandscape,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: VedaColors.black.withValues(alpha: 0.6),
                        border: Border.all(
                            color: VedaColors.zinc700, width: 1),
                      ),
                      child: const Icon(Icons.fullscreen_exit,
                          size: 18, color: VedaColors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Portrait: normal layout
        return Scaffold(
          backgroundColor: VedaColors.black,
          body: Column(
            children: [
              _buildAppBar(),
              Expanded(child: _buildBody()),
              _buildBottomBar(),
            ],
          ),
        );
      },
    );
  }

  // ── App bar ──

  Widget _buildAppBar() {
    final entry =
        _playlist.isNotEmpty ? _playlist[_currentIndex] : null;

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
                    border:
                        Border.all(color: VedaColors.zinc700, width: 1),
                  ),
                  child: const Icon(Icons.arrow_back,
                      size: 16, color: VedaColors.white),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (entry?.title ?? widget.module.title).toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: VedaColors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (entry?.subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        entry!.subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w300,
                          color: VedaColors.zinc500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Progress indicator
              if (_playlist.length > 1)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: VedaColors.zinc700, width: 1),
                  ),
                  child: Text(
                    '${_currentIndex + 1}/${_playlist.length}',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      color: VedaColors.zinc500,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              if (_moduleMarkedComplete) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
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
            ],
          ),
        ),
      ),
    );
  }

  // ── Body ──

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }
    if (_errorMessage != null) {
      return _buildErrorState();
    }
    if (_allDone) {
      return _buildCompletedState();
    }
    if (_chewieController != null) {
      return _buildVideoPlayer();
    }
    return _buildLoadingState();
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: VedaColors.zinc500,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'LOADING VIDEO...',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              color: VedaColors.zinc500,
              letterSpacing: 2.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                size: 32, color: VedaColors.zinc500),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w300,
                color: VedaColors.zinc500,
              ),
            ),
            const SizedBox(height: 24),
            // Retry or skip
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTextButton('RETRY', () => _initPlayer(_currentIndex)),
                if (_currentIndex < _playlist.length - 1) ...[
                  const SizedBox(width: 16),
                  _buildTextButton('SKIP', _playNext),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                border: Border.all(color: VedaColors.white, width: 1),
              ),
              child: const Icon(Icons.check,
                  size: 24, color: VedaColors.white),
            ),
            const SizedBox(height: 24),
            Text(
              'ALL VIDEOS COMPLETED',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 12,
                color: VedaColors.white,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_playlist.length} video${_playlist.length == 1 ? '' : 's'} watched',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w300,
                color: VedaColors.zinc500,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTextButton(
                    'GO BACK', () => Navigator.of(context).pop()),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: _rewatch,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: VedaColors.accent, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.replay,
                            size: 14, color: VedaColors.accent),
                        const SizedBox(width: 8),
                        Text(
                          'RE-WATCH',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            color: VedaColors.accent,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return Column(
      children: [
        // Video player with fullscreen toggle
        Expanded(
          child: Stack(
            children: [
              Center(
                child: AspectRatio(
                  aspectRatio:
                      _videoController?.value.aspectRatio ?? 16 / 9,
                  child: Chewie(controller: _chewieController!),
                ),
              ),
              // Landscape / fullscreen button
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: _enterLandscape,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: VedaColors.black.withValues(alpha: 0.6),
                      border:
                          Border.all(color: VedaColors.zinc700, width: 1),
                    ),
                    child: const Icon(Icons.fullscreen,
                        size: 16, color: VedaColors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Playlist (if more than one video)
        if (_playlist.length > 1) _buildPlaylistView(),
      ],
    );
  }

  // ── Playlist ──

  Widget _buildPlaylistView() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 180),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: VedaColors.zinc800, width: 1),
        ),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _playlist.length,
        itemBuilder: (context, index) {
          final entry = _playlist[index];
          final isActive = index == _currentIndex;
          final isPast = index < _currentIndex;

          return GestureDetector(
            onTap: () => _playAtIndex(index),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              color: isActive ? VedaColors.zinc900 : Colors.transparent,
              child: Row(
                children: [
                  // Index / status
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isActive
                            ? VedaColors.white
                            : (isPast
                                ? VedaColors.zinc700
                                : VedaColors.zinc800),
                        width: 1,
                      ),
                      color: isPast
                          ? VedaColors.zinc800
                          : Colors.transparent,
                    ),
                    child: Center(
                      child: isPast
                          ? const Icon(Icons.check,
                              size: 12, color: VedaColors.zinc500)
                          : (isActive
                              ? const Icon(Icons.play_arrow,
                                  size: 12, color: VedaColors.white)
                              : Text(
                                  '${index + 1}',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 10,
                                    color: VedaColors.zinc500,
                                  ),
                                )),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: isActive
                                ? FontWeight.w600
                                : FontWeight.w300,
                            color: isActive
                                ? VedaColors.white
                                : (isPast
                                    ? VedaColors.zinc500
                                    : VedaColors.white),
                          ),
                        ),
                        if (entry.isModule)
                          Text(
                            'MODULE VIDEO',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 9,
                              color: VedaColors.zinc500,
                              letterSpacing: 1.0,
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Playing indicator
                  if (isActive)
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: VedaColors.accent,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Bottom bar ──

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: VedaColors.zinc800, width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Answer display
          if (_answerText != null) ...[
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 200),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: VedaColors.zinc900,
                border: Border.all(color: VedaColors.zinc700, width: 1),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: VedaColors.accent,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'ANSWER',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 9,
                          color: VedaColors.accent,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: _dismissAnswer,
                        child: const Icon(Icons.close,
                            size: 14, color: VedaColors.zinc500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Text(
                        _answerText!,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w300,
                          color: VedaColors.white,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Generating answer indicator
          if (_isAskingQuestion) ...[
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: VedaColors.zinc800, width: 1),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: VedaColors.zinc500,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'THINKING...',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      color: VedaColors.zinc500,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Listening transcript
          if (_isListening && _spokenText.isNotEmpty) ...[
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
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

          // Controls row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Previous
              if (_currentIndex > 0)
                GestureDetector(
                  onTap: _playPrevious,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: VedaColors.zinc700, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.skip_previous,
                            size: 14, color: VedaColors.white),
                        const SizedBox(width: 8),
                        Text(
                          'PREV',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            color: VedaColors.white,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                const SizedBox.shrink(),

              // Ask question / Stop listening button
              if (_isListening)
                GestureDetector(
                  onTap: _stopListening,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: VedaColors.accent, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.stop,
                            size: 14, color: VedaColors.accent),
                        const SizedBox(width: 8),
                        Text(
                          'DONE',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            color: VedaColors.accent,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (!_isAskingQuestion)
                GestureDetector(
                  onTap: _startListening,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: VedaColors.zinc700, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.mic_outlined,
                            size: 14, color: VedaColors.white),
                        const SizedBox(width: 8),
                        Text(
                          'ASK',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            color: VedaColors.white,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Next
              if (_currentIndex < _playlist.length - 1)
                GestureDetector(
                  onTap: _playNext,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: VedaColors.zinc700, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'NEXT',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            color: VedaColors.white,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.skip_next,
                            size: 14, color: VedaColors.white),
                      ],
                    ),
                  ),
                )
              else
                const SizedBox.shrink(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: VedaColors.white, width: 1),
        ),
        child: Text(
          label,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            color: VedaColors.white,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}
