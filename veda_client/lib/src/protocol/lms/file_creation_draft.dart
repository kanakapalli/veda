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
import 'package:veda_client/src/protocol/protocol.dart' as _i3;

/// File Creation Draft - stores user's in-progress notes/files created with AI assistance
abstract class FileCreationDraft implements _i1.SerializableModel {
  FileCreationDraft._({
    this.id,
    required this.creatorId,
    this.creator,
    this.courseId,
    required this.title,
    required this.content,
    this.chatHistory,
    String? fileType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : fileType = fileType ?? 'md',
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory FileCreationDraft({
    int? id,
    required _i1.UuidValue creatorId,
    _i2.AuthUser? creator,
    int? courseId,
    required String title,
    required String content,
    String? chatHistory,
    String? fileType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _FileCreationDraftImpl;

  factory FileCreationDraft.fromJson(Map<String, dynamic> jsonSerialization) {
    return FileCreationDraft(
      id: jsonSerialization['id'] as int?,
      creatorId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['creatorId'],
      ),
      creator: jsonSerialization['creator'] == null
          ? null
          : _i3.Protocol().deserialize<_i2.AuthUser>(
              jsonSerialization['creator'],
            ),
      courseId: jsonSerialization['courseId'] as int?,
      title: jsonSerialization['title'] as String,
      content: jsonSerialization['content'] as String,
      chatHistory: jsonSerialization['chatHistory'] as String?,
      fileType: jsonSerialization['fileType'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  _i1.UuidValue creatorId;

  /// Link to the user who created this draft
  _i2.AuthUser? creator;

  /// Link to the course this draft belongs to
  int? courseId;

  /// Title of the file/note
  String title;

  /// Content in markdown format
  String content;

  /// AI chat history for this draft (JSON string)
  String? chatHistory;

  /// File type (txt, md, pdf)
  String fileType;

  /// Creation timestamp
  DateTime createdAt;

  /// Last update timestamp
  DateTime updatedAt;

  /// Returns a shallow copy of this [FileCreationDraft]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  FileCreationDraft copyWith({
    int? id,
    _i1.UuidValue? creatorId,
    _i2.AuthUser? creator,
    int? courseId,
    String? title,
    String? content,
    String? chatHistory,
    String? fileType,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'FileCreationDraft',
      if (id != null) 'id': id,
      'creatorId': creatorId.toJson(),
      if (creator != null) 'creator': creator?.toJson(),
      if (courseId != null) 'courseId': courseId,
      'title': title,
      'content': content,
      if (chatHistory != null) 'chatHistory': chatHistory,
      'fileType': fileType,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _FileCreationDraftImpl extends FileCreationDraft {
  _FileCreationDraftImpl({
    int? id,
    required _i1.UuidValue creatorId,
    _i2.AuthUser? creator,
    int? courseId,
    required String title,
    required String content,
    String? chatHistory,
    String? fileType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         creatorId: creatorId,
         creator: creator,
         courseId: courseId,
         title: title,
         content: content,
         chatHistory: chatHistory,
         fileType: fileType,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [FileCreationDraft]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  FileCreationDraft copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? creatorId,
    Object? creator = _Undefined,
    Object? courseId = _Undefined,
    String? title,
    String? content,
    Object? chatHistory = _Undefined,
    String? fileType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FileCreationDraft(
      id: id is int? ? id : this.id,
      creatorId: creatorId ?? this.creatorId,
      creator: creator is _i2.AuthUser? ? creator : this.creator?.copyWith(),
      courseId: courseId is int? ? courseId : this.courseId,
      title: title ?? this.title,
      content: content ?? this.content,
      chatHistory: chatHistory is String? ? chatHistory : this.chatHistory,
      fileType: fileType ?? this.fileType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
