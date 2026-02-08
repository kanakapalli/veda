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
import 'gemini/chat_message.dart' as _i2;
import 'gemini/chat_request.dart' as _i3;
import 'gemini/chat_response.dart' as _i4;
import 'gemini/course_chat_request.dart' as _i5;
import 'gemini/course_chat_response.dart' as _i6;
import 'greetings/greeting.dart' as _i7;
import 'lms/course.dart' as _i8;
import 'lms/course_index.dart' as _i9;
import 'lms/course_visibility.dart' as _i10;
import 'lms/knowledge_file.dart' as _i11;
import 'lms/module.dart' as _i12;
import 'lms/module_item.dart' as _i13;
import 'lms/topic.dart' as _i14;
import 'profiles/user_profile.dart' as _i15;
import 'profiles/user_profile_with_email.dart' as _i16;
import 'package:veda_client/src/protocol/lms/course.dart' as _i17;
import 'package:veda_client/src/protocol/lms/knowledge_file.dart' as _i18;
import 'package:veda_client/src/protocol/lms/module.dart' as _i19;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i20;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i21;
export 'gemini/chat_message.dart';
export 'gemini/chat_request.dart';
export 'gemini/chat_response.dart';
export 'gemini/course_chat_request.dart';
export 'gemini/course_chat_response.dart';
export 'greetings/greeting.dart';
export 'lms/course.dart';
export 'lms/course_index.dart';
export 'lms/course_visibility.dart';
export 'lms/knowledge_file.dart';
export 'lms/module.dart';
export 'lms/module_item.dart';
export 'lms/topic.dart';
export 'profiles/user_profile.dart';
export 'profiles/user_profile_with_email.dart';
export 'client.dart';

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on FormatException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _i2.ChatMessage) {
      return _i2.ChatMessage.fromJson(data) as T;
    }
    if (t == _i3.ChatRequest) {
      return _i3.ChatRequest.fromJson(data) as T;
    }
    if (t == _i4.ChatResponse) {
      return _i4.ChatResponse.fromJson(data) as T;
    }
    if (t == _i5.CourseChatRequest) {
      return _i5.CourseChatRequest.fromJson(data) as T;
    }
    if (t == _i6.CourseChatResponse) {
      return _i6.CourseChatResponse.fromJson(data) as T;
    }
    if (t == _i7.Greeting) {
      return _i7.Greeting.fromJson(data) as T;
    }
    if (t == _i8.Course) {
      return _i8.Course.fromJson(data) as T;
    }
    if (t == _i9.CourseIndex) {
      return _i9.CourseIndex.fromJson(data) as T;
    }
    if (t == _i10.CourseVisibility) {
      return _i10.CourseVisibility.fromJson(data) as T;
    }
    if (t == _i11.KnowledgeFile) {
      return _i11.KnowledgeFile.fromJson(data) as T;
    }
    if (t == _i12.Module) {
      return _i12.Module.fromJson(data) as T;
    }
    if (t == _i13.ModuleItem) {
      return _i13.ModuleItem.fromJson(data) as T;
    }
    if (t == _i14.Topic) {
      return _i14.Topic.fromJson(data) as T;
    }
    if (t == _i15.VedaUserProfile) {
      return _i15.VedaUserProfile.fromJson(data) as T;
    }
    if (t == _i16.VedaUserProfileWithEmail) {
      return _i16.VedaUserProfileWithEmail.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.ChatMessage?>()) {
      return (data != null ? _i2.ChatMessage.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.ChatRequest?>()) {
      return (data != null ? _i3.ChatRequest.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.ChatResponse?>()) {
      return (data != null ? _i4.ChatResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.CourseChatRequest?>()) {
      return (data != null ? _i5.CourseChatRequest.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.CourseChatResponse?>()) {
      return (data != null ? _i6.CourseChatResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.Greeting?>()) {
      return (data != null ? _i7.Greeting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.Course?>()) {
      return (data != null ? _i8.Course.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.CourseIndex?>()) {
      return (data != null ? _i9.CourseIndex.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.CourseVisibility?>()) {
      return (data != null ? _i10.CourseVisibility.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.KnowledgeFile?>()) {
      return (data != null ? _i11.KnowledgeFile.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i12.Module?>()) {
      return (data != null ? _i12.Module.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i13.ModuleItem?>()) {
      return (data != null ? _i13.ModuleItem.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i14.Topic?>()) {
      return (data != null ? _i14.Topic.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i15.VedaUserProfile?>()) {
      return (data != null ? _i15.VedaUserProfile.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i16.VedaUserProfileWithEmail?>()) {
      return (data != null
              ? _i16.VedaUserProfileWithEmail.fromJson(data)
              : null)
          as T;
    }
    if (t == List<_i2.ChatMessage>) {
      return (data as List).map((e) => deserialize<_i2.ChatMessage>(e)).toList()
          as T;
    }
    if (t == _i1.getType<List<_i2.ChatMessage>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i2.ChatMessage>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == _i1.getType<List<String>?>()) {
      return (data != null
              ? (data as List).map((e) => deserialize<String>(e)).toList()
              : null)
          as T;
    }
    if (t == List<_i12.Module>) {
      return (data as List).map((e) => deserialize<_i12.Module>(e)).toList()
          as T;
    }
    if (t == _i1.getType<List<_i12.Module>?>()) {
      return (data != null
              ? (data as List).map((e) => deserialize<_i12.Module>(e)).toList()
              : null)
          as T;
    }
    if (t == List<_i9.CourseIndex>) {
      return (data as List).map((e) => deserialize<_i9.CourseIndex>(e)).toList()
          as T;
    }
    if (t == _i1.getType<List<_i9.CourseIndex>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i9.CourseIndex>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_i11.KnowledgeFile>) {
      return (data as List)
              .map((e) => deserialize<_i11.KnowledgeFile>(e))
              .toList()
          as T;
    }
    if (t == _i1.getType<List<_i11.KnowledgeFile>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i11.KnowledgeFile>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_i13.ModuleItem>) {
      return (data as List).map((e) => deserialize<_i13.ModuleItem>(e)).toList()
          as T;
    }
    if (t == _i1.getType<List<_i13.ModuleItem>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i13.ModuleItem>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<Map<String, String>>) {
      return (data as List)
              .map((e) => deserialize<Map<String, String>>(e))
              .toList()
          as T;
    }
    if (t == Map<String, String>) {
      return (data as Map).map(
            (k, v) => MapEntry(deserialize<String>(k), deserialize<String>(v)),
          )
          as T;
    }
    if (t == _i1.getType<List<Map<String, String>>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<Map<String, String>>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<int>) {
      return (data as List).map((e) => deserialize<int>(e)).toList() as T;
    }
    if (t == List<_i17.Course>) {
      return (data as List).map((e) => deserialize<_i17.Course>(e)).toList()
          as T;
    }
    if (t == List<_i18.KnowledgeFile>) {
      return (data as List)
              .map((e) => deserialize<_i18.KnowledgeFile>(e))
              .toList()
          as T;
    }
    if (t == List<_i19.Module>) {
      return (data as List).map((e) => deserialize<_i19.Module>(e)).toList()
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    try {
      return _i20.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i21.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.ChatMessage => 'ChatMessage',
      _i3.ChatRequest => 'ChatRequest',
      _i4.ChatResponse => 'ChatResponse',
      _i5.CourseChatRequest => 'CourseChatRequest',
      _i6.CourseChatResponse => 'CourseChatResponse',
      _i7.Greeting => 'Greeting',
      _i8.Course => 'Course',
      _i9.CourseIndex => 'CourseIndex',
      _i10.CourseVisibility => 'CourseVisibility',
      _i11.KnowledgeFile => 'KnowledgeFile',
      _i12.Module => 'Module',
      _i13.ModuleItem => 'ModuleItem',
      _i14.Topic => 'Topic',
      _i15.VedaUserProfile => 'VedaUserProfile',
      _i16.VedaUserProfileWithEmail => 'VedaUserProfileWithEmail',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('veda.', '');
    }

    switch (data) {
      case _i2.ChatMessage():
        return 'ChatMessage';
      case _i3.ChatRequest():
        return 'ChatRequest';
      case _i4.ChatResponse():
        return 'ChatResponse';
      case _i5.CourseChatRequest():
        return 'CourseChatRequest';
      case _i6.CourseChatResponse():
        return 'CourseChatResponse';
      case _i7.Greeting():
        return 'Greeting';
      case _i8.Course():
        return 'Course';
      case _i9.CourseIndex():
        return 'CourseIndex';
      case _i10.CourseVisibility():
        return 'CourseVisibility';
      case _i11.KnowledgeFile():
        return 'KnowledgeFile';
      case _i12.Module():
        return 'Module';
      case _i13.ModuleItem():
        return 'ModuleItem';
      case _i14.Topic():
        return 'Topic';
      case _i15.VedaUserProfile():
        return 'VedaUserProfile';
      case _i16.VedaUserProfileWithEmail():
        return 'VedaUserProfileWithEmail';
    }
    className = _i20.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    className = _i21.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_core.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'ChatMessage') {
      return deserialize<_i2.ChatMessage>(data['data']);
    }
    if (dataClassName == 'ChatRequest') {
      return deserialize<_i3.ChatRequest>(data['data']);
    }
    if (dataClassName == 'ChatResponse') {
      return deserialize<_i4.ChatResponse>(data['data']);
    }
    if (dataClassName == 'CourseChatRequest') {
      return deserialize<_i5.CourseChatRequest>(data['data']);
    }
    if (dataClassName == 'CourseChatResponse') {
      return deserialize<_i6.CourseChatResponse>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_i7.Greeting>(data['data']);
    }
    if (dataClassName == 'Course') {
      return deserialize<_i8.Course>(data['data']);
    }
    if (dataClassName == 'CourseIndex') {
      return deserialize<_i9.CourseIndex>(data['data']);
    }
    if (dataClassName == 'CourseVisibility') {
      return deserialize<_i10.CourseVisibility>(data['data']);
    }
    if (dataClassName == 'KnowledgeFile') {
      return deserialize<_i11.KnowledgeFile>(data['data']);
    }
    if (dataClassName == 'Module') {
      return deserialize<_i12.Module>(data['data']);
    }
    if (dataClassName == 'ModuleItem') {
      return deserialize<_i13.ModuleItem>(data['data']);
    }
    if (dataClassName == 'Topic') {
      return deserialize<_i14.Topic>(data['data']);
    }
    if (dataClassName == 'VedaUserProfile') {
      return deserialize<_i15.VedaUserProfile>(data['data']);
    }
    if (dataClassName == 'VedaUserProfileWithEmail') {
      return deserialize<_i16.VedaUserProfileWithEmail>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i20.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i21.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _i20.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i21.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
