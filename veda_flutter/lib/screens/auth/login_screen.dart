import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
// ignore: depend_on_referenced_packages
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    show EmailAccountLoginException, EmailAccountLoginExceptionReason;
import '../../main.dart';
import 'stark_widgets.dart';

/// Email validation regex
final _emailRegex =
    RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

/// Login screen - email + password
class LoginScreen extends StatefulWidget {
  final VoidCallback onLogin;
  final VoidCallback onCreateAccount;
  final VoidCallback onForgotPassword;
  final String? errorMessage;
  final String? successMessage;
  final Function(String?) setError;

  const LoginScreen({
    super.key,
    required this.onLogin,
    required this.onCreateAccount,
    required this.onForgotPassword,
    this.errorMessage,
    this.successMessage,
    required this.setError,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late AnimationController _animController;
  bool _isLoading = false;
  bool _obscurePassword = true;
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
    _animController.dispose();
    super.dispose();
  }

  bool _validateFields() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    bool isValid = true;

    setState(() {
      _emailError = null;
      _passwordError = null;
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
    widget.setError(null);

    try {
      final authSuccess =
          await client.emailIdp.login(email: email, password: password);
      await client.auth.updateSignedInUser(authSuccess);
      widget.onLogin();
    } on EmailAccountLoginException catch (e) {
      switch (e.reason) {
        case EmailAccountLoginExceptionReason.invalidCredentials:
          setState(() => _passwordError = 'Invalid email or password');
          break;
        case EmailAccountLoginExceptionReason.tooManyAttempts:
          widget
              .setError('Too many failed attempts. Please try again later.');
          break;
        default:
          widget.setError('Login failed. Please try again.');
      }
    } on AuthUserBlockedException {
      widget
          .setError('This account has been blocked. Please contact support.');
    } catch (e) {
      widget.setError(
          'Login failed. Please check your connection and try again.');
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
    return Scaffold(
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
                child: const StarkBranding(),
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
                      // Success message
                      if (widget.successMessage != null)
                        _buildFadeSlide(
                          interval: const Interval(0.0, 0.3,
                              curve: Curves.easeOut),
                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 24),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: StarkColors.white, width: 1),
                            ),
                            child: Text(
                              widget.successMessage!.toUpperCase(),
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 10,
                                color: StarkColors.white,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),

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
                              'ACCESS',
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

                      const SizedBox(height: 64),

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

                      const SizedBox(height: 16),

                      // Password input
                      _buildFadeSlide(
                        interval: const Interval(0.25, 0.55,
                            curve: Curves.easeOut),
                        child: StarkTextField(
                          controller: _passwordController,
                          label: 'Password',
                          placeholder: 'ENTER PASSWORD...',
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
                      ),

                      const SizedBox(height: 12),

                      // Forgot password link
                      _buildFadeSlide(
                        interval: const Interval(0.28, 0.58,
                            curve: Curves.easeOut),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: StarkLink(
                            label: 'Forgot Password?',
                            onTap: widget.onForgotPassword,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Buttons
                      _buildFadeSlide(
                        interval: const Interval(0.3, 0.6,
                            curve: Curves.easeOut),
                        child: Column(
                          children: [
                            StarkPrimaryButton(
                              label: 'Request Access',
                              onPressed: _handleLogin,
                              isLoading: _isLoading,
                            ),
                            const SizedBox(height: 24),
                            StarkLink(
                              label: 'New Here? Create Account',
                              onTap: widget.onCreateAccount,
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
    );
  }
}
