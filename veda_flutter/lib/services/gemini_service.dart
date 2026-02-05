import '../main.dart';
import 'package:veda_client/veda_client.dart';

/// Result of a course chat that may include updated course data
class CourseChatResult {
  final String text;
  final List<String> toolsExecuted;
  final Course? updatedCourse;
  final String? error;

  CourseChatResult({
    required this.text,
    this.toolsExecuted = const [],
    this.updatedCourse,
    this.error,
  });

  bool get hasError => error != null && error!.isNotEmpty;
  bool get hasUpdates => toolsExecuted.isNotEmpty;
}

/// Service for interacting with Gemini AI via server endpoint
class GeminiService {
  static GeminiService? _instance;

  final List<ChatMessage> _history = [];
  String? _systemInstruction;
  int? _currentCourseId;

  GeminiService._();

  static GeminiService get instance {
    _instance ??= GeminiService._();
    return _instance!;
  }

  /// Start a new chat session with optional system instruction
  void startChatSession({String? systemInstruction, int? courseId}) {
    _history.clear();
    _systemInstruction = systemInstruction;
    _currentCourseId = courseId;
  }

  /// Set the current course ID for course-specific chats
  void setCourseId(int courseId) {
    _currentCourseId = courseId;
  }

  /// Send a message and get a response (basic chat, no tools)
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

  /// Send a course chat message with tool calling support
  /// The AI can update course fields, generate images, create modules, etc.
  Future<CourseChatResult> sendCourseMessage(
    String message, {
    int? courseId,
  }) async {
    final effectiveCourseId = courseId ?? _currentCourseId;

    if (effectiveCourseId == null) {
      return CourseChatResult(
        text: '',
        error: 'No course ID set for course chat',
      );
    }

    try {
      final request = CourseChatRequest(
        message: message,
        courseId: effectiveCourseId,
        history: _history.isNotEmpty ? List.from(_history) : null,
        systemInstruction: _systemInstruction,
      );

      final response = await client.gemini.courseChat(request);

      if (response.error != null && response.error!.isNotEmpty) {
        return CourseChatResult(
          text: '',
          error: response.error,
        );
      }

      // Add to history
      _history.add(ChatMessage(role: 'user', content: message));
      _history.add(ChatMessage(role: 'model', content: response.text));

      return CourseChatResult(
        text: response.text,
        toolsExecuted: response.toolsExecuted ?? [],
        updatedCourse: response.updatedCourse,
      );
    } catch (e) {
      return CourseChatResult(
        text: '',
        error: e.toString(),
      );
    }
  }

  /// Reset the chat session
  void resetChat() {
    _history.clear();
  }
}
