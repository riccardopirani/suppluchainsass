import 'package:fabricos/config/env.dart';
import 'package:fabricos/config/stripe_plans.dart';
import 'package:fabricos/features/app_shell/providers/fabricos_provider.dart';
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
  String _sizeBand = '10-50';
  int _seats = 10;
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
      setState(() => _error = context.l10n.t('validation_name_required'));
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
            startTrial: _startTrial,
          );
      ref.invalidate(fabricUserContextProvider);

      final userCtx = await ref.read(fabricUserContextProvider.future);
      final companyId = userCtx.companyId;

      if (!_startTrial && companyId != null) {
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
                        l10n.t('onboarding_welcome'),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.t('onboarding_company_setup_subtitle'),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 20),
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
                      const SizedBox(height: 16),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.t('billing_seat_summary')),
                        subtitle: Text(
                          '$_seats ${l10n.t('pricing_users')} · €${unitPrice.toStringAsFixed(2)} ${l10n.t('pricing_per_user_month')} · €${total.toStringAsFixed(0)}${l10n.t('per_month')}'
                          '${_startTrial ? ' · ${l10n.t('billing_trial_30_days')}' : ''}',
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
                              color: Theme.of(context).colorScheme.onErrorContainer,
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
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(l10n.t('create_workspace_continue')),
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
