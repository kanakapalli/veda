import 'package:serverpod_auth_idp_server/core.dart'; // gives authUserId extension
import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Endpoint for managing Veda user profiles linked to authenticated users.
class VedaUserProfileEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Creates or updates a user profile for the authenticated user.
  Future<VedaUserProfile> upsertProfile(
    Session session, {
    required String fullName,
    String? bio,
    required List<String> interests,
    String? learningGoal,
  }) async {
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw Exception('User not authenticated');
    }

    // UuidValue from extension
    final authUserId = authInfo.authUserId;

    final now = DateTime.now();

    // authUserId is UuidValue, matches model field type
    final existing = await VedaUserProfile.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(authUserId),
    );

    if (existing != null) {
      final updated = existing.copyWith(
        fullName: fullName,
        bio: bio,
        interests: interests,
        learningGoal: learningGoal,
        updatedAt: now,
      );
      return await VedaUserProfile.db.updateRow(session, updated);
    }

    final profile = VedaUserProfile(
      authUserId: authUserId,
      fullName: fullName,
      bio: bio,
      interests: interests,
      learningGoal: learningGoal,
      createdAt: now,
      updatedAt: now,
    );

    return await VedaUserProfile.db.insertRow(session, profile);
  }

  /// Gets the profile for the authenticated user.
  Future<VedaUserProfile?> getMyProfile(Session session) async {
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw Exception('User not authenticated');
    }

    final authUserId = authInfo.authUserId;

    return await VedaUserProfile.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(authUserId),
    );
  }

  /// Checks if the authenticated user has completed onboarding.
  Future<bool> hasCompletedOnboarding(Session session) async {
    final profile = await getMyProfile(session);
    return profile != null && (profile.fullName?.isNotEmpty ?? false);
  }

  /// Gets the user profile with email from Serverpod's auth system.
  Future<VedaUserProfileWithEmail?> getMyProfileWithEmail(
      Session session) async {
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw Exception('User not authenticated');
    }

    final authUserId = authInfo.authUserId;

    // Get the profile
    final profile = await VedaUserProfile.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(authUserId),
    );

    // Get email from Serverpod's auth system using AuthServices
    String? email;
    try {
      final userProfile = await AuthServices.instance.userProfiles
          .findUserProfileByUserId(session, authUserId);
      email = userProfile.email;
    } catch (e) {
      // Email not found or error - continue without it
      session.log('Failed to fetch email from auth system: $e');
    }

    return VedaUserProfileWithEmail(
      profile: profile,
      email: email,
    );
  }
}
