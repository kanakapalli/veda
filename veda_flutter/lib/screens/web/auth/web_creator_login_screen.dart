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

/// Web Creator Login Screen - Minimalist design for course creators
class WebCreatorLoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  final VoidCallback onSwitchToRegister;

  const WebCreatorLoginScreen({
    super.key,
    required this.onLoginSuccess,
    required this.onSwitchToRegister,
  });

  @override
  State<WebCreatorLoginScreen> createState() => _WebCreatorLoginScreenState();
}

class _WebCreatorLoginScreenState extends State<WebCreatorLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _emailError;
  String? _passwordError;
  String? _generalError;

  @override
  void initState() {
    super.initState();
    // Pre-fill with default credentials for development
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _emailController.text = 'kanakapalli.anurag@gmail.com';
      _passwordController.text = 'asdasdasd';
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validateFields() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    bool isValid = true;

    setState(() {
      _emailError = null;
      _passwordError = null;
      _generalError = null;
    });

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
    }

    return isValid;
  }

  Future<void> _handleLogin() async {
    if (!_validateFields()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() => _isLoading = true);

    try {
      final authSuccess =
          await client.emailIdp.login(email: email, password: password);
      await client.auth.updateSignedInUser(authSuccess);

      // Check if user has creator role
      final profile = await client.vedaUserProfile.getMyProfile();
      if (profile != null && !profile.userTypes.contains(UserType.creator)) {
        // User doesn't have creator role
        await client.auth.signOutDevice();
        setState(() {
          _generalError = 'You need to register as a creator to access this platform. Please create a creator account.';
          _isLoading = false;
        });
        return;
      }

      widget.onLoginSuccess();
    } on EmailAccountLoginException catch (e) {
      setState(() {
        _isLoading = false;
        switch (e.reason) {
          case EmailAccountLoginExceptionReason.invalidCredentials:
            _passwordError = 'Invalid email or password';
            break;
          case EmailAccountLoginExceptionReason.tooManyAttempts:
            _generalError = 'Too many failed attempts. Please try again later.';
            break;
          default:
            _generalError = 'Login failed. Please try again.';
        }
      });
    } on AuthUserBlockedException {
      setState(() {
        _isLoading = false;
        _generalError = 'This account has been blocked. Please contact support.';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _generalError = 'Login failed. Please check your connection and try again.';
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
            constraints: const BoxConstraints(maxWidth: 440),
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
                    'SIGN IN',
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
                    'Access your creator studio',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: VedaColors.zinc500,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 72),

                  // General Error Message
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

                  // Email Field
                  Text(
                    'EMAIL',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: VedaColors.zinc500,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _WebTextField(
                    controller: _emailController,
                    hintText: 'creator@example.com',
                    keyboardType: TextInputType.emailAddress,
                    errorText: _emailError,
                  ),
                  const SizedBox(height: 32),

                  // Password Field
                  Text(
                    'PASSWORD',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: VedaColors.zinc500,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _WebTextField(
                    controller: _passwordController,
                    hintText: 'Enter your password',
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
                  const SizedBox(height: 48),

                  // Sign In Button
                  _WebButton(
                    label: _isLoading ? 'SIGNING IN...' : 'SIGN IN',
                    onPressed: _isLoading ? null : _handleLogin,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 32),

                  // Switch to Register
                  Center(
                    child: TextButton(
                      onPressed: widget.onSwitchToRegister,
                      child: Text(
                        'Don\'t have an account? Create one',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: VedaColors.accent,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 96),

                  // Footer
                  Center(
                    child: Text(
                      'For learners, download the mobile app',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: VedaColors.zinc700,
                        letterSpacing: 0.2,
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
}

// ---------------------------------------------------------------------------
// WEB COMPONENTS
// ---------------------------------------------------------------------------

class _WebTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? errorText;
  final Widget? suffixIcon;

  const _WebTextField({
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.errorText,
    this.suffixIcon,
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
