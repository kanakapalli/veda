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

abstract class LiveSessionConfig
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  LiveSessionConfig._({
    required this.courseId,
    this.systemPrompt,
    this.moduleTitle,
    this.voiceName,
  });

  factory LiveSessionConfig({
    required int courseId,
    String? systemPrompt,
    String? moduleTitle,
    String? voiceName,
  }) = _LiveSessionConfigImpl;

  factory LiveSessionConfig.fromJson(Map<String, dynamic> jsonSerialization) {
    return LiveSessionConfig(
      courseId: jsonSerialization['courseId'] as int,
      systemPrompt: jsonSerialization['systemPrompt'] as String?,
      moduleTitle: jsonSerialization['moduleTitle'] as String?,
      voiceName: jsonSerialization['voiceName'] as String?,
    );
  }

  int courseId;

  String? systemPrompt;

  String? moduleTitle;

  String? voiceName;

  /// Returns a shallow copy of this [LiveSessionConfig]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  LiveSessionConfig copyWith({
    int? courseId,
    String? systemPrompt,
    String? moduleTitle,
    String? voiceName,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'LiveSessionConfig',
      'courseId': courseId,
      if (systemPrompt != null) 'systemPrompt': systemPrompt,
      if (moduleTitle != null) 'moduleTitle': moduleTitle,
      if (voiceName != null) 'voiceName': voiceName,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'LiveSessionConfig',
      'courseId': courseId,
      if (systemPrompt != null) 'systemPrompt': systemPrompt,
      if (moduleTitle != null) 'moduleTitle': moduleTitle,
      if (voiceName != null) 'voiceName': voiceName,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _LiveSessionConfigImpl extends LiveSessionConfig {
  _LiveSessionConfigImpl({
    required int courseId,
    String? systemPrompt,
    String? moduleTitle,
    String? voiceName,
  }) : super._(
         courseId: courseId,
         systemPrompt: systemPrompt,
         moduleTitle: moduleTitle,
         voiceName: voiceName,
       );

  /// Returns a shallow copy of this [LiveSessionConfig]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  LiveSessionConfig copyWith({
    int? courseId,
    Object? systemPrompt = _Undefined,
    Object? moduleTitle = _Undefined,
    Object? voiceName = _Undefined,
  }) {
    return LiveSessionConfig(
      courseId: courseId ?? this.courseId,
      systemPrompt: systemPrompt is String? ? systemPrompt : this.systemPrompt,
      moduleTitle: moduleTitle is String? ? moduleTitle : this.moduleTitle,
      voiceName: voiceName is String? ? voiceName : this.voiceName,
    );
  }
}
