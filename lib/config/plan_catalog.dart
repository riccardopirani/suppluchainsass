/// SaaS plan tiers aligned with marketing (EUR / month, ex VAT).
/// Checkout uses `flatMonthlyCents` with quantity = 1 unless seats are added later.
enum SubscriptionPlanTier { starter, growth, pro, enterprise }

class PlanDefinition {
  const PlanDefinition({
    required this.tier,
    required this.marketingName,
    required this.flatMonthlyCents,
    required this.annualDiscountPercent,
    required this.maxPlants,
    required this.maxMachines,
    required this.includesAiAlerts,
    required this.includesSupplierIntel,
    required this.includesInventoryAutomation,
    required this.includesApi,
    required this.includesSso,
    required this.includesWhiteLabel,
  });

  final SubscriptionPlanTier tier;
  final String marketingName;
  final int flatMonthlyCents;
  final int annualDiscountPercent;
  final int maxPlants;
  final int? maxMachines;
  final bool includesAiAlerts;
  final bool includesSupplierIntel;
  final bool includesInventoryAutomation;
  final bool includesApi;
  final bool includesSso;
  final bool includesWhiteLabel;

  double get monthlyEuros => flatMonthlyCents / 100.0;

  int get annualMonthlyEquivalentCents =>
      (flatMonthlyCents * (100 - annualDiscountPercent) / 100).round();
}

class PlanCatalog {
  PlanCatalog._();

  static const PlanDefinition starter = PlanDefinition(
    tier: SubscriptionPlanTier.starter,
    marketingName: 'Starter',
    flatMonthlyCents: 29900,
    annualDiscountPercent: 17,
    maxPlants: 1,
    maxMachines: 10,
    includesAiAlerts: false,
    includesSupplierIntel: false,
    includesInventoryAutomation: false,
    includesApi: false,
    includesSso: false,
    includesWhiteLabel: false,
  );

  static const PlanDefinition growth = PlanDefinition(
    tier: SubscriptionPlanTier.growth,
    marketingName: 'Growth',
    flatMonthlyCents: 79900,
    annualDiscountPercent: 17,
    maxPlants: 1,
    maxMachines: null,
    includesAiAlerts: true,
    includesSupplierIntel: true,
    includesInventoryAutomation: true,
    includesApi: false,
    includesSso: false,
    includesWhiteLabel: false,
  );

  static const PlanDefinition pro = PlanDefinition(
    tier: SubscriptionPlanTier.pro,
    marketingName: 'Pro',
    flatMonthlyCents: 149900,
    annualDiscountPercent: 17,
    maxPlants: 8,
    maxMachines: null,
    includesAiAlerts: true,
    includesSupplierIntel: true,
    includesInventoryAutomation: true,
    includesApi: false,
    includesSso: false,
    includesWhiteLabel: false,
  );

  /// Floor price for enterprise; sales-led.
  static const PlanDefinition enterprise = PlanDefinition(
    tier: SubscriptionPlanTier.enterprise,
    marketingName: 'Enterprise',
    flatMonthlyCents: 199900,
    annualDiscountPercent: 20,
    maxPlants: 999,
    maxMachines: null,
    includesAiAlerts: true,
    includesSupplierIntel: true,
    includesInventoryAutomation: true,
    includesApi: true,
    includesSso: true,
    includesWhiteLabel: true,
  );

  static PlanDefinition byTier(SubscriptionPlanTier tier) => switch (tier) {
        SubscriptionPlanTier.starter => starter,
        SubscriptionPlanTier.growth => growth,
        SubscriptionPlanTier.pro => pro,
        SubscriptionPlanTier.enterprise => enterprise,
      };

  static SubscriptionPlanTier? tryParseTier(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final s = raw.toLowerCase().trim();
    if (s.contains('enterprise')) return SubscriptionPlanTier.enterprise;
    if (s == 'pro' || s.contains('professional')) {
      return SubscriptionPlanTier.pro;
    }
    if (s.contains('growth')) return SubscriptionPlanTier.growth;
    if (s.contains('starter') || s.contains('basic')) {
      return SubscriptionPlanTier.starter;
    }
    return null;
  }
}

/// Feature flags for upgrade prompts (UI-only; enforce in backend for production).
class SubscriptionEntitlements {
  const SubscriptionEntitlements({required this.tier});

  final SubscriptionPlanTier tier;

  bool get canUseAiCopilot => tier != SubscriptionPlanTier.starter;
  bool get canUseAutoActions => tier != SubscriptionPlanTier.starter;
  bool get canUseExecutiveReport => true;
  bool get canUseAdvancedSimulation =>
      tier == SubscriptionPlanTier.growth ||
      tier == SubscriptionPlanTier.pro ||
      tier == SubscriptionPlanTier.enterprise;
  bool get canUseApi => tier == SubscriptionPlanTier.enterprise;
  bool get canUseMultiPlant =>
      tier == SubscriptionPlanTier.pro || tier == SubscriptionPlanTier.enterprise;
}
