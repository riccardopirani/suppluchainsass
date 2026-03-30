import 'package:fabricos/features/app_shell/providers/fabricos_provider.dart';
import 'package:fabricos/features/billing/presentation/subscription_gate_page.dart';
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

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.companyName});

  final String companyName;

  @override
  Widget build(BuildContext context) {
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
          ListTile(
            leading: const Icon(Icons.dashboard_rounded),
            title: const Text('Dashboard'),
            onTap: () => context.go('/app'),
          ),
          ListTile(
            leading: const Icon(Icons.visibility_outlined),
            title: const Text('Supply Dashboard'),
            onTap: () => context.go('/app/supply'),
          ),
          ListTile(
            leading: const Icon(Icons.inventory_2_outlined),
            title: const Text('Inventory'),
            onTap: () => context.go('/app/inventory'),
          ),
          ListTile(
            leading: const Icon(Icons.precision_manufacturing_outlined),
            title: const Text('Machines'),
            onTap: () => context.go('/app/machines'),
          ),
          ListTile(
            leading: const Icon(Icons.fact_check_outlined),
            title: const Text('Orders'),
            onTap: () => context.go('/app/orders'),
          ),
          ListTile(
            leading: const Icon(Icons.local_shipping_outlined),
            title: const Text('Suppliers'),
            onTap: () => context.go('/app/suppliers'),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Reports'),
            onTap: () => context.go('/app/reports'),
          ),
          ListTile(
            leading: const Icon(Icons.credit_card_outlined),
            title: const Text('Billing'),
            onTap: () => context.go('/app/billing'),
          ),
          ListTile(
            leading: const Icon(Icons.local_shipping_outlined),
            title: const Text('Shipments'),
            onTap: () => context.go('/app/shipments'),
          ),
          ListTile(
            leading: const Icon(Icons.science_outlined),
            title: const Text('Simulation'),
            onTap: () => context.go('/app/simulation'),
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
