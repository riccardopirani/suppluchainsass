import 'package:fabricos/config/stripe_plans.dart';
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
  final _seatsController = TextEditingController(text: '10');
  bool _loading = false;
  String? _error;
  double _sliderVal = 10;
  bool _startWithTrial = true;
  String? _planFromUrl;

  int get _qty {
    final v = int.tryParse(_seatsController.text) ?? 1;
    return v < 1 ? 1 : v;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final uri = GoRouterState.of(context).uri;
    final seatsParam = uri.queryParameters['seats'];
    if (seatsParam != null) {
      final parsed = int.tryParse(seatsParam);
      if (parsed != null && parsed >= 1) {
        _seatsController.text = '$parsed';
        _sliderVal = parsed.clamp(1, 500).toDouble();
      }
    }
    _planFromUrl = uri.queryParameters['plan'];
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _seatsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _error = null;
      _loading = true;
    });
    try {
      final qty = _qty;
      await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        data: {
          'full_name': _nameController.text.trim(),
          'seats': qty,
          'start_trial': _startWithTrial,
          if (_planFromUrl != null && _planFromUrl!.isNotEmpty)
            'plan': _planFromUrl,
        },
      );
      await Supabase.instance.client.auth.refreshSession();
      if (mounted) {
        final p = _planFromUrl != null && _planFromUrl!.isNotEmpty
            ? _planFromUrl!
            : 'growth';
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null) {
          try {
            await Supabase.instance.client.functions.invoke(
              'send-registration-welcome',
              body: {
                'fullName': _nameController.text.trim(),
                'seats': qty,
                'startTrial': _startWithTrial,
                'plan': p,
              },
            );
          } catch (_) {
            // Best-effort: signup and onboarding still proceed if mail fails
          }
        }
        context.go(
          '/onboarding?seats=$qty&trial=${_startWithTrial ? '1' : '0'}&plan=$p',
        );
      }
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

  Widget _seatsCountField() {
    return SizedBox(
      width: 72,
      child: TextField(
        controller: _seatsController,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF2563EB),
          fontSize: 26,
          fontWeight: FontWeight.w800,
        ),
        decoration: _seatInputDecoration(),
        onChanged: (v) {
          final n = int.tryParse(v);
          setState(() {
            if (n != null && n >= 1 && n <= 500) _sliderVal = n.toDouble();
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final qty = _qty;
    final unitPrice = SeatPricing.unitPrice(qty);
    final total = SeatPricing.monthlyTotal(qty);
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
      form: _buildFormCard(context, l10n, qty, unitPrice, total),
    );
  }

  Widget _buildFormCard(
    BuildContext context,
    AppLocalizations l10n,
    int qty,
    double unitPrice,
    double total,
  ) {
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
              l10n.t('pricing_how_many_users'),
              style: const TextStyle(
                color: Color(0xFFF9FAFB),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            LayoutBuilder(
              builder: (context, rc) {
                final stackSeats = rc.maxWidth < 400;
                if (stackSeats) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          _seatsCountField(),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n.t('pricing_users'),
                              style: const TextStyle(color: Color(0xFFF9FAFB)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '€${total.toStringAsFixed(0)}${l10n.t('per_month')}',
                        style: const TextStyle(
                          color: Color(0xFFF9FAFB),
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  );
                }
                return Row(
                  children: [
                    _seatsCountField(),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.t('pricing_users'),
                        style: const TextStyle(color: Color(0xFFF9FAFB)),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        '€${total.toStringAsFixed(0)}${l10n.t('per_month')}',
                        textAlign: TextAlign.end,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFF9FAFB),
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            Slider(
              min: 1,
              max: 500,
              divisions: 499,
              value: _sliderVal.clamp(1, 500),
              label: '${_sliderVal.round()}',
              onChanged: (v) {
                setState(() {
                  _sliderVal = v;
                  _seatsController.text = '${v.round()}';
                });
              },
            ),
            Text(
              '€${unitPrice.toStringAsFixed(2)} ${l10n.t('pricing_per_user_month')}',
              style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0x08FFFFFF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF1F2937)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.t('billing_trial_toggle_title'),
                          style: const TextStyle(
                            color: Color(0xFFF9FAFB),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.t('billing_trial_toggle_subtitle'),
                          style: const TextStyle(
                            color: Color(0xFFCBD5E1),
                            fontSize: 12.5,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _startWithTrial,
                    onChanged: (v) => setState(() => _startWithTrial = v),
                  ),
                ],
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

  InputDecoration _seatInputDecoration() {
    return InputDecoration(
      isDense: true,
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
