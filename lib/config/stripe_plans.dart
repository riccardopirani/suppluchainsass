import 'package:fabricos/config/plan_catalog.dart';

/// Flat plan checkout: `quantity` is always 1 in Stripe; amount is monthly or yearly total.
abstract final class PlanCheckoutPricing {
  static int unitAmountCents(SubscriptionPlanTier tier, {required bool annual}) {
    final d = PlanCatalog.byTier(tier);
    return annual ? d.annualTotalCents : d.flatMonthlyCents;
  }
}
