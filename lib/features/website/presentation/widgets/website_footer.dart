import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WebsiteFooter extends StatelessWidget {
  const WebsiteFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        runAlignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 12,
        children: [
          const Text('FabricOS · AI Operations Platform for Manufacturing'),
          Wrap(
            spacing: 8,
            children: [
              TextButton(
                onPressed: () => context.go('/privacy'),
                child: const Text('Privacy'),
              ),
              TextButton(
                onPressed: () => context.go('/terms'),
                child: const Text('Terms'),
              ),
              TextButton(
                onPressed: () => context.go('/cookies'),
                child: const Text('Cookies'),
              ),
              TextButton(
                onPressed: () => context.go('/contact'),
                child: const Text('Contact'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
