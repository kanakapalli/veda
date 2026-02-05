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
import '../lms/module_item.dart' as _i3;
import 'package:veda_client/src/protocol/protocol.dart' as _i4;

/// Module - hierarchical organization unit within a course
abstract class Module implements _i1.SerializableModel {
  Module._({
    this.id,
    required this.title,
    this.description,
    required this.sortOrder,
    this.imageUrl,
    this.bannerImageUrl,
    this.videoUrl,
    required this.courseId,
    this.course,
    this.items,
  });

  factory Module({
    int? id,
    required String title,
    String? description,
    required int sortOrder,
    String? imageUrl,
    String? bannerImageUrl,
    String? videoUrl,
    required int courseId,
    _i2.Course? course,
    List<_i3.ModuleItem>? items,
  }) = _ModuleImpl;

  factory Module.fromJson(Map<String, dynamic> jsonSerialization) {
    return Module(
      id: jsonSerialization['id'] as int?,
      title: jsonSerialization['title'] as String,
      description: jsonSerialization['description'] as String?,
      sortOrder: jsonSerialization['sortOrder'] as int,
      imageUrl: jsonSerialization['imageUrl'] as String?,
      bannerImageUrl: jsonSerialization['bannerImageUrl'] as String?,
      videoUrl: jsonSerialization['videoUrl'] as String?,
      courseId: jsonSerialization['courseId'] as int,
      course: jsonSerialization['course'] == null
          ? null
          : _i4.Protocol().deserialize<_i2.Course>(jsonSerialization['course']),
      items: jsonSerialization['items'] == null
          ? null
          : _i4.Protocol().deserialize<List<_i3.ModuleItem>>(
              jsonSerialization['items'],
            ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// Module title
  String title;

  /// Module description
  String? description;

  /// Sort order within the course
  int sortOrder;

  /// URL for module image
  String? imageUrl;

  /// URL for module banner image
  String? bannerImageUrl;

  /// URL for module intro video
  String? videoUrl;

  /// Foreign key to parent course
  int courseId;

  /// Parent course reference
  _i2.Course? course;

  /// List of module items (topics) in this module
  List<_i3.ModuleItem>? items;

  /// Returns a shallow copy of this [Module]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Module copyWith({
    int? id,
    String? title,
    String? description,
    int? sortOrder,
    String? imageUrl,
    String? bannerImageUrl,
    String? videoUrl,
    int? courseId,
    _i2.Course? course,
    List<_i3.ModuleItem>? items,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Module',
      if (id != null) 'id': id,
      'title': title,
      if (description != null) 'description': description,
      'sortOrder': sortOrder,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (bannerImageUrl != null) 'bannerImageUrl': bannerImageUrl,
      if (videoUrl != null) 'videoUrl': videoUrl,
      'courseId': courseId,
      if (course != null) 'course': course?.toJson(),
      if (items != null) 'items': items?.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ModuleImpl extends Module {
  _ModuleImpl({
    int? id,
    required String title,
    String? description,
    required int sortOrder,
    String? imageUrl,
    String? bannerImageUrl,
    String? videoUrl,
    required int courseId,
    _i2.Course? course,
    List<_i3.ModuleItem>? items,
  }) : super._(
         id: id,
         title: title,
         description: description,
         sortOrder: sortOrder,
         imageUrl: imageUrl,
         bannerImageUrl: bannerImageUrl,
         videoUrl: videoUrl,
         courseId: courseId,
         course: course,
         items: items,
       );

  /// Returns a shallow copy of this [Module]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Module copyWith({
    Object? id = _Undefined,
    String? title,
    Object? description = _Undefined,
    int? sortOrder,
    Object? imageUrl = _Undefined,
    Object? bannerImageUrl = _Undefined,
    Object? videoUrl = _Undefined,
    int? courseId,
    Object? course = _Undefined,
    Object? items = _Undefined,
  }) {
    return Module(
      id: id is int? ? id : this.id,
      title: title ?? this.title,
      description: description is String? ? description : this.description,
      sortOrder: sortOrder ?? this.sortOrder,
      imageUrl: imageUrl is String? ? imageUrl : this.imageUrl,
      bannerImageUrl: bannerImageUrl is String?
          ? bannerImageUrl
          : this.bannerImageUrl,
      videoUrl: videoUrl is String? ? videoUrl : this.videoUrl,
      courseId: courseId ?? this.courseId,
      course: course is _i2.Course? ? course : this.course?.copyWith(),
      items: items is List<_i3.ModuleItem>?
          ? items
          : this.items?.map((e0) => e0.copyWith()).toList(),
    );
  }
}
