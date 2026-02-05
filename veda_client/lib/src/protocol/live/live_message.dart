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

abstract class LiveMessage implements _i1.SerializableModel {
  LiveMessage._({
    required this.type,
    this.text,
    this.audioBase64,
    required this.isUser,
  });

  factory LiveMessage({
    required String type,
    String? text,
    String? audioBase64,
    required bool isUser,
  }) = _LiveMessageImpl;

  factory LiveMessage.fromJson(Map<String, dynamic> jsonSerialization) {
    return LiveMessage(
      type: jsonSerialization['type'] as String,
      text: jsonSerialization['text'] as String?,
      audioBase64: jsonSerialization['audioBase64'] as String?,
      isUser: jsonSerialization['isUser'] as bool,
    );
  }

  String type;

  String? text;

  String? audioBase64;

  bool isUser;

  /// Returns a shallow copy of this [LiveMessage]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  LiveMessage copyWith({
    String? type,
    String? text,
    String? audioBase64,
    bool? isUser,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'LiveMessage',
      'type': type,
      if (text != null) 'text': text,
      if (audioBase64 != null) 'audioBase64': audioBase64,
      'isUser': isUser,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _LiveMessageImpl extends LiveMessage {
  _LiveMessageImpl({
    required String type,
    String? text,
    String? audioBase64,
    required bool isUser,
  }) : super._(
         type: type,
         text: text,
         audioBase64: audioBase64,
         isUser: isUser,
       );

  /// Returns a shallow copy of this [LiveMessage]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  LiveMessage copyWith({
    String? type,
    Object? text = _Undefined,
    Object? audioBase64 = _Undefined,
    bool? isUser,
  }) {
    return LiveMessage(
      type: type ?? this.type,
      text: text is String? ? text : this.text,
      audioBase64: audioBase64 is String? ? audioBase64 : this.audioBase64,
      isUser: isUser ?? this.isUser,
    );
  }
}
