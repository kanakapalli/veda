import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:veda_client/veda_client.dart';

import '../design_system/veda_colors.dart';
import '../main.dart';
import 'profile_edit_screen.dart';

class ProfileScreen extends StatefulWidget {
  final Future<void> Function() onSignOut;

  const ProfileScreen({super.key, required this.onSignOut});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;
  bool _signingOut = false;

  VedaUserProfile? _profile;
  String? _email;
  int _enrolledCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final results = await Future.wait([
        client.vedaUserProfile.getMyProfileWithEmail(),
        client.lms.getMyEnrollments(),
      ]);

      final profileWithEmail = results[0] as VedaUserProfileWithEmail?;
      final enrollments = results[1] as List<Enrollment>;

      if (mounted) {
        setState(() {
          _profile = profileWithEmail?.profile;
          _email = profileWithEmail?.email;
          _enrolledCount = enrollments.length;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Header
        // SliverAppBar(
        //   pinned: true,
        //   toolbarHeight: 72,
        //   backgroundColor: VedaColors.black,
        //   surfaceTintColor: Colors.transparent,
        //   automaticallyImplyLeading: false,
        //   flexibleSpace: Container(
        //     decoration: const BoxDecoration(
        //       border: Border(
        //         bottom: BorderSide(color: VedaColors.white, width: 2),
        //       ),
        //     ),
        //     child: SafeArea(
        //       child: Padding(
        //         padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
        //         child: Row(
        //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //           crossAxisAlignment: CrossAxisAlignment.end,
        //           children: [
        //             const SizedBox.shrink(),
        //             GestureDetector(
        //               onTap: () {
        //                 Navigator.of(context).push(
        //                   MaterialPageRoute(
        //                     builder: (context) => const ProfileEditScreen(),
        //                   ),
        //                 ).then((_) => _loadProfile());
        //               },
        //               child: Container(
        //                 width: 40,
        //                 height: 40,
        //                 decoration: BoxDecoration(
        //                   border:
        //                       Border.all(color: VedaColors.white, width: 2),
        //                 ),
        //                 child: const Icon(
        //                   Icons.settings_outlined,
        //                   color: VedaColors.white,
        //                   size: 20,
        //                 ),
        //               ),
        //             ),
        //           ],
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
        // Body
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 100),
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const ProfileEditScreen(),
                            ),
                          ).then((_) => _loadProfile());
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: VedaColors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.settings_outlined,
                            color: VedaColors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                
                // Avatar section
                _buildAvatarSection(),
                const SizedBox(height: 40),
                // Subscription status
                _buildSubscriptionSection(),
                const SizedBox(height: 40),
                // System settings
                _buildSettingsSection(),
                const SizedBox(height: 40),
                // Knowledge archive
                _buildArchiveSection(),
                const SizedBox(height: 40),
                // Become a creator
                _buildCreatorCTA(),
                const SizedBox(height: 40),
                // Logout
                _buildLogoutSection(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // AVATAR
  // ---------------------------------------------------------------------------
  Widget _buildAvatarSection() {
    final displayName = _profile?.fullName?.toUpperCase() ?? 'USER';
    final initials = _profile?.fullName != null
        ? _profile!.fullName!.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase()
        : '?';
    final hasImage = _profile?.profileImageUrl != null;

    return Center(
      child: Column(
        children: [
          // Avatar with verified badge
          Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: VedaColors.white, width: 3),
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: VedaColors.zinc800,
                  ),
                  child: hasImage
                      ? ClipOval(
                          child: Image.network(
                            _profile!.profileImageUrl!,
                            fit: BoxFit.cover,
                            width: 112,
                            height: 112,
                            errorBuilder: (_, __, ___) => Center(
                              child: Text(
                                initials,
                                style: GoogleFonts.inter(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  color: VedaColors.white,
                                ),
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            initials,
                            style: GoogleFonts.inter(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: VedaColors.white,
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Name
          _isLoading
              ? Container(
                  width: 160,
                  height: 28,
                  color: VedaColors.zinc800,
                )
              : Text(
                  displayName,
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: VedaColors.white,
                    letterSpacing: -0.5,
                  ),
                ),
          if (_email != null) ...[
            const SizedBox(height: 6),
            Text(
              _email!,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: VedaColors.zinc500,
                letterSpacing: 0.5,
              ),
            ),
          ],
          const SizedBox(height: 8),
          // Bio
          if (_profile?.bio != null && _profile!.bio!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                _profile!.bio!,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: VedaColors.white.withValues(alpha: 0.7),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          // Interests
          if (_profile?.interests != null && _profile!.interests!.isNotEmpty)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: _profile!.interests!.map((interest) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: VedaColors.white, width: 1),
                  ),
                  child: Text(
                    interest.toUpperCase(),
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: VedaColors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SUBSCRIPTION
  // ---------------------------------------------------------------------------
  Widget _buildSubscriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('SUBSCRIPTION_STATUS'),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: VedaColors.white, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        color: VedaColors.white,
                        child: Text(
                          'ACTIVE PLAN',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: VedaColors.black,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'PRO LEARNER',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: VedaColors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.card_membership,
                    color: VedaColors.zinc500,
                    size: 24,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                height: 1,
                color: VedaColors.zinc800,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'RENEWS ON',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      color: VedaColors.zinc500,
                      letterSpacing: 1.0,
                    ),
                  ),
                  Text(
                    'OCT 24, 2024',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: VedaColors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // SYSTEM SETTINGS
  // ---------------------------------------------------------------------------
  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('SYSTEM_SETTINGS'),
        const SizedBox(height: 16),
        Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: VedaColors.white, width: 2),
            ),
          ),
          child: Column(
            children: [
              _buildSettingRow(
                icon: Icons.notifications_outlined,
                title: 'NOTIFICATIONS',
                subtitle: 'UPDATES & MENTIONS',
                value: _notificationsEnabled,
                onChanged: (v) =>
                    setState(() => _notificationsEnabled = v),
                borderColor: VedaColors.zinc800,
              ),
              _buildSettingRow(
                icon: Icons.fingerprint,
                title: 'BIOMETRIC ACCESS',
                subtitle: 'FACEID / TOUCHID',
                value: _biometricEnabled,
                onChanged: (v) =>
                    setState(() => _biometricEnabled = v),
                borderColor: VedaColors.white,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: borderColor, width: 2),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: VedaColors.zinc500, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: VedaColors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9,
                    color: VedaColors.zinc500,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
          _StarkToggle(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // KNOWLEDGE ARCHIVE
  // ---------------------------------------------------------------------------
  Widget _buildArchiveSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('KNOWLEDGE_ARCHIVE'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: VedaColors.white, width: 2),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: VedaColors.zinc900,
                  border: Border.all(color: VedaColors.white, width: 1),
                ),
                child: const Icon(
                  Icons.storage,
                  color: VedaColors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PERSONAL VAULT',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: VedaColors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$_enrolledCount ENROLLED COURSES',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9,
                        color: VedaColors.zinc500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward,
                color: VedaColors.white,
                size: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // BECOME A CREATOR
  // ---------------------------------------------------------------------------
  Widget _buildCreatorCTA() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: VedaColors.white,
        border: Border.all(color: VedaColors.white, width: 2),
      ),
      child: Stack(
        children: [
          // Background icon
          Positioned(
            top: -8,
            right: -8,
            child: Icon(
              Icons.architecture,
              size: 64,
              color: VedaColors.black.withValues(alpha: 0.1),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BECOME\nA CREATOR',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: VedaColors.black,
                  letterSpacing: -1.0,
                  height: 0.9,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.only(left: 12),
                decoration: const BoxDecoration(
                  border: Border(
                    left: BorderSide(color: VedaColors.black, width: 2),
                  ),
                ),
                child: Text(
                  'BUILD RAG-BASED COURSES. TRAIN\nCUSTOM AGENTS. MONETIZE\nKNOWLEDGE.',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: VedaColors.black,
                    letterSpacing: 0.5,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                color: VedaColors.black,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'ACCESS STUDIO',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: VedaColors.white,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_outward,
                      size: 14,
                      color: VedaColors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // LOGOUT
  // ---------------------------------------------------------------------------
  Widget _buildLogoutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('SESSION'),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _signingOut ? null : _handleSignOut,
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFFEF5350),
                width: 2,
              ),
            ),
            child: _signingOut
                ? const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFFEF5350),
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.logout,
                        size: 18,
                        color: Color(0xFFEF5350),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'SIGN OUT',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFFEF5350),
                          letterSpacing: 3.0,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'ENCRYPTED SESSION \u2022 DEVICE ONLY',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 8,
              color: VedaColors.zinc800,
              letterSpacing: 2.0,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleSignOut() async {
    setState(() => _signingOut = true);
    try {
      await widget.onSignOut();
    } finally {
      if (mounted) {
        setState(() => _signingOut = false);
      }
    }
  }

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------
  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.jetBrainsMono(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        color: VedaColors.zinc500,
        letterSpacing: 3.0,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// STARK TOGGLE
// ---------------------------------------------------------------------------
class _StarkToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _StarkToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 40,
        height: 24,
        decoration: BoxDecoration(
          color: value ? VedaColors.white : Colors.transparent,
          border: Border.all(
            color: value ? VedaColors.white : VedaColors.zinc500,
            width: 2,
          ),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 150),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 16,
            height: 16,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            color: value ? VedaColors.black : VedaColors.zinc500,
          ),
        ),
      ),
    );
  }
}
