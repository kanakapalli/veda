/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;
import '../lms/course.dart' as _i2;
import 'package:veda_server/src/generated/protocol.dart' as _i3;

abstract class CourseChatResponse
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  CourseChatResponse._({
    required this.text,
    this.error,
    this.toolsExecuted,
    this.updatedCourse,
  });

  factory CourseChatResponse({
    required String text,
    String? error,
    List<String>? toolsExecuted,
    _i2.Course? updatedCourse,
  }) = _CourseChatResponseImpl;

  factory CourseChatResponse.fromJson(Map<String, dynamic> jsonSerialization) {
    return CourseChatResponse(
      text: jsonSerialization['text'] as String,
      error: jsonSerialization['error'] as String?,
      toolsExecuted: jsonSerialization['toolsExecuted'] == null
          ? null
          : _i3.Protocol().deserialize<List<String>>(
              jsonSerialization['toolsExecuted'],
            ),
      updatedCourse: jsonSerialization['updatedCourse'] == null
          ? null
          : _i3.Protocol().deserialize<_i2.Course>(
              jsonSerialization['updatedCourse'],
            ),
    );
  }

  String text;

  String? error;

  List<String>? toolsExecuted;

  _i2.Course? updatedCourse;

  /// Returns a shallow copy of this [CourseChatResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CourseChatResponse copyWith({
    String? text,
    String? error,
    List<String>? toolsExecuted,
    _i2.Course? updatedCourse,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CourseChatResponse',
      'text': text,
      if (error != null) 'error': error,
      if (toolsExecuted != null) 'toolsExecuted': toolsExecuted?.toJson(),
      if (updatedCourse != null) 'updatedCourse': updatedCourse?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CourseChatResponse',
      'text': text,
      if (error != null) 'error': error,
      if (toolsExecuted != null) 'toolsExecuted': toolsExecuted?.toJson(),
      if (updatedCourse != null)
        'updatedCourse': updatedCourse?.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CourseChatResponseImpl extends CourseChatResponse {
  _CourseChatResponseImpl({
    required String text,
    String? error,
    List<String>? toolsExecuted,
    _i2.Course? updatedCourse,
  }) : super._(
         text: text,
         error: error,
         toolsExecuted: toolsExecuted,
         updatedCourse: updatedCourse,
       );

  /// Returns a shallow copy of this [CourseChatResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CourseChatResponse copyWith({
    String? text,
    Object? error = _Undefined,
    Object? toolsExecuted = _Undefined,
    Object? updatedCourse = _Undefined,
  }) {
    return CourseChatResponse(
      text: text ?? this.text,
      error: error is String? ? error : this.error,
      toolsExecuted: toolsExecuted is List<String>?
          ? toolsExecuted
          : this.toolsExecuted?.map((e0) => e0).toList(),
      updatedCourse: updatedCourse is _i2.Course?
          ? updatedCourse
          : this.updatedCourse?.copyWith(),
    );
  }
}
