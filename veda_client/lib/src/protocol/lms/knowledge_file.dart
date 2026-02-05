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
import '../lms/course.dart' as _i2;
import 'package:veda_client/src/protocol/protocol.dart' as _i3;

/// KnowledgeFile - source material for AI course generation
abstract class KnowledgeFile implements _i1.SerializableModel {
  KnowledgeFile._({
    this.id,
    required this.fileName,
    required this.fileUrl,
    required this.fileSize,
    this.fileType,
    DateTime? uploadedAt,
    required this.courseId,
    this.course,
  }) : uploadedAt = uploadedAt ?? DateTime.now();

  factory KnowledgeFile({
    int? id,
    required String fileName,
    required String fileUrl,
    required int fileSize,
    String? fileType,
    DateTime? uploadedAt,
    required int courseId,
    _i2.Course? course,
  }) = _KnowledgeFileImpl;

  factory KnowledgeFile.fromJson(Map<String, dynamic> jsonSerialization) {
    return KnowledgeFile(
      id: jsonSerialization['id'] as int?,
      fileName: jsonSerialization['fileName'] as String,
      fileUrl: jsonSerialization['fileUrl'] as String,
      fileSize: jsonSerialization['fileSize'] as int,
      fileType: jsonSerialization['fileType'] as String?,
      uploadedAt: jsonSerialization['uploadedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['uploadedAt']),
      courseId: jsonSerialization['courseId'] as int,
      course: jsonSerialization['course'] == null
          ? null
          : _i3.Protocol().deserialize<_i2.Course>(jsonSerialization['course']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// Original file name
  String fileName;

  /// URL to the stored file
  String fileUrl;

  /// File size in bytes
  int fileSize;

  /// File MIME type or extension
  String? fileType;

  /// Timestamp when the file was uploaded
  DateTime uploadedAt;

  /// Foreign key to parent course
  int courseId;

  /// Parent course reference
  _i2.Course? course;

  /// Returns a shallow copy of this [KnowledgeFile]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  KnowledgeFile copyWith({
    int? id,
    String? fileName,
    String? fileUrl,
    int? fileSize,
    String? fileType,
    DateTime? uploadedAt,
    int? courseId,
    _i2.Course? course,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'KnowledgeFile',
      if (id != null) 'id': id,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'fileSize': fileSize,
      if (fileType != null) 'fileType': fileType,
      'uploadedAt': uploadedAt.toJson(),
      'courseId': courseId,
      if (course != null) 'course': course?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _KnowledgeFileImpl extends KnowledgeFile {
  _KnowledgeFileImpl({
    int? id,
    required String fileName,
    required String fileUrl,
    required int fileSize,
    String? fileType,
    DateTime? uploadedAt,
    required int courseId,
    _i2.Course? course,
  }) : super._(
         id: id,
         fileName: fileName,
         fileUrl: fileUrl,
         fileSize: fileSize,
         fileType: fileType,
         uploadedAt: uploadedAt,
         courseId: courseId,
         course: course,
       );

  /// Returns a shallow copy of this [KnowledgeFile]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  KnowledgeFile copyWith({
    Object? id = _Undefined,
    String? fileName,
    String? fileUrl,
    int? fileSize,
    Object? fileType = _Undefined,
    DateTime? uploadedAt,
    int? courseId,
    Object? course = _Undefined,
  }) {
    return KnowledgeFile(
      id: id is int? ? id : this.id,
      fileName: fileName ?? this.fileName,
      fileUrl: fileUrl ?? this.fileUrl,
      fileSize: fileSize ?? this.fileSize,
      fileType: fileType is String? ? fileType : this.fileType,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      courseId: courseId ?? this.courseId,
      course: course is _i2.Course? ? course : this.course?.copyWith(),
    );
  }
}
