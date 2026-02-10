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
import '../lms/module.dart' as _i3;
import '../lms/course.dart' as _i4;
import 'package:veda_client/src/protocol/protocol.dart' as _i5;

/// ModuleProgress - tracks user progress through course modules
abstract class ModuleProgress implements _i1.SerializableModel {
  ModuleProgress._({
    this.id,
    required this.userId,
    this.user,
    required this.moduleId,
    this.module,
    required this.courseId,
    this.course,
    bool? completed,
    this.completedAt,
    DateTime? startedAt,
  }) : completed = completed ?? false,
       startedAt = startedAt ?? DateTime.now();

  factory ModuleProgress({
    int? id,
    required _i1.UuidValue userId,
    _i2.AuthUser? user,
    required int moduleId,
    _i3.Module? module,
    required int courseId,
    _i4.Course? course,
    bool? completed,
    DateTime? completedAt,
    DateTime? startedAt,
  }) = _ModuleProgressImpl;

  factory ModuleProgress.fromJson(Map<String, dynamic> jsonSerialization) {
    return ModuleProgress(
      id: jsonSerialization['id'] as int?,
      userId: _i1.UuidValueJsonExtension.fromJson(jsonSerialization['userId']),
      user: jsonSerialization['user'] == null
          ? null
          : _i5.Protocol().deserialize<_i2.AuthUser>(jsonSerialization['user']),
      moduleId: jsonSerialization['moduleId'] as int,
      module: jsonSerialization['module'] == null
          ? null
          : _i5.Protocol().deserialize<_i3.Module>(jsonSerialization['module']),
      courseId: jsonSerialization['courseId'] as int,
      course: jsonSerialization['course'] == null
          ? null
          : _i5.Protocol().deserialize<_i4.Course>(jsonSerialization['course']),
      completed: jsonSerialization['completed'] as bool?,
      completedAt: jsonSerialization['completedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['completedAt'],
            ),
      startedAt: jsonSerialization['startedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['startedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  _i1.UuidValue userId;

  /// Link to the authenticated user
  _i2.AuthUser? user;

  /// Foreign key to the module
  int moduleId;

  /// Parent module reference
  _i3.Module? module;

  /// Foreign key to the course (denormalized for quick lookups)
  int courseId;

  /// Parent course reference
  _i4.Course? course;

  /// Whether the module has been completed
  bool completed;

  /// Timestamp when the module was completed
  DateTime? completedAt;

  /// Timestamp when the user started this module
  DateTime startedAt;

  /// Returns a shallow copy of this [ModuleProgress]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ModuleProgress copyWith({
    int? id,
    _i1.UuidValue? userId,
    _i2.AuthUser? user,
    int? moduleId,
    _i3.Module? module,
    int? courseId,
    _i4.Course? course,
    bool? completed,
    DateTime? completedAt,
    DateTime? startedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ModuleProgress',
      if (id != null) 'id': id,
      'userId': userId.toJson(),
      if (user != null) 'user': user?.toJson(),
      'moduleId': moduleId,
      if (module != null) 'module': module?.toJson(),
      'courseId': courseId,
      if (course != null) 'course': course?.toJson(),
      'completed': completed,
      if (completedAt != null) 'completedAt': completedAt?.toJson(),
      'startedAt': startedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ModuleProgressImpl extends ModuleProgress {
  _ModuleProgressImpl({
    int? id,
    required _i1.UuidValue userId,
    _i2.AuthUser? user,
    required int moduleId,
    _i3.Module? module,
    required int courseId,
    _i4.Course? course,
    bool? completed,
    DateTime? completedAt,
    DateTime? startedAt,
  }) : super._(
         id: id,
         userId: userId,
         user: user,
         moduleId: moduleId,
         module: module,
         courseId: courseId,
         course: course,
         completed: completed,
         completedAt: completedAt,
         startedAt: startedAt,
       );

  /// Returns a shallow copy of this [ModuleProgress]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ModuleProgress copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? userId,
    Object? user = _Undefined,
    int? moduleId,
    Object? module = _Undefined,
    int? courseId,
    Object? course = _Undefined,
    bool? completed,
    Object? completedAt = _Undefined,
    DateTime? startedAt,
  }) {
    return ModuleProgress(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      user: user is _i2.AuthUser? ? user : this.user?.copyWith(),
      moduleId: moduleId ?? this.moduleId,
      module: module is _i3.Module? ? module : this.module?.copyWith(),
      courseId: courseId ?? this.courseId,
      course: course is _i4.Course? ? course : this.course?.copyWith(),
      completed: completed ?? this.completed,
      completedAt: completedAt is DateTime? ? completedAt : this.completedAt,
      startedAt: startedAt ?? this.startedAt,
    );
  }
}
