import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stockguard_ai/localization/app_localizations.dart';
import 'package:stockguard_ai/features/website/presentation/widgets/language_selector.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.t('settings'),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: Text(context.l10n.t('profile')),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.business_outlined),
                      title: Text(context.l10n.t('company')),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.notifications_outlined),
                      title: Text(context.l10n.t('notifications')),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.language),
                      title: Text(context.l10n.t('language')),
                      trailing: const LanguageSelector(),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.credit_card_outlined),
                      title: Text(context.l10n.t('billing')),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/app/billing'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
