import 'package:fabricos/config/plan_catalog.dart';
import 'package:fabricos/core/marketing/roi_calculator_logic.dart';
import 'package:fabricos/features/app_shell/providers/fabricos_provider.dart';
import 'package:fabricos/localization/app_localizations.dart';
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
  bool _loading = false;
  String? _error;

  static const _steps = 6;

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
      await ref
          .read(fabricosRepositoryProvider)
          .createCompanyAndAssignUser(
            companyName: companyName,
            sizeBand: _sizeBand,
            plan: plan != null && plan.isNotEmpty ? plan : null,
          );
      ref.invalidate(fabricUserContextProvider);

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

    final l10n = context.l10n;
    final planTier = PlanCatalog.tryParseTier(uri.queryParameters['plan']) ??
        SubscriptionPlanTier.professionale;
    final planDef = PlanCatalog.byTier(planTier);
    final roi = _roiPreview();
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 560;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(compact ? 16 : 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(compact ? 18 : 24),
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
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
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
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
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
                            DropdownMenuItem(
                              value: '10-50',
                              child: Text('10-50 ${l10n.t('pricing_users')}'),
                            ),
                            DropdownMenuItem(
                              value: '51-200',
                              child: Text('51-200 ${l10n.t('pricing_users')}'),
                            ),
                            DropdownMenuItem(
                              value: '201-500',
                              child: Text('201-500 ${l10n.t('pricing_users')}'),
                            ),
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
                            DropdownMenuItem(
                              value: '2-3',
                              child: Text('2–3 sites'),
                            ),
                            DropdownMenuItem(
                              value: '4+',
                              child: Text('4+ sites'),
                            ),
                          ],
                          onChanged: (v) =>
                              setState(() => _plantsBand = v ?? '1'),
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
                            DropdownMenuItem(
                              value: '<10',
                              child: Text('<10 machines'),
                            ),
                            DropdownMenuItem(
                              value: '10-50',
                              child: Text('10–50 machines'),
                            ),
                            DropdownMenuItem(
                              value: '51-200',
                              child: Text('51–200 machines'),
                            ),
                            DropdownMenuItem(
                              value: '200+',
                              child: Text('200+ machines'),
                            ),
                          ],
                          onChanged: (v) =>
                              setState(() => _machinesBand = v ?? '10-50'),
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
                              onSelected: (_) =>
                                  setState(() => _pain = 'downtime'),
                            ),
                            ChoiceChip(
                              label: Text(l10n.t('onboarding_pain_delays')),
                              selected: _pain == 'delays',
                              onSelected: (_) =>
                                  setState(() => _pain = 'delays'),
                            ),
                            ChoiceChip(
                              label: Text(l10n.t('onboarding_pain_inventory')),
                              selected: _pain == 'inventory',
                              onSelected: (_) =>
                                  setState(() => _pain = 'inventory'),
                            ),
                            ChoiceChip(
                              label: Text(l10n.t('onboarding_pain_visibility')),
                              selected: _pain == 'visibility',
                              onSelected: (_) =>
                                  setState(() => _pain = 'visibility'),
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
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                                .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '€${roi.estimatedMonthlySavings.round()}${l10n.t('per_month')} · est. savings',
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.t('onboarding_roi_blurb'),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          l10n.t('billing_plan_summary'),
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${planDef.marketingName} — €${planDef.monthlyEuros.toStringAsFixed(0)}${l10n.t('per_month')} · '
                          '€${planDef.annualEuros.toStringAsFixed(0)}${l10n.t('per_year')} · '
                          '${l10n.t('billing_trial_30_days')}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
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
                              color: Theme.of(
                                context,
                              ).colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final stackButtons = constraints.maxWidth < 420;
                          final backButton = _step > 0
                              ? OutlinedButton(
                                  onPressed: _loading
                                      ? null
                                      : () => setState(() => _step -= 1),
                                  child: Text(l10n.t('onboarding_back')),
                                )
                              : null;
                          final nextButton = _step < _steps - 1
                              ? FilledButton(
                                  onPressed: _loading
                                      ? null
                                      : () {
                                          if (_step == 1 &&
                                              _companyController.text
                                                  .trim()
                                                  .isEmpty) {
                                            setState(
                                              () => _error = l10n.t(
                                                'validation_name_required',
                                              ),
                                            );
                                            return;
                                          }
                                          setState(() {
                                            _error = null;
                                            _step += 1;
                                          });
                                        },
                                  child: Text(l10n.t('onboarding_next')),
                                )
                              : FilledButton(
                                  onPressed: _loading ? null : _complete,
                                  child: _loading
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          l10n.t('create_workspace_continue'),
                                        ),
                                );

                          if (stackButtons) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (backButton != null) backButton,
                                if (backButton != null)
                                  const SizedBox(height: 12),
                                nextButton,
                              ],
                            );
                          }

                          return Row(
                            children: [
                              if (backButton != null) backButton,
                              const Spacer(),
                              nextButton,
                            ],
                          );
                        },
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
