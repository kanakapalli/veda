import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:file_picker/file_picker.dart';
import '../../main.dart';
import 'auth_flow_screen.dart';
import 'stark_widgets.dart';

/// Email validation regex
final _emailRegex =
    RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

/// Onboarding/Registration screen
class RegisterScreen extends StatefulWidget {
  final RegistrationData registrationData;
  final VoidCallback onOtpSent;
  final VoidCallback onBack;
  final String? errorMessage;
  final Function(String?) setError;

  const RegisterScreen({
    super.key,
    required this.registrationData,
    required this.onOtpSent,
    required this.onBack,
    this.errorMessage,
    required this.setError,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _bioController = TextEditingController();
  final int _bioMaxLength = 200;

  final Set<String> _selectedInterests = {};
  final List<String> _availableInterests = [
    'Architecture',
    'AI_Logic',
    'Ethics',
    'Quant',
  ];
  String? _selectedGoal;
  bool _isLoading = false;
  bool _obscurePassword = true;

  // Profile image
  Uint8List? _profileImageBytes;
  String? _profileImageName;

  // Field-level errors
  String? _nameError;
  String? _emailError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animController.forward();

    // Pre-fill from registration data
    _nameController.text = widget.registrationData.fullName;
    _emailController.text = widget.registrationData.email;
    _bioController.text = widget.registrationData.bio;
    _selectedInterests.addAll(widget.registrationData.interests);
    _selectedGoal = widget.registrationData.learningGoal;
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _clearErrors() {
    setState(() {
      _nameError = null;
      _emailError = null;
      _passwordError = null;
    });
    widget.setError(null);
  }

  Future<void> _pickProfileImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      if (file.bytes != null) {
        setState(() {
          _profileImageBytes = file.bytes;
          _profileImageName = file.name;
        });
      }
    }
  }

  bool _validateFields() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    bool isValid = true;

    _clearErrors();

    if (name.isEmpty) {
      setState(() => _nameError = 'Name is required');
      isValid = false;
    } else if (name.length < 2) {
      setState(() => _nameError = 'Name must be at least 2 characters');
      isValid = false;
    }

    if (email.isEmpty) {
      setState(() => _emailError = 'Email is required');
      isValid = false;
    } else if (!_emailRegex.hasMatch(email)) {
      setState(() => _emailError = 'Invalid email format');
      isValid = false;
    }

    if (password.isEmpty) {
      setState(() => _passwordError = 'Password is required');
      isValid = false;
    } else if (password.length < 8) {
      setState(
          () => _passwordError = 'Password must be at least 8 characters');
      isValid = false;
    }

    return isValid;
  }

  Future<void> _handleSubmit() async {
    if (!_validateFields()) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() => _isLoading = true);

    try {
      // Start registration (sends OTP)
      // The server will handle duplicate email detection
      final requestId =
          await client.emailIdp.startRegistration(email: email);

      // Store data for after OTP verification (including image bytes)
      widget.registrationData.fullName = name;
      widget.registrationData.email = email;
      widget.registrationData.password = password;
      widget.registrationData.bio = _bioController.text.trim();
      widget.registrationData.interests = _selectedInterests.toList();
      widget.registrationData.learningGoal = _selectedGoal;
      widget.registrationData.accountRequestId = requestId;
      widget.registrationData.profileImageBytes = _profileImageBytes;
      widget.registrationData.profileImageName = _profileImageName;

      widget.onOtpSent();
    } catch (e) {
      // Check if it's a duplicate email error
      final errorMessage = e.toString();
      if (errorMessage.contains('already') || errorMessage.contains('exist')) {
        setState(() => _emailError = 'An account with this email already exists. Please sign in instead.');
      } else {
        widget.setError('Registration failed. Please check your connection and try again.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildFadeSlide(
      {required Interval interval, required Widget child}) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animController, curve: interval),
      ),
      child: SlideTransition(
        position:
            Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
                .animate(CurvedAnimation(
                    parent: _animController, curve: interval)),
        child: child,
      ),
    );
  }

  Widget _buildProfileImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: _pickProfileImage,
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: StarkColors.white, width: 2),
              color: StarkColors.black,
            ),
            child: _profileImageBytes != null
                ? ClipOval(
                    child: Image.memory(
                      _profileImageBytes!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(
                    Icons.add_a_photo_outlined,
                    color: StarkColors.zinc500,
                    size: 32,
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _profileImageBytes != null ? 'TAP TO CHANGE' : 'ADD PROFILE IMAGE',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 8,
            color: StarkColors.zinc500,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) widget.onBack();
      },
      child: Scaffold(
        backgroundColor: StarkColors.black,
        body: SafeArea(
          child: Stack(
          children: [
            // Back button
            Positioned(
              top: 32,
              right: 32,
              child: IconButton(
                onPressed: widget.onBack,
                icon: const Icon(Icons.close,
                    color: StarkColors.white, size: 20),
              ),
            ),

            // Main content
            Positioned.fill(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(32, 60, 32, 120),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      _buildFadeSlide(
                        interval: const Interval(0.05, 0.35,
                            curve: Curves.easeOut),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'VEDA_',
                              style: GoogleFonts.inter(
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                                color: StarkColors.white,
                                letterSpacing: -2.0,
                                height: 0.9,
                              ),
                            ),
                            Text(
                              'ONBOARD',
                              style: GoogleFonts.inter(
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                                color: StarkColors.white,
                                letterSpacing: -2.0,
                                height: 0.9,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                                width: 48,
                                height: 2,
                                color: StarkColors.white),
                          ],
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Form fields
                      _buildFadeSlide(
                        interval: const Interval(0.1, 0.4,
                            curve: Curves.easeOut),
                        child: Column(
                          children: [
                            // Profile image picker
                            _buildProfileImagePicker(),
                            const SizedBox(height: 20),
                            StarkTextField(
                              controller: _nameController,
                              label: 'Identity // Full Name',
                              placeholder: 'ENTER NAME',
                              errorText: _nameError,
                            ),
                            const SizedBox(height: 20),
                            StarkTextField(
                              controller: _emailController,
                              label: 'Identity // Email',
                              placeholder: 'ENTER EMAIL',
                              keyboardType: TextInputType.emailAddress,
                              errorText: _emailError,
                            ),
                            const SizedBox(height: 20),
                            StarkTextField(
                              controller: _passwordController,
                              label: 'Security // Password',
                              placeholder: 'CREATE PASSWORD',
                              obscureText: _obscurePassword,
                              errorText:
                                  _passwordError ?? widget.errorMessage,
                              suffixIcon: GestureDetector(
                                onTap: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(right: 12),
                                  child: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: StarkColors.zinc500,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Bio field
                            _StarkBioField(
                              controller: _bioController,
                              maxLength: _bioMaxLength,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Interest tags
                      _buildFadeSlide(
                        interval: const Interval(0.15, 0.45,
                            curve: Curves.easeOut),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.only(bottom: 4),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                      color: StarkColors.zinc800),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'INTEL_PROFILE',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: StarkColors.white,
                                      letterSpacing: 2.0,
                                    ),
                                  ),
                                  Text(
                                    'MULTI-SELECT',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 8,
                                      color: StarkColors.zinc500,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children:
                                  _availableInterests.map((interest) {
                                return StarkInterestTag(
                                  label: interest,
                                  isSelected: _selectedInterests
                                      .contains(interest),
                                  onTap: () {
                                    setState(() {
                                      if (_selectedInterests
                                          .contains(interest)) {
                                        _selectedInterests
                                            .remove(interest);
                                      } else {
                                        _selectedInterests.add(interest);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Learning goal
                      _buildFadeSlide(
                        interval: const Interval(0.2, 0.5,
                            curve: Curves.easeOut),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.only(bottom: 4),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                      color: StarkColors.zinc800),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'LEARNING GOAL?',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: StarkColors.white,
                                      letterSpacing: 2.0,
                                    ),
                                  ),
                                  Text(
                                    'REQUIRED',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 8,
                                      color: StarkColors.zinc500,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: StarkGoalCard(
                                    label: 'CAREER\nPIVOT',
                                    isSelected:
                                        _selectedGoal == 'career_pivot',
                                    onTap: () => setState(() =>
                                        _selectedGoal = 'career_pivot'),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: StarkGoalCard(
                                    label: 'ACADEMIC\nDEPTH',
                                    isSelected:
                                        _selectedGoal == 'academic_depth',
                                    onTap: () => setState(() =>
                                        _selectedGoal = 'academic_depth'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Submit button
                      _buildFadeSlide(
                        interval: const Interval(0.25, 0.55,
                            curve: Curves.easeOut),
                        child: StarkPrimaryButton(
                          label: 'Veda Learning',
                          onPressed: _handleSubmit,
                          isLoading: _isLoading,
                          showArrow: false,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

/// Bio/textarea field for registration
class _StarkBioField extends StatefulWidget {
  final TextEditingController controller;
  final int maxLength;

  const _StarkBioField({
    required this.controller,
    required this.maxLength,
  });

  @override
  State<_StarkBioField> createState() => _StarkBioFieldState();
}

class _StarkBioFieldState extends State<_StarkBioField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 4),
          child: Text(
            'BIO_DATA // CONTEXT',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: StarkColors.zinc500,
              letterSpacing: 2.0,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: StarkColors.white, width: 2),
          ),
          child: Stack(
            children: [
              TextField(
                controller: widget.controller,
                maxLines: 4,
                maxLength: widget.maxLength,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: StarkColors.white,
                  letterSpacing: 0.5,
                  height: 1.4,
                ),
                decoration: InputDecoration(
                  hintText: 'DESCRIBE YOURSELF',
                  hintStyle: GoogleFonts.jetBrainsMono(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: StarkColors.zinc800,
                    letterSpacing: 0.5,
                  ),
                  contentPadding: const EdgeInsets.all(12),
                  border: InputBorder.none,
                  counterText: '',
                ),
                textCapitalization: TextCapitalization.sentences,
                onChanged: (_) => setState(() {}),
              ),
              Positioned(
                bottom: 12,
                right: 12,
                child: Text(
                  '${widget.controller.text.length}/${widget.maxLength}',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    color: StarkColors.zinc500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
