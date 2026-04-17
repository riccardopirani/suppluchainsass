import 'package:fabricos/features/team/data/team_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fabricos/localization/app_localizations.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _error = null;
      _loading = true;
    });
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      await Supabase.instance.client.auth.refreshSession();
      if (!mounted) return;
      final companies = await ref.read(userCompaniesProvider.future);
      if (companies.length > 1 && mounted) {
        final chosen = await showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => _CompanySelectorDialog(companies: companies),
        );
        if (chosen != null) {
          final userId = Supabase.instance.client.auth.currentUser?.id;
          if (userId != null) {
            await ref.read(teamServiceProvider).switchCompany(userId, chosen);
          }
        }
      }
      if (mounted) context.go('/app');
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
    final isWeb = MediaQuery.sizeOf(context).width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFF030712),
      body: isWeb
          ? Row(
              children: [
                Expanded(
                  child: Container(
                    color: const Color(0xFF030712),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(48.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.t('app_name'),
                              style: const TextStyle(
                                color: Color(0xFFF9FAFB),
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.8,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.t('tagline'),
                              style: const TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(child: _buildForm(context, l10n)),
              ],
            )
          : _buildForm(context, l10n),
    );
  }

  Widget _buildForm(BuildContext context, AppLocalizations l10n) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
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
                      l10n.t('login_title'),
                      style: const TextStyle(
                        color: Color(0xFFF9FAFB),
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Accedi al tuo account',
                      style: TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 24),
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
                      const SizedBox(height: 14),
                    ],
                    TextFormField(
                      controller: _emailController,
                      style: const TextStyle(color: Color(0xFFF9FAFB)),
                      decoration: _inputDecoration(l10n.t('login_email')),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Email required' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _passwordController,
                      style: const TextStyle(color: Color(0xFFF9FAFB)),
                      decoration: _inputDecoration(l10n.t('login_password')),
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Password required' : null,
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.push('/forgot-password'),
                        child: const Text(
                          'Password dimenticata?',
                          style: TextStyle(color: Color(0xFF9CA3AF)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
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
                          : Text(l10n.t('cta_sign_in')),
                    ),
                    const SizedBox(height: 14),
                    TextButton(
                      onPressed: () => context.push('/register'),
                      child: const Text(
                        'Registrati',
                        style: TextStyle(color: Color(0xFF9CA3AF)),
                      ),
                    ),
                  ],
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
}

class _CompanySelectorDialog extends StatelessWidget {
  const _CompanySelectorDialog({required this.companies});
  final List<Map<String, dynamic>> companies;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.t('team_select_company')),
      content: SizedBox(
        width: 340,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: companies.length,
          itemBuilder: (ctx, i) {
            final c = companies[i];
            return ListTile(
              leading: const Icon(Icons.business_outlined),
              title: Text(c['company_name']?.toString() ?? ''),
              subtitle: Text(c['role']?.toString() ?? ''),
              onTap: () => Navigator.pop(context, c['company_id']?.toString()),
            );
          },
        ),
      ),
    );
  }
}
