import 'package:fabricos/config/plan_catalog.dart';

/// Store product IDs — create **auto-renewable subscriptions** with these IDs in
/// App Store Connect / Play Console (optional; web uses Stripe).
abstract final class IapProductIds {
  static String productIdFor({required SubscriptionPlanTier tier, required bool annual}) {
    final suffix = annual ? 'annual' : 'month';
    return switch (tier) {
      SubscriptionPlanTier.essenziale => 'com.fabricos.plan.essenziale.$suffix',
      SubscriptionPlanTier.professionale => 'com.fabricos.plan.professionale.$suffix',
      SubscriptionPlanTier.industriale => 'com.fabricos.plan.industriale.$suffix',
    };
  }
}
