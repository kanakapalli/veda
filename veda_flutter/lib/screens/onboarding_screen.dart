import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../design_system/veda_colors.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback onBack;

  const OnboardingScreen({
    super.key,
    required this.onComplete,
    required this.onBack,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _bioController = TextEditingController();
  final int _bioMaxLength = 200;

  // Interest tags
  final Set<String> _selectedInterests = {'AI_LOGIC'};
  final List<String> _availableInterests = [
    'ARCHITECTURE',
    'AI_LOGIC',
    'ETHICS',
    'QUANT',
  ];

  // Learning goal
  String? _selectedGoal;

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
    _animController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_nameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty) {
      widget.onComplete();
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
            // Top left branding
            Positioned(
              top: 32,
              left: 32,
              child: _buildFadeSlide(
                interval: const Interval(0.0, 0.3, curve: Curves.easeOut),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      color: VedaColors.white,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'VEDA SYSTEM // INIT',
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
            ),

            // Main scrollable content
            Positioned.fill(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(32, 80, 32, 120),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      _buildFadeSlide(
                        interval:
                            const Interval(0.05, 0.35, curve: Curves.easeOut),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'VEDA_',
                              style: GoogleFonts.inter(
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                                color: VedaColors.white,
                                letterSpacing: -2.0,
                                height: 0.9,
                              ),
                            ),
                            Text(
                              'ONBOARD',
                              style: GoogleFonts.inter(
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                                color: VedaColors.white,
                                letterSpacing: -2.0,
                                height: 0.9,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              width: 48,
                              height: 2,
                              color: VedaColors.white,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Form fields
                      _buildFadeSlide(
                        interval:
                            const Interval(0.1, 0.4, curve: Curves.easeOut),
                        child: Column(
                          children: [
                            // Full Name
                            _StarkTextField(
                              controller: _nameController,
                              label: 'IDENTITY // FULL NAME',
                              placeholder: 'ENTER NAME',
                            ),
                            const SizedBox(height: 20),

                            // Email
                            _StarkTextField(
                              controller: _emailController,
                              label: 'IDENTITY // EMAIL',
                              placeholder: 'ENTER EMAIL',
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 20),

                            // Password
                            _StarkTextField(
                              controller: _passwordController,
                              label: 'SECURITY // PASSWORD',
                              placeholder: 'CREATE PASSWORD',
                              obscureText: true,
                            ),
                            const SizedBox(height: 20),

                            // Bio
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
                        interval:
                            const Interval(0.15, 0.45, curve: Curves.easeOut),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Section header
                            Container(
                              padding: const EdgeInsets.only(bottom: 4),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: VedaColors.zinc800,
                                    width: 1,
                                  ),
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
                                      color: VedaColors.white,
                                      letterSpacing: 2.0,
                                    ),
                                  ),
                                  Text(
                                    'MULTI-SELECT',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w400,
                                      color: VedaColors.zinc500,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Tags
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _availableInterests.map((interest) {
                                final isSelected =
                                    _selectedInterests.contains(interest);
                                return _InterestTag(
                                  label: interest,
                                  isSelected: isSelected,
                                  onTap: () {
                                    setState(() {
                                      if (isSelected) {
                                        _selectedInterests.remove(interest);
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
                        interval:
                            const Interval(0.2, 0.5, curve: Curves.easeOut),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Section header
                            Container(
                              padding: const EdgeInsets.only(bottom: 4),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: VedaColors.zinc800,
                                    width: 1,
                                  ),
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
                                      color: VedaColors.white,
                                      letterSpacing: 2.0,
                                    ),
                                  ),
                                  Text(
                                    'REQUIRED',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w400,
                                      color: VedaColors.zinc500,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Goal options
                            Row(
                              children: [
                                Expanded(
                                  child: _GoalOption(
                                    label: 'CAREER\nPIVOT',
                                    isSelected: _selectedGoal == 'career_pivot',
                                    onTap: () {
                                      setState(() {
                                        _selectedGoal = 'career_pivot';
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _GoalOption(
                                    label: 'ACADEMIC\nDEPTH',
                                    isSelected:
                                        _selectedGoal == 'academic_depth',
                                    onTap: () {
                                      setState(() {
                                        _selectedGoal = 'academic_depth';
                                      });
                                    },
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
                        interval:
                            const Interval(0.25, 0.55, curve: Curves.easeOut),
                        child: _SubmitButton(
                          label: 'COMMENCE_STARK_LEARNING',
                          onPressed: _onSubmit,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom footer
            Positioned(
              left: 32,
              right: 32,
              bottom: 32,
              child: _buildFadeSlide(
                interval: const Interval(0.5, 0.8, curve: Curves.easeOut),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Dots
                    Row(
                      children: List.generate(
                        3,
                        (i) => Container(
                          width: 2,
                          height: 2,
                          margin: const EdgeInsets.only(right: 8),
                          color: VedaColors.zinc700,
                        ),
                      ),
                    ),
                    // Encrypted label
                    Text(
                      'ENCRYPTED CONNECTION',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 8,
                        fontWeight: FontWeight.w400,
                        color: VedaColors.zinc800,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Right side badge
            Positioned(
              right: 0,
              bottom: 96,
              child: _buildFadeSlide(
                interval: const Interval(0.6, 0.9, curve: Curves.easeOut),
                child: Transform.rotate(
                  angle: 1.5708, // 90 degrees
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    color: VedaColors.white,
                    child: Text(
                      'NODE_GENESIS_01',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        color: VedaColors.black,
                        letterSpacing: 3.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Back button
            Positioned(
              top: 32,
              right: 32,
              child: GestureDetector(
                onTap: widget.onBack,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.close,
                    color: VedaColors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Stark-style text field
class _StarkTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String placeholder;
  final TextInputType? keyboardType;
  final bool obscureText;

  const _StarkTextField({
    required this.controller,
    required this.label,
    required this.placeholder,
    this.keyboardType,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 4),
          child: Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: VedaColors.zinc500,
              letterSpacing: 2.0,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: VedaColors.white, width: 2),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: VedaColors.white,
              letterSpacing: 0.5,
            ),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: GoogleFonts.jetBrainsMono(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: VedaColors.zinc800,
                letterSpacing: 0.5,
              ),
              contentPadding: const EdgeInsets.all(12),
              border: InputBorder.none,
            ),
            textCapitalization: TextCapitalization.characters,
          ),
        ),
      ],
    );
  }
}

/// Stark-style bio/textarea field
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
              color: VedaColors.zinc500,
              letterSpacing: 2.0,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: VedaColors.white, width: 2),
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
                  color: VedaColors.white,
                  letterSpacing: 0.5,
                  height: 1.4,
                ),
                decoration: InputDecoration(
                  hintText: 'DESCRIBE YOURSELF',
                  hintStyle: GoogleFonts.jetBrainsMono(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: VedaColors.zinc800,
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
}

/// Interest tag chip
class _InterestTag extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _InterestTag({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_InterestTag> createState() => _InterestTagState();
}

class _InterestTagState extends State<_InterestTag> {
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? VedaColors.white
                : (_isHovered ? VedaColors.zinc900 : VedaColors.black),
            border: Border.all(color: VedaColors.white, width: 1),
          ),
          child: Text(
            widget.label,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: widget.isSelected ? VedaColors.black : VedaColors.white,
              letterSpacing: 2.0,
            ),
          ),
        ),
      ),
    );
  }
}

/// Learning goal option card
class _GoalOption extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GoalOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_GoalOption> createState() => _GoalOptionState();
}

class _GoalOptionState extends State<_GoalOption> {
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
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? VedaColors.white
                : (_isHovered ? VedaColors.zinc900 : VedaColors.black),
            border: Border.all(color: VedaColors.white, width: 1),
          ),
          child: Center(
            child: Text(
              widget.label,
              textAlign: TextAlign.center,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: widget.isSelected ? VedaColors.black : VedaColors.white,
                letterSpacing: 1.5,
                height: 1.4,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Submit button
class _SubmitButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;

  const _SubmitButton({
    required this.label,
    required this.onPressed,
  });

  @override
  State<_SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<_SubmitButton> {
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
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: _isHovered ? VedaColors.zinc900 : VedaColors.white,
            border: Border.all(color: VedaColors.white, width: 2),
          ),
          child: Center(
            child: Text(
              widget.label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: _isHovered ? VedaColors.white : VedaColors.black,
                letterSpacing: 3.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
