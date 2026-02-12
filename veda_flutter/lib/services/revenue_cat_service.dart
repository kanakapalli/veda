import 'dart:async';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:veda_client/veda_client.dart' as veda;

import '../main.dart' show client;

/// Centralized service for managing RevenueCat subscriptions, entitlements,
/// and customer info across the Veda app.
///
/// Usage:
///   await RevenueCatService.instance.initialize();
///   final isPro = RevenueCatService.instance.isProUser;
class RevenueCatService {
  RevenueCatService._();
  static final RevenueCatService instance = RevenueCatService._();

  // ---------------------------------------------------------------------------
  // Configuration
  // ---------------------------------------------------------------------------

  /// RevenueCat public API key.
  static const String _apiKey = 'test_BztqgHOxgafXCMWIcQtQLmXmryA';

  /// The entitlement identifier configured in the RevenueCat dashboard.
  static const String entitlementId = 'veda Pro';

  /// Product identifiers for each subscription tier.
  static const String monthlyProductId = 'monthly';
  static const String yearlyProductId = 'yearly';
  static const String sixMonthProductId = 'six_month';

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  /// The latest customer info from RevenueCat.
  CustomerInfo? _customerInfo;
  CustomerInfo? get customerInfo => _customerInfo;

  /// Whether the SDK has been initialised.
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Stream controller that broadcasts subscription‐status changes.
  final _statusController = StreamController<bool>.broadcast();

  /// A stream that emits `true` when the user becomes a Pro subscriber,
  /// and `false` when they lose access.
  Stream<bool> get onSubscriptionStatusChanged => _statusController.stream;

  // ---------------------------------------------------------------------------
  // Derived getters
  // ---------------------------------------------------------------------------

  /// Whether the current user has an active "veda Pro" entitlement.
  bool get isProUser {
    return _customerInfo?.entitlements.all[entitlementId]?.isActive ?? false;
  }

  /// The active entitlements map (handy for debugging).
  Map<String, EntitlementInfo> get activeEntitlements {
    return _customerInfo?.entitlements.active ?? {};
  }

  /// The current subscription plan name, or `null` if none.
  String? get currentPlanName {
    final entitlement = _customerInfo?.entitlements.all[entitlementId];
    if (entitlement == null || !entitlement.isActive) return null;
    final productId = entitlement.productIdentifier;
    if (productId.contains('yearly') || productId == yearlyProductId) {
      return 'Yearly';
    }
    if (productId.contains('six_month') || productId == sixMonthProductId) {
      return 'Six Month';
    }
    return 'Monthly';
  }

  /// The expiration date for the active subscription, if available.
  DateTime? get expirationDate {
    final entitlement = _customerInfo?.entitlements.all[entitlementId];
    if (entitlement == null || !entitlement.isActive) return null;
    final raw = entitlement.expirationDate;
    return raw != null ? DateTime.tryParse(raw) : null;
  }

  /// Whether the subscription will auto-renew at the end of the period.
  bool get willRenew {
    final entitlement = _customerInfo?.entitlements.all[entitlementId];
    if (entitlement == null || !entitlement.isActive) return false;
    return entitlement.willRenew;
  }

  // ---------------------------------------------------------------------------
  // Initialisation
  // ---------------------------------------------------------------------------

  /// Call once at app start (e.g. inside `main()`).
  Future<void> initialize({String? appUserId}) async {
    if (_isInitialized) return;

    try {
      // Enable verbose logging in debug builds.
      await Purchases.setLogLevel(LogLevel.debug);

      final configuration = PurchasesConfiguration(_apiKey);
      if (appUserId != null) {
        configuration.appUserID = appUserId;
      }

      await Purchases.configure(configuration);

      // Listen for customer info updates pushed by the SDK.
      Purchases.addCustomerInfoUpdateListener(_onCustomerInfoUpdated);

      // Fetch the initial customer info.
      _customerInfo = await Purchases.getCustomerInfo();
      _isInitialized = true;

      log('[RevenueCat] Initialized — Pro: $isProUser');
    } catch (e) {
      log('[RevenueCat] Initialization error: $e');
      // Don't rethrow — the app can still function without subscriptions.
    }
  }

  // ---------------------------------------------------------------------------
  // User identification
  // ---------------------------------------------------------------------------

  /// Log in a known user so purchases are tied to their account.
  Future<void> logIn(String appUserId) async {
    try {
      final result = await Purchases.logIn(appUserId);
      _customerInfo = result.customerInfo;
      _statusController.add(isProUser);
      log('[RevenueCat] Logged in as $appUserId — Pro: $isProUser');
    } catch (e) {
      log('[RevenueCat] Login error: $e');
    }
  }

  /// Log out (reverts to an anonymous user).
  Future<void> logOut() async {
    try {
      _customerInfo = await Purchases.logOut();
      _statusController.add(isProUser);
      log('[RevenueCat] Logged out — Pro: $isProUser');
    } catch (e) {
      log('[RevenueCat] Logout error: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Offerings & Products
  // ---------------------------------------------------------------------------

  /// Fetch the current offerings configured in RevenueCat.
  Future<Offerings?> getOfferings() async {
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      log('[RevenueCat] Error fetching offerings: $e');
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Purchases
  // ---------------------------------------------------------------------------

  /// Purchase a specific package (from an Offering).
  Future<bool> purchasePackage(Package package) async {
    try {
      final result = await Purchases.purchasePackage(package);
      _customerInfo = result.customerInfo;
      _statusController.add(isProUser);
      log('[RevenueCat] Purchase successful — Pro: $isProUser');
      return isProUser;
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        log('[RevenueCat] Purchase cancelled by user');
      } else {
        log('[RevenueCat] Purchase error: $errorCode — ${e.message}');
      }
      return false;
    }
  }

  /// Restore previous purchases.
  Future<bool> restorePurchases() async {
    try {
      _customerInfo = await Purchases.restorePurchases();
      _statusController.add(isProUser);
      log('[RevenueCat] Restore successful — Pro: $isProUser');
      return isProUser;
    } catch (e) {
      log('[RevenueCat] Restore error: $e');
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Paywalls (RevenueCatUI)
  // ---------------------------------------------------------------------------

  /// Present the RevenueCat‐hosted paywall.
  /// Returns the [PaywallResult] so callers can react to the outcome.
  Future<PaywallResult> presentPaywall() async {
    try {
      final result = await RevenueCatUI.presentPaywall();
      log('[RevenueCat] Paywall result: $result');
      // Refresh customer info after paywall interaction.
      await refreshCustomerInfo();
      return result;
    } catch (e) {
      log('[RevenueCat] Paywall error: $e');
      return PaywallResult.error;
    }
  }

  /// Present the paywall only if the user does NOT already have the
  /// given entitlement.
  Future<PaywallResult> presentPaywallIfNeeded() async {
    try {
      final result =
          await RevenueCatUI.presentPaywallIfNeeded(entitlementId);
      log('[RevenueCat] PaywallIfNeeded result: $result');
      await refreshCustomerInfo();
      return result;
    } catch (e) {
      log('[RevenueCat] PaywallIfNeeded error: $e');
      return PaywallResult.error;
    }
  }

  // ---------------------------------------------------------------------------
  // Customer Center (RevenueCatUI)
  // ---------------------------------------------------------------------------

  /// Present the RevenueCat Customer Center for managing subscriptions.
  Future<void> presentCustomerCenter() async {
    try {
      await RevenueCatUI.presentCustomerCenter();
      // Refresh after the user might have changed their subscription.
      await refreshCustomerInfo();
    } catch (e) {
      log('[RevenueCat] Customer Center error: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Customer Info
  // ---------------------------------------------------------------------------

  /// Force-refresh the cached customer info from RevenueCat.
  Future<CustomerInfo?> refreshCustomerInfo() async {
    try {
      _customerInfo = await Purchases.getCustomerInfo();
      _statusController.add(isProUser);
      // Sync the latest state to the Veda server.
      syncSubscriptionToServer();
      return _customerInfo;
    } catch (e) {
      log('[RevenueCat] Error refreshing customer info: $e');
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Server Sync
  // ---------------------------------------------------------------------------

  /// Pushes the current RevenueCat subscription state to the Veda server
  /// so it is persisted on the user profile.
  Future<void> syncSubscriptionToServer() async {
    try {
      final entitlement = _customerInfo?.entitlements.all[entitlementId];

      veda.SubscriptionStatus status;
      String? plan;
      DateTime? expiryDate;
      String? productId;

      if (entitlement != null && entitlement.isActive) {
        status = entitlement.willRenew
            ? veda.SubscriptionStatus.active
            : veda.SubscriptionStatus.cancelling;
        plan = currentPlanName;
        productId = entitlement.productIdentifier;
        final raw = entitlement.expirationDate;
        expiryDate = raw != null ? DateTime.tryParse(raw) : null;
      } else {
        // Check if there was a subscription that expired.
        final latestExpiry = entitlement?.expirationDate;
        if (latestExpiry != null) {
          status = veda.SubscriptionStatus.expired;
          expiryDate = DateTime.tryParse(latestExpiry);
        } else {
          status = veda.SubscriptionStatus.none;
        }
      }

      await client.vedaUserProfile.updateSubscriptionStatus(
        status: status,
        plan: plan,
        expiryDate: expiryDate,
        productId: productId,
      );

      log('[RevenueCat] Subscription synced to server — status: $status');
    } catch (e) {
      log('[RevenueCat] Failed to sync subscription to server: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Internal
  // ---------------------------------------------------------------------------

  void _onCustomerInfoUpdated(CustomerInfo info) {
    _customerInfo = info;
    _statusController.add(isProUser);
    log('[RevenueCat] Customer info updated — Pro: $isProUser');
    // Sync to server in the background.
    syncSubscriptionToServer();
  }

  /// Clean up (usually not needed, but here for completeness).
  void dispose() {
    _statusController.close();
  }
}
