import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stockguard_ai/localization/app_localizations.dart';

class PricingPage extends StatelessWidget {
  const PricingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              Text(
                l10n.t('nav_pricing'),
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 48),
              Wrap(
                spacing: 24,
                runSpacing: 24,
                alignment: WrapAlignment.center,
                children: [
                  _PlanCard(
                    title: l10n.t('plan_starter'),
                    price: '\$29',
                    period: l10n.t('per_month'),
                    features: [
                      l10n.t('plan_feature_workspace'),
                      '3 ${l10n.t('plan_feature_users')}',
                      l10n.t('plan_feature_skus').replaceAll('{count}', '500'),
                      l10n.t('plan_feature_csv'),
                      l10n.t('plan_feature_basic_alerts'),
                    ],
                    cta: l10n.t('cta_start_trial'),
                    onCta: () => context.go('/register'),
                  ),
                  _PlanCard(
                    title: l10n.t('plan_growth'),
                    price: '\$79',
                    period: l10n.t('per_month'),
                    features: [
                      '10 ${l10n.t('plan_feature_users')}',
                      l10n.t('plan_feature_skus').replaceAll('{count}', '5,000'),
                      l10n.t('plan_feature_forecasting'),
                      l10n.t('plan_feature_suppliers'),
                      l10n.t('plan_feature_po'),
                    ],
                    cta: l10n.t('cta_start_trial'),
                    onCta: () => context.go('/register'),
                    highlighted: true,
                  ),
                  _PlanCard(
                    title: l10n.t('plan_pro'),
                    price: '\$199',
                    period: l10n.t('per_month'),
                    features: [
                      '25 ${l10n.t('plan_feature_users')}',
                      l10n.t('plan_feature_skus').replaceAll('{count}', '25,000'),
                      l10n.t('plan_feature_priority_support'),
                      l10n.t('plan_feature_advanced_alerts'),
                      l10n.t('plan_feature_api'),
                    ],
                    cta: l10n.t('cta_start_trial'),
                    onCta: () => context.go('/register'),
                  ),
                  _PlanCard(
                    title: l10n.t('plan_enterprise'),
                    price: 'Custom',
                    period: '',
                    features: [
                      l10n.t('plan_feature_custom_limits'),
                      l10n.t('plan_feature_sso'),
                      l10n.t('plan_feature_dedicated_support'),
                      l10n.t('plan_feature_onboarding'),
                    ],
                    cta: l10n.t('contact_sales'),
                    onCta: () => context.go('/contact'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.price,
    required this.period,
    required this.features,
    required this.cta,
    required this.onCta,
    this.highlighted = false,
  });

  final String title;
  final String price;
  final String period;
  final List<String> features;
  final String cta;
  final VoidCallback onCta;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: highlighted
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: highlighted ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(price, style: Theme.of(context).textTheme.headlineMedium),
              Text(period, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: 24),
          ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline, size: 18, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(f, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              )),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onCta,
              child: Text(cta),
            ),
          ),
        ],
      ),
    );
  }
}
