import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'gemini_service.dart';

class GeminiEndpoint extends Endpoint {
  /// Send a chat message to Gemini and get a response (basic, no tools)
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

  /// Send a course chat message with tool calling support
  /// Tools can update course fields, generate images, and create modules
  Future<CourseChatResponse> courseChat(
    Session session,
    CourseChatRequest request,
  ) async {
    final apiKey = session.passwords['geminiApiKey'];

    if (apiKey == null || apiKey.isEmpty) {
      return CourseChatResponse(
        text: '',
        error: 'Gemini API key not configured',
      );
    }

    // Fetch the course to work with
    var course = await Course.db.findById(session, request.courseId);
    if (course == null) {
      return CourseChatResponse(
        text: '',
        error: 'Course not found',
      );
    }

    final gemini = GeminiService(apiKey: apiKey);
    final toolsExecuted = <String>[];

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

      // Build system instruction with course context
      final courseContext = '''
You are a Course Architect AI assistant. You are currently editing the course:
- Title: ${course.title}
- Description: ${course.description ?? 'Not set'}
- Visibility: ${course.visibility.name}
- Video URL: ${course.videoUrl ?? 'Not set'}

You have tools available to update the course. When the user asks you to change
any course property, use the appropriate tool. Be helpful and confirm actions taken.

${request.systemInstruction ?? ''}
''';

      // Send to Gemini with course tools
      final result = await gemini.courseChat(
        message: request.message,
        history: history,
        systemInstruction: courseContext,
      );

      // If there's a function call, execute it
      if (result.hasFunctionCall) {
        final functionResult = await _executeCourseFunction(
          session,
          course,
          result.functionName!,
          result.functionArgs!,
        );

        toolsExecuted.add(result.functionName!);

        // Refresh course data after update
        course = await Course.db.findById(session, request.courseId);

        // Build contents for follow-up call
        final contents = <Map<String, dynamic>>[];
        if (history != null) {
          for (final msg in history) {
            contents.add({
              'role': msg['role'],
              'parts': [
                {'text': msg['content']}
              ],
            });
          }
        }
        contents.add({
          'role': 'user',
          'parts': [
            {'text': request.message}
          ],
        });

        // Send function result back to Gemini for final response
        final finalResponse = await gemini.sendFunctionResultForCourse(
          contents: contents,
          functionName: result.functionName!,
          functionArgs: result.functionArgs!,
          result: functionResult,
          systemInstruction: courseContext,
        );

        return CourseChatResponse(
          text: finalResponse,
          toolsExecuted: toolsExecuted,
          updatedCourse: course,
        );
      }

      // No function call, return text response
      return CourseChatResponse(
        text: result.text ?? 'No response generated.',
        toolsExecuted: toolsExecuted,
        updatedCourse: course,
      );
    } catch (e) {
      session.log('Course chat error: $e', level: LogLevel.error);
      return CourseChatResponse(
        text: '',
        error: 'Failed to process course chat: ${e.toString()}',
      );
    }
  }

  /// Execute a course-related function and return the result
  Future<Map<String, dynamic>> _executeCourseFunction(
    Session session,
    Course course,
    String functionName,
    Map<String, dynamic> args,
  ) async {
    switch (functionName) {
      case 'updateCourseTitle':
        final title = args['title'] as String;
        course.title = title;
        course.updatedAt = DateTime.now();
        await Course.db.updateRow(session, course);
        return {'success': true, 'message': 'Course title updated to "$title"'};

      case 'updateCourseDescription':
        final description = args['description'] as String;
        course.description = description;
        course.updatedAt = DateTime.now();
        await Course.db.updateRow(session, course);
        return {
          'success': true,
          'message': 'Course description updated successfully'
        };

      case 'updateCourseVisibility':
        final visibilityStr = args['visibility'] as String;
        final visibility = CourseVisibility.values.firstWhere(
          (v) => v.name == visibilityStr,
          orElse: () => CourseVisibility.draft,
        );
        course.visibility = visibility;
        course.updatedAt = DateTime.now();
        await Course.db.updateRow(session, course);
        return {
          'success': true,
          'message': 'Course visibility changed to $visibilityStr'
        };

      case 'updateCourseVideoUrl':
        final videoUrl = args['videoUrl'] as String;
        course.videoUrl = videoUrl;
        course.updatedAt = DateTime.now();
        await Course.db.updateRow(session, course);
        return {'success': true, 'message': 'Course video URL updated'};

      case 'updateCourseSystemPrompt':
        final systemPrompt = args['systemPrompt'] as String;
        course.systemPrompt = systemPrompt;
        course.updatedAt = DateTime.now();
        await Course.db.updateRow(session, course);
        return {'success': true, 'message': 'Course system prompt updated'};

      case 'generateCourseImage':
        final imagePrompt = args['imagePrompt'] as String;
        // For now, return a placeholder - actual image generation would use
        // an image generation API like DALL-E, Imagen, or Stability AI
        // In production, you would:
        // 1. Call image generation API with the prompt
        // 2. Upload the generated image to cloud storage
        // 3. Save the URL to course.courseImageUrl
        return {
          'success': true,
          'message':
              'Image generation requested with prompt: "$imagePrompt". Note: Actual image generation not yet implemented - integrate with an image generation API.',
          'imagePrompt': imagePrompt,
        };

      case 'generateBannerImage':
        final imagePrompt = args['imagePrompt'] as String;
        // Similar to course image - placeholder for now
        return {
          'success': true,
          'message':
              'Banner image generation requested with prompt: "$imagePrompt". Note: Actual image generation not yet implemented - integrate with an image generation API.',
          'imagePrompt': imagePrompt,
        };

      case 'createModule':
        final title = args['title'] as String;
        final description = args['description'] as String?;
        final sortOrder = args['sortOrder'] as int;

        final module = Module(
          title: title,
          description: description,
          sortOrder: sortOrder,
          courseId: course.id!,
        );
        final createdModule = await Module.db.insertRow(session, module);
        return {
          'success': true,
          'message': 'Module "$title" created with ID ${createdModule.id}',
          'moduleId': createdModule.id,
        };

      default:
        return {'success': false, 'message': 'Unknown function: $functionName'};
    }
  }
}
