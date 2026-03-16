import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stockguard_ai/localization/app_localizations.dart';
import 'package:stockguard_ai/features/website/presentation/widgets/language_selector.dart';

class WebsiteNavBar extends ConsumerWidget implements PreferredSizeWidget {
  const WebsiteNavBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isWide = MediaQuery.sizeOf(context).width > 900;

    return AppBar(
      elevation: 0,
      title: GestureDetector(
        onTap: () => context.go('/'),
        child: Text(
          l10n.t('app_name'),
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      centerTitle: false,
      actions: [
        if (isWide) ...[
          TextButton(
            onPressed: () => context.go('/features'),
            child: Text(l10n.t('nav_features')),
          ),
          TextButton(
            onPressed: () => context.go('/pricing'),
            child: Text(l10n.t('nav_pricing')),
          ),
          TextButton(
            onPressed: () => context.go('/contact'),
            child: Text(l10n.t('nav_contact')),
          ),
          TextButton(
            onPressed: () => context.go('/faq'),
            child: Text(l10n.t('nav_faq')),
          ),
        ],
        const LanguageSelector(),
        const SizedBox(width: 8),
        OutlinedButton(
          onPressed: () => context.go('/login'),
          child: Text(l10n.t('nav_login')),
        ),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: () => context.go('/register'),
          child: Text(l10n.t('nav_register')),
        ),
        const SizedBox(width: 24),
      ],
    );
  }
}
