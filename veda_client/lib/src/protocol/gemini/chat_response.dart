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

abstract class ChatResponse implements _i1.SerializableModel {
  ChatResponse._({
    required this.text,
    this.error,
  });

  factory ChatResponse({
    required String text,
    String? error,
  }) = _ChatResponseImpl;

  factory ChatResponse.fromJson(Map<String, dynamic> jsonSerialization) {
    return ChatResponse(
      text: jsonSerialization['text'] as String,
      error: jsonSerialization['error'] as String?,
    );
  }

  String text;

  String? error;

  /// Returns a shallow copy of this [ChatResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ChatResponse copyWith({
    String? text,
    String? error,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ChatResponse',
      'text': text,
      if (error != null) 'error': error,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ChatResponseImpl extends ChatResponse {
  _ChatResponseImpl({
    required String text,
    String? error,
  }) : super._(
         text: text,
         error: error,
       );

  /// Returns a shallow copy of this [ChatResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ChatResponse copyWith({
    String? text,
    Object? error = _Undefined,
  }) {
    return ChatResponse(
      text: text ?? this.text,
      error: error is String? ? error : this.error,
    );
  }
}
