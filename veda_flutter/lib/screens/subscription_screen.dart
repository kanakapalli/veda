import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../design_system/veda_colors.dart';
import '../services/revenue_cat_service.dart';

/// A full-screen subscription management page that:
///   • Shows the user's current plan (or "Free" if no subscription).
///   • Displays the available RevenueCat offerings / packages.
///   • Lets the user purchase or restore purchases.
///
/// For the recommended approach, use [RevenueCatService.instance.presentPaywall]
/// or [presentPaywallIfNeeded] which shows the remotely-configured RevenueCat
/// paywall. This screen serves as a fallback / custom paywall.
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

  StreamSubscription<bool>? _statusSub;

  @override
  void initState() {
    super.initState();
    _loadOfferings();
    // Listen for subscription changes while this screen is open.
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
          _errorMessage =
              'No offerings are currently available. Please try again later.';
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
          const SnackBar(
            content: Text('Welcome to Veda Pro!'),
            backgroundColor: VedaColors.white,
          ),
        );
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
                ? 'Purchases restored! Welcome back.'
                : 'No previous purchases found.',
          ),
          backgroundColor: VedaColors.white,
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VedaColors.black,
      appBar: AppBar(
        backgroundColor: VedaColors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: VedaColors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'SUBSCRIPTION',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: VedaColors.white,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: VedaColors.white),
            )
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current status
          _buildCurrentPlanCard(),
          const SizedBox(height: 32),

          // Error
          if (_errorMessage != null) ...[
            Text(
              _errorMessage!,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: VedaColors.error,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Available plans
          if (_offerings?.current != null) ...[
            Text(
              'CHOOSE A PLAN',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: VedaColors.zinc500,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            ..._offerings!.current!.availablePackages
                .map((pkg) => _buildPackageCard(pkg)),
          ],

          const SizedBox(height: 24),

          // Restore purchases
          Center(
            child: TextButton(
              onPressed: _isPurchasing ? null : _restore,
              child: Text(
                'Restore Purchases',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: VedaColors.accent,
                  decoration: TextDecoration.underline,
                  decorationColor: VedaColors.accent,
                ),
              ),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Widgets
  // ---------------------------------------------------------------------------

  Widget _buildCurrentPlanCard() {
    final isPro = _rc.isProUser;
    final planName = _rc.currentPlanName ?? 'FREE';
    final expiry = _rc.expirationDate;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(
          color: isPro ? VedaColors.white : VedaColors.zinc700,
          width: isPro ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            color: isPro ? VedaColors.white : VedaColors.zinc800,
            child: Text(
              isPro ? 'ACTIVE PLAN' : 'CURRENT PLAN',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: isPro ? VedaColors.black : VedaColors.zinc500,
                letterSpacing: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isPro ? 'VEDA PRO — $planName' : 'FREE',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: VedaColors.white,
              letterSpacing: -0.3,
            ),
          ),
          if (isPro && expiry != null) ...[
            const SizedBox(height: 16),
            Container(height: 1, color: VedaColors.zinc800),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'RENEWS ON',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    color: VedaColors.zinc500,
                    letterSpacing: 1.0,
                  ),
                ),
                Text(
                  _formatDate(expiry),
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: VedaColors.white,
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

  Widget _buildPackageCard(Package package) {
    final product = package.storeProduct;
    final isCurrentPlan = _rc.isProUser &&
        _rc.customerInfo?.entitlements.all[RevenueCatService.entitlementId]
                ?.productIdentifier ==
            product.identifier;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: (_isPurchasing || isCurrentPlan)
            ? null
            : () => _purchase(package),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(
              color: isCurrentPlan ? VedaColors.accent : VedaColors.zinc700,
              width: isCurrentPlan ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: VedaColors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (product.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        product.description,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: VedaColors.zinc500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
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
                    _periodLabel(package.packageType),
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
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
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _periodLabel(PackageType type) {
    switch (type) {
      case PackageType.monthly:
        return '/ MONTH';
      case PackageType.annual:
        return '/ YEAR';
      case PackageType.sixMonth:
        return '/ 6 MONTHS';
      case PackageType.threeMonth:
        return '/ 3 MONTHS';
      case PackageType.weekly:
        return '/ WEEK';
      case PackageType.lifetime:
        return 'LIFETIME';
      default:
        return '';
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', //
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
