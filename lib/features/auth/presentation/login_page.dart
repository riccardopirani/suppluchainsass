import 'package:fabricos/features/team/data/team_provider.dart';
import 'package:fabricos/features/auth/presentation/widgets/auth_shell.dart';
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
    return AuthPageShell(
      eyebrow: 'Accesso sicuro',
      title: 'Controlla produzione, alert e team in un solo posto',
      subtitle:
          'Accedi a FabricOS per riprendere il controllo operativo in pochi secondi, con una vista chiara su ordini, task e anomalie.',
      bullets: const [
        (
          icon: Icons.notifications_active_outlined,
          text: 'Alert in tempo reale',
        ),
        (icon: Icons.groups_outlined, text: 'Team e company switch'),
        (icon: Icons.bar_chart_outlined, text: 'KPI e ROI live'),
      ],
      form: _buildFormCard(context, l10n),
    );
  }

  Widget _buildFormCard(BuildContext context, AppLocalizations l10n) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 560;
    return Container(
      padding: EdgeInsets.all(compact ? 20 : 28),
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
              l10n.t('login_title'),
              style: const TextStyle(
                color: Color(0xFFF9FAFB),
                fontSize: 30,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Accedi al tuo account',
              style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 15),
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
