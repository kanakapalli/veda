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
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import '../gemini/chat_message.dart' as _i2;
import 'package:veda_client/src/protocol/protocol.dart' as _i3;

abstract class CourseChatRequest implements _i1.SerializableModel {
  CourseChatRequest._({
    required this.message,
    required this.courseId,
    this.history,
    this.systemInstruction,
  });

  factory CourseChatRequest({
    required String message,
    required int courseId,
    List<_i2.ChatMessage>? history,
    String? systemInstruction,
  }) = _CourseChatRequestImpl;

  factory CourseChatRequest.fromJson(Map<String, dynamic> jsonSerialization) {
    return CourseChatRequest(
      message: jsonSerialization['message'] as String,
      courseId: jsonSerialization['courseId'] as int,
      history: jsonSerialization['history'] == null
          ? null
          : _i3.Protocol().deserialize<List<_i2.ChatMessage>>(
              jsonSerialization['history'],
            ),
      systemInstruction: jsonSerialization['systemInstruction'] as String?,
    );
  }

  String message;

  int courseId;

  List<_i2.ChatMessage>? history;

  String? systemInstruction;

  /// Returns a shallow copy of this [CourseChatRequest]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CourseChatRequest copyWith({
    String? message,
    int? courseId,
    List<_i2.ChatMessage>? history,
    String? systemInstruction,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CourseChatRequest',
      'message': message,
      'courseId': courseId,
      if (history != null)
        'history': history?.toJson(valueToJson: (v) => v.toJson()),
      if (systemInstruction != null) 'systemInstruction': systemInstruction,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CourseChatRequestImpl extends CourseChatRequest {
  _CourseChatRequestImpl({
    required String message,
    required int courseId,
    List<_i2.ChatMessage>? history,
    String? systemInstruction,
  }) : super._(
         message: message,
         courseId: courseId,
         history: history,
         systemInstruction: systemInstruction,
       );

  /// Returns a shallow copy of this [CourseChatRequest]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CourseChatRequest copyWith({
    String? message,
    int? courseId,
    Object? history = _Undefined,
    Object? systemInstruction = _Undefined,
  }) {
    return CourseChatRequest(
      message: message ?? this.message,
      courseId: courseId ?? this.courseId,
      history: history is List<_i2.ChatMessage>?
          ? history
          : this.history?.map((e0) => e0.copyWith()).toList(),
      systemInstruction: systemInstruction is String?
          ? systemInstruction
          : this.systemInstruction,
    );
  }
}
