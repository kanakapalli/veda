import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// ignore: depend_on_referenced_packages
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    show
        EmailAccountPasswordResetException,
        EmailAccountPasswordResetExceptionReason;
import '../../main.dart';
import 'auth_flow_screen.dart';
import 'stark_widgets.dart';

/// Email validation regex
final _emailRegex =
    RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

/// Forgot password screen - enter email to start reset
class ForgotPasswordScreen extends StatefulWidget {
  final PasswordResetData passwordResetData;
  final VoidCallback onOtpSent;
  final VoidCallback onBack;
  final Function(String?) setError;

  const ForgotPasswordScreen({
    super.key,
    required this.passwordResetData,
    required this.onOtpSent,
    required this.onBack,
    required this.setError,
  });

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  late AnimationController _animController;
  bool _isLoading = false;
  String? _emailError;
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
    _emailController.dispose();
    _animController.dispose();
    super.dispose();
  }

  bool _validateFields() {
    final email = _emailController.text.trim();
    bool isValid = true;

    setState(() {
      _emailError = null;
      _errorMessage = null;
    });

    if (email.isEmpty) {
      setState(() => _emailError = 'Email is required');
      isValid = false;
    } else if (!_emailRegex.hasMatch(email)) {
      setState(() => _emailError = 'Invalid email format');
      isValid = false;
    }

    return isValid;
  }

  Future<void> _handleSubmit() async {
    if (!_validateFields()) return;

    final email = _emailController.text.trim();

    setState(() => _isLoading = true);

    try {
      final requestId =
          await client.emailIdp.startPasswordReset(email: email);

      widget.passwordResetData.email = email;
      widget.passwordResetData.passwordResetRequestId = requestId;

      widget.onOtpSent();
    } on EmailAccountPasswordResetException catch (e) {
      setState(() {
        switch (e.reason) {
          case EmailAccountPasswordResetExceptionReason.tooManyAttempts:
            _errorMessage = 'Too many attempts. Please try again later.';
            break;
          default:
            _errorMessage = 'Password reset failed. Please try again.';
        }
      });
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
                    label: 'VEDA SYSTEM // RECOVERY'),
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
                              'RECOVER',
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
                          'ENTER YOUR REGISTERED EMAIL TO RECEIVE A VERIFICATION CODE',
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

                      // Email input
                      _buildFadeSlide(
                        interval: const Interval(0.2, 0.5,
                            curve: Curves.easeOut),
                        child: StarkTextField(
                          controller: _emailController,
                          label: 'Email',
                          placeholder: 'ENTER_ID...',
                          keyboardType: TextInputType.emailAddress,
                          errorText: _emailError,
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
                        child: Column(
                          children: [
                            StarkPrimaryButton(
                              label: 'Send Reset Code',
                              onPressed: _handleSubmit,
                              isLoading: _isLoading,
                            ),
                            const SizedBox(height: 24),
                            StarkLink(
                              label: 'Back to Login',
                              onTap: widget.onBack,
                            ),
                          ],
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
