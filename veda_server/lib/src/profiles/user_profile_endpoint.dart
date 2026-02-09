import 'package:serverpod_auth_idp_server/core.dart'; // gives authUserId extension
import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Endpoint for managing Veda user profiles linked to authenticated users.
class VedaUserProfileEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Creates or updates a user profile for the authenticated user.
  /// Adds the specified userType to the user's roles if not already present.
  /// This allows users to be both learners and creators by registering on both platforms.
  Future<VedaUserProfile> upsertProfile(
    Session session, {
    required UserType userType,
    required String fullName,
    String? bio,
    List<String>? interests,
    String? learningGoal,
    String? websiteUrl,
    String? profileImageUrl,
    List<String>? expertise,
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
      // Add new user type if not already present
      final updatedTypes = existing.userTypes.toList();
      if (!updatedTypes.contains(userType)) {
        updatedTypes.add(userType);
      }

      // Merge fields based on user type being added
      final updated = existing.copyWith(
        userTypes: updatedTypes,
        fullName: fullName,
        bio: bio ?? existing.bio,
        // Learner fields - only update if adding learner type
        interests: userType == UserType.learner
            ? (interests ?? existing.interests)
            : existing.interests,
        learningGoal: userType == UserType.learner
            ? (learningGoal ?? existing.learningGoal)
            : existing.learningGoal,
        // Creator fields - only update if adding creator type
        websiteUrl: userType == UserType.creator
            ? (websiteUrl ?? existing.websiteUrl)
            : existing.websiteUrl,
        profileImageUrl: userType == UserType.creator
            ? (profileImageUrl ?? existing.profileImageUrl)
            : existing.profileImageUrl,
        expertise: userType == UserType.creator
            ? (expertise ?? existing.expertise)
            : existing.expertise,
        updatedAt: now,
      );
      return await VedaUserProfile.db.updateRow(session, updated);
    }

    // Create new profile with the specified user type
    final profile = VedaUserProfile(
      authUserId: authUserId,
      userTypes: [userType],
      fullName: fullName,
      bio: bio,
      interests: interests ?? [],
      learningGoal: learningGoal,
      websiteUrl: websiteUrl,
      profileImageUrl: profileImageUrl,
      expertise: expertise ?? [],
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
