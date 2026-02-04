import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../design_system/veda_colors.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  final VoidCallback onVerified;
  final VoidCallback onBack;

  const OtpScreen({
    super.key,
    required this.email,
    required this.onVerified,
    required this.onBack,
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
  int _secondsRemaining = 179; // 2:59
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animController.forward();
    _startTimer();

    // Auto-focus first input
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
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _resendToken() {
    setState(() {
      _secondsRemaining = 179;
    });
    _timer?.cancel();
    _startTimer();
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

    // Check if all digits are filled
    final code = _controllers.map((c) => c.text).join();
    if (code.length == 6) {
      _verifyCode(code);
    }
  }

  void _onKeyPressed(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _verifyCode(String code) {
    // For demo, accept any 6-digit code
    // In real implementation, verify with server
    setState(() {
      _attemptsUsed++;
    });

    if (_attemptsUsed < 3) {
      widget.onVerified();
    }
  }

  Widget _buildFadeSlide({
    required Interval interval,
    required Widget child,
  }) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animController, curve: interval),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: _animController, curve: interval),
        ),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VedaColors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Grid lines (decorative)
            Positioned.fill(
              child: CustomPaint(painter: _GridLinesPainter()),
            ),

            // Header
            Positioned(
              top: 24,
              left: 24,
              right: 24,
              child: _buildFadeSlide(
                interval: const Interval(0.0, 0.3, curve: Curves.easeOut),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'VEDA PROTOCOL',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 9,
                            fontWeight: FontWeight.w400,
                            color: VedaColors.zinc500,
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              color: VedaColors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'SYSTEM ACTIVE',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: VedaColors.white,
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
                            fontWeight: FontWeight.w400,
                            color: VedaColors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                        Text(
                          'NODE: LOCAL',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 9,
                            fontWeight: FontWeight.w400,
                            color: VedaColors.zinc500,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
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
                        interval:
                            const Interval(0.1, 0.4, curve: Curves.easeOut),
                        child: _buildLockIcon(),
                      ),

                      const SizedBox(height: 24),

                      // Title
                      _buildFadeSlide(
                        interval:
                            const Interval(0.15, 0.45, curve: Curves.easeOut),
                        child: Column(
                          children: [
                            Text(
                              'VEDA',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: VedaColors.white,
                                letterSpacing: 8.0,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'IDENTITY VERIFICATION LAYER 02',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                                color: VedaColors.zinc500,
                                letterSpacing: 2.0,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 64),

                      // Passcode input section
                      _buildFadeSlide(
                        interval:
                            const Interval(0.2, 0.5, curve: Curves.easeOut),
                        child: Column(
                          children: [
                            // Label row
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'ENTER PASSCODE',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: VedaColors.zinc500,
                                      letterSpacing: 2.0,
                                    ),
                                  ),
                                  Text(
                                    'ATTEMPTS: $_attemptsUsed/3',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w400,
                                      color: VedaColors.zinc600,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // OTP boxes
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(6, (index) {
                                return _buildOtpBox(index);
                              }),
                            ),

                            const SizedBox(height: 16),

                            // Timer and resend row
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.timer_outlined,
                                        size: 10,
                                        color: VedaColors.zinc500,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'EXPIRES $_formattedTime',
                                        style: GoogleFonts.jetBrainsMono(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w400,
                                          color: VedaColors.zinc500,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: _resendToken,
                                    child: Container(
                                      padding: const EdgeInsets.only(bottom: 1),
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: VedaColors.white,
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'RESEND TOKEN',
                                        style: GoogleFonts.jetBrainsMono(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w400,
                                          color: VedaColors.white,
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
                        interval:
                            const Interval(0.3, 0.6, curve: Curves.easeOut),
                        child: _VerifyButton(
                          onPressed: () {
                            final code =
                                _controllers.map((c) => c.text).join();
                            if (code.length == 6) {
                              _verifyCode(code);
                            }
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
                interval: const Interval(0.5, 0.8, curve: Curves.easeOut),
                child: Column(
                  children: [
                    Container(
                      height: 1,
                      color: VedaColors.zinc800,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ENCRYPTED // AES-256',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 8,
                            fontWeight: FontWeight.w400,
                            color: VedaColors.zinc600,
                            letterSpacing: 2.0,
                          ),
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {},
                              child: Text(
                                'HELP',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w400,
                                  color: VedaColors.zinc600,
                                  letterSpacing: 2.0,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            GestureDetector(
                              onTap: () {},
                              child: Text(
                                'TERMS',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w400,
                                  color: VedaColors.zinc600,
                                  letterSpacing: 2.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Back button
            Positioned(
              top: 24,
              left: 24,
              child: GestureDetector(
                onTap: widget.onBack,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.arrow_back,
                    color: VedaColors.white,
                    size: 20,
                  ),
                ),
              ),
            ),

            // Right badge
            Positioned(
              right: 0,
              bottom: 96,
              child: _buildFadeSlide(
                interval: const Interval(0.6, 0.9, curve: Curves.easeOut),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: const BoxDecoration(
                    color: VedaColors.black,
                    border: Border(
                      left: BorderSide(color: VedaColors.white, width: 1),
                      top: BorderSide(color: VedaColors.white, width: 1),
                      bottom: BorderSide(color: VedaColors.white, width: 1),
                    ),
                  ),
                  child: Text(
                    'AUTH_MOD_V2',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 8,
                      fontWeight: FontWeight.w400,
                      color: VedaColors.white,
                      letterSpacing: 3.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLockIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        border: Border.all(color: VedaColors.white, width: 1),
      ),
      child: Stack(
        children: [
          // Corner accents
          Positioned(
            top: -1,
            left: -1,
            child: Container(width: 4, height: 4, color: VedaColors.white),
          ),
          Positioned(
            top: -1,
            right: -1,
            child: Container(width: 4, height: 4, color: VedaColors.white),
          ),
          Positioned(
            bottom: -1,
            left: -1,
            child: Container(width: 4, height: 4, color: VedaColors.white),
          ),
          Positioned(
            bottom: -1,
            right: -1,
            child: Container(width: 4, height: 4, color: VedaColors.white),
          ),
          // Lock icon
          Center(
            child: Icon(
              Icons.lock_outline,
              color: VedaColors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 48,
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (event) => _onKeyPressed(index, event),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: VedaColors.white, width: 1),
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
              color: VedaColors.white,
            ),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 16),
            ),
            onChanged: (value) => _onDigitChanged(index, value),
          ),
        ),
      ),
    );
  }
}

class _VerifyButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _VerifyButton({required this.onPressed});

  @override
  State<_VerifyButton> createState() => _VerifyButtonState();
}

class _VerifyButtonState extends State<_VerifyButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: _isHovered ? VedaColors.white : VedaColors.black,
            border: Border.all(color: VedaColors.white, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'VERIFY IDENTITY',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _isHovered ? VedaColors.black : VedaColors.white,
                  letterSpacing: 3.0,
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.arrow_forward,
                size: 14,
                color: _isHovered ? VedaColors.black : VedaColors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Decorative grid lines painter
class _GridLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = VedaColors.zinc900
      ..strokeWidth = 1;

    // Horizontal lines at 1/4 and 3/4 height
    canvas.drawLine(
      Offset(0, size.height * 0.25),
      Offset(size.width, size.height * 0.25),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.75),
      Offset(size.width, size.height * 0.75),
      paint,
    );

    // Vertical lines at left and right margins
    canvas.drawLine(
      Offset(24, 0),
      Offset(24, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - 24, 0),
      Offset(size.width - 24, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
