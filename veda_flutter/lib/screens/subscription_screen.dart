import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../design_system/veda_colors.dart';
import '../services/revenue_cat_service.dart';

/// Full-screen subscription management screen.
///
/// Shows the user's current plan, available offerings, and lets them
/// purchase, restore, or manage their subscription — all in the Veda
/// stark-minimalist design language.
class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final _rc = RevenueCatService.instance;

  bool _isLoading = true;
  bool _isPurchasing = false;
  Offerings? _offerings;
  String? _errorMessage;
  int? _selectedPackageIndex;

  StreamSubscription<bool>? _statusSub;

  @override
  void initState() {
    super.initState();
    _loadOfferings();
    _statusSub = _rc.onSubscriptionStatusChanged.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _statusSub?.cancel();
    super.dispose();
  }

  Future<void> _loadOfferings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final offerings = await _rc.getOfferings();

    if (mounted) {
      setState(() {
        _offerings = offerings;
        _isLoading = false;
        if (offerings?.current == null) {
          _errorMessage = 'No plans available right now. Try again later.';
        }
      });
    }
  }

  Future<void> _purchase(Package package) async {
    setState(() => _isPurchasing = true);
    final success = await _rc.purchasePackage(package);
    if (mounted) {
      setState(() => _isPurchasing = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'WELCOME TO VEDA PRO',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: VedaColors.black,
                letterSpacing: 1.5,
              ),
            ),
            backgroundColor: VedaColors.white,
          ),
        );
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) Navigator.of(context).pop();
        });
      }
    }
  }

  Future<void> _restore() async {
    setState(() => _isPurchasing = true);
    final success = await _rc.restorePurchases();
    if (mounted) {
      setState(() => _isPurchasing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'PURCHASES RESTORED — WELCOME BACK'
                : 'NO PREVIOUS PURCHASES FOUND',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: VedaColors.black,
              letterSpacing: 1.0,
            ),
          ),
          backgroundColor: VedaColors.white,
        ),
      );
      if (success) {
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) Navigator.of(context).pop();
        });
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VedaColors.black,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: VedaColors.white,
                  strokeWidth: 1,
                ),
              )
            : _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    final isPro = _rc.isProUser;

    return Column(
      children: [
        // ── Top bar ─────────────────────────────────────────────────────
        _buildTopBar(),

        // ── Scrollable content ──────────────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero
                _buildHeroSection(isPro),
                const SizedBox(height: 40),

                // Features
                if (!isPro) ...[
                  _buildFeaturesSection(),
                  const SizedBox(height: 40),
                ],

                // Current plan (if pro)
                if (isPro) ...[
                  _buildCurrentPlanCard(),
                  const SizedBox(height: 40),
                ],

                // Error
                if (_errorMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: VedaColors.error, width: 1),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        color: VedaColors.error,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Plans
                if (!isPro && _offerings?.current != null) ...[
                  _sectionLabel('CHOOSE YOUR PLAN'),
                  const SizedBox(height: 20),
                  _buildPlansList(),
                  const SizedBox(height: 24),

                  // Subscribe button
                  _buildSubscribeButton(),
                  const SizedBox(height: 24),

                  // Restore
                  _buildRestoreRow(),
                ],

                // Manage (if pro)
                if (isPro) ...[
                  _buildManageButton(),
                ],

                const SizedBox(height: 48),

                // Legal
                Text(
                  'Subscriptions will be charged to your payment method. '
                  'They automatically renew unless cancelled at least '
                  '24 hours before the end of the current period.',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: VedaColors.zinc700,
                    height: 1.6,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Sections
  // ---------------------------------------------------------------------------

  Widget _buildTopBar() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: VedaColors.zinc800, width: 1),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              child: const Icon(
                Icons.arrow_back,
                color: VedaColors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'SUBSCRIPTION',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: VedaColors.white,
              letterSpacing: 2.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(bool isPro) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo mark
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            border: Border.all(color: VedaColors.white, width: 2),
          ),
          alignment: Alignment.center,
          child: Text(
            'V',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: VedaColors.white,
              height: 1.0,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          isPro ? 'VEDA PRO' : 'UPGRADE TO\nVEDA PRO',
          style: GoogleFonts.inter(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: VedaColors.white,
            letterSpacing: -1.0,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          isPro
              ? 'You have full access to all courses, coaches, and premium content.'
              : 'Unlock unlimited access to all courses, expert coaches, and premium learning paths.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: VedaColors.zinc500,
            height: 1.5,
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesSection() {
    const features = [
      ('UNLIMITED COURSES', 'Access every course in the Veda library'),
      ('EXPERT COACHES', 'Learn from industry professionals'),
      ('OFFLINE ACCESS', 'Download content for learning anywhere'),
      ('PRIORITY SUPPORT', 'Get help when you need it'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('WHAT YOU GET'),
        const SizedBox(height: 16),
        ...features.map((f) => _buildFeatureRow(f.$1, f.$2)),
      ],
    );
  }

  Widget _buildFeatureRow(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(top: 1),
            decoration: BoxDecoration(
              border: Border.all(color: VedaColors.white, width: 1),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.check,
              size: 12,
              color: VedaColors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: VedaColors.white,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: VedaColors.zinc500,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPlanCard() {
    final planName = _rc.currentPlanName ?? 'Pro';
    final expiry = _rc.expirationDate;
    final willRenew = _rc.willRenew;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: VedaColors.white, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            color: VedaColors.white,
            child: Text(
              'ACTIVE PLAN',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: VedaColors.black,
                letterSpacing: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'VEDA PRO — ${planName.toUpperCase()}',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: VedaColors.white,
              letterSpacing: -0.3,
            ),
          ),
          if (expiry != null) ...[
            const SizedBox(height: 20),
            Container(height: 1, color: VedaColors.zinc800),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: willRenew
                            ? const Color(0xFF4ADE80)
                            : const Color(0xFFFBBF24),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      willRenew ? 'ACTIVE' : 'CANCELLING',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: VedaColors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${willRenew ? "RENEWS" : "EXPIRES"} ${_formatDate(expiry)}',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    color: VedaColors.zinc500,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlansList() {
    final packages = _offerings!.current!.availablePackages;

    return Column(
      children: List.generate(packages.length, (i) {
        final pkg = packages[i];
        final product = pkg.storeProduct;
        final isSelected = _selectedPackageIndex == i;
        final isPopular = pkg.packageType == PackageType.annual;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: _isPurchasing
                ? null
                : () => setState(() => _selectedPackageIndex = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isSelected ? VedaColors.zinc900 : Colors.transparent,
                border: Border.all(
                  color: isSelected ? VedaColors.white : VedaColors.zinc700,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  // Selection indicator
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? VedaColors.white
                            : VedaColors.zinc600,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: isSelected
                        ? Center(
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: VedaColors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),

                  // Plan details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _planDisplayName(pkg.packageType),
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: VedaColors.white,
                                letterSpacing: -0.2,
                              ),
                            ),
                            if (isPopular) ...[
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                color: VedaColors.accent,
                                child: Text(
                                  'BEST VALUE',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w700,
                                    color: VedaColors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (product.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            product.description,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: VedaColors.zinc500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        product.priceString,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: VedaColors.white,
                        ),
                      ),
                      Text(
                        _periodLabel(pkg.packageType),
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 9,
                          color: VedaColors.zinc500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSubscribeButton() {
    final packages = _offerings?.current?.availablePackages;
    final canPurchase =
        packages != null && _selectedPackageIndex != null && !_isPurchasing;

    return GestureDetector(
      onTap: canPurchase
          ? () => _purchase(packages[_selectedPackageIndex!])
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: canPurchase ? VedaColors.white : VedaColors.zinc800,
          border: Border.all(
            color: canPurchase ? VedaColors.white : VedaColors.zinc700,
            width: canPurchase ? 2 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: _isPurchasing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: VedaColors.black,
                ),
              )
            : Text(
                _selectedPackageIndex != null
                    ? 'SUBSCRIBE NOW'
                    : 'SELECT A PLAN',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: canPurchase ? VedaColors.black : VedaColors.zinc600,
                  letterSpacing: 2.5,
                ),
              ),
      ),
    );
  }

  Widget _buildRestoreRow() {
    return Center(
      child: GestureDetector(
        onTap: _isPurchasing ? null : _restore,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'RESTORE PURCHASES',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              color: VedaColors.zinc500,
              letterSpacing: 1.5,
              decoration: TextDecoration.underline,
              decorationColor: VedaColors.zinc500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildManageButton() {
    return GestureDetector(
      onTap: () => _rc.presentCustomerCenter(),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          border: Border.all(color: VedaColors.zinc700, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.settings_outlined,
              size: 18,
              color: VedaColors.zinc500,
            ),
            const SizedBox(width: 12),
            Text(
              'MANAGE SUBSCRIPTION',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: VedaColors.zinc500,
                letterSpacing: 3.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.jetBrainsMono(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        color: VedaColors.zinc500,
        letterSpacing: 3.0,
      ),
    );
  }

  String _planDisplayName(PackageType type) {
    switch (type) {
      case PackageType.monthly:
        return 'Monthly';
      case PackageType.annual:
        return 'Yearly';
      case PackageType.sixMonth:
        return 'Six Months';
      case PackageType.threeMonth:
        return 'Three Months';
      case PackageType.weekly:
        return 'Weekly';
      case PackageType.lifetime:
        return 'Lifetime';
      default:
        return 'Plan';
    }
  }

  String _periodLabel(PackageType type) {
    switch (type) {
      case PackageType.monthly:
        return '/ MONTH';
      case PackageType.annual:
        return '/ YEAR';
      case PackageType.sixMonth:
        return '/ 6 MO';
      case PackageType.threeMonth:
        return '/ 3 MO';
      case PackageType.weekly:
        return '/ WEEK';
      case PackageType.lifetime:
        return 'FOREVER';
      default:
        return '';
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
