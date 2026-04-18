import 'dart:async';

import 'package:fabricos/config/env.dart';
import 'package:fabricos/config/plan_catalog.dart';
import 'package:fabricos/config/stripe_plans.dart';
import 'package:fabricos/core/marketing/roi_calculator_logic.dart';
import 'package:fabricos/features/app_shell/providers/fabricos_provider.dart';
import 'package:fabricos/features/billing/data/fabric_iap_coordinator.dart';
import 'package:fabricos/features/billing/data/mobile_billing_platform.dart';
import 'package:fabricos/localization/app_localizations.dart';
import 'package:fabricos/utils/redirect_to_url.dart'
    if (dart.library.html) 'package:fabricos/utils/redirect_to_url_web.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _companyController = TextEditingController();
  int _step = 0;
  String _sizeBand = '10-50';
  String _plantsBand = '1';
  String _machinesBand = '10-50';
  String _pain = 'downtime';
  int _seats = 10;
  bool _startTrial = true;
  bool _loading = false;
  String? _error;

  static const _steps = 6;

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

  RoiCalculatorResult _roiPreview() {
    var monthlyRevenue = 520000.0;
    monthlyRevenue += switch (_plantsBand) {
      '1' => 0.0,
      '2-3' => 220000.0,
      _ => 480000.0,
    };
    monthlyRevenue += switch (_machinesBand) {
      '10-50' => 90000.0,
      '51-200' => 240000.0,
      _ => 420000.0,
    };

    var downtimeHours = switch (_machinesBand) {
      '<10' => 18.0,
      '10-50' => 28.0,
      '51-200' => 44.0,
      _ => 62.0,
    };
    if (_pain == 'downtime') downtimeHours += 22;

    var delayCost = 12000.0 + (_plantsBand == '1' ? 0.0 : 9000.0);
    if (_pain == 'delays') delayCost += 24000;

    var inventory = 680000.0;
    if (_pain == 'inventory') inventory += 520000;
    if (_pain == 'visibility') inventory += 180000;

    return RoiCalculatorLogic.estimate(
      monthlyRevenue: monthlyRevenue,
      downtimeHours: downtimeHours,
      avgDelayCostPerEvent: delayCost,
      inventoryValue: inventory,
    );
  }

  @override
  void dispose() {
    _companyController.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    final companyName = _companyController.text.trim();
    if (companyName.isEmpty) {
      setState(() => _error = context.l10n.t('validation_name_required'));
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final plan = GoRouterState.of(context).uri.queryParameters['plan'];

    try {
      await ref.read(fabricosRepositoryProvider).createCompanyAndAssignUser(
            companyName: companyName,
            sizeBand: _sizeBand,
            plan: plan != null && plan.isNotEmpty ? plan : null,
            startTrial: _startTrial,
          );
      ref.invalidate(fabricUserContextProvider);

      final userCtx = await ref.read(fabricUserContextProvider.future);
      final companyId = userCtx.companyId;

      if (!_startTrial && companyId != null) {
        if (kUseMobileStoreBilling) {
          final tier = PlanCatalog.tryParseTier(plan ?? '') ?? SubscriptionPlanTier.growth;
          if (tier == SubscriptionPlanTier.enterprise) {
            if (mounted) context.go('/contact');
            return;
          }
          final iap = ref.read(fabricIapCoordinatorProvider);
          final done = Completer<void>();
          var canceled = false;
          iap.onSuccess = () {
            if (!done.isCompleted) done.complete();
          };
          iap.onError = (m) {
            if (!done.isCompleted) done.completeError(Exception(m ?? 'Purchase failed'));
          };
          iap.onCanceled = () {
            canceled = true;
            if (!done.isCompleted) done.complete();
          };
          try {
            await iap.startPurchase(companyId: companyId, tier: tier, annual: false);
            await done.future.timeout(
              const Duration(minutes: 3),
              onTimeout: () => throw TimeoutException('iap'),
            );
            if (canceled) return;
            ref.invalidate(billingStatusProvider);
            if (mounted) context.go('/app');
            return;
          } on TimeoutException {
            if (mounted) {
              setState(() => _error = context.l10n.t('billing_iap_timeout'));
            }
            return;
          } catch (e) {
            if (mounted) setState(() => _error = e.toString());
            return;
          } finally {
            iap.onSuccess = null;
            iap.onError = null;
            iap.onCanceled = null;
          }
        }
        final origin = _appOrigin();
        final unitCents = SeatPricing.unitCentsForQuantity(_seats);
        final url = await ref.read(fabricosRepositoryProvider).createCheckoutSession(
              companyId: companyId,
              quantity: _seats,
              unitAmountCents: unitCents,
              trialDays: 0,
              successUrl: '$origin/app/billing?success=true',
              cancelUrl: '$origin/app/billing?canceled=true',
            );
        if (url != null && mounted) {
          await redirectToUrl(url);
          return;
        }
      }

      if (mounted) context.go('/app');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uri = GoRouterState.of(context).uri;
    final seatsParam = uri.queryParameters['seats'];
    if (seatsParam != null) {
      final parsed = int.tryParse(seatsParam);
      if (parsed != null && parsed >= 1) _seats = parsed;
    }
    _startTrial = (uri.queryParameters['trial'] ?? (_startTrial ? '1' : '0')) == '1';

    final l10n = context.l10n;
    final total = SeatPricing.monthlyTotal(_seats);
    final unitPrice = SeatPricing.unitPrice(_seats);
    final roi = _roiPreview();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LinearProgressIndicator(
                        value: (_step + 1) / _steps,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${switch (_step) {
                          0 => l10n.t('onboarding_step_welcome'),
                          1 => l10n.t('onboarding_step_company'),
                          2 => l10n.t('onboarding_step_plants'),
                          3 => l10n.t('onboarding_step_machines'),
                          4 => l10n.t('onboarding_step_pain'),
                          _ => l10n.t('onboarding_step_roi'),
                        }} · ${_step + 1}/$_steps',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 20),
                      if (_step == 0) ...[
                        Text(
                          l10n.t('onboarding_welcome'),
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.t('onboarding_intro_body'),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                      if (_step == 1) ...[
                        Text(
                          l10n.t('onboarding_step_company'),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _companyController,
                          decoration: InputDecoration(
                            labelText: l10n.t('company_name'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _sizeBand,
                          items: [
                            DropdownMenuItem(value: '10-50', child: Text('10-50 ${l10n.t('pricing_users')}')),
                            DropdownMenuItem(value: '51-200', child: Text('51-200 ${l10n.t('pricing_users')}')),
                            DropdownMenuItem(value: '201-500', child: Text('201-500 ${l10n.t('pricing_users')}')),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => _sizeBand = value);
                          },
                          decoration: InputDecoration(
                            labelText: l10n.t('company_size'),
                          ),
                        ),
                      ],
                      if (_step == 2) ...[
                        Text(
                          l10n.t('onboarding_step_plants'),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: _plantsBand,
                          items: const [
                            DropdownMenuItem(value: '1', child: Text('1 site')),
                            DropdownMenuItem(value: '2-3', child: Text('2–3 sites')),
                            DropdownMenuItem(value: '4+', child: Text('4+ sites')),
                          ],
                          onChanged: (v) => setState(() => _plantsBand = v ?? '1'),
                          decoration: InputDecoration(
                            labelText: l10n.t('onboarding_plants_label'),
                          ),
                        ),
                      ],
                      if (_step == 3) ...[
                        Text(
                          l10n.t('onboarding_step_machines'),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: _machinesBand,
                          items: [
                            DropdownMenuItem(value: '<10', child: Text('<10 machines')),
                            DropdownMenuItem(value: '10-50', child: Text('10–50 machines')),
                            DropdownMenuItem(value: '51-200', child: Text('51–200 machines')),
                            DropdownMenuItem(value: '200+', child: Text('200+ machines')),
                          ],
                          onChanged: (v) => setState(() => _machinesBand = v ?? '10-50'),
                          decoration: InputDecoration(
                            labelText: l10n.t('onboarding_machines_label'),
                          ),
                        ),
                      ],
                      if (_step == 4) ...[
                        Text(
                          l10n.t('onboarding_step_pain'),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.t('onboarding_pain_label'),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ChoiceChip(
                              label: Text(l10n.t('onboarding_pain_downtime')),
                              selected: _pain == 'downtime',
                              onSelected: (_) => setState(() => _pain = 'downtime'),
                            ),
                            ChoiceChip(
                              label: Text(l10n.t('onboarding_pain_delays')),
                              selected: _pain == 'delays',
                              onSelected: (_) => setState(() => _pain = 'delays'),
                            ),
                            ChoiceChip(
                              label: Text(l10n.t('onboarding_pain_inventory')),
                              selected: _pain == 'inventory',
                              onSelected: (_) => setState(() => _pain = 'inventory'),
                            ),
                            ChoiceChip(
                              label: Text(l10n.t('onboarding_pain_visibility')),
                              selected: _pain == 'visibility',
                              onSelected: (_) => setState(() => _pain = 'visibility'),
                            ),
                          ],
                        ),
                      ],
                      if (_step == 5) ...[
                        Text(
                          l10n.t('onboarding_step_roi'),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '€${roi.estimatedMonthlySavings.round()}${l10n.t('per_month')} · est. savings',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.t('onboarding_roi_blurb'),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          l10n.t('billing_seat_summary'),
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$_seats ${l10n.t('pricing_users')} · €${unitPrice.toStringAsFixed(2)} ${l10n.t('pricing_per_user_month')} · €${total.toStringAsFixed(0)}${l10n.t('per_month')}'
                          '${_startTrial ? ' · ${l10n.t('billing_trial_30_days')}' : ''}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _error!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          if (_step > 0)
                            OutlinedButton(
                              onPressed: _loading ? null : () => setState(() => _step -= 1),
                              child: Text(l10n.t('onboarding_back')),
                            ),
                          const Spacer(),
                          if (_step < _steps - 1)
                            FilledButton(
                              onPressed: _loading
                                  ? null
                                  : () {
                                      if (_step == 1 && _companyController.text.trim().isEmpty) {
                                        setState(() => _error = l10n.t('validation_name_required'));
                                        return;
                                      }
                                      setState(() {
                                        _error = null;
                                        _step += 1;
                                      });
                                    },
                              child: Text(l10n.t('onboarding_next')),
                            )
                          else
                            FilledButton(
                              onPressed: _loading ? null : _complete,
                              child: _loading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : Text(l10n.t('create_workspace_continue')),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
