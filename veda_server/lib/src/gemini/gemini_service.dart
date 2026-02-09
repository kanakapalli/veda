import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;

/// Result of a Gemini chat that may contain a function call
class GeminiChatResult {
  final String? text;
  final String? functionName;
  final Map<String, dynamic>? functionArgs;

  GeminiChatResult({this.text, this.functionName, this.functionArgs});

  bool get hasFunctionCall => functionName != null;
}

/// Service for interacting with Gemini API using Google AI Studio API key
class GeminiService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';
  static const String _model = 'gemini-2.0-flash';

  final String apiKey;

  GeminiService({required this.apiKey});

  /// Course tool definitions for Gemini function calling
  static final List<Map<String, dynamic>> _courseTools = [
    {
      'function_declarations': [
        {
          'name': 'updateCourseTitle',
          'description': 'Update the title of the current course. ONLY use when user EXPLICITLY requests to change the title (e.g., "change the title to...", "rename the course to..."). Do NOT use based on conversation context alone.',
          'parameters': {
            'type': 'object',
            'properties': {
              'title': {
                'type': 'string',
                'description': 'The new title for the course'
              },
            },
            'required': ['title'],
          },
        },
        {
          'name': 'updateCourseDescription',
          'description': 'Update the description of the current course. ONLY use when user EXPLICITLY requests to change the description (e.g., "update the description to...", "change description..."). Do NOT use based on conversation context alone.',
          'parameters': {
            'type': 'object',
            'properties': {
              'description': {
                'type': 'string',
                'description': 'The new description for the course'
              },
            },
            'required': ['description'],
          },
        },
        {
          'name': 'updateCourseVisibility',
          'description':
              'Update the visibility status of the current course (draft, public, or private). ONLY use when user explicitly requests to change visibility (e.g., "make it public", "set to draft", "change visibility to private").',
          'parameters': {
            'type': 'object',
            'properties': {
              'visibility': {
                'type': 'string',
                'enum': ['draft', 'public', 'private'],
                'description': 'The visibility status: draft, public, or private'
              },
            },
            'required': ['visibility'],
          },
        },
        {
          'name': 'updateCourseVideoUrl',
          'description':
              'Update the intro video URL for the current course. ONLY use when user explicitly provides a video URL to add/update (e.g., "add this video as intro: https://...", "set the intro video to...").',
          'parameters': {
            'type': 'object',
            'properties': {
              'videoUrl': {
                'type': 'string',
                'description': 'The URL of the intro video (YouTube, Vimeo, etc.)'
              },
            },
            'required': ['videoUrl'],
          },
        },
        {
          'name': 'updateCourseSystemPrompt',
          'description':
              'Update the AI system prompt that guides teaching mode and content generation for this course. Use PROACTIVELY as you learn about the course through conversation - update whenever you gain insights about: topic focus, target audience, teaching style, learning objectives, difficulty level, or subject matter context. You can call this multiple times as understanding evolves. Do NOT ask permission - just update it intelligently to capture course context.',
          'parameters': {
            'type': 'object',
            'properties': {
              'systemPrompt': {
                'type': 'string',
                'description': 'Comprehensive system prompt describing the course focus, target audience, teaching approach, and key context for AI-generated content. Example: "Beginner-friendly Python course for data science professionals transitioning from Excel. Focus on practical applications, real-world datasets, and gradual progression from basic syntax to pandas and visualization."'
              },
            },
            'required': ['systemPrompt'],
          },
        },
        {
          'name': 'generateCourseImage',
          'description':
              'Generate and set a course thumbnail image using AI based on course content',
          'parameters': {
            'type': 'object',
            'properties': {
              'imagePrompt': {
                'type': 'string',
                'description':
                    'Description of the image to generate (e.g., "minimalist illustration of programming concepts")'
              },
            },
            'required': ['imagePrompt'],
          },
        },
        {
          'name': 'generateBannerImage',
          'description':
              'Generate and set a course banner image using AI based on course content',
          'parameters': {
            'type': 'object',
            'properties': {
              'imagePrompt': {
                'type': 'string',
                'description':
                    'Description of the banner image to generate (wide format, e.g., "abstract representation of machine learning")'
              },
            },
            'required': ['imagePrompt'],
          },
        },
        {
          'name': 'createModule',
          'description': 'Create a new module in the course',
          'parameters': {
            'type': 'object',
            'properties': {
              'title': {
                'type': 'string',
                'description': 'The title of the module'
              },
              'description': {
                'type': 'string',
                'description': 'A brief description of the module content'
              },
              'sortOrder': {
                'type': 'integer',
                'description': 'The order position of this module (1, 2, 3, etc.)'
              },
            },
            'required': ['title', 'sortOrder'],
          },
        },
        {
          'name': 'generateTableOfContents',
          'description':
              'Generate a complete table of contents (modules with topics) for the course based on uploaded knowledge files and course information. Use this when the user asks to create, generate, or update the course structure/syllabus/TOC.',
          'parameters': {
            'type': 'object',
            'properties': {
              'customPrompt': {
                'type': 'string',
                'description':
                    'Optional custom instructions for how to structure the table of contents (e.g., "Focus on beginner-friendly progression", "Include advanced topics", "Split into 10 modules", "Make it practical with lots of examples")',
              },
            },
            'required': [],
          },
        },
      ],
    },
  ];

  /// Calculator tool definitions for Gemini function calling
  static final List<Map<String, dynamic>> _calculatorTools = [
    {
      'function_declarations': [
        {
          'name': 'add',
          'description': 'Add two numbers together',
          'parameters': {
            'type': 'object',
            'properties': {
              'a': {'type': 'number', 'description': 'First number'},
              'b': {'type': 'number', 'description': 'Second number'},
            },
            'required': ['a', 'b'],
          },
        },
        {
          'name': 'subtract',
          'description': 'Subtract second number from first number',
          'parameters': {
            'type': 'object',
            'properties': {
              'a': {'type': 'number', 'description': 'First number'},
              'b': {'type': 'number', 'description': 'Second number to subtract'},
            },
            'required': ['a', 'b'],
          },
        },
        {
          'name': 'multiply',
          'description': 'Multiply two numbers',
          'parameters': {
            'type': 'object',
            'properties': {
              'a': {'type': 'number', 'description': 'First number'},
              'b': {'type': 'number', 'description': 'Second number'},
            },
            'required': ['a', 'b'],
          },
        },
        {
          'name': 'divide',
          'description': 'Divide first number by second number',
          'parameters': {
            'type': 'object',
            'properties': {
              'a': {'type': 'number', 'description': 'Dividend (number to be divided)'},
              'b': {'type': 'number', 'description': 'Divisor (number to divide by)'},
            },
            'required': ['a', 'b'],
          },
        },
        {
          'name': 'power',
          'description': 'Raise a number to a power (exponentiation)',
          'parameters': {
            'type': 'object',
            'properties': {
              'base': {'type': 'number', 'description': 'The base number'},
              'exponent': {'type': 'number', 'description': 'The exponent/power'},
            },
            'required': ['base', 'exponent'],
          },
        },
        {
          'name': 'sqrt',
          'description': 'Calculate the square root of a number',
          'parameters': {
            'type': 'object',
            'properties': {
              'number': {'type': 'number', 'description': 'The number to find square root of'},
            },
            'required': ['number'],
          },
        },
        {
          'name': 'percentage',
          'description': 'Calculate percentage of a number',
          'parameters': {
            'type': 'object',
            'properties': {
              'value': {'type': 'number', 'description': 'The base value'},
              'percent': {'type': 'number', 'description': 'The percentage to calculate'},
            },
            'required': ['value', 'percent'],
          },
        },
      ],
    },
  ];

  /// Execute a calculator function
  dynamic _executeFunction(String name, Map<String, dynamic> args) {
    switch (name) {
      case 'add':
        return (args['a'] as num) + (args['b'] as num);
      case 'subtract':
        return (args['a'] as num) - (args['b'] as num);
      case 'multiply':
        return (args['a'] as num) * (args['b'] as num);
      case 'divide':
        final b = args['b'] as num;
        if (b == 0) return 'Error: Division by zero';
        return (args['a'] as num) / b;
      case 'power':
        return math.pow(args['base'] as num, args['exponent'] as num);
      case 'sqrt':
        final n = args['number'] as num;
        if (n < 0) return 'Error: Cannot calculate square root of negative number';
        return math.sqrt(n);
      case 'percentage':
        return (args['value'] as num) * (args['percent'] as num) / 100;
      default:
        return 'Error: Unknown function $name';
    }
  }

  /// Send a chat message and get a response (with tool calling support)
  Future<String> chat({
    required String message,
    List<Map<String, String>>? history,
    String? systemInstruction,
    bool enableTools = true,
  }) async {
    final url = Uri.parse('$_baseUrl/$_model:generateContent?key=$apiKey');

    final contents = <Map<String, dynamic>>[];

    // Add history if provided
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

    // Add current user message
    contents.add({
      'role': 'user',
      'parts': [
        {'text': message}
      ],
    });

    final body = <String, dynamic>{
      'contents': contents,
    };

    // Add system instruction if provided
    if (systemInstruction != null && systemInstruction.isNotEmpty) {
      body['systemInstruction'] = {
        'parts': [
          {'text': systemInstruction}
        ],
      };
    }

    // Add calculator tools
    if (enableTools) {
      body['tools'] = _calculatorTools;
    }

    // Add generation config
    body['generationConfig'] = {
      'temperature': 0.7,
      'topK': 40,
      'topP': 0.95,
      'maxOutputTokens': 2048,
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return await _processResponse(data, contents, systemInstruction);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(
        'Gemini API error: ${error['error']?['message'] ?? response.body}',
      );
    }
  }

  /// Process the response, handling function calls if present
  Future<String> _processResponse(
    Map<String, dynamic> data,
    List<Map<String, dynamic>> contents,
    String? systemInstruction,
  ) async {
    final candidates = data['candidates'] as List<dynamic>?;

    if (candidates == null || candidates.isEmpty) {
      return 'No response generated.';
    }

    final content = candidates[0]['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List<dynamic>?;

    if (parts == null || parts.isEmpty) {
      return 'No response generated.';
    }

    // Check if there's a function call
    final functionCall = parts[0]['functionCall'] as Map<String, dynamic>?;

    if (functionCall != null) {
      final functionName = functionCall['name'] as String;
      final functionArgs = functionCall['args'] as Map<String, dynamic>;

      // Execute the function
      final result = _executeFunction(functionName, functionArgs);

      // Send the function result back to Gemini
      return await _sendFunctionResult(
        contents,
        functionName,
        functionArgs,
        result,
        systemInstruction,
      );
    }

    // Regular text response
    return parts[0]['text'] as String? ?? 'No response generated.';
  }

  /// Send a course chat message with course-specific tools
  /// Returns either text or a function call for the endpoint to handle
  Future<GeminiChatResult> courseChat({
    required String message,
    List<Map<String, String>>? history,
    String? systemInstruction,
  }) async {
    final url = Uri.parse('$_baseUrl/$_model:generateContent?key=$apiKey');

    final contents = <Map<String, dynamic>>[];

    // Add history if provided
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

    // Add current user message
    contents.add({
      'role': 'user',
      'parts': [
        {'text': message}
      ],
    });

    final body = <String, dynamic>{
      'contents': contents,
      'tools': _courseTools,
      'generationConfig': {
        'temperature': 0.7,
        'topK': 40,
        'topP': 0.95,
        'maxOutputTokens': 2048,
      },
    };

    // Add system instruction if provided
    if (systemInstruction != null && systemInstruction.isNotEmpty) {
      body['systemInstruction'] = {
        'parts': [
          {'text': systemInstruction}
        ],
      };
    }

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return _parseCourseResponse(data);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(
        'Gemini API error: ${error['error']?['message'] ?? response.body}',
      );
    }
  }

  /// Parse the response and return text or function call info
  GeminiChatResult _parseCourseResponse(Map<String, dynamic> data) {
    final candidates = data['candidates'] as List<dynamic>?;

    if (candidates == null || candidates.isEmpty) {
      return GeminiChatResult(text: 'No response generated.');
    }

    final content = candidates[0]['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List<dynamic>?;

    if (parts == null || parts.isEmpty) {
      return GeminiChatResult(text: 'No response generated.');
    }

    // Check if there's a function call
    final functionCall = parts[0]['functionCall'] as Map<String, dynamic>?;

    if (functionCall != null) {
      final functionName = functionCall['name'] as String;
      final functionArgs = functionCall['args'] as Map<String, dynamic>;
      return GeminiChatResult(
        functionName: functionName,
        functionArgs: functionArgs,
      );
    }

    // Regular text response
    return GeminiChatResult(
      text: parts[0]['text'] as String? ?? 'No response generated.',
    );
  }

  /// Continue conversation after function execution with the result
  Future<String> sendFunctionResultForCourse({
    required List<Map<String, dynamic>> contents,
    required String functionName,
    required Map<String, dynamic> functionArgs,
    required dynamic result,
    String? systemInstruction,
  }) async {
    final url = Uri.parse('$_baseUrl/$_model:generateContent?key=$apiKey');

    // Add the model's function call to contents
    contents.add({
      'role': 'model',
      'parts': [
        {
          'functionCall': {
            'name': functionName,
            'args': functionArgs,
          }
        }
      ],
    });

    // Add the function response
    contents.add({
      'role': 'function',
      'parts': [
        {
          'functionResponse': {
            'name': functionName,
            'response': {
              'result': result,
            },
          }
        }
      ],
    });

    final body = <String, dynamic>{
      'contents': contents,
      'tools': _courseTools,
      'generationConfig': {
        'temperature': 0.7,
        'topK': 40,
        'topP': 0.95,
        'maxOutputTokens': 2048,
      },
    };

    if (systemInstruction != null && systemInstruction.isNotEmpty) {
      body['systemInstruction'] = {
        'parts': [
          {'text': systemInstruction}
        ],
      };
    }

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final candidates = data['candidates'] as List<dynamic>?;

      if (candidates != null && candidates.isNotEmpty) {
        final content = candidates[0]['content'] as Map<String, dynamic>?;
        final parts = content?['parts'] as List<dynamic>?;

        if (parts != null && parts.isNotEmpty) {
          return parts[0]['text'] as String? ?? 'Action completed successfully.';
        }
      }
      return 'Action completed successfully.';
    } else {
      final error = jsonDecode(response.body);
      throw Exception(
        'Gemini API error: ${error['error']?['message'] ?? response.body}',
      );
    }
  }

  /// Send function result back to Gemini for final response
  Future<String> _sendFunctionResult(
    List<Map<String, dynamic>> contents,
    String functionName,
    Map<String, dynamic> functionArgs,
    dynamic result,
    String? systemInstruction,
  ) async {
    final url = Uri.parse('$_baseUrl/$_model:generateContent?key=$apiKey');

    // Add the model's function call to contents
    contents.add({
      'role': 'model',
      'parts': [
        {
          'functionCall': {
            'name': functionName,
            'args': functionArgs,
          }
        }
      ],
    });

    // Add the function response
    contents.add({
      'role': 'function',
      'parts': [
        {
          'functionResponse': {
            'name': functionName,
            'response': {
              'result': result,
            },
          }
        }
      ],
    });

    final body = <String, dynamic>{
      'contents': contents,
      'tools': _calculatorTools,
      'generationConfig': {
        'temperature': 0.7,
        'topK': 40,
        'topP': 0.95,
        'maxOutputTokens': 2048,
      },
    };

    if (systemInstruction != null && systemInstruction.isNotEmpty) {
      body['systemInstruction'] = {
        'parts': [
          {'text': systemInstruction}
        ],
      };
    }

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final candidates = data['candidates'] as List<dynamic>?;

      if (candidates != null && candidates.isNotEmpty) {
        final content = candidates[0]['content'] as Map<String, dynamic>?;
        final parts = content?['parts'] as List<dynamic>?;

        if (parts != null && parts.isNotEmpty) {
          // Check for another function call (chained calculations)
          final nextFunctionCall = parts[0]['functionCall'] as Map<String, dynamic>?;
          if (nextFunctionCall != null) {
            final nextName = nextFunctionCall['name'] as String;
            final nextArgs = nextFunctionCall['args'] as Map<String, dynamic>;
            final nextResult = _executeFunction(nextName, nextArgs);
            return await _sendFunctionResult(
              contents,
              nextName,
              nextArgs,
              nextResult,
              systemInstruction,
            );
          }
          return parts[0]['text'] as String? ?? 'Calculation complete: $result';
        }
      }
      return 'Calculation result: $result';
    } else {
      final error = jsonDecode(response.body);
      throw Exception(
        'Gemini API error: ${error['error']?['message'] ?? response.body}',
      );
    }
  }

  /// Generate text embedding using Gemini embedding model
  /// Returns a 3072-dimensional vector for semantic search (gemini-embedding-001)
  Future<List<double>> generateEmbedding(String text) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-embedding-001:embedContent?key=$apiKey',
    );

    final body = jsonEncode({
      'content': {
        'parts': [
          {'text': text}
        ]
      },
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final values = data['embedding']['values'] as List;
      return values.cast<double>();
    } else {
      final error = jsonDecode(response.body);
      throw Exception(
        'Gemini embedding API error: ${error['error']?['message'] ?? response.body}',
      );
    }
  }
}
