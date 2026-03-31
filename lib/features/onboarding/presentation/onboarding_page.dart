import 'package:fabricos/config/env.dart';
import 'package:fabricos/features/app_shell/providers/fabricos_provider.dart';
import 'package:fabricos/localization/app_localizations.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _companyController = TextEditingController();
  String _sizeBand = '10-50';
  String _selectedPlan = 'starter';
  bool _startTrial = true;
  bool _loading = false;
  String? _error;

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

  @override
  void dispose() {
    _companyController.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    final companyName = _companyController.text.trim();
    if (companyName.isEmpty) {
      setState(() => _error = 'Company name is required.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await ref
          .read(fabricosRepositoryProvider)
          .createCompanyAndAssignUser(
            companyName: companyName,
            sizeBand: _sizeBand,
            plan: _selectedPlan,
            startTrial: _startTrial,
          );
      ref.invalidate(fabricUserContextProvider);

      final userCtx = await ref.read(fabricUserContextProvider.future);
      final companyId = userCtx.companyId;

      if (!_startTrial && companyId != null) {
        final env = ref.read(envProvider);
        final origin = _appOrigin();

        String priceId;
        switch (_selectedPlan) {
          case 'pro':
            priceId = env.stripeProMonthlyPriceId;
            break;
          case 'business':
            priceId = env.stripeBusinessMonthlyPriceId;
            break;
          case 'starter':
          default:
            priceId = env.stripeStarterMonthlyPriceId;
            break;
        }

        if (priceId.isNotEmpty) {
          final url = await ref.read(fabricosRepositoryProvider).createCheckoutSession(
                companyId: companyId,
                priceId: priceId,
                trialDays: 0,
                successUrl: '$origin/app/billing?success=true',
                cancelUrl: '$origin/app/billing?canceled=true',
              );
          if (url != null && mounted) {
            await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
          }
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
    _selectedPlan = uri.queryParameters['plan'] ?? _selectedPlan;
    _startTrial = (uri.queryParameters['trial'] ?? (_startTrial ? '1' : '0')) == '1';

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
                      Text(
                        context.l10n.t('onboarding_welcome'),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.t('onboarding_company_setup_subtitle'),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _companyController,
                        decoration: InputDecoration(
                          labelText: context.l10n.t('company_name'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _sizeBand,
                        items: const [
                          DropdownMenuItem(
                            value: '10-50',
                            child: Text('10-50 employees'),
                          ),
                          DropdownMenuItem(
                            value: '51-200',
                            child: Text('51-200 employees'),
                          ),
                          DropdownMenuItem(
                            value: '201-500',
                            child: Text('201-500 employees'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => _sizeBand = value);
                        },
                        decoration: InputDecoration(
                          labelText: context.l10n.t('company_size'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(context.l10n.t('billing_selected_plan')),
                        subtitle: Text(
                          '$_selectedPlan · ${_startTrial ? context.l10n.t('billing_trial_30_days') : context.l10n.t('billing_no_trial')}',
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_error != null)
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
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _loading ? null : _complete,
                          child: _loading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(context.l10n.t('create_workspace_continue')),
                        ),
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
