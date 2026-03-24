import 'package:fabricos/features/website/presentation/widgets/language_selector.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WebsiteNavBar extends StatelessWidget implements PreferredSizeWidget {
  const WebsiteNavBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width > 950;

    return AppBar(
      title: GestureDetector(
        onTap: () => context.go('/'),
        child: const Text(
          'FabricOS',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      centerTitle: false,
      actions: [
        if (isWide) ...[
          TextButton(
            onPressed: () => context.go('/features'),
            child: const Text('Features'),
          ),
          TextButton(
            onPressed: () => context.go('/pricing'),
            child: const Text('Pricing'),
          ),
          TextButton(
            onPressed: () => context.go('/contact'),
            child: const Text('Contact'),
          ),
          TextButton(
            onPressed: () => context.go('/faq'),
            child: const Text('FAQ'),
          ),
        ],
        const LanguageSelector(),
        const SizedBox(width: 8),
        OutlinedButton(
          onPressed: () => context.go('/login'),
          child: const Text('Login'),
        ),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: () => context.go('/register'),
          child: const Text('Start free'),
        ),
        const SizedBox(width: 20),
      ],
    );
  }
}
