import 'package:fabricos/config/env.dart';
import 'package:fabricos/config/stripe_plans.dart';
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
  double _seats = 10;

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

  Future<void> _openCheckout(String companyId, int qty, {int trialDays = 0}) async {
    final unitCents = SeatPricing.unitCentsForQuantity(qty);
    setState(() => _busy = true);
    try {
      final origin = _appOrigin();
      final url = await ref.read(fabricosRepositoryProvider).createCheckoutSession(
            companyId: companyId,
            quantity: qty,
            unitAmountCents: unitCents,
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
    final companyIdAsync = ref.watch(currentCompanyIdProvider);
    final billingAsync = ref.watch(billingStatusProvider);
    final historyAsync = ref.watch(paymentHistoryProvider);
    final qty = _seats.round();
    final unitPrice = SeatPricing.unitPrice(qty);
    final total = SeatPricing.monthlyTotal(qty);

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
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.t('pricing_how_many_users'),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Text(
                                '$qty',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              const SizedBox(width: 8),
                              Text(l10n.t('pricing_users')),
                            ],
                          ),
                          Slider(
                            min: 1,
                            max: 200,
                            divisions: 199,
                            value: _seats,
                            label: '$qty',
                            onChanged: (v) => setState(() => _seats = v),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('1', style: Theme.of(context).textTheme.bodySmall),
                              Text('200+', style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Text(
                                '€${total.toStringAsFixed(0)}',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              const SizedBox(width: 8),
                              Text(l10n.t('per_month')),
                              const Spacer(),
                              Text(
                                '€${unitPrice.toStringAsFixed(2)} ${l10n.t('pricing_per_user_month')}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: _busy ? null : () => _openCheckout(companyId, qty),
                              child: _busy
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : Text(l10n.t('billing_subscribe_now')),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.tonal(
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
                                      title: Text(
                                        '€${(row['amount_paid'] as num?)?.toStringAsFixed(2) ?? '-'} ${(row['currency'] ?? '').toString().toUpperCase()}',
                                      ),
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
}
