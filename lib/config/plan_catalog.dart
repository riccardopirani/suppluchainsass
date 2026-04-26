/// Three commercial tiers (EUR / month ex VAT). Yearly = 12× monthly (no extra discount).
enum SubscriptionPlanTier { essenziale, professionale, industriale }

class PlanDefinition {
  const PlanDefinition({
    required this.tier,
    required this.planKey,
    required this.marketingName,
    required this.tagline,
    required this.flatMonthlyCents,
    required this.annualTotalCents,
    required this.maxPlants,
    required this.maxUsers,
    required this.includesPredictiveAi,
    required this.includesWhatIf,
    required this.includesEsgCompliance,
    required this.includesCopilot,
    required this.includesApiErp,
    required this.includesAutoReplenishmentFull,
    required this.includesWhiteLabelSla,
  });

  final SubscriptionPlanTier tier;
  /// Stored in `companies.selected_plan` and Stripe metadata.
  final String planKey;
  final String marketingName;
  final String tagline;
  final int flatMonthlyCents;
  final int annualTotalCents;
  final int maxPlants;
  /// `null` = unlimited (display only; enforce in product as needed).
  final int? maxUsers;
  final bool includesPredictiveAi;
  final bool includesWhatIf;
  final bool includesEsgCompliance;
  final bool includesCopilot;
  final bool includesApiErp;
  final bool includesAutoReplenishmentFull;
  final bool includesWhiteLabelSla;

  double get monthlyEuros => flatMonthlyCents / 100.0;
  double get annualEuros => annualTotalCents / 100.0;
}

class PlanCatalog {
  PlanCatalog._();

  /// UI order for plan pickers (matches enum declaration order).
  static const List<SubscriptionPlanTier> orderedTiers = [
    SubscriptionPlanTier.essenziale,
    SubscriptionPlanTier.professionale,
    SubscriptionPlanTier.industriale,
  ];

  static const PlanDefinition essenziale = PlanDefinition(
    tier: SubscriptionPlanTier.essenziale,
    planKey: 'essenziale',
    marketingName: 'Essenziale',
    tagline: 'Ingresso — 1 stabilimento, operazioni core senza complessità.',
    flatMonthlyCents: 79000,
    annualTotalCents: 948000,
    maxPlants: 1,
    maxUsers: null,
    includesPredictiveAi: false,
    includesWhatIf: false,
    includesEsgCompliance: false,
    includesCopilot: false,
    includesApiErp: false,
    includesAutoReplenishmentFull: false,
    includesWhiteLabelSla: false,
  );

  static const PlanDefinition professionale = PlanDefinition(
    tier: SubscriptionPlanTier.professionale,
    planKey: 'professionale',
    marketingName: 'Professionale',
    tagline: 'Core — AI predittiva, supply avanzata, reportistica direzione.',
    flatMonthlyCents: 169000,
    annualTotalCents: 2028000,
    maxPlants: 3,
    maxUsers: 50,
    includesPredictiveAi: true,
    includesWhatIf: true,
    includesEsgCompliance: true,
    includesCopilot: true,
    includesApiErp: false,
    includesAutoReplenishmentFull: false,
    includesWhiteLabelSla: false,
  );

  static const PlanDefinition industriale = PlanDefinition(
    tier: SubscriptionPlanTier.industriale,
    planKey: 'industriale',
    marketingName: 'Industriale',
    tagline: 'Full — multi-stabilimento, integrazioni ERP, automazione completa.',
    flatMonthlyCents: 349000,
    annualTotalCents: 4188000,
    maxPlants: 999,
    maxUsers: null,
    includesPredictiveAi: true,
    includesWhatIf: true,
    includesEsgCompliance: true,
    includesCopilot: true,
    includesApiErp: true,
    includesAutoReplenishmentFull: true,
    includesWhiteLabelSla: true,
  );

  static PlanDefinition byTier(SubscriptionPlanTier tier) => switch (tier) {
        SubscriptionPlanTier.essenziale => essenziale,
        SubscriptionPlanTier.professionale => professionale,
        SubscriptionPlanTier.industriale => industriale,
      };

  static SubscriptionPlanTier? tryParseTier(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final s = raw.toLowerCase().trim();
    if (s == 'industriale' ||
        s.contains('industrial') ||
        s.contains('full') ||
        s.contains('fascia c')) {
      return SubscriptionPlanTier.industriale;
    }
    if (s == 'professionale' ||
        s.contains('professional') ||
        s.contains('core') ||
        s == 'pro' ||
        s.contains('growth') ||
        s.contains('fascia b')) {
      return SubscriptionPlanTier.professionale;
    }
    if (s == 'essenziale' ||
        s.contains('essential') ||
        s.contains('ingresso') ||
        s.contains('starter') ||
        s.contains('basic') ||
        s.contains('fascia a')) {
      return SubscriptionPlanTier.essenziale;
    }
    if (s.contains('enterprise')) return SubscriptionPlanTier.industriale;
    return null;
  }
}

/// Feature gates aligned with [PlanDefinition].
/// Supabase Edge Functions enforce the same rules via `_shared/plan_entitlements.ts`.
class SubscriptionEntitlements {
  const SubscriptionEntitlements({required this.tier});

  final SubscriptionPlanTier tier;

  PlanDefinition get _d => PlanCatalog.byTier(tier);

  /// AI Copilot chat.
  bool get canUseAiCopilot => _d.includesCopilot;

  /// Predictive maintenance / failure risk signals.
  bool get canUsePredictiveAi => _d.includesPredictiveAi;

  /// Demand forecast, disruption detection, AI inventory optimize, supplier risk scoring.
  bool get canUseAiSupplyFeatures => _d.includesPredictiveAi;

  /// Cost + inventory AI optimization (Industriale positioning).
  bool get canUseCostInventoryOptimizationAi =>
      _d.includesAutoReplenishmentFull && _d.includesApiErp;

  bool get canUseAutoActions => canUseAiCopilot;

  bool get canUseExecutiveReport =>
      _d.includesCopilot || _d.includesEsgCompliance;

  bool get canUseAdvancedSimulation => _d.includesWhatIf;

  bool get canUseApi => _d.includesApiErp;

  /// More than one plant/site (Essenziale = 1 site).
  bool get canUseMultiPlant => _d.maxPlants > 1;

  bool get canUseControlTower => _d.includesPredictiveAi;

  bool get canUseForecasting => _d.includesPredictiveAi;

  /// ESG / compliance reports module (PDF).
  bool get canUseEsgReportsModule => _d.includesEsgCompliance;

  /// Full automatic replenishment execution (Industriale).
  bool get canUseFullAutoReplenishment => _d.includesAutoReplenishmentFull;
}
