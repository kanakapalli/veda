import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
// ignore: depend_on_referenced_packages
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    show
        EmailAccountRequestException,
        EmailAccountRequestExceptionReason;
import 'package:veda_client/veda_client.dart';
import '../../../design_system/veda_colors.dart';
import '../../../main.dart';
import 'web_creator_register_screen.dart';

/// Web Creator OTP Verification Screen
class WebCreatorOtpScreen extends StatefulWidget {
  final CreatorRegistrationData registrationData;
  final VoidCallback onVerified;
  final VoidCallback onBack;

  const WebCreatorOtpScreen({
    super.key,
    required this.registrationData,
    required this.onVerified,
    required this.onBack,
  });

  @override
  State<WebCreatorOtpScreen> createState() => _WebCreatorOtpScreenState();
}

class _WebCreatorOtpScreenState extends State<WebCreatorOtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  int _attemptsUsed = 0;
  int _secondsRemaining = 179;
  Timer? _timer;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _resendCode() async {
    setState(() {
      _secondsRemaining = 179;
      _errorMessage = null;
      for (final c in _controllers) {
        c.clear();
      }
    });
    _timer?.cancel();
    _startTimer();

    try {
      final requestId = await client.emailIdp.startRegistration(
        email: widget.registrationData.email,
      );
      widget.registrationData.accountRequestId = requestId;
      setState(() => _errorMessage = null);
      _focusNodes[0].requestFocus();
    } catch (e) {
      setState(
          () => _errorMessage = 'Failed to resend code. Please try again.');
    }
  }

  String get _formattedTime {
    final minutes = _secondsRemaining ~/ 60;
    final seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _onDigitChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    final code = _controllers.map((c) => c.text).join();
    if (code.length == 6) {
      _verifyCode(code);
    }
  }

  Future<void> _verifyCode(String code) async {
    if (widget.registrationData.accountRequestId == null) {
      setState(() =>
          _errorMessage = 'Invalid session. Please go back and try again.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Verify registration code → get registrationToken
      final token = await client.emailIdp.verifyRegistrationCode(
        accountRequestId: widget.registrationData.accountRequestId!,
        verificationCode: code,
      );

      // Complete registration with password
      final authSuccess = await client.emailIdp.finishRegistration(
        registrationToken: token,
        password: widget.registrationData.password,
      );
      await client.auth.updateSignedInUser(authSuccess);

      // Create creator profile
      try {
        await client.vedaUserProfile.upsertProfile(
          userType: UserType.creator,
          fullName: widget.registrationData.fullName,
          bio: widget.registrationData.bio.isEmpty
              ? null
              : widget.registrationData.bio,
          websiteUrl: widget.registrationData.websiteUrl.isEmpty
              ? null
              : widget.registrationData.websiteUrl,
          expertise: widget.registrationData.expertise,
          interests: [],
          learningGoal: null,
        );
      } catch (e) {
        debugPrint('Failed to save profile: $e');
      }

      widget.onVerified();
    } on EmailAccountRequestException catch (e) {
      setState(() {
        _attemptsUsed++;
        switch (e.reason) {
          case EmailAccountRequestExceptionReason.expired:
            _errorMessage =
                'Verification code expired. Please request a new one.';
            break;
          case EmailAccountRequestExceptionReason.invalid:
            _errorMessage =
                'Invalid code or email already registered. Please try again.';
            break;
          case EmailAccountRequestExceptionReason.policyViolation:
            _errorMessage = 'Password does not meet requirements.';
            break;
          case EmailAccountRequestExceptionReason.tooManyAttempts:
            _errorMessage = 'Too many attempts. Please try again later.';
            break;
          default:
            _errorMessage = 'Verification failed. Please try again.';
        }
        for (final c in _controllers) {
          c.clear();
        }
        _focusNodes[0].requestFocus();
      });
    } on AuthUserBlockedException {
      setState(() => _errorMessage = 'This account has been blocked.');
    } catch (e) {
      setState(() {
        _attemptsUsed++;
        _errorMessage = 'Verification failed. Please try again.';
        for (final c in _controllers) {
          c.clear();
        }
        _focusNodes[0].requestFocus();
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VedaColors.black,
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
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
                    'VERIFY EMAIL',
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
                    'Enter the 6-digit code sent to ${widget.registrationData.email}',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: VedaColors.zinc500,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 72),

                  // OTP Input
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (i) => _buildOtpBox(i)),
                  ),

                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        _errorMessage!,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: VedaColors.error,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Timer and Resend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'EXPIRES $_formattedTime',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          color: VedaColors.zinc500,
                          letterSpacing: 1.5,
                        ),
                      ),
                      TextButton(
                        onPressed: _resendCode,
                        child: Text(
                          'RESEND CODE',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            color: VedaColors.accent,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 48),

                  // Verify Button
                  _WebButton(
                    label: _isLoading ? 'VERIFYING...' : 'VERIFY',
                    isLoading: _isLoading,
                    onPressed: () {
                      final code = _controllers.map((c) => c.text).join();
                      if (code.length == 6) _verifyCode(code);
                    },
                  ),

                  const SizedBox(height: 32),

                  // Back Button
                  Center(
                    child: TextButton(
                      onPressed: widget.onBack,
                      child: Text(
                        'Back to registration',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: VedaColors.zinc500,
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

  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 64,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        maxLength: 1,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: GoogleFonts.jetBrainsMono(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          color: VedaColors.white,
        ),
        decoration: InputDecoration(
          counterText: '',
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: VedaColors.zinc800, width: 1),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: VedaColors.zinc800, width: 1),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: VedaColors.accent, width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
        ),
        onChanged: (value) => _onDigitChanged(index, value),
      ),
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
