import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:veda_client/veda_client.dart';

import '../main.dart';

/// State of the live audio session
enum LiveSessionState {
  idle,
  connecting,
  teaching, // AI is speaking
  listening, // User is speaking
  processing,
  error,
  disconnected,
}

/// A transcript entry in the conversation
class TranscriptEntry {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  TranscriptEntry({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Completely independent service for live audio conversation
/// Uses Serverpod streaming — does NOT share any state with GeminiService
class GeminiLiveService {
  GeminiLiveService._();
  static final GeminiLiveService instance = GeminiLiveService._();

  LiveSessionState _state = LiveSessionState.idle;
  final List<TranscriptEntry> _transcript = [];

  StreamController<LiveMessage>? _inputController;
  StreamSubscription<LiveMessage>? _outputSubscription;

  // Callbacks
  void Function(LiveSessionState)? onStateChanged;
  void Function(List<TranscriptEntry>)? onTranscriptUpdated;
  void Function(Uint8List)? onAudioReceived;
  void Function(String)? onError;
  void Function()? onSessionEnding; // Called when AI ends session via tool call

  LiveSessionState get state => _state;
  List<TranscriptEntry> get transcript => List.unmodifiable(_transcript);

  void _setState(LiveSessionState newState) {
    debugPrint('[GeminiLiveService] State: $_state -> $newState');
    _state = newState;
    onStateChanged?.call(newState);
  }

  /// Start a live audio session for a course
  Future<void> connect({
    required int courseId,
    String voiceName = 'Aoede',
  }) async {
    debugPrint('[GeminiLiveService] connect() called: courseId=$courseId, voice=$voiceName');

    if (_state == LiveSessionState.connecting ||
        _state == LiveSessionState.teaching ||
        _state == LiveSessionState.listening) {
      debugPrint('[GeminiLiveService] Already active (state=$_state), skipping');
      return; // Already active
    }

    // Clean up any existing session first
    await _cleanup();

    _setState(LiveSessionState.connecting);
    _transcript.clear();

    try {
      // Create input stream for sending messages to server
      _inputController = StreamController<LiveMessage>();
      debugPrint('[GeminiLiveService] Created input controller');

      // Call the streaming endpoint
      debugPrint('[GeminiLiveService] Calling client.live.audioSession()...');
      final outputStream = client.live.audioSession(_inputController!.stream);
      debugPrint('[GeminiLiveService] Got output stream, setting up listener');

      // Listen to responses from server
      _outputSubscription = outputStream.listen(
        _handleServerMessage,
        onError: (error) {
          debugPrint('[GeminiLiveService] Output stream ERROR: $error');
          _setState(LiveSessionState.error);
          onError?.call('Stream error: $error');
        },
        onDone: () {
          debugPrint('[GeminiLiveService] Output stream DONE (server closed)');
          _setState(LiveSessionState.disconnected);
        },
      );

      // Send config as first message
      debugPrint('[GeminiLiveService] Sending config message: courseId=$courseId');
      _inputController!.add(LiveMessage(
        type: 'config',
        text: courseId.toString(),
        audioBase64: voiceName,
        isUser: false,
      ));
      debugPrint('[GeminiLiveService] Config message sent');
    } catch (e, stackTrace) {
      debugPrint('[GeminiLiveService] EXCEPTION in connect(): $e\n$stackTrace');
      _setState(LiveSessionState.error);
      onError?.call('Failed to connect: $e');
    }
  }

  void _handleServerMessage(LiveMessage message) {
    debugPrint('[GeminiLiveService] Server message: type=${message.type}, text=${message.text?.substring(0, (message.text?.length ?? 0).clamp(0, 80))}');

    switch (message.type) {
      case 'state':
        debugPrint('[GeminiLiveService] State message: ${message.text}');
        switch (message.text) {
          case 'connecting':
            _setState(LiveSessionState.connecting);
            break;
          case 'connected':
            debugPrint('[GeminiLiveService] CONNECTED — switching to teaching mode');
            _setState(LiveSessionState.teaching);
            break;
          case 'turn_complete':
            debugPrint('[GeminiLiveService] Turn complete');
            _setState(LiveSessionState.teaching);
            break;
          case 'interrupted':
            // Don't change state - user is already in listening mode from UI action
            debugPrint('[GeminiLiveService] AI was interrupted');
            break;
          case 'end_session':
            debugPrint('[GeminiLiveService] AI requested END SESSION');
            // Notify that session is ending (UI can show a message)
            onSessionEnding?.call();
            break;
          case 'disconnected':
            debugPrint('[GeminiLiveService] Server says DISCONNECTED');
            _setState(LiveSessionState.disconnected);
            break;
        }
        break;

      case 'text':
        if (message.text != null && message.text!.isNotEmpty) {
          debugPrint('[GeminiLiveService] AI text: "${message.text!.substring(0, message.text!.length.clamp(0, 80))}"');
          _addTranscript(message.text!, isUser: false);
          if (_state != LiveSessionState.teaching) {
            _setState(LiveSessionState.teaching);
          }
        }
        break;

      case 'audio':
        if (message.audioBase64 != null) {
          debugPrint('[GeminiLiveService] AI audio: ${message.audioBase64!.length} bytes base64');
          try {
            final bytes = _decodeBase64(message.audioBase64!);
            onAudioReceived?.call(bytes);
          } catch (e) {
            debugPrint('[GeminiLiveService] Audio decode error: $e');
          }
        }
        if (_state != LiveSessionState.teaching) {
          _setState(LiveSessionState.teaching);
        }
        break;

      case 'error':
        debugPrint('[GeminiLiveService] ERROR from server: ${message.text}');
        _setState(LiveSessionState.error);
        onError?.call(message.text ?? 'Unknown error');
        break;
    }
  }

  Uint8List _decodeBase64(String base64String) {
    return Uint8List.fromList(base64Decode(base64String));
  }

  void _addTranscript(String text, {required bool isUser}) {
    // Append to last entry if same speaker
    if (_transcript.isNotEmpty && _transcript.last.isUser == isUser) {
      final last = _transcript.removeLast();
      _transcript.add(TranscriptEntry(
        text: '${last.text} $text',
        isUser: isUser,
        timestamp: last.timestamp,
      ));
    } else {
      _transcript.add(TranscriptEntry(text: text, isUser: isUser));
    }
    onTranscriptUpdated?.call(_transcript);
  }

  /// Send text message to AI (typed input)
  void sendText(String text) {
    if (_inputController == null || text.trim().isEmpty) {
      debugPrint('[GeminiLiveService] sendText() skipped: controller=${_inputController != null}, text="${text.trim()}"');
      return;
    }

    debugPrint('[GeminiLiveService] sendText: "$text"');
    _addTranscript(text, isUser: true);
    _setState(LiveSessionState.processing);

    _inputController!.add(LiveMessage(
      type: 'text',
      text: text,
      isUser: true,
    ));
  }

  /// Send audio data to AI (base64 encoded PCM)
  void sendAudio(Uint8List audioData) {
    if (_inputController == null) return;

    if (_state != LiveSessionState.listening) {
      _setState(LiveSessionState.listening);
    }

    // Base64 encode the audio
    final base64 = _encodeBase64(audioData);

    _inputController!.add(LiveMessage(
      type: 'audio',
      audioBase64: base64,
      isUser: true,
    ));
  }

  String _encodeBase64(Uint8List bytes) {
    return base64Encode(bytes);
  }

  /// Signal end of audio turn
  void endAudioTurn() {
    _inputController?.add(LiveMessage(
      type: 'end_turn',
      isUser: true,
    ));
    _setState(LiveSessionState.processing);
  }

  /// Interrupt AI while speaking
  void interrupt() {
    _inputController?.add(LiveMessage(
      type: 'interrupt',
      isUser: true,
    ));
    _setState(LiveSessionState.listening);
  }

  /// Internal cleanup without state change
  Future<void> _cleanup() async {
    debugPrint('[GeminiLiveService] _cleanup() called');

    // Cancel subscription first
    await _outputSubscription?.cancel();
    _outputSubscription = null;

    // Close input controller
    await _inputController?.close();
    _inputController = null;
  }

  /// Disconnect the live session
  Future<void> disconnect() async {
    debugPrint('[GeminiLiveService] disconnect() called');

    // Send disconnect message if controller exists
    if (_inputController != null && !_inputController!.isClosed) {
      _inputController!.add(LiveMessage(
        type: 'disconnect',
        isUser: false,
      ));
    }

    await _cleanup();

    _setState(LiveSessionState.idle);
    debugPrint('[GeminiLiveService] Disconnected');
  }

  /// Clear transcript
  void clearTranscript() {
    _transcript.clear();
    onTranscriptUpdated?.call(_transcript);
  }

  /// Dispose
  Future<void> dispose() async {
    await disconnect();
  }
}
