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
import '../profiles/user_type.dart' as _i3;
import '../profiles/subscription_status.dart' as _i4;
import 'package:veda_client/src/protocol/protocol.dart' as _i5;

/// Veda user profile data linked to authenticated user.
/// Uses relation to AuthUser as per Serverpod recommended pattern.
abstract class VedaUserProfile implements _i1.SerializableModel {
  VedaUserProfile._({
    this.id,
    required this.authUserId,
    this.authUser,
    required this.userTypes,
    this.fullName,
    this.bio,
    this.interests,
    this.learningGoal,
    this.websiteUrl,
    this.profileImageUrl,
    this.expertise,
    this.subscriptionStatus,
    this.subscriptionPlan,
    this.subscriptionExpiryDate,
    this.subscriptionProductId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VedaUserProfile({
    int? id,
    required _i1.UuidValue authUserId,
    _i2.AuthUser? authUser,
    required List<_i3.UserType> userTypes,
    String? fullName,
    String? bio,
    List<String>? interests,
    String? learningGoal,
    String? websiteUrl,
    String? profileImageUrl,
    List<String>? expertise,
    _i4.SubscriptionStatus? subscriptionStatus,
    String? subscriptionPlan,
    DateTime? subscriptionExpiryDate,
    String? subscriptionProductId,
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
          : _i5.Protocol().deserialize<_i2.AuthUser>(
              jsonSerialization['authUser'],
            ),
      userTypes: _i5.Protocol().deserialize<List<_i3.UserType>>(
        jsonSerialization['userTypes'],
      ),
      fullName: jsonSerialization['fullName'] as String?,
      bio: jsonSerialization['bio'] as String?,
      interests: jsonSerialization['interests'] == null
          ? null
          : _i5.Protocol().deserialize<List<String>>(
              jsonSerialization['interests'],
            ),
      learningGoal: jsonSerialization['learningGoal'] as String?,
      websiteUrl: jsonSerialization['websiteUrl'] as String?,
      profileImageUrl: jsonSerialization['profileImageUrl'] as String?,
      expertise: jsonSerialization['expertise'] == null
          ? null
          : _i5.Protocol().deserialize<List<String>>(
              jsonSerialization['expertise'],
            ),
      subscriptionStatus: jsonSerialization['subscriptionStatus'] == null
          ? null
          : _i4.SubscriptionStatus.fromJson(
              (jsonSerialization['subscriptionStatus'] as String),
            ),
      subscriptionPlan: jsonSerialization['subscriptionPlan'] as String?,
      subscriptionExpiryDate:
          jsonSerialization['subscriptionExpiryDate'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['subscriptionExpiryDate'],
            ),
      subscriptionProductId:
          jsonSerialization['subscriptionProductId'] as String?,
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

  /// User types: can be both learner (mobile) and creator (web).
  /// User must register on each platform separately to get both roles.
  List<_i3.UserType> userTypes;

  /// Full name of the user.
  String? fullName;

  /// User biography or context description (max 500 characters for creators, 200 for learners).
  String? bio;

  /// List of interest tags selected during onboarding (learners only).
  List<String>? interests;

  /// Learning goal: 'career_pivot' or 'academic_depth' (learners only).
  String? learningGoal;

  /// Creator website or portfolio URL (creators only).
  String? websiteUrl;

  /// Profile image URL (avatar) (creators only for now).
  String? profileImageUrl;

  /// Areas of expertise or teaching topics (creators only).
  List<String>? expertise;

  /// Current subscription status (none, active, cancelling, expired).
  _i4.SubscriptionStatus? subscriptionStatus;

  /// Name of the current subscription plan (e.g. 'Monthly', 'Yearly', 'Six Month').
  String? subscriptionPlan;

  /// Subscription expiry or next renewal date.
  DateTime? subscriptionExpiryDate;

  /// RevenueCat product identifier for the active subscription.
  String? subscriptionProductId;

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
    List<_i3.UserType>? userTypes,
    String? fullName,
    String? bio,
    List<String>? interests,
    String? learningGoal,
    String? websiteUrl,
    String? profileImageUrl,
    List<String>? expertise,
    _i4.SubscriptionStatus? subscriptionStatus,
    String? subscriptionPlan,
    DateTime? subscriptionExpiryDate,
    String? subscriptionProductId,
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
      'userTypes': userTypes.toJson(valueToJson: (v) => v.toJson()),
      if (fullName != null) 'fullName': fullName,
      if (bio != null) 'bio': bio,
      if (interests != null) 'interests': interests?.toJson(),
      if (learningGoal != null) 'learningGoal': learningGoal,
      if (websiteUrl != null) 'websiteUrl': websiteUrl,
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      if (expertise != null) 'expertise': expertise?.toJson(),
      if (subscriptionStatus != null)
        'subscriptionStatus': subscriptionStatus?.toJson(),
      if (subscriptionPlan != null) 'subscriptionPlan': subscriptionPlan,
      if (subscriptionExpiryDate != null)
        'subscriptionExpiryDate': subscriptionExpiryDate?.toJson(),
      if (subscriptionProductId != null)
        'subscriptionProductId': subscriptionProductId,
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
    required List<_i3.UserType> userTypes,
    String? fullName,
    String? bio,
    List<String>? interests,
    String? learningGoal,
    String? websiteUrl,
    String? profileImageUrl,
    List<String>? expertise,
    _i4.SubscriptionStatus? subscriptionStatus,
    String? subscriptionPlan,
    DateTime? subscriptionExpiryDate,
    String? subscriptionProductId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         authUserId: authUserId,
         authUser: authUser,
         userTypes: userTypes,
         fullName: fullName,
         bio: bio,
         interests: interests,
         learningGoal: learningGoal,
         websiteUrl: websiteUrl,
         profileImageUrl: profileImageUrl,
         expertise: expertise,
         subscriptionStatus: subscriptionStatus,
         subscriptionPlan: subscriptionPlan,
         subscriptionExpiryDate: subscriptionExpiryDate,
         subscriptionProductId: subscriptionProductId,
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
    List<_i3.UserType>? userTypes,
    Object? fullName = _Undefined,
    Object? bio = _Undefined,
    Object? interests = _Undefined,
    Object? learningGoal = _Undefined,
    Object? websiteUrl = _Undefined,
    Object? profileImageUrl = _Undefined,
    Object? expertise = _Undefined,
    Object? subscriptionStatus = _Undefined,
    Object? subscriptionPlan = _Undefined,
    Object? subscriptionExpiryDate = _Undefined,
    Object? subscriptionProductId = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VedaUserProfile(
      id: id is int? ? id : this.id,
      authUserId: authUserId ?? this.authUserId,
      authUser: authUser is _i2.AuthUser?
          ? authUser
          : this.authUser?.copyWith(),
      userTypes: userTypes ?? this.userTypes.map((e0) => e0).toList(),
      fullName: fullName is String? ? fullName : this.fullName,
      bio: bio is String? ? bio : this.bio,
      interests: interests is List<String>?
          ? interests
          : this.interests?.map((e0) => e0).toList(),
      learningGoal: learningGoal is String? ? learningGoal : this.learningGoal,
      websiteUrl: websiteUrl is String? ? websiteUrl : this.websiteUrl,
      profileImageUrl: profileImageUrl is String?
          ? profileImageUrl
          : this.profileImageUrl,
      expertise: expertise is List<String>?
          ? expertise
          : this.expertise?.map((e0) => e0).toList(),
      subscriptionStatus: subscriptionStatus is _i4.SubscriptionStatus?
          ? subscriptionStatus
          : this.subscriptionStatus,
      subscriptionPlan: subscriptionPlan is String?
          ? subscriptionPlan
          : this.subscriptionPlan,
      subscriptionExpiryDate: subscriptionExpiryDate is DateTime?
          ? subscriptionExpiryDate
          : this.subscriptionExpiryDate,
      subscriptionProductId: subscriptionProductId is String?
          ? subscriptionProductId
          : this.subscriptionProductId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
