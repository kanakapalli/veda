import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;

/// Service for interacting with Gemini API using Google AI Studio API key
class GeminiService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';
  static const String _model = 'gemini-2.0-flash';

  final String apiKey;

  GeminiService({required this.apiKey});

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
}
