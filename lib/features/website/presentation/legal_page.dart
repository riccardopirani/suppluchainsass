import 'package:flutter/material.dart';
import 'package:fabricos/localization/app_localizations.dart';

enum LegalType { privacy, terms, cookies }

class LegalPage extends StatelessWidget {
  const LegalPage({super.key, required this.type});

  final LegalType type;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final title = switch (type) {
      LegalType.privacy => l10n.t('footer_privacy'),
      LegalType.terms => l10n.t('footer_terms'),
      LegalType.cookies => l10n.t('footer_cookies'),
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 24),
              Text(
                'Last updated: 2026-01-01.\n\n'
                'This is placeholder legal content. Replace with your actual privacy policy, terms of service, and cookie policy before going to production.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
