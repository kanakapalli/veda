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
import '../lms/course.dart' as _i3;
import 'package:veda_client/src/protocol/protocol.dart' as _i4;

/// Enrollment - tracks which users have enrolled in which courses
abstract class Enrollment implements _i1.SerializableModel {
  Enrollment._({
    this.id,
    required this.userId,
    this.user,
    required this.courseId,
    this.course,
    DateTime? enrolledAt,
  }) : enrolledAt = enrolledAt ?? DateTime.now();

  factory Enrollment({
    int? id,
    required _i1.UuidValue userId,
    _i2.AuthUser? user,
    required int courseId,
    _i3.Course? course,
    DateTime? enrolledAt,
  }) = _EnrollmentImpl;

  factory Enrollment.fromJson(Map<String, dynamic> jsonSerialization) {
    return Enrollment(
      id: jsonSerialization['id'] as int?,
      userId: _i1.UuidValueJsonExtension.fromJson(jsonSerialization['userId']),
      user: jsonSerialization['user'] == null
          ? null
          : _i4.Protocol().deserialize<_i2.AuthUser>(jsonSerialization['user']),
      courseId: jsonSerialization['courseId'] as int,
      course: jsonSerialization['course'] == null
          ? null
          : _i4.Protocol().deserialize<_i3.Course>(jsonSerialization['course']),
      enrolledAt: jsonSerialization['enrolledAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['enrolledAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  _i1.UuidValue userId;

  /// Link to the authenticated user who enrolled
  _i2.AuthUser? user;

  /// Foreign key to the enrolled course
  int courseId;

  /// Parent course reference
  _i3.Course? course;

  /// Timestamp when the user enrolled
  DateTime enrolledAt;

  /// Returns a shallow copy of this [Enrollment]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Enrollment copyWith({
    int? id,
    _i1.UuidValue? userId,
    _i2.AuthUser? user,
    int? courseId,
    _i3.Course? course,
    DateTime? enrolledAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Enrollment',
      if (id != null) 'id': id,
      'userId': userId.toJson(),
      if (user != null) 'user': user?.toJson(),
      'courseId': courseId,
      if (course != null) 'course': course?.toJson(),
      'enrolledAt': enrolledAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _EnrollmentImpl extends Enrollment {
  _EnrollmentImpl({
    int? id,
    required _i1.UuidValue userId,
    _i2.AuthUser? user,
    required int courseId,
    _i3.Course? course,
    DateTime? enrolledAt,
  }) : super._(
         id: id,
         userId: userId,
         user: user,
         courseId: courseId,
         course: course,
         enrolledAt: enrolledAt,
       );

  /// Returns a shallow copy of this [Enrollment]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Enrollment copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? userId,
    Object? user = _Undefined,
    int? courseId,
    Object? course = _Undefined,
    DateTime? enrolledAt,
  }) {
    return Enrollment(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      user: user is _i2.AuthUser? ? user : this.user?.copyWith(),
      courseId: courseId ?? this.courseId,
      course: course is _i3.Course? ? course : this.course?.copyWith(),
      enrolledAt: enrolledAt ?? this.enrolledAt,
    );
  }
}
