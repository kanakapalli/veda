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

/// Veda user profile data linked to authenticated user.
/// Uses relation to AuthUser as per Serverpod recommended pattern.
abstract class VedaUserProfile implements _i1.SerializableModel {
  VedaUserProfile._({
    this.id,
    required this.authUserId,
    this.authUser,
    this.fullName,
    this.bio,
    this.interests,
    this.learningGoal,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VedaUserProfile({
    int? id,
    required _i1.UuidValue authUserId,
    _i2.AuthUser? authUser,
    String? fullName,
    String? bio,
    List<String>? interests,
    String? learningGoal,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _VedaUserProfileImpl;

  factory VedaUserProfile.fromJson(Map<String, dynamic> jsonSerialization) {
    return VedaUserProfile(
      id: jsonSerialization['id'] as int?,
      authUserId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
      authUser: jsonSerialization['authUser'] == null
          ? null
          : _i3.Protocol().deserialize<_i2.AuthUser>(
              jsonSerialization['authUser'],
            ),
      fullName: jsonSerialization['fullName'] as String?,
      bio: jsonSerialization['bio'] as String?,
      interests: jsonSerialization['interests'] == null
          ? null
          : _i3.Protocol().deserialize<List<String>>(
              jsonSerialization['interests'],
            ),
      learningGoal: jsonSerialization['learningGoal'] as String?,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  _i1.UuidValue authUserId;

  /// Link to the authenticated user (creates authUserId automatically)
  _i2.AuthUser? authUser;

  /// Full name of the user.
  String? fullName;

  /// User biography or context description (max 200 characters).
  String? bio;

  /// List of interest tags selected during onboarding.
  List<String>? interests;

  /// Learning goal: 'career_pivot' or 'academic_depth'.
  String? learningGoal;

  /// Timestamp when the profile was created.
  DateTime createdAt;

  /// Timestamp when the profile was last updated.
  DateTime updatedAt;

  /// Returns a shallow copy of this [VedaUserProfile]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  VedaUserProfile copyWith({
    int? id,
    _i1.UuidValue? authUserId,
    _i2.AuthUser? authUser,
    String? fullName,
    String? bio,
    List<String>? interests,
    String? learningGoal,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'VedaUserProfile',
      if (id != null) 'id': id,
      'authUserId': authUserId.toJson(),
      if (authUser != null) 'authUser': authUser?.toJson(),
      if (fullName != null) 'fullName': fullName,
      if (bio != null) 'bio': bio,
      if (interests != null) 'interests': interests?.toJson(),
      if (learningGoal != null) 'learningGoal': learningGoal,
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

class _VedaUserProfileImpl extends VedaUserProfile {
  _VedaUserProfileImpl({
    int? id,
    required _i1.UuidValue authUserId,
    _i2.AuthUser? authUser,
    String? fullName,
    String? bio,
    List<String>? interests,
    String? learningGoal,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         authUserId: authUserId,
         authUser: authUser,
         fullName: fullName,
         bio: bio,
         interests: interests,
         learningGoal: learningGoal,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [VedaUserProfile]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  VedaUserProfile copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? authUserId,
    Object? authUser = _Undefined,
    Object? fullName = _Undefined,
    Object? bio = _Undefined,
    Object? interests = _Undefined,
    Object? learningGoal = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VedaUserProfile(
      id: id is int? ? id : this.id,
      authUserId: authUserId ?? this.authUserId,
      authUser: authUser is _i2.AuthUser?
          ? authUser
          : this.authUser?.copyWith(),
      fullName: fullName is String? ? fullName : this.fullName,
      bio: bio is String? ? bio : this.bio,
      interests: interests is List<String>?
          ? interests
          : this.interests?.map((e0) => e0).toList(),
      learningGoal: learningGoal is String? ? learningGoal : this.learningGoal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
