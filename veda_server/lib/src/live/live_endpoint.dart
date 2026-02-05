import 'dart:async';

import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'gemini_live_api.dart';

/// Streaming endpoint for Gemini Live Audio conversations
/// Completely independent from the existing GeminiEndpoint
class LiveEndpoint extends Endpoint {
  /// Bidirectional streaming for live audio/text conversation
  ///
  /// Client sends LiveMessage via input stream:
  ///   type='config' (first message) — text=courseId, audioBase64=voiceName
  ///   type='text' — text=user message
  ///   type='audio' — audioBase64=base64 PCM data
  ///   type='end_turn' — signals end of user audio turn
  ///   type='interrupt' — interrupts AI while speaking
  ///   type='disconnect' — close session
  ///
  /// Server returns LiveMessage via output stream:
  ///   type='state' — text=connecting|connected|turn_complete|interrupted|disconnected
  ///   type='text' — AI text response
  ///   type='audio' — AI audio response (audioBase64)
  ///   type='error' — error message
  Stream<LiveMessage> audioSession(
    Session session,
    Stream<LiveMessage> inputStream,
  ) async* {
    var sessionOpen = true;

    void safeLog(String msg, {LogLevel level = LogLevel.info}) {
      if (sessionOpen) {
        try {
          session.log(msg, level: level);
        } catch (_) {
          sessionOpen = false;
        }
      }
    }

    safeLog('[LiveEndpoint] audioSession() called');

    final apiKey = session.passwords['geminiApiKey'];

    if (apiKey == null || apiKey.isEmpty) {
      safeLog('[LiveEndpoint] ERROR: geminiApiKey not found in passwords',
          level: LogLevel.error);
      yield LiveMessage(
        type: 'error',
        text: 'Gemini API key not configured',
        isUser: false,
      );
      return;
    }

    safeLog('[LiveEndpoint] API key found: ${apiKey.substring(0, 8)}...');

    // Output controller — collects messages from multiple sources
    final output = StreamController<LiveMessage>();
    GeminiLiveApi? liveApi;

    // Listen to client input in background
    inputStream.listen((message) async {
      safeLog(
          '[LiveEndpoint] Received client message: type=${message.type}, text=${message.text?.substring(0, message.text!.length.clamp(0, 50))}');

      try {
        switch (message.type) {
          case 'config':
            // Parse config and connect to Gemini Live API
            final courseId = int.tryParse(message.text ?? '0') ?? 0;
            safeLog('[LiveEndpoint] Config: courseId=$courseId, voice=${message.audioBase64}');

            // Fetch the course system prompt
            String systemPrompt = '';
            if (courseId > 0) {
              final course = await Course.db.findById(session, courseId);
              if (course != null) {
                systemPrompt = course.systemPrompt ?? '';
                safeLog(
                    '[LiveEndpoint] Course found: "${course.title}", systemPrompt length=${systemPrompt.length}');
              } else {
                safeLog('[LiveEndpoint] WARNING: Course $courseId not found',
                    level: LogLevel.warning);
              }
            } else {
              safeLog('[LiveEndpoint] WARNING: Invalid courseId=$courseId',
                  level: LogLevel.warning);
            }

            // Create and connect Gemini Live API
            safeLog('[LiveEndpoint] Creating GeminiLiveApi...');
            liveApi = GeminiLiveApi(
              apiKey: apiKey,
              systemPrompt: systemPrompt,
              moduleTitle: null,
              voiceName: message.audioBase64 ?? 'Aoede',
              log: (msg, {bool isError = false}) {
                safeLog(
                  '[GeminiLiveApi] $msg',
                  level: isError ? LogLevel.error : LogLevel.info,
                );
              },
            );

            // Forward Gemini responses to output
            liveApi!.responses.listen((response) {
              if (output.isClosed) return;
              final type = response['type'] as String;
              safeLog('[LiveEndpoint] Gemini response: type=$type');

              switch (type) {
                case 'setup_complete':
                  output.add(LiveMessage(
                    type: 'state',
                    text: 'connected',
                    isUser: false,
                  ));
                  // Send initial greeting to get AI to start teaching
                  safeLog('[LiveEndpoint] Sending initial greeting to start teaching');
                  liveApi?.sendText('Hello! Please start teaching me about the topic.');
                  break;
                case 'text':
                  // This is thinking text, don't send to client transcript
                  break;
                case 'transcript':
                  // This is actual spoken transcript
                  final text = response['text'] as String?;
                  safeLog(
                      '[LiveEndpoint] AI transcript: "${text != null ? text.substring(0, text.length.clamp(0, 80)) : ''}"');
                  output.add(LiveMessage(
                    type: 'text',
                    text: text,
                    isUser: false,
                  ));
                  break;
                case 'audio':
                  output.add(LiveMessage(
                    type: 'audio',
                    audioBase64: response['data'] as String?,
                    isUser: false,
                  ));
                  break;
                case 'turn_complete':
                  output.add(LiveMessage(
                    type: 'state',
                    text: 'turn_complete',
                    isUser: false,
                  ));
                  break;
                case 'interrupted':
                  output.add(LiveMessage(
                    type: 'state',
                    text: 'interrupted',
                    isUser: false,
                  ));
                  break;
                case 'error':
                  safeLog(
                      '[LiveEndpoint] Gemini ERROR: ${response['message']}',
                      level: LogLevel.error);
                  output.add(LiveMessage(
                    type: 'error',
                    text: response['message'] as String?,
                    isUser: false,
                  ));
                  break;
                case 'end_session':
                  final reason = response['reason'] as String? ?? 'completed';
                  safeLog('[LiveEndpoint] AI requested END SESSION: $reason');
                  output.add(LiveMessage(
                    type: 'state',
                    text: 'end_session',
                    isUser: false,
                  ));
                  break;
                case 'disconnected':
                  safeLog('[LiveEndpoint] Gemini DISCONNECTED',
                      level: LogLevel.warning);
                  output.add(LiveMessage(
                    type: 'state',
                    text: 'disconnected',
                    isUser: false,
                  ));
                  break;
              }
            }, onError: (error) {
              safeLog('[LiveEndpoint] Gemini response stream ERROR: $error',
                  level: LogLevel.error);
            }, onDone: () {
              safeLog('[LiveEndpoint] Gemini response stream DONE');
            });

            output.add(LiveMessage(
              type: 'state',
              text: 'connecting',
              isUser: false,
            ));

            safeLog('[LiveEndpoint] Calling liveApi.connect()...');
            await liveApi!.connect();
            safeLog(
                '[LiveEndpoint] liveApi.connect() returned, isConnected=${liveApi!.isConnected}');
            break;

          case 'text':
            safeLog('[LiveEndpoint] Forwarding text to Gemini: "${message.text}"');
            liveApi?.sendText(message.text ?? '');
            break;

          case 'audio':
            liveApi?.sendAudio(message.audioBase64 ?? '');
            break;

          case 'end_turn':
            safeLog('[LiveEndpoint] End turn signal');
            liveApi?.endAudioTurn();
            break;

          case 'interrupt':
            safeLog('[LiveEndpoint] Interrupt signal');
            liveApi?.sendText('');
            break;

          case 'disconnect':
            safeLog('[LiveEndpoint] Client requested disconnect');
            await liveApi?.dispose();
            liveApi = null;
            output.add(LiveMessage(
              type: 'state',
              text: 'disconnected',
              isUser: false,
            ));
            await output.close();
            break;
        }
      } catch (e, stackTrace) {
        safeLog('[LiveEndpoint] EXCEPTION in input handler: $e\n$stackTrace',
            level: LogLevel.error);
        if (!output.isClosed) {
          output.add(LiveMessage(
            type: 'error',
            text: 'Error: $e',
            isUser: false,
          ));
        }
      }
    }, onError: (error) {
      safeLog('[LiveEndpoint] Input stream ERROR: $error',
          level: LogLevel.error);
    }, onDone: () async {
      // Client disconnected — clean up
      safeLog('[LiveEndpoint] Input stream DONE (client disconnected)');
      await liveApi?.dispose();
      liveApi = null;
      if (!output.isClosed) {
        await output.close();
      }
    });

    // Relay everything from the output controller to the client
    safeLog('[LiveEndpoint] Starting output relay loop...');
    try {
      await for (final msg in output.stream) {
        yield msg;
      }
    } finally {
      sessionOpen = false;
      await liveApi?.dispose();
      if (!output.isClosed) {
        await output.close();
      }
    }
  }
}
