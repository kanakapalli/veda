import 'package:flutter/material.dart';
import 'veda_colors.dart';
import 'veda_spacing.dart';
import 'veda_text_styles.dart';
import 'widgets/veda_button.dart';
import 'widgets/veda_card.dart';
import 'widgets/veda_grid.dart';
import 'widgets/veda_input.dart';

/// Design system showcase demonstrating all Veda components.
///
/// Displays colors, typography, spacing, buttons, inputs, and cards
/// following the Neo-Minimalist design guidelines.
class DesignSystemScreen extends StatefulWidget {
  const DesignSystemScreen({super.key});

  @override
  State<DesignSystemScreen> createState() => _DesignSystemScreenState();
}

class _DesignSystemScreenState extends State<DesignSystemScreen> {
  bool _showGrid = true;
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VedaColors.black,
      appBar: AppBar(
        backgroundColor: VedaColors.black,
        elevation: 0,
        title: const Text(
          'Design System',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w300,
            color: VedaColors.white,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showGrid ? Icons.grid_on : Icons.grid_off,
              color: VedaColors.white,
            ),
            onPressed: () {
              setState(() => _showGrid = !_showGrid);
            },
          ),
        ],
      ),
      body: VedaGridBackground(
        showGrid: _showGrid,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: VedaSpacing.screenPaddingMobile,
              vertical: VedaSpacing.lg,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: VedaSpacing.maxContentWidth,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      title: 'Colors',
                      child: _buildColors(),
                    ),
                    const SizedBox(height: VedaSpacing.xxl),
                    _buildSection(
                      title: 'Typography',
                      child: _buildTypography(),
                    ),
                    const SizedBox(height: VedaSpacing.xxl),
                    _buildSection(
                      title: 'Spacing',
                      child: _buildSpacing(),
                    ),
                    const SizedBox(height: VedaSpacing.xxl),
                    _buildSection(
                      title: 'Buttons',
                      child: _buildButtons(),
                    ),
                    const SizedBox(height: VedaSpacing.xxl),
                    _buildSection(
                      title: 'Inputs',
                      child: _buildInputs(),
                    ),
                    const SizedBox(height: VedaSpacing.xxl),
                    _buildSection(
                      title: 'Cards',
                      child: _buildCards(),
                    ),
                    const SizedBox(height: VedaSpacing.xxl),
                    _buildSection(
                      title: 'Icons & Loading',
                      child: _buildIconsAndLoading(),
                    ),
                    const SizedBox(height: VedaSpacing.massive),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: VedaTextStyles.headlineMedium),
        const SizedBox(height: VedaSpacing.lg),
        const VedaDivider(),
        const SizedBox(height: VedaSpacing.lg),
        child,
      ],
    );
  }

  Widget _buildColors() {
    return Wrap(
      spacing: VedaSpacing.base,
      runSpacing: VedaSpacing.base,
      children: [
        _colorSwatch('Black', VedaColors.black, VedaColors.white),
        _colorSwatch('White', VedaColors.white, VedaColors.black),
        _colorSwatch('Accent', VedaColors.accent, VedaColors.white),
        _colorSwatch('Grey 500', VedaColors.grey500, VedaColors.black),
        _colorSwatch('Grey 700', VedaColors.grey700, VedaColors.white),
        _colorSwatch('Grey 800', VedaColors.grey800, VedaColors.white),
        _colorSwatch('Grey 900', VedaColors.grey900, VedaColors.white),
        _colorSwatch('Error', VedaColors.error, VedaColors.white),
      ],
    );
  }

  Widget _colorSwatch(String name, Color color, Color textColor) {
    return Container(
      width: 100,
      height: 80,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: VedaColors.grey800, width: 1),
      ),
      child: Center(
        child: Text(
          name,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: textColor,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildTypography() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Display Large', style: VedaTextStyles.displayLarge),
        const SizedBox(height: VedaSpacing.md),
        const Text('Headline Medium', style: VedaTextStyles.headlineMedium),
        const SizedBox(height: VedaSpacing.md),
        const Text('Headline Small', style: VedaTextStyles.headlineSmall),
        const SizedBox(height: VedaSpacing.md),
        const Text('Body Large', style: VedaTextStyles.bodyLarge),
        const SizedBox(height: VedaSpacing.md),
        const Text('Body Medium', style: VedaTextStyles.bodyMedium),
        const SizedBox(height: VedaSpacing.md),
        const Text('Body Small', style: VedaTextStyles.bodySmall),
        const SizedBox(height: VedaSpacing.md),
        const Text('Label Large', style: VedaTextStyles.labelLarge),
        const SizedBox(height: VedaSpacing.md),
        const Text('Label Medium', style: VedaTextStyles.labelMedium),
      ],
    );
  }

  Widget _buildSpacing() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _spacingExample('XS (4px)', VedaSpacing.xs),
        _spacingExample('SM (8px)', VedaSpacing.sm),
        _spacingExample('MD (12px)', VedaSpacing.md),
        _spacingExample('Base (16px)', VedaSpacing.base),
        _spacingExample('LG (24px)', VedaSpacing.lg),
        _spacingExample('XL (32px)', VedaSpacing.xl),
        _spacingExample('XXL (48px)', VedaSpacing.xxl),
        _spacingExample('XXXL (72px)', VedaSpacing.xxxl),
        _spacingExample('Huge (96px)', VedaSpacing.huge),
      ],
    );
  }

  Widget _spacingExample(String label, double size) {
    return Padding(
      padding: const EdgeInsets.only(bottom: VedaSpacing.sm),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(label, style: VedaTextStyles.bodyMedium),
          ),
          Container(
            width: size,
            height: VedaSpacing.lg,
            color: VedaColors.accent,
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        VedaButton(
          label: 'Primary Button',
          onPressed: () {},
        ),
        const SizedBox(height: VedaSpacing.base),
        VedaButton(
          label: 'With Icon',
          icon: Icons.arrow_forward,
          onPressed: () {},
        ),
        const SizedBox(height: VedaSpacing.base),
        const VedaButton(
          label: 'Disabled',
          onPressed: null,
        ),
        const SizedBox(height: VedaSpacing.base),
        const VedaButton(
          label: 'Loading',
          isLoading: true,
        ),
        const SizedBox(height: VedaSpacing.lg),
        VedaTextButton(
          label: 'Text Button',
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildInputs() {
    return Column(
      children: [
        VedaInput(
          label: 'Email',
          hint: 'Enter your email',
          controller: _textController,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: VedaSpacing.base),
        const VedaInput(
          label: 'Password',
          hint: 'Enter your password',
          obscureText: true,
        ),
        const SizedBox(height: VedaSpacing.base),
        const VedaInput(
          label: 'Message',
          hint: 'Enter your message',
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildCards() {
    return Column(
      children: [
        VedaCard(
          onTap: () {},
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Interactive Card', style: VedaTextStyles.labelLarge),
              const SizedBox(height: VedaSpacing.sm),
              const Text(
                'This card has hover effects and can be tapped.',
                style: VedaTextStyles.bodyLarge,
              ),
            ],
          ),
        ),
        const SizedBox(height: VedaSpacing.base),
        const VedaCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Static Card', style: VedaTextStyles.labelLarge),
              SizedBox(height: VedaSpacing.sm),
              Text(
                'This card has no interaction but maintains the visual style.',
                style: VedaTextStyles.bodyLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIconsAndLoading() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          children: [
            const Icon(Icons.check_circle_outline,
                size: 32, color: VedaColors.white),
            const SizedBox(height: VedaSpacing.sm),
            Text('Icon', style: VedaTextStyles.bodySmall),
          ],
        ),
        Column(
          children: [
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 1,
                valueColor: AlwaysStoppedAnimation(VedaColors.accent),
              ),
            ),
            const SizedBox(height: VedaSpacing.sm),
            Text('Loading', style: VedaTextStyles.bodySmall),
          ],
        ),
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                border: Border.all(color: VedaColors.grey800, width: 1),
              ),
              child: const Center(
                child: Icon(Icons.add, size: 18, color: VedaColors.white),
              ),
            ),
            const SizedBox(height: VedaSpacing.sm),
            Text('Outlined', style: VedaTextStyles.bodySmall),
          ],
        ),
      ],
    );
  }
}
