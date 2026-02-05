import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'gemini_service.dart';

class GeminiEndpoint extends Endpoint {
  /// Send a chat message to Gemini and get a response
  Future<ChatResponse> chat(Session session, ChatRequest request) async {
    // Get API key from server config (passwords.yaml)
    final apiKey = session.passwords['geminiApiKey'];

    if (apiKey == null || apiKey.isEmpty) {
      return ChatResponse(
        text: '',
        error: 'Gemini API key not configured. Add geminiApiKey to passwords.yaml',
      );
    }

    final gemini = GeminiService(apiKey: apiKey);

    try {
      // Convert history to the format expected by GeminiService
      List<Map<String, String>>? history;
      if (request.history != null && request.history!.isNotEmpty) {
        history = request.history!
            .map((msg) => {
                  'role': msg.role,
                  'content': msg.content,
                })
            .toList();
      }

      final response = await gemini.chat(
        message: request.message,
        history: history,
        systemInstruction: request.systemInstruction,
      );

      return ChatResponse(text: response);
    } catch (e) {
      session.log('Gemini error: $e', level: LogLevel.error);
      return ChatResponse(
        text: '',
        error: 'Failed to get response from Gemini: ${e.toString()}',
      );
    }
  }
}
