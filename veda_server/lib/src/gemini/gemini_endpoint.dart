import 'dart:convert';

import 'package:serverpod/serverpod.dart';
import 'package:http/http.dart' as http;

import '../generated/protocol.dart';
import '../lms/lms_endpoint.dart';
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

  /// Start a teaching chat session for a specific module
  /// Generates comprehensive teaching content based on course and module context
  Future<String> startTeachingChat(
    Session session,
    int courseId, {
    required String systemPrompt,
    required String firstMessage,
    required int minWords,
    required int maxWords,
  }) async {
    final apiKey = session.passwords['geminiApiKey'];

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Gemini API key not configured');
    }

    try {
      // Fetch course
      final course = await Course.db.findById(session, courseId);
      if (course == null) {
        throw Exception('Course not found');
      }

      final gemini = GeminiService(apiKey: apiKey);

      // RAG: Retrieve relevant knowledge chunks
      session.log('🔍 [Teaching RAG] Retrieving relevant knowledge for: "$firstMessage"');

      final queryEmbedding = await gemini.generateEmbedding(firstMessage);
      final queryVector = Vector(queryEmbedding);

      final relevantChunks = await KnowledgeFile.db.find(
        session,
        where: (t) => t.courseId.equals(courseId),
        orderBy: (t) => t.embedding.distanceCosine(queryVector),
        limit: 5,
      );

      session.log('✅ [Teaching RAG] Found ${relevantChunks.length} relevant chunks');

      // Build context from retrieved knowledge
      final knowledgeContext = relevantChunks.isEmpty
          ? ''
          : '''

RELEVANT KNOWLEDGE FROM COURSE MATERIALS:
${relevantChunks.map((chunk) => '''
--- From: ${chunk.fileName} ---
${chunk.textContent ?? ''}
''').join('\n')}

Use the above knowledge to inform your teaching. Reference specific facts, examples, and details from the course materials when relevant.
''';

      // Add word count constraint and RAG context to system prompt
      final fullSystemPrompt = '''
$systemPrompt
$knowledgeContext

CRITICAL REQUIREMENT:
Your response MUST be between $minWords and $maxWords words.
Count your words carefully and ensure you stay within this range.
''';

      // Send chat request with system instruction
      final response = await gemini.chat(
        message: firstMessage,
        systemInstruction: fullSystemPrompt,
      );

      return response;
    } catch (e) {
      session.log('Teaching chat error: $e', level: LogLevel.error);
      throw Exception('Failed to start teaching session: ${e.toString()}');
    }
  }

  /// Answer a student question during a teaching session
  /// Provides clarification and additional explanations with RAG
  Future<String> answerTeachingQuestion(
    Session session,
    int courseId, {
    required String moduleTitle,
    required String question,
    List<Map<String, String>>? history,
  }) async {
    final apiKey = session.passwords['geminiApiKey'];

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Gemini API key not configured');
    }

    try {
      // Fetch course
      final course = await Course.db.findById(session, courseId);
      if (course == null) {
        throw Exception('Course not found');
      }

      final gemini = GeminiService(apiKey: apiKey);

      // RAG: Retrieve relevant knowledge chunks for the question
      session.log('🔍 [Q&A RAG] Retrieving relevant knowledge for question: "$question"');

      final queryEmbedding = await gemini.generateEmbedding(question);
      final queryVector = Vector(queryEmbedding);

      final relevantChunks = await KnowledgeFile.db.find(
        session,
        where: (t) => t.courseId.equals(courseId),
        orderBy: (t) => t.embedding.distanceCosine(queryVector),
        limit: 3, // Fewer chunks for Q&A to keep responses concise
      );

      session.log('✅ [Q&A RAG] Found ${relevantChunks.length} relevant chunks');

      // Build context from retrieved knowledge
      final knowledgeContext = relevantChunks.isEmpty
          ? ''
          : '''

RELEVANT KNOWLEDGE FROM COURSE MATERIALS:
${relevantChunks.map((chunk) => '''
--- From: ${chunk.fileName} ---
${chunk.textContent ?? ''}
''').join('\n')}

Use the above knowledge to provide accurate, detailed answers grounded in the course materials.
''';

      // Build context-aware system prompt
      final systemPrompt = '''
You are a teacher for the course "${course.title}".
You are currently teaching the module: "$moduleTitle".

COURSE CONTEXT:
${course.description ?? 'No description'}

${course.systemPrompt != null ? 'TEACHING FOCUS:\n${course.systemPrompt}\n' : ''}
$knowledgeContext

YOUR ROLE:
A student has asked you a question during your teaching session.
Provide a clear, helpful answer that:
- Directly addresses their question
- Uses simple language and examples
- Connects back to the module content
- References specific information from the course materials when relevant
- Encourages further understanding
- References previous questions/answers if relevant

AUDIO TAGS FOR EXPRESSIVENESS:
Use square bracket tags to make your answer more engaging:
- [excited] when they ask a great question
- [thoughtful] when considering their question
- [pauses] before key explanations
- [encouragingly] when praising their curiosity
- [chuckles] for relatable examples

Example: "[excited] That's an excellent question! [pauses] Let me explain it this way..."

Keep your response concise (100-300 words) but thorough.
''';

      // Send chat request with history for context
      final response = await gemini.chat(
        message: question,
        history: history,
        systemInstruction: systemPrompt,
      );

      return response;
    } catch (e) {
      session.log('Teaching question error: $e', level: LogLevel.error);
      throw Exception('Failed to answer question: ${e.toString()}');
    }
  }

  /// Generate speech from text using ElevenLabs API
  /// Returns audio bytes (MP3 format)
  Future<List<int>> generateSpeech(Session session, String text) async {
    final apiKey = session.passwords['elevenlabsApiKey'];

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('ElevenLabs API key not configured. Add elevenlabsApiKey to passwords.yaml');
    }

    try {
      // ElevenLabs STREAMING API endpoint for lower latency
      // Using "Rachel" voice (21m00Tcm4TlvDq8ikWAM) - natural, clear English voice
      // Model: eleven_turbo_v2 - v3 generation model with full audio tag support
      // Using /stream endpoint to receive audio chunks as they're generated
      final voiceId = '21m00Tcm4TlvDq8ikWAM';
      final url = Uri.parse('https://api.elevenlabs.io/v1/text-to-speech/$voiceId/stream');

      session.log('🎙️ Generating speech with ElevenLabs v3 (${text.length} chars)...');
      session.log('📝 Text preview: ${text.substring(0, text.length > 100 ? 100 : text.length)}...');

      final response = await http.post(
        url,
        headers: {
          'Accept': 'audio/mpeg',
          'Content-Type': 'application/json',
          'xi-api-key': apiKey,
        },
        body: jsonEncode({
          'text': text,
          'model_id': 'eleven_v3', // v3 generation model with full audio tag support
          'voice_settings': {
            'stability': 0.5, // Balanced stability
            'similarity_boost': 0.8,
            'style': 0.5, // More expressive style
            'use_speaker_boost': true,
          },
          'optimize_streaming_latency': 3, // 0-4, higher = lower latency (3 is good balance)
          'output_format': 'mp3_44100_128', // High quality audio
        }),
      );

      if (response.statusCode == 200) {
        session.log('Speech generated successfully (${response.bodyBytes.length} bytes)');
        return response.bodyBytes;
      } else {
        final errorBody = utf8.decode(response.bodyBytes);
        session.log('ElevenLabs error: ${response.statusCode} - $errorBody', level: LogLevel.error);
        throw Exception('ElevenLabs API error: ${response.statusCode} - $errorBody');
      }
    } catch (e) {
      session.log('Speech generation error: $e', level: LogLevel.error);
      throw Exception('Failed to generate speech: ${e.toString()}');
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

      case 'generateTableOfContents':
        final customPrompt = args['customPrompt'] as String?;

        // Create LMS endpoint to access TOC generation
        final lmsEndpoint = LmsEndpoint();

        // Generate the table of contents
        final modules = await lmsEndpoint.generateCourseTableOfContents(
          session,
          course.id!,
          customPrompt: customPrompt,
        );

        return {
          'success': true,
          'message':
              'Generated ${modules.length} modules with ${modules.fold(0, (sum, m) => sum + (m.items?.length ?? 0))} topics',
          'moduleCount': modules.length,
          'topicCount': modules.fold(0, (sum, m) => sum + (m.items?.length ?? 0)),
        };

      default:
        return {'success': false, 'message': 'Unknown function: $functionName'};
    }
  }
}
