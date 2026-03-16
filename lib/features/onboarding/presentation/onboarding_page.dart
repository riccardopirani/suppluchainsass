import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stockguard_ai/localization/app_localizations.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  int _step = 0;
  final _companyController = TextEditingController();

  @override
  void dispose() {
    _companyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              LinearProgressIndicator(
                value: (_step + 1) / 4,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              const SizedBox(height: 48),
              Expanded(
                child: _step == 0
                    ? _WelcomeStep(l10n: l10n)
                    : _step == 1
                        ? _CompanyStep(controller: _companyController, l10n: l10n)
                        : _step == 2
                            ? _DataStep(l10n: l10n)
                            : _DoneStep(l10n: l10n),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_step > 0)
                    TextButton(
                      onPressed: () => setState(() => _step--),
                      child: Text(l10n.t('cancel')),
                    )
                  else
                    const SizedBox.shrink(),
                  FilledButton(
                    onPressed: () {
                      if (_step < 3) {
                        setState(() => _step++);
                      } else {
                        context.go('/app');
                      }
                    },
                    child: Text(_step < 3 ? l10n.t('next') : l10n.t('onboarding_done')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.rocket_launch_rounded,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            l10n.t('onboarding_welcome'),
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Set up your company and connect your data in a few steps.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _CompanyStep extends StatelessWidget {
  const _CompanyStep({required this.controller, required this.l10n});
  final TextEditingController controller;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.t('onboarding_company'),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: l10n.t('register_company'),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DataStep extends StatelessWidget {
  const _DataStep({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            l10n.t('onboarding_data'),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.upload_file),
            label: Text(l10n.t('import_csv')),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {},
            child: Text(l10n.t('demo')),
          ),
        ],
      ),
    );
  }
}

class _DoneStep extends StatelessWidget {
  const _DoneStep({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            l10n.t('onboarding_done'),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ],
      ),
    );
  }
}
