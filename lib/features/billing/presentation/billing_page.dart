import 'package:fabricos/config/env.dart';
import 'package:fabricos/features/app_shell/providers/fabricos_provider.dart';
import 'package:fabricos/localization/app_localizations.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class BillingPage extends ConsumerStatefulWidget {
  const BillingPage({super.key});

  @override
  ConsumerState<BillingPage> createState() => _BillingPageState();
}

class _BillingPageState extends ConsumerState<BillingPage> {
  bool _busy = false;

  /// Origin for Stripe return URLs — matches deployed app (web) or `APP_BASE_URL` compile flag.
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

  Future<void> _openCheckout(String companyId, String priceId, {int trialDays = 0}) async {
    if (priceId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing Stripe price id configuration.')),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      final origin = _appOrigin();
      final url = await ref.read(fabricosRepositoryProvider).createCheckoutSession(
            companyId: companyId,
            priceId: priceId,
            trialDays: trialDays,
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
      final url = await ref.read(fabricosRepositoryProvider).createPortalSession(
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
    final env = ref.watch(envProvider);
    final companyIdAsync = ref.watch(currentCompanyIdProvider);
    final billingAsync = ref.watch(billingStatusProvider);
    final historyAsync = ref.watch(paymentHistoryProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: companyIdAsync.when(
            data: (companyId) => SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.t('billing'), style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 12),
                  billingAsync.when(
                    data: (billing) => Text(
                      billing.hasActiveSubscription
                          ? l10n.t('billing_active')
                          : billing.inTrial
                              ? '${l10n.t('billing_trial_until')} ${billing.trialEndsAt?.toLocal().toString().split(' ').first ?? ''}'
                              : l10n.t('billing_no_active'),
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('$e'),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _planCard(
                        context,
                        title: l10n.t('plan_starter'),
                        price: '€49/${l10n.t('per_month').replaceAll('/', '')}',
                        features: [l10n.t('billing_starter_f1'), l10n.t('billing_starter_f2')],
                        onSelect: () => _openCheckout(companyId, env.stripeStarterMonthlyPriceId, trialDays: 30),
                      ),
                      _planCard(
                        context,
                        title: 'Pro',
                        price: '€149/${l10n.t('per_month').replaceAll('/', '')}',
                        features: [l10n.t('billing_pro_f1'), l10n.t('billing_pro_f2')],
                        onSelect: () => _openCheckout(companyId, env.stripeProMonthlyPriceId),
                      ),
                      _planCard(
                        context,
                        title: 'Business',
                        price: '€1,200/${l10n.t('per_month').replaceAll('/', '')}',
                        features: [l10n.t('billing_business_f1'), l10n.t('billing_business_f2')],
                        onSelect: () => _openCheckout(companyId, env.stripeBusinessMonthlyPriceId),
                      ),
                      _planCard(
                        context,
                        title: l10n.t('plan_enterprise'),
                        price: '€5,000+/${l10n.t('per_month').replaceAll('/', '')}',
                        features: [l10n.t('billing_enterprise_f1')],
                        onSelect: () {},
                        ctaLabel: l10n.t('contact_sales'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _busy ? null : () => _openPortal(companyId),
                    child: Text(l10n.t('manage_subscription')),
                  ),
                  const SizedBox(height: 20),
                  Text(l10n.t('billing_purchase_history'), style: Theme.of(context).textTheme.titleMedium),
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
                                      title: Text('€${(row['amount_paid'] as num?)?.toStringAsFixed(2) ?? '-'} ${(row['currency'] ?? '').toString().toUpperCase()}'),
                                      subtitle: Text('${row['paid_at'] ?? ''}'),
                                      trailing: Text(row['stripe_invoice_id']?.toString() ?? ''),
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

  Widget _planCard(
    BuildContext context, {
    required String title,
    required String price,
    required List<String> features,
    required VoidCallback onSelect,
    String? ctaLabel,
  }) {
    return SizedBox(
      width: 280,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              Text(price, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              ...features.map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text('• $f'),
                  )),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _busy ? null : onSelect,
                  child: Text(ctaLabel ?? context.l10n.t('cta_get_started')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
