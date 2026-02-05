import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

/// Completely independent service for Gemini Live Audio API
/// This does NOT share any code with the existing GeminiService
class GeminiLiveApi {
  static const String _wsBaseUrl =
      'wss://generativelanguage.googleapis.com/ws/google.ai.generativelanguage.v1beta.GenerativeService.BidiGenerateContent';
  static const String _model = 'gemini-2.5-flash-native-audio-preview-12-2025';

  final String apiKey;
  final String systemPrompt;
  final String? moduleTitle;
  final String voiceName;
  final void Function(String message, {bool isError})? log;

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  bool _isConnected = false;
  bool _setupComplete = false;

  // Stream controllers for bidirectional communication
  final _responseController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get responses => _responseController.stream;
  bool get isConnected => _isConnected;

  GeminiLiveApi({
    required this.apiKey,
    required this.systemPrompt,
    this.moduleTitle,
    this.voiceName = 'Aoede',
    this.log,
  });

  void _log(String msg, {bool isError = false}) {
    log?.call(msg, isError: isError);
  }

  /// Connect to the Gemini Live API
  Future<void> connect() async {
    if (_isConnected) {
      _log('Already connected, skipping');
      
      return;
    }

    final maskedKey = '${apiKey.substring(0, 8)}...';
    _log('Connecting to Gemini Live API (model=$_model, key=$maskedKey)');

    final uri = Uri.parse('$_wsBaseUrl?key=$apiKey');
    _log('WebSocket URI: ${uri.toString().replaceAll(apiKey, maskedKey)}');

    try {
      _channel = WebSocketChannel.connect(uri);
      _log('WebSocket channel created, waiting for ready...');

      await _channel!.ready;
      _isConnected = true;
      _log('WebSocket ready and connected');
    } catch (e) {
      _log('WebSocket connection FAILED: $e', isError: true);
      _responseController.add({
        'type': 'error',
        'message': 'WebSocket connection failed: $e',
      });
      return;
    }

    // Listen for responses
    _subscription = _channel!.stream.listen(
      _handleMessage,
      onError: (error) {
        _log('WebSocket stream ERROR: $error', isError: true);
        _responseController.add({
          'type': 'error',
          'message': error.toString(),
        });
        _isConnected = false;
      },
      onDone: () {
        final closeCode = _channel?.closeCode;
        final closeReason = _channel?.closeReason;
        _log('WebSocket stream DONE — closeCode=$closeCode, closeReason="$closeReason"');
        _isConnected = false;
        if (!_responseController.isClosed) {
          _responseController.add({'type': 'disconnected'});
        }
      },
    );

    // Send setup message
    _log('Sending setup message...');
    await _sendSetup();
  }

  Future<void> _sendSetup() async {
    final promptPreview = systemPrompt.length > 100
        ? '${systemPrompt.substring(0, 100)}...'
        : systemPrompt;
    _log('System prompt: "$promptPreview"');
    _log('Voice: $voiceName, Module: $moduleTitle');

    final setupMessage = {
      'setup': {
        'model': 'models/$_model',
        'generationConfig': {
          'responseModalities': ['AUDIO'],
          'speechConfig': {
            'voiceConfig': {
              'prebuiltVoiceConfig': {
                'voiceName': voiceName,
              }
            }
          }
        },
        'systemInstruction': {
          'parts': [
            {
              'text': '''You are an AI tutor helping a student learn.
Your role is to explain concepts clearly and answer questions.
Be conversational, encouraging, and adapt to the student's pace.
Keep explanations concise but thorough.
${moduleTitle != null ? 'Current topic: $moduleTitle' : ''}

$systemPrompt

IMPORTANT: When you have completed explaining the topic fully and the student has no more questions, you MUST call the end_session tool to end the tutoring session. Say goodbye to the student before calling the tool.'''
            }
          ]
        },
        // Enable transcription of AI audio output
        'outputAudioTranscription': {},
        // Tools available to the model
        'tools': [
          {
            'functionDeclarations': [
              {
                'name': 'end_session',
                'description':
                    'End the tutoring session. Call this when you have completed explaining the topic and the student has no more questions.',
                'parameters': {
                  'type': 'object',
                  'properties': {
                    'reason': {
                      'type': 'string',
                      'description':
                          'The reason for ending the session, e.g., "topic_completed", "student_satisfied"'
                    }
                  },
                  'required': ['reason']
                }
              }
            ]
          }
        ]
      }
    };

    final json = jsonEncode(setupMessage);
    _log('Setup message size: ${json.length} bytes');
    _channel!.sink.add(json);
    _log('Setup message sent, waiting for setupComplete...');
  }

  void _handleMessage(dynamic message) {
    try {
      String raw;
      if (message is String) {
        raw = message;
      } else if (message is List<int>) {
        // Binary message — decode as UTF-8
        raw = utf8.decode(message);
      } else {
        _log('Unknown message type: ${message.runtimeType}', isError: true);
        return;
      }
      _log('Received message (${raw.length} bytes): ${raw.length > 200 ? '${raw.substring(0, 200)}...' : raw}');

      final data = jsonDecode(raw) as Map<String, dynamic>;

      // Handle setup complete
      if (data.containsKey('setupComplete')) {
        _setupComplete = true;
        _log('Setup COMPLETE - ready for conversation');
        _responseController.add({'type': 'setup_complete'});
        return;
      }

      // Handle output transcription (what AI is actually speaking)
      if (data.containsKey('serverContent')) {
        final serverContent = data['serverContent'] as Map<String, dynamic>;

        // Check if interrupted
        if (serverContent['interrupted'] == true) {
          _log('AI was INTERRUPTED');
          _responseController.add({'type': 'interrupted'});
          return;
        }

        // Handle output transcription (actual spoken text)
        final outputTranscription = serverContent['outputTranscription'] as Map<String, dynamic>?;
        if (outputTranscription != null) {
          final text = outputTranscription['text'] as String?;
          if (text != null && text.isNotEmpty) {
            _log('AI TRANSCRIPT: "${text.length > 100 ? '${text.substring(0, 100)}...' : text}"');
            _responseController.add({
              'type': 'transcript',
              'text': text,
            });
          }
        }

        // Handle model turn (may contain thinking text, audio, or tool calls)
        final modelTurn = serverContent['modelTurn'] as Map<String, dynamic>?;
        if (modelTurn != null) {
          final parts = modelTurn['parts'] as List<dynamic>?;
          if (parts != null) {
            for (final part in parts) {
              final partMap = part as Map<String, dynamic>;

              // Handle text part (this is often thinking, not speech)
              if (partMap.containsKey('text')) {
                final text = partMap['text'] as String;
                _log('AI THINKING: "${text.length > 100 ? '${text.substring(0, 100)}...' : text}"');
                // Don't send thinking to transcript - only send actual spoken text via outputTranscription
              }

              // Handle function call (tool use)
              if (partMap.containsKey('functionCall')) {
                final functionCall = partMap['functionCall'] as Map<String, dynamic>;
                final functionName = functionCall['name'] as String?;
                final args = functionCall['args'] as Map<String, dynamic>?;
                _log('AI TOOL CALL: $functionName with args: $args');

                if (functionName == 'end_session') {
                  final reason = args?['reason'] as String? ?? 'completed';
                  _log('END SESSION requested: $reason');
                  _responseController.add({
                    'type': 'end_session',
                    'reason': reason,
                  });
                }
              }

              // Handle audio part
              if (partMap.containsKey('inlineData')) {
                final inlineData = partMap['inlineData'] as Map<String, dynamic>;
                final audioData = inlineData['data'] as String;
                _log('AI AUDIO chunk: ${audioData.length} bytes base64');
                _responseController.add({
                  'type': 'audio',
                  'data': audioData,
                  'mimeType': inlineData['mimeType'],
                });
              }
            }
          }
        }

        // Check turn complete
        if (serverContent['turnComplete'] == true) {
          _log('AI turn COMPLETE');
          _responseController.add({'type': 'turn_complete'});
        }
      }

      // Log any unrecognized message keys for debugging
      final knownKeys = {'setupComplete', 'serverContent'};
      final unknownKeys = data.keys.where((k) => !knownKeys.contains(k));
      if (unknownKeys.isNotEmpty) {
        _log('Other message keys: ${unknownKeys.join(', ')}');
      }
    } catch (e) {
      _log('Parse ERROR: $e', isError: true);
      _responseController.add({
        'type': 'error',
        'message': 'Parse error: $e',
      });
    }
  }

  /// Send text message to the AI
  void sendText(String text) {
    if (!_isConnected || !_setupComplete) {
      _log('Cannot send text: connected=$_isConnected, setupComplete=$_setupComplete', isError: true);
      return;
    }

    _log('Sending TEXT: "${text.length > 100 ? '${text.substring(0, 100)}...' : text}"');

    final message = {
      'clientContent': {
        'turns': [
          {
            'role': 'user',
            'parts': [
              {'text': text}
            ]
          }
        ],
        'turnComplete': true,
      }
    };

    _channel!.sink.add(jsonEncode(message));
  }

  /// Send audio data to the AI (base64 encoded PCM)
  void sendAudio(String audioBase64) {
    if (!_isConnected || !_setupComplete) return;

    final message = {
      'realtimeInput': {
        'mediaChunks': [
          {
            'mimeType': 'audio/pcm;rate=16000',
            'data': audioBase64,
          }
        ]
      }
    };

    _channel!.sink.add(jsonEncode(message));
  }

  /// Signal end of audio input
  void endAudioTurn() {
    if (!_isConnected || !_setupComplete) return;

    _log('Sending end-of-turn signal');

    final message = {
      'clientContent': {
        'turnComplete': true,
      }
    };

    _channel!.sink.add(jsonEncode(message));
  }

  /// Disconnect from the API
  Future<void> disconnect() async {
    _log('Disconnecting...');
    _isConnected = false;
    _setupComplete = false;

    await _subscription?.cancel();
    _subscription = null;

    await _channel?.sink.close();
    _channel = null;
    _log('Disconnected');
  }

  /// Dispose resources
  Future<void> dispose() async {
    await disconnect();
    if (!_responseController.isClosed) {
      await _responseController.close();
    }
  }
}
