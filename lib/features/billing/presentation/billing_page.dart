import 'package:fabricos/config/env.dart';
import 'package:fabricos/config/plan_catalog.dart';
import 'package:fabricos/config/stripe_plans.dart';
import 'package:fabricos/features/app_shell/providers/fabricos_provider.dart';
import 'package:fabricos/features/billing/data/fabric_iap_coordinator.dart';
import 'package:fabricos/features/billing/data/mobile_billing_platform.dart';
import 'package:fabricos/localization/app_localizations.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class BillingPage extends ConsumerStatefulWidget {
  const BillingPage({super.key});

  @override
  ConsumerState<BillingPage> createState() => _BillingPageState();
}

class _BillingPageState extends ConsumerState<BillingPage> {
  bool _busy = false;
  SubscriptionPlanTier _tier = SubscriptionPlanTier.growth;
  bool _annual = false;

  String _appOrigin() {
    final env = ref.read(envProvider);
    if (kIsWeb) {
      final u = Uri.base;
      if (u.hasScheme && u.host.isNotEmpty) {
        final port = u.hasPort ? ':${u.port}' : '';
        return '${u.scheme}://${u.host}$port';
      }
    }
    return env.appBaseUrl.replaceAll(RegExp(r'/$'), '');
  }

  void _attachIapHandlers(FabricIapCoordinator iap) {
    iap.onError = (m) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(m ?? 'Error')));
    };
    iap.onSuccess = () {
      ref.invalidate(billingStatusProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.t('billing_purchase_success'))),
      );
    };
  }

  Future<void> _startMobilePlanPurchase(String companyId) async {
    if (_tier == SubscriptionPlanTier.enterprise) return;
    setState(() => _busy = true);
    final iap = ref.read(fabricIapCoordinatorProvider);
    _attachIapHandlers(iap);
    try {
      await iap.startPurchase(
        companyId: companyId,
        tier: _tier,
        annual: _annual,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openCheckoutPlan(String companyId) async {
    final cents = PlanCheckoutPricing.unitAmountCents(_tier, annual: _annual);
    setState(() => _busy = true);
    try {
      final origin = _appOrigin();
      final url = await ref
          .read(fabricosRepositoryProvider)
          .createCheckoutSession(
            companyId: companyId,
            quantity: 1,
            unitAmountCents: cents,
            trialDays: 0,
            successUrl: '$origin/app/billing?success=true',
            cancelUrl: '$origin/app/billing?canceled=true',
          );
      if (url != null) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openCheckoutLegacySeats(String companyId, int qty) async {
    final unitCents = SeatPricing.unitCentsForQuantity(qty);
    setState(() => _busy = true);
    try {
      final origin = _appOrigin();
      final url = await ref
          .read(fabricosRepositoryProvider)
          .createCheckoutSession(
            companyId: companyId,
            quantity: qty,
            unitAmountCents: unitCents,
            trialDays: 0,
            successUrl: '$origin/app/billing?success=true',
            cancelUrl: '$origin/app/billing?canceled=true',
          );
      if (url != null) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openPortal(String companyId) async {
    setState(() => _busy = true);
    try {
      final origin = _appOrigin();
      final url = await ref
          .read(fabricosRepositoryProvider)
          .createPortalSession(
            companyId: companyId,
            returnUrl: '$origin/app/billing',
          );
      if (url != null) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final companyIdAsync = ref.watch(currentCompanyIdProvider);
    final billingAsync = ref.watch(billingStatusProvider);
    final historyAsync = ref.watch(paymentHistoryProvider);
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 560;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(compact ? 16 : 24),
          child: companyIdAsync.when(
            data: (companyId) => SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.t('billing'),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  billingAsync.when(
                    data: (billing) => Text(
                      billing.hasActiveSubscription
                          ? '${l10n.t('billing_active')} · ${billing.resolvedTier.name}'
                          : billing.inTrial
                          ? '${l10n.t('billing_trial_until')} ${billing.trialEndsAt?.toLocal().toString().split(' ').first ?? ''}'
                          : l10n.t('billing_no_active'),
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('$e'),
                  ),
                  const SizedBox(height: 24),
                  billingAsync.when(
                    data: (billing) {
                      final hasSubscription = billing.hasActiveSubscription;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!hasSubscription) ...[
                            Text(
                              l10n.t('billing_plan_pick'),
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 6),
                            Text(l10n.t('billing_plan_subtitle')),
                            const SizedBox(height: 16),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(l10n.t('billing_annual')),
                              value: _annual,
                              onChanged: (v) => setState(() => _annual = v),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                _planChip(
                                  context,
                                  SubscriptionPlanTier.starter,
                                  l10n.t('plan_starter'),
                                ),
                                _planChip(
                                  context,
                                  SubscriptionPlanTier.growth,
                                  l10n.t('plan_growth'),
                                ),
                                _planChip(
                                  context,
                                  SubscriptionPlanTier.pro,
                                  l10n.t('plan_pro'),
                                ),
                                _planChip(
                                  context,
                                  SubscriptionPlanTier.enterprise,
                                  l10n.t('plan_enterprise'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _PlanSummaryCard(tier: _tier, annual: _annual),
                            const SizedBox(height: 16),
                            if (_tier == SubscriptionPlanTier.enterprise)
                              Text(
                                l10n.t('billing_enterprise_note'),
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            if (_tier == SubscriptionPlanTier.enterprise)
                              const SizedBox(height: 12),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 360),
                              child: SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: _busy
                                      ? null
                                      : () {
                                          if (_tier ==
                                              SubscriptionPlanTier.enterprise) {
                                            context.go('/contact');
                                          } else if (kUseMobileStoreBilling) {
                                            _startMobilePlanPurchase(companyId);
                                          } else {
                                            _openCheckoutPlan(companyId);
                                          }
                                        },
                                  child: _busy
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          _tier ==
                                                  SubscriptionPlanTier
                                                      .enterprise
                                              ? l10n.t('contact_sales')
                                              : kUseMobileStoreBilling
                                              ? l10n.t('billing_iap_continue')
                                              : l10n.t('billing_checkout'),
                                        ),
                                ),
                              ),
                            ),
                            if (!kUseMobileStoreBilling) ...[
                              const SizedBox(height: 32),
                              Text(
                                'Legacy seat-based checkout',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Per-user pricing still available for grandfathered contracts.',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 8),
                              OutlinedButton(
                                onPressed: _busy
                                    ? null
                                    : () => _openCheckoutLegacySeats(
                                        companyId,
                                        10,
                                      ),
                                child: const Text('10 seats · checkout'),
                              ),
                            ],
                          ],
                          if (hasSubscription) ...[
                            if (billing.isStoreBillingSubscription) ...[
                              Text(
                                l10n.t('billing_manage_in_store'),
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton(
                                onPressed: _busy
                                    ? null
                                    : () async {
                                        setState(() => _busy = true);
                                        final iap = ref.read(
                                          fabricIapCoordinatorProvider,
                                        );
                                        _attachIapHandlers(iap);
                                        try {
                                          await iap.restorePurchases();
                                        } finally {
                                          if (mounted) {
                                            setState(() => _busy = false);
                                          }
                                        }
                                      },
                                child: Text(
                                  l10n.t('billing_restore_purchases'),
                                ),
                              ),
                            ] else
                              FilledButton.tonal(
                                onPressed: _busy
                                    ? null
                                    : () => _openPortal(companyId),
                                child: Text(l10n.t('manage_subscription')),
                              ),
                          ],
                        ],
                      );
                    },
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('$e'),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    l10n.t('billing_purchase_history'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: historyAsync.when(
                      data: (rows) => rows.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(l10n.t('billing_no_purchases')),
                            )
                          : Column(
                              children: rows
                                  .map(
                                    (row) => ListTile(
                                      title: Text(
                                        '€${(row['amount_paid'] as num?)?.toStringAsFixed(2) ?? '-'} ${(row['currency'] ?? '').toString().toUpperCase()}',
                                      ),
                                      subtitle: Text('${row['paid_at'] ?? ''}'),
                                      trailing: Text(
                                        row['stripe_invoice_id']?.toString() ??
                                            '',
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                      loading: () => const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (e, _) => Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text('$e'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
          ),
        ),
      ),
    );
  }

  Widget _planChip(
    BuildContext context,
    SubscriptionPlanTier tier,
    String label,
  ) {
    final selected = _tier == tier;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _tier = tier),
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
    );
  }
}

class _PlanSummaryCard extends StatelessWidget {
  const _PlanSummaryCard({required this.tier, required this.annual});

  final SubscriptionPlanTier tier;
  final bool annual;

  @override
  Widget build(BuildContext context) {
    final d = PlanCatalog.byTier(tier);
    final cents = PlanCheckoutPricing.unitAmountCents(tier, annual: annual);
    final eur = (cents / 100).toStringAsFixed(0);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              d.marketingName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              tier == SubscriptionPlanTier.enterprise
                  ? 'From €${PlanCatalog.enterprise.monthlyEuros.toStringAsFixed(0)}/mo'
                  : '€$eur${context.l10n.t('per_month')}',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            if (annual && tier != SubscriptionPlanTier.enterprise) ...[
              const SizedBox(height: 6),
              Text(
                '${d.annualDiscountPercent}% discount vs monthly list',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
