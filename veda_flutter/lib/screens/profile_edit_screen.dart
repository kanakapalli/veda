import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../design_system/veda_colors.dart';
import '../main.dart';
import 'package:veda_client/veda_client.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _bioController = TextEditingController();
  final int _bioMaxLength = 200;
  bool _isSaving = false;
  bool _isLoading = true;

  List<String> _interests = [];
  String? _learningGoal;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      // Get user profile with email from Serverpod auth system
      final profileWithEmail =
          await client.vedaUserProfile.getMyProfileWithEmail();

      if (mounted) {
        setState(() {
          _nameController.text = profileWithEmail?.profile?.fullName ?? '';
          _emailController.text = profileWithEmail?.email ?? '';
          _bioController.text = profileWithEmail?.profile?.bio ?? '';
          _interests = profileWithEmail?.profile?.interests ?? [];
          _learningGoal = profileWithEmail?.profile?.learningGoal;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'FAILED TO LOAD PROFILE: ${e.toString()}',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
            backgroundColor: const Color(0xFFEF5350),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VedaColors.black,
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    color: VedaColors.white,
                    strokeWidth: 2,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'LOADING PROFILE...',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: VedaColors.zinc500,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Header
                _buildHeader(),
                // Body
                Expanded(
                  child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  _buildIdentityVisualSection(),
                  const SizedBox(height: 48),
                  _buildTextField(
                    label: 'FULL_NAME',
                    controller: _nameController,
                  ),
                  const SizedBox(height: 32),
                  _buildTextField(
                    label: 'EMAIL_ADDRESS',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    readOnly: true,
                  ),
                  const SizedBox(height: 32),
                  _buildBioField(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
                // Bottom fixed button
                _buildSaveButton(),
              ],
            ),
    );
  }

  // ---------------------------------------------------------------------------
  // HEADER
  // ---------------------------------------------------------------------------
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: VedaColors.white, width: 4),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.arrow_back,
                      color: VedaColors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'RETURN_DASH',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: VedaColors.white,
                        letterSpacing: 3.0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Title
              Text(
                'SYSTEM // USER_CONFIG',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: VedaColors.zinc500,
                  letterSpacing: 3.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'EDIT_PROFILE',
                style: GoogleFonts.inter(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: VedaColors.white,
                  letterSpacing: -1.5,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // IDENTITY VISUAL
  // ---------------------------------------------------------------------------
  Widget _buildIdentityVisualSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(color: VedaColors.zinc800, width: 2),
              ),
            ),
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              'IDENTITY_VISUAL',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: VedaColors.zinc500,
                letterSpacing: 3.0,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            // Current avatar
            Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                border: Border.all(color: VedaColors.white, width: 2),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: VedaColors.zinc900,
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 60,
                        color: VedaColors.zinc500,
                      ),
                    ),
                  ),
                  // Online indicator
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Upload button
            Expanded(
              child: GestureDetector(
                onTap: _handleAvatarUpload,
                child: Container(
                  height: 128,
                  decoration: BoxDecoration(
                    border: Border.all(color: VedaColors.white, width: 2),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.cloud_upload_outlined,
                        color: VedaColors.white,
                        size: 40,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'UPDATE_AVATAR',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: VedaColors.white,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TEXT FIELD
  // ---------------------------------------------------------------------------
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: VedaColors.zinc500,
            letterSpacing: 3.0,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: VedaColors.white, width: 2),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            readOnly: readOnly,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: readOnly ? VedaColors.zinc500 : VedaColors.white,
              letterSpacing: 0.5,
            ),
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.all(16),
              border: InputBorder.none,
              hintText: 'ENTER VALUE',
              hintStyle: TextStyle(color: VedaColors.zinc700),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // BIO FIELD
  // ---------------------------------------------------------------------------
  Widget _buildBioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BIO_DATA // CONTEXT',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: VedaColors.zinc500,
            letterSpacing: 3.0,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: VedaColors.white, width: 2),
          ),
          child: Stack(
            children: [
              TextField(
                controller: _bioController,
                maxLines: 5,
                maxLength: _bioMaxLength,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: VedaColors.white,
                  letterSpacing: 0.5,
                  height: 1.6,
                ),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(16),
                  border: InputBorder.none,
                  counterText: '',
                  hintText: 'ENTER BIO',
                  hintStyle: TextStyle(color: VedaColors.zinc700),
                ),
                onChanged: (_) => setState(() {}),
              ),
              Positioned(
                bottom: 16,
                right: 16,
                child: Text(
                  '${_bioController.text.length}/$_bioMaxLength',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    color: VedaColors.zinc500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // SAVE BUTTON
  // ---------------------------------------------------------------------------
  Widget _buildSaveButton() {
    return Container(
      decoration: const BoxDecoration(
        color: VedaColors.black,
        border: Border(
          top: BorderSide(color: VedaColors.white, width: 2),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: GestureDetector(
            onTap: _isSaving ? null : _handleSave,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: VedaColors.white,
                border: Border.all(color: VedaColors.white, width: 2),
              ),
              child: _isSaving
                  ? const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: VedaColors.black,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.save,
                          size: 20,
                          color: VedaColors.black,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'SAVE_CHANGES',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: VedaColors.black,
                            letterSpacing: 3.0,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HANDLERS
  // ---------------------------------------------------------------------------
  void _handleAvatarUpload() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'AVATAR UPLOAD COMING SOON',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
        backgroundColor: VedaColors.zinc900,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleSave() async {
    // Validate inputs
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'NAME IS REQUIRED',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          backgroundColor: const Color(0xFFEF5350),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Save profile to server
      // Note: Email is read-only and managed by Serverpod auth system
      // We update as learner type - the endpoint will preserve existing creator role if present
      await client.vedaUserProfile.upsertProfile(
        userType: UserType.learner,
        fullName: _nameController.text.trim(),
        bio: _bioController.text.trim().isEmpty
            ? null
            : _bioController.text.trim(),
        interests: _interests,
        learningGoal: _learningGoal,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'PROFILE UPDATED SUCCESSFULLY',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
            backgroundColor: VedaColors.zinc900,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'FAILED TO SAVE: ${e.toString()}',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
            backgroundColor: const Color(0xFFEF5350),
          ),
        );
      }
    }
  }
}
