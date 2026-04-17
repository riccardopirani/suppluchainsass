import 'package:fabricos/config/stripe_plans.dart';
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
        },
      );
      await Supabase.instance.client.auth.refreshSession();
      if (mounted) {
        context.go('/onboarding?seats=$qty&trial=${_startWithTrial ? '1' : '0'}');
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final qty = _qty;
    final unitPrice = SeatPricing.unitPrice(qty);
    final total = SeatPricing.monthlyTotal(qty);

    return Scaffold(
      backgroundColor: const Color(0xFF030712),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF1F2937)),
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
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.t('register_subtitle'),
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 32),
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
                      validator: (v) =>
                          (v == null || v.isEmpty) ? l10n.t('validation_name_required') : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      style: const TextStyle(color: Color(0xFFF9FAFB)),
                      decoration: _inputDecoration(l10n.t('login_email')),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? l10n.t('validation_email_required') : null,
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
                    Row(
                      children: [
                        SizedBox(
                          width: 80,
                          child: TextField(
                            controller: _seatsController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF2563EB),
                              fontSize: 28,
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
                        ),
                        const SizedBox(width: 4),
                        Text(
                          l10n.t('pricing_users'),
                          style: const TextStyle(color: Color(0xFFF9FAFB)),
                        ),
                        const Spacer(),
                        Text(
                          '€${total.toStringAsFixed(0)}${l10n.t('per_month')}',
                          style: const TextStyle(
                            color: Color(0xFFF9FAFB),
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ],
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
                    const SizedBox(height: 10),
                    SwitchListTile(
                      value: _startWithTrial,
                      onChanged: (v) => setState(() => _startWithTrial = v),
                      title: Text(l10n.t('billing_trial_toggle_title')),
                      subtitle: Text(l10n.t('billing_trial_toggle_subtitle')),
                      contentPadding: EdgeInsets.zero,
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
              ),
            ),
          ),
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
