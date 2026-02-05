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

/// CourseIndex - searchable metadata/tags for course discovery
abstract class CourseIndex implements _i1.SerializableModel {
  CourseIndex._({
    this.id,
    required this.title,
    this.description,
    this.imageUrl,
    this.tags,
    required this.sortOrder,
    required this.courseId,
    this.course,
  });

  factory CourseIndex({
    int? id,
    required String title,
    String? description,
    String? imageUrl,
    List<String>? tags,
    required int sortOrder,
    required int courseId,
    _i2.Course? course,
  }) = _CourseIndexImpl;

  factory CourseIndex.fromJson(Map<String, dynamic> jsonSerialization) {
    return CourseIndex(
      id: jsonSerialization['id'] as int?,
      title: jsonSerialization['title'] as String,
      description: jsonSerialization['description'] as String?,
      imageUrl: jsonSerialization['imageUrl'] as String?,
      tags: jsonSerialization['tags'] == null
          ? null
          : _i3.Protocol().deserialize<List<String>>(jsonSerialization['tags']),
      sortOrder: jsonSerialization['sortOrder'] as int,
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

  /// Index title/keyword
  String title;

  /// Index description
  String? description;

  /// URL for index image
  String? imageUrl;

  /// List of tags for this index
  List<String>? tags;

  /// Sort order
  int sortOrder;

  /// Foreign key to parent course
  int courseId;

  /// Parent course reference
  _i2.Course? course;

  /// Returns a shallow copy of this [CourseIndex]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CourseIndex copyWith({
    int? id,
    String? title,
    String? description,
    String? imageUrl,
    List<String>? tags,
    int? sortOrder,
    int? courseId,
    _i2.Course? course,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CourseIndex',
      if (id != null) 'id': id,
      'title': title,
      if (description != null) 'description': description,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (tags != null) 'tags': tags?.toJson(),
      'sortOrder': sortOrder,
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

class _CourseIndexImpl extends CourseIndex {
  _CourseIndexImpl({
    int? id,
    required String title,
    String? description,
    String? imageUrl,
    List<String>? tags,
    required int sortOrder,
    required int courseId,
    _i2.Course? course,
  }) : super._(
         id: id,
         title: title,
         description: description,
         imageUrl: imageUrl,
         tags: tags,
         sortOrder: sortOrder,
         courseId: courseId,
         course: course,
       );

  /// Returns a shallow copy of this [CourseIndex]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CourseIndex copyWith({
    Object? id = _Undefined,
    String? title,
    Object? description = _Undefined,
    Object? imageUrl = _Undefined,
    Object? tags = _Undefined,
    int? sortOrder,
    int? courseId,
    Object? course = _Undefined,
  }) {
    return CourseIndex(
      id: id is int? ? id : this.id,
      title: title ?? this.title,
      description: description is String? ? description : this.description,
      imageUrl: imageUrl is String? ? imageUrl : this.imageUrl,
      tags: tags is List<String>? ? tags : this.tags?.map((e0) => e0).toList(),
      sortOrder: sortOrder ?? this.sortOrder,
      courseId: courseId ?? this.courseId,
      course: course is _i2.Course? ? course : this.course?.copyWith(),
    );
  }
}
