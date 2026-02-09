import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
// ignore: depend_on_referenced_packages
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    show EmailAccountLoginException, EmailAccountLoginExceptionReason;
import 'package:veda_client/veda_client.dart';
import '../../../design_system/veda_colors.dart';
import '../../../main.dart';

/// Email validation regex
final _emailRegex =
    RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

/// Web Creator Registration Data
class CreatorRegistrationData {
  String email = '';
  String password = '';
  String fullName = '';
  String bio = '';
  String websiteUrl = '';
  List<String> expertise = [];
  UuidValue? accountRequestId;
}

/// Web Creator Registration Screen
class WebCreatorRegisterScreen extends StatefulWidget {
  final CreatorRegistrationData registrationData;
  final VoidCallback onOtpSent;
  final VoidCallback onSwitchToLogin;

  const WebCreatorRegisterScreen({
    super.key,
    required this.registrationData,
    required this.onOtpSent,
    required this.onSwitchToLogin,
  });

  @override
  State<WebCreatorRegisterScreen> createState() =>
      _WebCreatorRegisterScreenState();
}

class _WebCreatorRegisterScreenState extends State<WebCreatorRegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _bioController = TextEditingController();
  final _websiteController = TextEditingController();

  final int _bioMaxLength = 500;
  final Set<String> _selectedExpertise = {};
  final List<String> _availableExpertise = [
    'Programming',
    'Design',
    'Business',
    'Marketing',
    'Data Science',
    'AI & ML',
    'Web Development',
    'Mobile Development',
  ];

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _generalError;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.registrationData.fullName;
    _emailController.text = widget.registrationData.email;
    _bioController.text = widget.registrationData.bio;
    _websiteController.text = widget.registrationData.websiteUrl;
    _selectedExpertise.addAll(widget.registrationData.expertise);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _bioController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  bool _validateFields() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    bool isValid = true;

    setState(() {
      _nameError = null;
      _emailError = null;
      _passwordError = null;
      _generalError = null;
    });

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
      setState(() => _passwordError = 'Password must be at least 8 characters');
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
      final requestId = await client.emailIdp.startRegistration(email: email);

      // Store data for after OTP verification
      widget.registrationData.fullName = name;
      widget.registrationData.email = email;
      widget.registrationData.password = password;
      widget.registrationData.bio = _bioController.text.trim();
      widget.registrationData.websiteUrl = _websiteController.text.trim();
      widget.registrationData.expertise = _selectedExpertise.toList();
      widget.registrationData.accountRequestId = requestId;

      widget.onOtpSent();
    } catch (e) {
      setState(() {
        _isLoading = false;
        // Check if it's a duplicate email error
        final errorMessage = e.toString();
        if (errorMessage.contains('already') || errorMessage.contains('exist')) {
          _emailError = 'An account with this email already exists. Please sign in instead.';
        } else {
          _generalError = 'Registration failed. Please try again.';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VedaColors.black,
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(48.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo/Branding
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        color: VedaColors.white,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'VEDA CREATOR',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: VedaColors.zinc500,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 72),

                  // Title
                  Text(
                    'CREATE ACCOUNT',
                    style: GoogleFonts.inter(
                      fontSize: 52,
                      fontWeight: FontWeight.w300,
                      color: VedaColors.white,
                      letterSpacing: -1.2,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Start creating AI-powered courses',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: VedaColors.zinc500,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 72),

                  // General Error
                  if (_generalError != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        border: Border.all(color: VedaColors.error, width: 1),
                      ),
                      child: Text(
                        _generalError!,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: VedaColors.error,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),

                  // Name Field
                  _buildLabel('FULL NAME'),
                  const SizedBox(height: 12),
                  _WebTextField(
                    controller: _nameController,
                    hintText: 'Your name or business name',
                    errorText: _nameError,
                  ),
                  const SizedBox(height: 32),

                  // Email Field
                  _buildLabel('EMAIL'),
                  const SizedBox(height: 12),
                  _WebTextField(
                    controller: _emailController,
                    hintText: 'creator@example.com',
                    keyboardType: TextInputType.emailAddress,
                    errorText: _emailError,
                  ),
                  const SizedBox(height: 32),

                  // Password Field
                  _buildLabel('PASSWORD'),
                  const SizedBox(height: 12),
                  _WebTextField(
                    controller: _passwordController,
                    hintText: 'Create a strong password (min 8 characters)',
                    obscureText: _obscurePassword,
                    errorText: _passwordError,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 18,
                        color: VedaColors.zinc500,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Bio Field
                  _buildLabel('BIO (OPTIONAL)'),
                  const SizedBox(height: 12),
                  _WebTextField(
                    controller: _bioController,
                    hintText: 'Tell us about your teaching experience...',
                    maxLines: 4,
                    maxLength: _bioMaxLength,
                  ),
                  const SizedBox(height: 32),

                  // Website Field
                  _buildLabel('WEBSITE (OPTIONAL)'),
                  const SizedBox(height: 12),
                  _WebTextField(
                    controller: _websiteController,
                    hintText: 'https://yourwebsite.com',
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 32),

                  // Expertise Tags
                  _buildLabel('AREAS OF EXPERTISE (OPTIONAL)'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableExpertise.map((expertise) {
                      return _ExpertiseTag(
                        label: expertise,
                        isSelected: _selectedExpertise.contains(expertise),
                        onTap: () {
                          setState(() {
                            if (_selectedExpertise.contains(expertise)) {
                              _selectedExpertise.remove(expertise);
                            } else {
                              _selectedExpertise.add(expertise);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 48),

                  // Submit Button
                  _WebButton(
                    label: _isLoading ? 'CREATING ACCOUNT...' : 'CONTINUE',
                    onPressed: _isLoading ? null : _handleSubmit,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 32),

                  // Switch to Login
                  Center(
                    child: TextButton(
                      onPressed: widget.onSwitchToLogin,
                      child: Text(
                        'Already have an account? Sign in',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: VedaColors.accent,
                          letterSpacing: 0.2,
                        ),
                      ),
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.jetBrainsMono(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: VedaColors.zinc500,
        letterSpacing: 2.0,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// COMPONENTS
// ---------------------------------------------------------------------------

class _WebTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? errorText;
  final Widget? suffixIcon;
  final int maxLines;
  final int? maxLength;

  const _WebTextField({
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.errorText,
    this.suffixIcon,
    this.maxLines = 1,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: maxLines,
          maxLength: maxLength,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: VedaColors.white,
            letterSpacing: 0.3,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: VedaColors.zinc700,
              letterSpacing: 0.3,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(
                color: errorText != null ? VedaColors.error : VedaColors.zinc800,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(
                color: errorText != null ? VedaColors.error : VedaColors.zinc800,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(
                color: errorText != null ? VedaColors.error : VedaColors.accent,
                width: 1,
              ),
            ),
            suffixIcon: suffixIcon,
            counterText: '',
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 24, top: 8),
            child: Text(
              errorText!,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: VedaColors.error,
                letterSpacing: 0.2,
              ),
            ),
          ),
      ],
    );
  }
}

class _WebButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _WebButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  State<_WebButton> createState() => _WebButtonState();
}

class _WebButtonState extends State<_WebButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          height: 56,
          width: double.infinity,
          decoration: BoxDecoration(
            color: _isHovered && !isDisabled
                ? VedaColors.zinc900
                : Colors.transparent,
            border: Border.all(
              color: isDisabled
                  ? VedaColors.zinc900
                  : _isHovered
                      ? VedaColors.white
                      : VedaColors.zinc800,
              width: 1,
            ),
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 1,
                      valueColor: AlwaysStoppedAnimation(VedaColors.accent),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.label,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: isDisabled
                              ? VedaColors.white.withValues(alpha: 0.5)
                              : VedaColors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                      if (!isDisabled) ...[
                        const SizedBox(width: 16),
                        Icon(
                          Icons.arrow_forward,
                          size: 18,
                          color: _isHovered
                              ? VedaColors.white
                              : VedaColors.zinc700,
                        ),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _ExpertiseTag extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ExpertiseTag({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_ExpertiseTag> createState() => _ExpertiseTagState();
}

class _ExpertiseTagState extends State<_ExpertiseTag> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? VedaColors.accent.withValues(alpha: 0.2)
                : (_isHovered ? VedaColors.zinc900 : Colors.transparent),
            border: Border.all(
              color: widget.isSelected
                  ? VedaColors.accent
                  : VedaColors.zinc800,
              width: 1,
            ),
          ),
          child: Text(
            widget.label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color:
                  widget.isSelected ? VedaColors.accent : VedaColors.white,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}
