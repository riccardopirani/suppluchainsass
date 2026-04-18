import 'dart:async';

import 'package:fabricos/config/iap_product_ids.dart';
import 'package:fabricos/config/plan_catalog.dart';
import 'package:fabricos/features/app_shell/providers/fabricos_provider.dart';
import 'package:fabricos/features/billing/data/mobile_billing_platform.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

SubscriptionPlanTier? _tierFromStoreProductId(String productId) {
  if (productId.contains('.starter.')) return SubscriptionPlanTier.starter;
  if (productId.contains('.growth.')) return SubscriptionPlanTier.growth;
  if (productId.contains('.pro.')) return SubscriptionPlanTier.pro;
  return null;
}

/// Orchestrates StoreKit / Play Billing and registers purchases with Supabase.
class FabricIapCoordinator {
  FabricIapCoordinator(this._ref) {
    if (!kUseMobileStoreBilling) return;
    _subscription = InAppPurchase.instance.purchaseStream.listen(
      _onPurchases,
      onError: (Object e, _) => onError?.call('$e'),
    );
  }

  final Ref _ref;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  void Function(String? message)? onError;
  void Function()? onSuccess;
  void Function()? onCanceled;

  String? _pendingCompanyId;
  String? _pendingPlanKey;
  String? _pendingProductId;

  Future<void> startPurchase({
    required String companyId,
    required SubscriptionPlanTier tier,
    required bool annual,
  }) async {
    if (!kUseMobileStoreBilling) return;
    final iap = InAppPurchase.instance;
    if (!(await iap.isAvailable())) {
      onError?.call('Store not available');
      return;
    }
    final productId = IapProductIds.productIdFor(tier: tier, annual: annual);
    if (productId.isEmpty) {
      onError?.call('Plan not available in app store');
      return;
    }
    _pendingCompanyId = companyId;
    _pendingPlanKey = tier.name;
    _pendingProductId = productId;

    final response = await iap.queryProductDetails({productId});
    if (response.error != null) {
      _clearPending();
      onError?.call(response.error!.message);
      return;
    }
    if (response.productDetails.isEmpty) {
      _clearPending();
      onError?.call(
        'Product "$productId" not found. Add this subscription in App Store Connect / Play Console.',
      );
      return;
    }

    final param = PurchaseParam(productDetails: response.productDetails.first);
    try {
      await iap.buyNonConsumable(purchaseParam: param);
    } catch (e) {
      _clearPending();
      onError?.call('$e');
    }
  }

  Future<void> restorePurchases() async {
    if (!kUseMobileStoreBilling) return;
    try {
      await InAppPurchase.instance.restorePurchases();
    } catch (e) {
      onError?.call('$e');
    }
  }

  void _clearPending() {
    _pendingCompanyId = null;
    _pendingPlanKey = null;
    _pendingProductId = null;
  }

  Future<void> _onPurchases(List<PurchaseDetails> purchases) async {
    final companyId = _pendingCompanyId;
    final plan = _pendingPlanKey;
    final expectedProduct = _pendingProductId;

    for (final p in purchases) {
      if (p.status == PurchaseStatus.pending) continue;

      if (p.status == PurchaseStatus.error) {
        onError?.call(p.error?.message ?? 'Purchase error');
        _clearPending();
        continue;
      }

      if (p.status == PurchaseStatus.canceled) {
        onCanceled?.call();
        _clearPending();
        continue;
      }

      if (p.status != PurchaseStatus.purchased && p.status != PurchaseStatus.restored) {
        continue;
      }

      if (expectedProduct != null && p.productID != expectedProduct) {
        continue;
      }

      final asyncCompany = _ref.read(currentCompanyIdProvider);
      final cid = companyId ?? asyncCompany.valueOrNull;
      final tier = _tierFromStoreProductId(p.productID);
      final planKey = plan ?? tier?.name;

      if (cid == null || planKey == null) {
        if (p.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(p);
        }
        continue;
      }

      try {
        final src = p.verificationData.source.toString();
        final platform = src.toLowerCase().contains('android') ? 'android' : 'ios';
        await _ref.read(fabricosRepositoryProvider).registerMobilePurchase(
              companyId: cid,
              plan: planKey,
              platform: platform,
              productId: p.productID,
              purchaseId: p.purchaseID ?? '${p.productID}_${p.transactionDate}',
              verificationData: p.verificationData.serverVerificationData,
            );
        if (p.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(p);
        }
        _clearPending();
        onSuccess?.call();
      } catch (e) {
        onError?.call('$e');
      }
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}

final fabricIapCoordinatorProvider = Provider<FabricIapCoordinator>((ref) {
  final c = FabricIapCoordinator(ref);
  ref.onDispose(c.dispose);
  return c;
});
