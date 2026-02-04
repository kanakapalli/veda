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
import 'package:serverpod/serverpod.dart' as _i1;
import '../profiles/user_profile.dart' as _i2;
import 'package:veda_server/src/generated/protocol.dart' as _i3;

/// Response object combining VedaUserProfile with email from auth system
abstract class VedaUserProfileWithEmail
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  VedaUserProfileWithEmail._({
    this.profile,
    this.email,
  });

  factory VedaUserProfileWithEmail({
    _i2.VedaUserProfile? profile,
    String? email,
  }) = _VedaUserProfileWithEmailImpl;

  factory VedaUserProfileWithEmail.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return VedaUserProfileWithEmail(
      profile: jsonSerialization['profile'] == null
          ? null
          : _i3.Protocol().deserialize<_i2.VedaUserProfile>(
              jsonSerialization['profile'],
            ),
      email: jsonSerialization['email'] as String?,
    );
  }

  /// The user profile data
  _i2.VedaUserProfile? profile;

  /// Email from Serverpod auth system
  String? email;

  /// Returns a shallow copy of this [VedaUserProfileWithEmail]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  VedaUserProfileWithEmail copyWith({
    _i2.VedaUserProfile? profile,
    String? email,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'VedaUserProfileWithEmail',
      if (profile != null) 'profile': profile?.toJson(),
      if (email != null) 'email': email,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'VedaUserProfileWithEmail',
      if (profile != null) 'profile': profile?.toJsonForProtocol(),
      if (email != null) 'email': email,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _VedaUserProfileWithEmailImpl extends VedaUserProfileWithEmail {
  _VedaUserProfileWithEmailImpl({
    _i2.VedaUserProfile? profile,
    String? email,
  }) : super._(
         profile: profile,
         email: email,
       );

  /// Returns a shallow copy of this [VedaUserProfileWithEmail]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  VedaUserProfileWithEmail copyWith({
    Object? profile = _Undefined,
    Object? email = _Undefined,
  }) {
    return VedaUserProfileWithEmail(
      profile: profile is _i2.VedaUserProfile?
          ? profile
          : this.profile?.copyWith(),
      email: email is String? ? email : this.email,
    );
  }
}
