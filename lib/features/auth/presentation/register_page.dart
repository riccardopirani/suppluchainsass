import 'package:fabricos/config/plan_catalog.dart';
import 'package:fabricos/features/auth/presentation/widgets/auth_shell.dart';
import 'package:fabricos/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _loading = false;
  String? _error;
  SubscriptionPlanTier _selectedPlan = SubscriptionPlanTier.professionale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final uri = GoRouterState.of(context).uri;
    final parsed = PlanCatalog.tryParseTier(uri.queryParameters['plan']);
    if (parsed != null) {
      _selectedPlan = parsed;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _error = null;
      _loading = true;
    });
    try {
      final planName = _selectedPlan.name;
      await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        data: {
          'full_name': _nameController.text.trim(),
          'start_trial': true,
          'plan': planName,
        },
      );
      await Supabase.instance.client.auth.refreshSession();
      if (!mounted) return;
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        try {
          await Supabase.instance.client.functions.invoke(
            'send-registration-welcome',
            body: {
              'fullName': _nameController.text.trim(),
              'startTrial': true,
              'plan': planName,
            },
          );
        } catch (_) {
          // Best-effort: signup and onboarding still proceed if mail fails
        }
      }
      if (!mounted) return;
      setState(() => _loading = false);
      context.go('/onboarding?trial=1&plan=$planName');
    } on AuthException catch (e) {
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _error = context.tr('error_generic');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AuthPageShell(
      eyebrow: 'Crea account',
      title: 'Attiva il trial e metti il controllo operativo in moto',
      subtitle:
          'Registra la tua azienda, avvia i 30 giorni di prova e prepara il rinnovo in Stripe senza cambiare flusso.',
      bullets: const [
        (icon: Icons.verified_outlined, text: 'Trial di 30 giorni'),
        (icon: Icons.payments_outlined, text: 'Rinnovo Stripe integrato'),
        (icon: Icons.mail_outline, text: 'Email di onboarding e alert'),
      ],
      form: _buildFormCard(context, l10n),
    );
  }

  Widget _buildFormCard(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF1F2937)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 32,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.t('register_title'),
              style: const TextStyle(
                color: Color(0xFFF9FAFB),
                fontSize: 32,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.t('register_subtitle'),
              style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 15),
            ),
            const SizedBox(height: 28),
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0x1AFB7185),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0x66FB7185)),
                ),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Color(0xFFF9FAFB)),
                ),
              ),
              const SizedBox(height: 16),
            ],
            TextFormField(
              controller: _nameController,
              style: const TextStyle(color: Color(0xFFF9FAFB)),
              decoration: _inputDecoration(l10n.t('register_name')),
              textInputAction: TextInputAction.next,
              validator: (v) => (v == null || v.isEmpty)
                  ? l10n.t('validation_name_required')
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              style: const TextStyle(color: Color(0xFFF9FAFB)),
              decoration: _inputDecoration(l10n.t('login_email')),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: (v) => (v == null || v.isEmpty)
                  ? l10n.t('validation_email_required')
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              style: const TextStyle(color: Color(0xFFF9FAFB)),
              decoration: _inputDecoration(l10n.t('login_password')),
              obscureText: true,
              validator: (v) => (v == null || v.length < 6)
                  ? l10n.t('validation_password_min')
                  : null,
            ),
            const SizedBox(height: 20),
            Text(
              l10n.t('register_choose_plan'),
              style: const TextStyle(
                color: Color(0xFFF9FAFB),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            ...PlanCatalog.orderedTiers.map((tier) {
              final d = PlanCatalog.byTier(tier);
              final label = switch (tier) {
                SubscriptionPlanTier.essenziale => l10n.t('plan_essenziale'),
                SubscriptionPlanTier.professionale =>
                  l10n.t('plan_professionale'),
                SubscriptionPlanTier.industriale => l10n.t('plan_industriale'),
              };
              final selected = _selectedPlan == tier;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => setState(() => _selectedPlan = tier),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? const Color(0xFF2563EB)
                              : const Color(0xFF1F2937),
                          width: selected ? 1.8 : 1,
                        ),
                        color: selected
                            ? const Color(0x142563EB)
                            : const Color(0x08FFFFFF),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            selected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: selected
                                ? const Color(0xFF2563EB)
                                : const Color(0xFF6B7280),
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  label,
                                  style: const TextStyle(
                                    color: Color(0xFFF9FAFB),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '€${d.monthlyEuros.toStringAsFixed(0)}${l10n.t('per_month')} · €${d.annualEuros.toStringAsFixed(0)}${l10n.t('per_year')}',
                                  style: const TextStyle(
                                    color: Color(0xFF9CA3AF),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),
            Text(
              '· ${l10n.t('billing_trial_30_days')}: feature access follows the plan you select; subscribe before trial ends to keep using the app.',
              style: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 12.5,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _loading
                  ? null
                  : () {
                      if (_formKey.currentState?.validate() ?? false) {
                        _submit();
                      }
                    },
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.t('cta_sign_up')),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.go('/login'),
              child: Text(
                l10n.t('cta_sign_in'),
                style: const TextStyle(color: Color(0xFF9CA3AF)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF9CA3AF)),
      filled: true,
      fillColor: const Color(0x08FFFFFF),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF1F2937)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF1F2937)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF2563EB)),
      ),
    );
  }
}
