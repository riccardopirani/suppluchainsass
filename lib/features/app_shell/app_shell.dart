import 'package:fabricos/features/app_shell/providers/fabricos_provider.dart';
import 'package:fabricos/features/billing/presentation/subscription_gate_page.dart';
import 'package:fabricos/features/team/data/team_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userContext = ref.watch(fabricUserContextProvider);

    return userContext.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Unable to load workspace context: $error'),
          ),
        ),
      ),
      data: (ctx) {
        if (!ctx.isOnboarded) {
          return Scaffold(
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Complete onboarding',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Set up your company workspace before accessing FabricOS modules.',
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () => context.go('/onboarding'),
                          child: const Text('Go to onboarding'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        final billing = ref.watch(billingStatusProvider);
        final path = GoRouterState.of(context).uri.path;
        final isBillingRoute = path.startsWith('/app/billing');

        if (!isBillingRoute) {
          return billing.when(
            loading: () =>
                const Scaffold(body: Center(child: CircularProgressIndicator())),
            error: (error, _) => Scaffold(
              body: Center(
                child: Text('Unable to load billing status: $error'),
              ),
            ),
            data: (b) => b.canAccessApp
                ? _buildShell(context, child, ctx.companyName ?? 'FabricOS Workspace')
                : const SubscriptionGatePage(),
          );
        }

        return _buildShell(context, child, ctx.companyName ?? 'FabricOS Workspace');
      },
    );
  }

  Widget _buildShell(BuildContext context, Widget child, String companyName) {
    final isWide = MediaQuery.sizeOf(context).width >= 1024;
    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            _Sidebar(companyName: companyName),
            Expanded(child: child),
          ],
        ),
      );
    }
    return Scaffold(body: child, bottomNavigationBar: const _BottomNav());
  }
}

class _Sidebar extends ConsumerWidget {
  const _Sidebar({required this.companyName});

  final String companyName;

  static const _menuItems = <(String key, IconData icon, String label, String route)>[
    ('dashboard', Icons.dashboard_rounded, 'Dashboard', '/app'),
    ('supply', Icons.visibility_outlined, 'Supply Dashboard', '/app/supply'),
    ('inventory', Icons.inventory_2_outlined, 'Inventory', '/app/inventory'),
    ('machines', Icons.precision_manufacturing_outlined, 'Machines', '/app/machines'),
    ('orders', Icons.fact_check_outlined, 'Orders', '/app/orders'),
    ('suppliers', Icons.local_shipping_outlined, 'Suppliers', '/app/suppliers'),
    ('reports', Icons.description_outlined, 'Reports', '/app/reports'),
    ('billing', Icons.credit_card_outlined, 'Billing', '/app/billing'),
    ('shipments', Icons.local_shipping_outlined, 'Shipments', '/app/shipments'),
    ('simulation', Icons.science_outlined, 'Simulation', '/app/simulation'),
    ('team', Icons.people_outlined, 'Team', '/app/team'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userCtx = ref.watch(fabricUserContextProvider).valueOrNull;
    final companyId = userCtx?.companyId;
    final role = userCtx?.role ?? 'operator';
    final isAdmin = role == 'admin';

    final permsAsync = companyId != null && !isAdmin
        ? ref.watch(menuPermissionsProvider((companyId: companyId, role: role)))
        : null;

    final allowedRoutes = isAdmin
        ? null
        : permsAsync?.valueOrNull;

    return Container(
      width: 270,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('FabricOS', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  companyName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          for (final item in _menuItems)
            if (allowedRoutes == null || allowedRoutes.contains(item.$1))
              ListTile(
                leading: Icon(item.$2),
                title: Text(item.$3),
                onTap: () => context.go(item.$4),
              ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            onTap: () => context.go('/app/settings'),
          ),
          ListTile(
            leading: const Icon(Icons.logout_rounded),
            title: const Text('Sign out'),
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

class _BottomNav extends StatelessWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;

    var currentIndex = 0;
    if (path.contains('/machines')) {
      currentIndex = 1;
    } else if (path.contains('/orders')) {
      currentIndex = 2;
    } else if (path.contains('/suppliers')) {
      currentIndex = 3;
    } else if (path.contains('/reports')) {
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
            context.go('/app/machines');
            break;
          case 2:
            context.go('/app/orders');
            break;
          case 3:
            context.go('/app/suppliers');
            break;
          case 4:
            context.go('/app/reports');
            break;
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_rounded),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(Icons.precision_manufacturing_outlined),
          label: 'Machines',
        ),
        NavigationDestination(
          icon: Icon(Icons.fact_check_outlined),
          label: 'Orders',
        ),
        NavigationDestination(
          icon: Icon(Icons.local_shipping_outlined),
          label: 'Suppliers',
        ),
        NavigationDestination(
          icon: Icon(Icons.description_outlined),
          label: 'Reports',
        ),
      ],
    );
  }
}
