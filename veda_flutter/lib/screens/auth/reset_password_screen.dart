import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
// ignore: depend_on_referenced_packages
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    show
        EmailAccountPasswordResetException,
        EmailAccountPasswordResetExceptionReason;
import '../../main.dart';
import 'auth_flow_screen.dart';
import 'stark_widgets.dart';

/// Reset password screen - enter new password after OTP verification
class ResetPasswordScreen extends StatefulWidget {
  final PasswordResetData passwordResetData;
  final VoidCallback onPasswordReset;
  final VoidCallback onBack;
  final Function(String?) setError;

  const ResetPasswordScreen({
    super.key,
    required this.passwordResetData,
    required this.onPasswordReset,
    required this.onBack,
    required this.setError,
  });

  @override
  State<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  late AnimationController _animController;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  bool _validateFields() {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    bool isValid = true;

    setState(() {
      _passwordError = null;
      _confirmPasswordError = null;
      _errorMessage = null;
    });

    if (password.isEmpty) {
      setState(() => _passwordError = 'Password is required');
      isValid = false;
    } else if (password.length < 8) {
      setState(() =>
          _passwordError = 'Password must be at least 8 characters');
      isValid = false;
    }

    if (confirmPassword.isEmpty) {
      setState(
          () => _confirmPasswordError = 'Please confirm your password');
      isValid = false;
    } else if (password != confirmPassword) {
      setState(() => _confirmPasswordError = 'Passwords do not match');
      isValid = false;
    }

    return isValid;
  }

  Future<void> _handleSubmit() async {
    if (!_validateFields()) return;

    final token = widget.passwordResetData.finishPasswordResetToken;
    if (token == null) {
      setState(() => _errorMessage =
          'Invalid session. Please start the reset process again.');
      return;
    }

    final password = _passwordController.text;

    setState(() => _isLoading = true);

    try {
      await client.emailIdp.finishPasswordReset(
        finishPasswordResetToken: token,
        newPassword: password,
      );

      widget.onPasswordReset();
    } on EmailAccountPasswordResetException catch (e) {
      setState(() {
        switch (e.reason) {
          case EmailAccountPasswordResetExceptionReason.expired:
            _errorMessage =
                'Reset session expired. Please start over.';
            break;
          case EmailAccountPasswordResetExceptionReason.policyViolation:
            _passwordError =
                'Password does not meet security requirements.';
            break;
          case EmailAccountPasswordResetExceptionReason.invalid:
            _errorMessage =
                'Invalid reset session. Please start over.';
            break;
          default:
            _errorMessage = 'Password reset failed. Please try again.';
        }
      });
    } on AuthUserBlockedException {
      setState(() => _errorMessage =
          'This account has been blocked. Please contact support.');
    } catch (e) {
      setState(() => _errorMessage =
          'Request failed. Please check your connection and try again.');
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
              // Top-left branding
            Positioned(
              top: 32,
              left: 32,
              child: _buildFadeSlide(
                interval:
                    const Interval(0.0, 0.3, curve: Curves.easeOut),
                child: const StarkBranding(
                    label: 'VEDA SYSTEM // NEW PASSWORD'),
              ),
            ),

            // Back button
            Positioned(
              top: 32,
              right: 32,
              child: GestureDetector(
                onTap: widget.onBack,
                child: const Icon(Icons.close,
                    color: StarkColors.white, size: 20),
              ),
            ),

            // Main content
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      _buildFadeSlide(
                        interval: const Interval(0.1, 0.4,
                            curve: Curves.easeOut),
                        child: Column(
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
                              'RESET',
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
                                width: 32,
                                height: 2,
                                color: StarkColors.white),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Subtitle
                      _buildFadeSlide(
                        interval: const Interval(0.15, 0.45,
                            curve: Curves.easeOut),
                        child: Text(
                          'CREATE A NEW PASSWORD FOR YOUR ACCOUNT',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            color: StarkColors.zinc500,
                            letterSpacing: 1.5,
                            height: 1.6,
                          ),
                        ),
                      ),

                      const SizedBox(height: 48),

                      // New password
                      _buildFadeSlide(
                        interval: const Interval(0.2, 0.5,
                            curve: Curves.easeOut),
                        child: StarkTextField(
                          controller: _passwordController,
                          label: 'New Password',
                          placeholder: 'ENTER NEW PASSWORD...',
                          obscureText: _obscurePassword,
                          errorText: _passwordError,
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
                      ),

                      const SizedBox(height: 16),

                      // Confirm password
                      _buildFadeSlide(
                        interval: const Interval(0.25, 0.55,
                            curve: Curves.easeOut),
                        child: StarkTextField(
                          controller: _confirmPasswordController,
                          label: 'Confirm Password',
                          placeholder: 'CONFIRM PASSWORD...',
                          obscureText: _obscureConfirmPassword,
                          errorText: _confirmPasswordError,
                          suffixIcon: GestureDetector(
                            onTap: () => setState(() =>
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword),
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(right: 12),
                              child: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: StarkColors.zinc500,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ),

                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            _errorMessage!,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              color: StarkColors.error,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),

                      const SizedBox(height: 32),

                      // Submit button
                      _buildFadeSlide(
                        interval: const Interval(0.3, 0.6,
                            curve: Curves.easeOut),
                        child: StarkPrimaryButton(
                          label: 'Set New Password',
                          onPressed: _handleSubmit,
                          isLoading: _isLoading,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer
            Positioned(
              left: 32,
              right: 32,
                bottom: 32,
                child: _buildFadeSlide(
                  interval:
                      const Interval(0.5, 0.8, curve: Curves.easeOut),
                  child: const StarkFooter(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
