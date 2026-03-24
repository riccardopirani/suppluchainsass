import 'package:fabricos/features/app_shell/providers/fabricos_provider.dart';
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
  bool _loading = false;
  String? _error;

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
                        'Welcome to FabricOS',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create your company workspace to start using predictive maintenance, orders and ESG reporting.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _companyController,
                        decoration: const InputDecoration(
                          labelText: 'Company name',
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
                        decoration: const InputDecoration(
                          labelText: 'Company size',
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
                              : const Text('Create workspace and continue'),
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
