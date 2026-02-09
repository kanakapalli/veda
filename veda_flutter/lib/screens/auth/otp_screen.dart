import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
// ignore: depend_on_referenced_packages
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    show
        EmailAccountRequestException,
        EmailAccountRequestExceptionReason,
        EmailAccountPasswordResetException,
        EmailAccountPasswordResetExceptionReason;
import 'package:veda_client/veda_client.dart';
import '../../main.dart';
import 'auth_flow_screen.dart';
import 'stark_widgets.dart';

/// OTP screen mode
enum OtpMode {
  registration,
  passwordReset,
}

/// OTP verification screen for registration and password reset
class OtpScreen extends StatefulWidget {
  final OtpMode mode;
  final RegistrationData? registrationData;
  final PasswordResetData? passwordResetData;
  final VoidCallback onVerified;
  final VoidCallback onBack;
  final Function(String?) setError;

  const OtpScreen({
    super.key,
    required this.mode,
    this.registrationData,
    this.passwordResetData,
    required this.onVerified,
    required this.onBack,
    required this.setError,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
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
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animController.forward();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
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
      if (widget.mode == OtpMode.registration) {
        final requestId = await client.emailIdp.startRegistration(
          email: widget.registrationData!.email,
        );
        widget.registrationData!.accountRequestId = requestId;
      } else {
        final requestId = await client.emailIdp.startPasswordReset(
          email: widget.passwordResetData!.email,
        );
        widget.passwordResetData!.passwordResetRequestId = requestId;
      }
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
    if (widget.mode == OtpMode.registration) {
      await _verifyRegistrationCode(code);
    } else {
      await _verifyPasswordResetCode(code);
    }
  }

  Future<void> _verifyRegistrationCode(String code) async {
    if (widget.registrationData?.accountRequestId == null) {
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
        accountRequestId: widget.registrationData!.accountRequestId!,
        verificationCode: code,
      );

      // Complete registration with password
      final authSuccess = await client.emailIdp.finishRegistration(
        registrationToken: token,
        password: widget.registrationData!.password,
      );
      await client.auth.updateSignedInUser(authSuccess);

      // Save profile data (email is already in auth system)
      try {
        await client.vedaUserProfile.upsertProfile(
          userType: UserType.learner,
          fullName: widget.registrationData!.fullName,
          bio: widget.registrationData!.bio.isEmpty
              ? null
              : widget.registrationData!.bio,
          interests: widget.registrationData!.interests,
          learningGoal: widget.registrationData!.learningGoal,
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

  Future<void> _verifyPasswordResetCode(String code) async {
    if (widget.passwordResetData?.passwordResetRequestId == null) {
      setState(() =>
          _errorMessage = 'Invalid session. Please go back and try again.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await client.emailIdp.verifyPasswordResetCode(
        passwordResetRequestId:
            widget.passwordResetData!.passwordResetRequestId!,
        verificationCode: code,
      );

      widget.passwordResetData!.finishPasswordResetToken = token;
      widget.onVerified();
    } on EmailAccountPasswordResetException catch (e) {
      setState(() {
        _attemptsUsed++;
        switch (e.reason) {
          case EmailAccountPasswordResetExceptionReason.expired:
            _errorMessage =
                'Reset code expired. Please request a new one.';
            break;
          case EmailAccountPasswordResetExceptionReason.tooManyAttempts:
            _errorMessage = 'Too many attempts. Please try again later.';
            break;
          case EmailAccountPasswordResetExceptionReason.invalid:
            _errorMessage = 'Invalid code. Please try again.';
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

  Widget _buildOtpBox(int index) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          border: Border.all(color: StarkColors.white, width: 1),
        ),
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          maxLength: 1,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: GoogleFonts.jetBrainsMono(
            fontSize: 20,
            fontWeight: FontWeight.w400,
            color: StarkColors.white,
          ),
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 20),
          ),
          onChanged: (value) => _onDigitChanged(index, value),
        ),
      ),
    );
  }

  String get _subtitleText => widget.mode == OtpMode.registration
      ? 'IDENTITY VERIFICATION LAYER 02'
      : 'PASSWORD RESET VERIFICATION';

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
              // Grid lines
              Positioned.fill(child: _GridLines()),

              // Header
              Positioned(
                top: 24,
                left: 24,
                right: 24,
                child: _buildFadeSlide(
                interval:
                    const Interval(0.0, 0.3, curve: Curves.easeOut),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'VEDA PROTOCOL',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 9,
                            color: StarkColors.zinc500,
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                                width: 8,
                                height: 8,
                                color: StarkColors.white),
                            const SizedBox(width: 8),
                            Text(
                              'SYSTEM ACTIVE',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: StarkColors.white,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'ID: 8829_X',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 9,
                            color: StarkColors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                        Text(
                          'NODE: LOCAL',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 9,
                            color: StarkColors.zinc500,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Back button
            Positioned(
              top: 80,
              left: 24,
              child: GestureDetector(
                onTap: widget.onBack,
                child: const Icon(Icons.arrow_back,
                    color: StarkColors.white, size: 20),
              ),
            ),

            // Main content
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Lock icon
                      _buildFadeSlide(
                        interval: const Interval(0.1, 0.4,
                            curve: Curves.easeOut),
                        child: _LockIcon(),
                      ),

                      const SizedBox(height: 24),

                      // Title
                      _buildFadeSlide(
                        interval: const Interval(0.15, 0.45,
                            curve: Curves.easeOut),
                        child: Column(
                          children: [
                            Text(
                              'VEDA',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: StarkColors.white,
                                letterSpacing: 8.0,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _subtitleText,
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 10,
                                color: StarkColors.zinc500,
                                letterSpacing: 2.0,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 64),

                      // OTP input
                      _buildFadeSlide(
                        interval: const Interval(0.2, 0.5,
                            curve: Curves.easeOut),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'ENTER PASSCODE',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: StarkColors.zinc500,
                                      letterSpacing: 2.0,
                                    ),
                                  ),
                                  Text(
                                    'ATTEMPTS: $_attemptsUsed/3',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 10,
                                      color: StarkColors.zinc600,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: List.generate(
                                  6, (i) => _buildOtpBox(i)),
                            ),
                            if (_errorMessage != null)
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 8),
                                child: Text(
                                  _errorMessage!,
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 10,
                                    color: StarkColors.error,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                          Icons.timer_outlined,
                                          size: 10,
                                          color:
                                              StarkColors.zinc500),
                                      const SizedBox(width: 6),
                                      Text(
                                        'EXPIRES $_formattedTime',
                                        style: GoogleFonts
                                            .jetBrainsMono(
                                          fontSize: 9,
                                          color:
                                              StarkColors.zinc500,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: _resendCode,
                                    child: Container(
                                      padding:
                                          const EdgeInsets.only(
                                              bottom: 1),
                                      decoration:
                                          const BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                              color: StarkColors
                                                  .white),
                                        ),
                                      ),
                                      child: Text(
                                        'RESEND TOKEN',
                                        style: GoogleFonts
                                            .jetBrainsMono(
                                          fontSize: 9,
                                          color:
                                              StarkColors.white,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Verify button
                      _buildFadeSlide(
                        interval: const Interval(0.3, 0.6,
                            curve: Curves.easeOut),
                        child: StarkSecondaryButton(
                          label: 'Verify Identity',
                          isLoading: _isLoading,
                          onPressed: () {
                            final code = _controllers
                                .map((c) => c.text)
                                .join();
                            if (code.length == 6) _verifyCode(code);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer
            Positioned(
              left: 24,
              right: 24,
              bottom: 24,
              child: _buildFadeSlide(
                interval:
                    const Interval(0.5, 0.8, curve: Curves.easeOut),
                child: Column(
                  children: [
                    Container(
                        height: 1, color: StarkColors.zinc800),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ENCRYPTED // AES-256',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 8,
                            color: StarkColors.zinc600,
                            letterSpacing: 2.0,
                          ),
                        ),
                        Row(
                          children: [
                            Text('HELP',
                                style:
                                    GoogleFonts.jetBrainsMono(
                                        fontSize: 8,
                                        color:
                                            StarkColors.zinc600,
                                        letterSpacing: 2.0)),
                            const SizedBox(width: 16),
                            Text('TERMS',
                                style:
                                    GoogleFonts.jetBrainsMono(
                                        fontSize: 8,
                                        color:
                                            StarkColors.zinc600,
                                        letterSpacing: 2.0)),
                          ],
                        ),
                      ],
                    ),
                  ],
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

/// Lock icon widget
class _LockIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        border: Border.all(color: StarkColors.white, width: 1),
      ),
      child: Stack(
        children: [
          Positioned(top: -1, left: -1, child: _corner()),
          Positioned(top: -1, right: -1, child: _corner()),
          Positioned(bottom: -1, left: -1, child: _corner()),
          Positioned(bottom: -1, right: -1, child: _corner()),
          const Center(
            child: Icon(Icons.lock_outline,
                color: StarkColors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _corner() =>
      Container(width: 4, height: 4, color: StarkColors.white);
}

/// Grid lines for OTP screen
class _GridLines extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GridLinesPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _GridLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = StarkColors.zinc900
      ..strokeWidth = 1;

    canvas.drawLine(Offset(0, size.height * 0.25),
        Offset(size.width, size.height * 0.25), paint);
    canvas.drawLine(Offset(0, size.height * 0.75),
        Offset(size.width, size.height * 0.75), paint);
    canvas.drawLine(
        Offset(24, 0), Offset(24, size.height), paint);
    canvas.drawLine(Offset(size.width - 24, 0),
        Offset(size.width - 24, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
