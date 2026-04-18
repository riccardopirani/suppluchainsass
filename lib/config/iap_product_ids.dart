import 'package:fabricos/config/plan_catalog.dart';

/// Store product IDs — create **auto-renewable subscriptions** with these IDs in
/// App Store Connect and Google Play Console (must match exactly).
abstract final class IapProductIds {
  static String productIdFor({required SubscriptionPlanTier tier, required bool annual}) {
    if (tier == SubscriptionPlanTier.enterprise) return '';
    final suffix = annual ? 'annual' : 'monthly';
    return switch (tier) {
      SubscriptionPlanTier.starter => 'com.fabricos.plan.starter.$suffix',
      SubscriptionPlanTier.growth => 'com.fabricos.plan.growth.$suffix',
      SubscriptionPlanTier.pro => 'com.fabricos.plan.pro.$suffix',
      SubscriptionPlanTier.enterprise => '',
    };
  }
}
