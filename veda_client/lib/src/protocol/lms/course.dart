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
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i2;
import '../lms/course_visibility.dart' as _i3;
import '../lms/module.dart' as _i4;
import '../lms/course_index.dart' as _i5;
import '../lms/knowledge_file.dart' as _i6;
import 'package:veda_client/src/protocol/protocol.dart' as _i7;

/// Course container - defines high-level course settings and AI parameters
abstract class Course implements _i1.SerializableModel {
  Course._({
    this.id,
    required this.creatorId,
    this.creator,
    required this.title,
    this.description,
    this.courseImageUrl,
    this.bannerImageUrl,
    this.videoUrl,
    required this.visibility,
    this.systemPrompt,
    this.courseTopics,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.modules,
    this.courseIndices,
    this.knowledgeFiles,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory Course({
    int? id,
    required _i1.UuidValue creatorId,
    _i2.AuthUser? creator,
    required String title,
    String? description,
    String? courseImageUrl,
    String? bannerImageUrl,
    String? videoUrl,
    required _i3.CourseVisibility visibility,
    String? systemPrompt,
    List<String>? courseTopics,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<_i4.Module>? modules,
    List<_i5.CourseIndex>? courseIndices,
    List<_i6.KnowledgeFile>? knowledgeFiles,
  }) = _CourseImpl;

  factory Course.fromJson(Map<String, dynamic> jsonSerialization) {
    return Course(
      id: jsonSerialization['id'] as int?,
      creatorId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['creatorId'],
      ),
      creator: jsonSerialization['creator'] == null
          ? null
          : _i7.Protocol().deserialize<_i2.AuthUser>(
              jsonSerialization['creator'],
            ),
      title: jsonSerialization['title'] as String,
      description: jsonSerialization['description'] as String?,
      courseImageUrl: jsonSerialization['courseImageUrl'] as String?,
      bannerImageUrl: jsonSerialization['bannerImageUrl'] as String?,
      videoUrl: jsonSerialization['videoUrl'] as String?,
      visibility: _i3.CourseVisibility.fromJson(
        (jsonSerialization['visibility'] as String),
      ),
      systemPrompt: jsonSerialization['systemPrompt'] as String?,
      courseTopics: jsonSerialization['courseTopics'] == null
          ? null
          : _i7.Protocol().deserialize<List<String>>(
              jsonSerialization['courseTopics'],
            ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
      modules: jsonSerialization['modules'] == null
          ? null
          : _i7.Protocol().deserialize<List<_i4.Module>>(
              jsonSerialization['modules'],
            ),
      courseIndices: jsonSerialization['courseIndices'] == null
          ? null
          : _i7.Protocol().deserialize<List<_i5.CourseIndex>>(
              jsonSerialization['courseIndices'],
            ),
      knowledgeFiles: jsonSerialization['knowledgeFiles'] == null
          ? null
          : _i7.Protocol().deserialize<List<_i6.KnowledgeFile>>(
              jsonSerialization['knowledgeFiles'],
            ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  _i1.UuidValue creatorId;

  /// Link to the authenticated user who created this course (nullable, set by server)
  _i2.AuthUser? creator;

  /// Course title
  String title;

  /// Course description
  String? description;

  /// URL for course thumbnail image
  String? courseImageUrl;

  /// URL for course banner image
  String? bannerImageUrl;

  /// URL for course intro video
  String? videoUrl;

  /// Course visibility status (draft, public, private)
  _i3.CourseVisibility visibility;

  /// System prompt for AI course generation
  String? systemPrompt;

  /// Course topics/tags for categorization and search
  List<String>? courseTopics;

  /// Timestamp when the course was created
  DateTime createdAt;

  /// Timestamp when the course was last updated
  DateTime updatedAt;

  /// List of modules in this course
  List<_i4.Module>? modules;

  /// List of course indices (searchable tags/keywords)
  List<_i5.CourseIndex>? courseIndices;

  /// List of knowledge files for AI generation
  List<_i6.KnowledgeFile>? knowledgeFiles;

  /// Returns a shallow copy of this [Course]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Course copyWith({
    int? id,
    _i1.UuidValue? creatorId,
    _i2.AuthUser? creator,
    String? title,
    String? description,
    String? courseImageUrl,
    String? bannerImageUrl,
    String? videoUrl,
    _i3.CourseVisibility? visibility,
    String? systemPrompt,
    List<String>? courseTopics,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<_i4.Module>? modules,
    List<_i5.CourseIndex>? courseIndices,
    List<_i6.KnowledgeFile>? knowledgeFiles,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Course',
      if (id != null) 'id': id,
      'creatorId': creatorId.toJson(),
      if (creator != null) 'creator': creator?.toJson(),
      'title': title,
      if (description != null) 'description': description,
      if (courseImageUrl != null) 'courseImageUrl': courseImageUrl,
      if (bannerImageUrl != null) 'bannerImageUrl': bannerImageUrl,
      if (videoUrl != null) 'videoUrl': videoUrl,
      'visibility': visibility.toJson(),
      if (systemPrompt != null) 'systemPrompt': systemPrompt,
      if (courseTopics != null) 'courseTopics': courseTopics?.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (modules != null)
        'modules': modules?.toJson(valueToJson: (v) => v.toJson()),
      if (courseIndices != null)
        'courseIndices': courseIndices?.toJson(valueToJson: (v) => v.toJson()),
      if (knowledgeFiles != null)
        'knowledgeFiles': knowledgeFiles?.toJson(
          valueToJson: (v) => v.toJson(),
        ),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CourseImpl extends Course {
  _CourseImpl({
    int? id,
    required _i1.UuidValue creatorId,
    _i2.AuthUser? creator,
    required String title,
    String? description,
    String? courseImageUrl,
    String? bannerImageUrl,
    String? videoUrl,
    required _i3.CourseVisibility visibility,
    String? systemPrompt,
    List<String>? courseTopics,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<_i4.Module>? modules,
    List<_i5.CourseIndex>? courseIndices,
    List<_i6.KnowledgeFile>? knowledgeFiles,
  }) : super._(
         id: id,
         creatorId: creatorId,
         creator: creator,
         title: title,
         description: description,
         courseImageUrl: courseImageUrl,
         bannerImageUrl: bannerImageUrl,
         videoUrl: videoUrl,
         visibility: visibility,
         systemPrompt: systemPrompt,
         courseTopics: courseTopics,
         createdAt: createdAt,
         updatedAt: updatedAt,
         modules: modules,
         courseIndices: courseIndices,
         knowledgeFiles: knowledgeFiles,
       );

  /// Returns a shallow copy of this [Course]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Course copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? creatorId,
    Object? creator = _Undefined,
    String? title,
    Object? description = _Undefined,
    Object? courseImageUrl = _Undefined,
    Object? bannerImageUrl = _Undefined,
    Object? videoUrl = _Undefined,
    _i3.CourseVisibility? visibility,
    Object? systemPrompt = _Undefined,
    Object? courseTopics = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? modules = _Undefined,
    Object? courseIndices = _Undefined,
    Object? knowledgeFiles = _Undefined,
  }) {
    return Course(
      id: id is int? ? id : this.id,
      creatorId: creatorId ?? this.creatorId,
      creator: creator is _i2.AuthUser? ? creator : this.creator?.copyWith(),
      title: title ?? this.title,
      description: description is String? ? description : this.description,
      courseImageUrl: courseImageUrl is String?
          ? courseImageUrl
          : this.courseImageUrl,
      bannerImageUrl: bannerImageUrl is String?
          ? bannerImageUrl
          : this.bannerImageUrl,
      videoUrl: videoUrl is String? ? videoUrl : this.videoUrl,
      visibility: visibility ?? this.visibility,
      systemPrompt: systemPrompt is String? ? systemPrompt : this.systemPrompt,
      courseTopics: courseTopics is List<String>?
          ? courseTopics
          : this.courseTopics?.map((e0) => e0).toList(),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      modules: modules is List<_i4.Module>?
          ? modules
          : this.modules?.map((e0) => e0.copyWith()).toList(),
      courseIndices: courseIndices is List<_i5.CourseIndex>?
          ? courseIndices
          : this.courseIndices?.map((e0) => e0.copyWith()).toList(),
      knowledgeFiles: knowledgeFiles is List<_i6.KnowledgeFile>?
          ? knowledgeFiles
          : this.knowledgeFiles?.map((e0) => e0.copyWith()).toList(),
    );
  }
}
