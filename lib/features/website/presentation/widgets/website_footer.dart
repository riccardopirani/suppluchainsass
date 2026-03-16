import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stockguard_ai/localization/app_localizations.dart';

class WebsiteFooter extends StatelessWidget {
  const WebsiteFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Wrap(
        spacing: 32,
        runSpacing: 16,
        alignment: WrapAlignment.center,
        children: [
          TextButton(
            onPressed: () => context.go('/privacy'),
            child: Text(l10n.t('footer_privacy')),
          ),
          TextButton(
            onPressed: () => context.go('/terms'),
            child: Text(l10n.t('footer_terms')),
          ),
          TextButton(
            onPressed: () => context.go('/cookies'),
            child: Text(l10n.t('footer_cookies')),
          ),
          TextButton(
            onPressed: () => context.go('/contact'),
            child: Text(l10n.t('footer_contact')),
          ),
        ],
      ),
    );
  }
}
