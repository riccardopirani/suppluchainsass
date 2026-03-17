import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stockguard_ai/localization/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:stockguard_ai/features/app_shell/widgets/warehouse_selector.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = MediaQuery.sizeOf(context).width >= 1024;

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            const _Sidebar(),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: const _BottomNav(),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              context.l10n.t('app_name'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const WarehouseSelector(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.dashboard_rounded),
            title: Text(context.l10n.t('dashboard')),
            onTap: () => context.go('/app'),
          ),
          ListTile(
            leading: const Icon(Icons.inventory_2_outlined),
            title: Text(context.l10n.t('products')),
            onTap: () => context.go('/app/products'),
          ),
          ListTile(
            leading: const Icon(Icons.reorder_rounded),
            title: Text(context.l10n.t('reorder_suggestions')),
            onTap: () => context.go('/app/reorder'),
          ),
          ListTile(
            leading: const Icon(Icons.trending_up_rounded),
            title: Text(context.l10n.t('forecasting')),
            onTap: () => context.go('/app/forecasting'),
          ),
          ListTile(
            leading: const Icon(Icons.local_shipping_outlined),
            title: Text(context.l10n.t('suppliers')),
            onTap: () => context.go('/app/suppliers'),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: Text(context.l10n.t('alerts')),
            onTap: () => context.go('/app/alerts'),
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart_outlined),
            title: Text(context.l10n.t('purchase_orders')),
            onTap: () => context.go('/app/purchase-orders'),
          ),
          ListTile(
            leading: const Icon(Icons.analytics_outlined),
            title: Text(context.l10n.t('analytics')),
            onTap: () => context.go('/app/analytics'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.credit_card_outlined),
            title: Text(context.l10n.t('billing')),
            onTap: () => context.go('/app/billing'),
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: Text(context.l10n.t('settings')),
            onTap: () => context.go('/app/settings'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(context.l10n.t('sign_out')),
            onTap: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) context.go('/');
            },
          ),
        ],
      ),
    );
  }
}


class _BottomNav extends ConsumerWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final loc = GoRouterState.of(context).uri.path;

    int currentIndex = 0;
    if (loc.contains('products')) {
      currentIndex = 1;
    } else if (loc.contains('reorder')) {
      currentIndex = 2;
    } else if (loc.contains('alerts')) {
      currentIndex = 3;
    } else if (loc.contains('settings')) {
      currentIndex = 4;
    }

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (i) {
        switch (i) {
          case 0:
            context.go('/app');
            break;
          case 1:
            context.go('/app/products');
            break;
          case 2:
            context.go('/app/reorder');
            break;
          case 3:
            context.go('/app/alerts');
            break;
          case 4:
            context.go('/app/settings');
            break;
        }
      },
      destinations: [
        NavigationDestination(icon: const Icon(Icons.dashboard_rounded), label: l10n.t('dashboard')),
        NavigationDestination(icon: const Icon(Icons.inventory_2_outlined), label: l10n.t('products')),
        NavigationDestination(icon: const Icon(Icons.reorder_rounded), label: l10n.t('reorder_suggestions').split(' ').first),
        NavigationDestination(icon: const Icon(Icons.notifications_outlined), label: l10n.t('alerts')),
        NavigationDestination(icon: const Icon(Icons.settings_outlined), label: l10n.t('settings')),
      ],
    );
  }
}
