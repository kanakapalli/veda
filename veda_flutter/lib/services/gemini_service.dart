import '../main.dart';
import 'package:veda_client/veda_client.dart';

/// Service for interacting with Gemini AI via server endpoint
class GeminiService {
  static GeminiService? _instance;

  final List<ChatMessage> _history = [];
  String? _systemInstruction;

  GeminiService._();

  static GeminiService get instance {
    _instance ??= GeminiService._();
    return _instance!;
  }

  /// Start a new chat session with optional system instruction
  void startChatSession({String? systemInstruction}) {
    _history.clear();
    _systemInstruction = systemInstruction;
  }

  /// Send a message and get a response
  Future<String> sendMessage(String message) async {
    try {
      final request = ChatRequest(
        message: message,
        history: _history.isNotEmpty ? List.from(_history) : null,
        systemInstruction: _systemInstruction,
      );

      final response = await client.gemini.chat(request);

      if (response.error != null && response.error!.isNotEmpty) {
        return 'Error: ${response.error}';
      }

      // Add to history
      _history.add(ChatMessage(role: 'user', content: message));
      _history.add(ChatMessage(role: 'model', content: response.text));

      return response.text;
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  /// Reset the chat session
  void resetChat() {
    _history.clear();
  }
}
