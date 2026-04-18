import 'package:fabricos/features/app_shell/providers/fabricos_provider.dart';
import 'package:fabricos/features/billing/presentation/subscription_gate_page.dart';
import 'package:fabricos/features/copilot/presentation/fabric_copilot_sheet.dart';
import 'package:fabricos/features/team/data/team_provider.dart';
import 'package:fabricos/localization/app_localizations.dart';
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
    const shellBackground = Color(0xFF050914);
    const shellBorder = Color(0xFF1A2436);
    const panelBackground = Color(0xFF08111F);

    if (isWide) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF08111F), Color(0xFF050914)],
              ),
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Row(
                children: [
                  _Sidebar(companyName: companyName),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.topRight,
                          radius: 1.2,
                          colors: [Color(0x2220BDF8), Color(0x00000000)],
                        ),
                      ),
                      child: Column(
                        children: [
                          const _TopBar(),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: panelBackground.withValues(alpha: 0.88),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: shellBorder.withValues(alpha: 0.8),
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: child,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Positioned(
            right: 32,
            bottom: 32,
            child: FabricCopilotFab(),
          ),
        ],
      );
    }
    return Scaffold(
      backgroundColor: shellBackground,
      body: SafeArea(child: child),
      bottomNavigationBar: const _BottomNav(),
      floatingActionButton: const FabricCopilotFab(),
    );
  }
}

class _Sidebar extends ConsumerWidget {
  const _Sidebar({required this.companyName});

  final String companyName;

  static const (String, IconData, String, String) _dash = (
    'dashboard',
    Icons.dashboard_rounded,
    'Dashboard',
    '/app',
  );

  static const _operations = <(String, IconData, String, String)>[
    ('machines', Icons.precision_manufacturing_outlined, 'Machines', '/app/machines'),
    ('orders', Icons.fact_check_outlined, 'Orders', '/app/orders'),
  ];

  static const _supply = <(String, IconData, String, String)>[
    ('supply', Icons.visibility_outlined, 'Supply', '/app/supply'),
    ('inventory', Icons.inventory_2_outlined, 'Inventory', '/app/inventory'),
    ('suppliers', Icons.local_shipping_outlined, 'Suppliers', '/app/suppliers'),
    ('shipments', Icons.route_outlined, 'Shipments', '/app/shipments'),
  ];

  static const _intelligence = <(String, IconData, String, String)>[
    ('control_tower', Icons.hub_outlined, 'AI Control Tower', '/app/control-tower'),
    ('executive_report', Icons.insights_outlined, 'CEO report', '/app/executive-report'),
    ('forecasting', Icons.trending_up_outlined, 'Forecasts', '/app/forecasting'),
    ('simulation', Icons.science_outlined, 'What-if lab', '/app/simulation'),
    ('reports', Icons.description_outlined, 'Reports', '/app/reports'),
  ];

  static String _itemLabel(BuildContext context, String key, String fallback) {
    final l10n = context.l10n;
    return switch (key) {
      'control_tower' => l10n.t('app_menu_control_tower'),
      'executive_report' => l10n.t('app_menu_executive'),
      'simulation' => l10n.t('app_menu_simulation'),
      'forecasting' => l10n.t('app_menu_forecasting'),
      _ => fallback,
    };
  }

  static Widget? _navTile({
    required BuildContext context,
    required (String, IconData, String, String) item,
    required List<String>? allowedRoutes,
    required String currentPath,
    required Color sidebarForeground,
    required Color sidebarPrimary,
  }) {
    if (allowedRoutes != null && !allowedRoutes.contains(item.$1)) {
      return null;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        dense: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: currentPath == item.$4 ? const BorderSide(color: Color(0x227DD3FC)) : BorderSide.none,
        ),
        tileColor: currentPath == item.$4 ? sidebarPrimary.withValues(alpha: 0.8) : Colors.transparent,
        textColor: sidebarForeground,
        iconColor: sidebarForeground,
        leading: Icon(item.$2, size: 20),
        title: Text(
          _itemLabel(context, item.$1, item.$3),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        onTap: () => context.go(item.$4),
      ),
    );
  }

  static Widget _sectionLabel(BuildContext context, String l10nKey) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 14, 10, 6),
      child: Text(
        context.l10n.t(l10nKey).toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF8EA3C2),
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userCtx = ref.watch(fabricUserContextProvider).valueOrNull;
    final companyId = userCtx?.companyId;
    final role = userCtx?.role ?? 'operator';
    final isAdmin = role == 'admin';

    final permsAsync = companyId != null && !isAdmin
        ? ref.watch(menuPermissionsProvider((companyId: companyId, role: role)))
        : null;

    final allowedRoutes = isAdmin ? null : permsAsync?.valueOrNull;
    final currentPath = GoRouterState.of(context).uri.path;
    const sidebarForeground = Color(0xFFC7D6F3);
    const mutedForeground = Color(0xFF8EA3C2);
    const sidebarPrimary = Color(0xFF0D1B30);
    const border = Color(0xFF1A2436);

    final children = <Widget>[
      Padding(
        padding: const EdgeInsets.fromLTRB(6, 8, 6, 16),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF7DD3FC), Color(0x337DD3FC)],
                ),
              ),
              child: const Icon(Icons.radar_rounded, color: Color(0xFF03111E)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'FabricOS',
                    style: TextStyle(
                      color: Color(0xFFEAF2FF),
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    companyName,
                    style: const TextStyle(
                      color: mutedForeground,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: const Color(0x1F34D399),
              ),
              child: const Text(
                'Live',
                style: TextStyle(
                  color: Color(0xFF34D399),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    ];

    final dash = _navTile(
      context: context,
      item: _dash,
      allowedRoutes: allowedRoutes,
      currentPath: currentPath,
      sidebarForeground: sidebarForeground,
      sidebarPrimary: sidebarPrimary,
    );
    if (dash != null) children.add(dash);

    children.add(_sectionLabel(context, 'nav_section_operations'));
    for (final item in _operations) {
      final w = _navTile(
        context: context,
        item: item,
        allowedRoutes: allowedRoutes,
        currentPath: currentPath,
        sidebarForeground: sidebarForeground,
        sidebarPrimary: sidebarPrimary,
      );
      if (w != null) children.add(w);
    }

    children.add(_sectionLabel(context, 'nav_section_supply'));
    for (final item in _supply) {
      final w = _navTile(
        context: context,
        item: item,
        allowedRoutes: allowedRoutes,
        currentPath: currentPath,
        sidebarForeground: sidebarForeground,
        sidebarPrimary: sidebarPrimary,
      );
      if (w != null) children.add(w);
    }

    children.add(_sectionLabel(context, 'nav_section_intelligence'));
    for (final item in _intelligence) {
      final w = _navTile(
        context: context,
        item: item,
        allowedRoutes: allowedRoutes,
        currentPath: currentPath,
        sidebarForeground: sidebarForeground,
        sidebarPrimary: sidebarPrimary,
      );
      if (w != null) children.add(w);
    }

    final billing = _navTile(
      context: context,
      item: ('billing', Icons.credit_card_outlined, 'Billing', '/app/billing'),
      allowedRoutes: allowedRoutes,
      currentPath: currentPath,
      sidebarForeground: sidebarForeground,
      sidebarPrimary: sidebarPrimary,
    );
    if (billing != null) children.add(billing);

    children.add(_sectionLabel(context, 'nav_section_workspace'));
    final team = _navTile(
      context: context,
      item: ('team', Icons.people_outlined, 'Team', '/app/team'),
      allowedRoutes: allowedRoutes,
      currentPath: currentPath,
      sidebarForeground: sidebarForeground,
      sidebarPrimary: sidebarPrimary,
    );
    if (team != null) children.add(team);

    children.add(
      ListTile(
        leading: const Icon(Icons.settings_outlined, size: 20),
        iconColor: sidebarForeground,
        textColor: sidebarForeground,
        title: const Text('Settings', style: TextStyle(fontSize: 14)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onTap: () => context.go('/app/settings'),
      ),
    );

    return Container(
      width: 272,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF040A14), Color(0xEE040A14)],
        ),
        border: Border(
          right: BorderSide(color: border.withValues(alpha: 0.9)),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(14, 18, 14, 14),
        children: [
          ...children,
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color(0xF20C1628),
              border: Border.all(color: border),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Access logic',
                  style: TextStyle(
                    color: Color(0xFFEAF2FF),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Onboarding and subscription gates are enforced before app access. Non-admin users can see route-filtered menus.',
                  style: TextStyle(
                    color: mutedForeground,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: border),
          ListTile(
            leading: const Icon(Icons.logout_rounded, size: 20),
            iconColor: sidebarForeground,
            textColor: sidebarForeground,
            title: const Text('Sign out', style: TextStyle(fontSize: 14)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

class _TopBar extends ConsumerWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userCtx = ref.watch(fabricUserContextProvider).valueOrNull;
    final path = GoRouterState.of(context).uri.path;
    final title = switch (path) {
      '/app' => 'Global Supply Command',
      '/app/control-tower' => context.l10n.t('control_tower_title'),
      '/app/executive-report' => context.l10n.t('exec_report_title'),
      '/app/forecasting' => context.l10n.t('app_menu_forecasting'),
      '/app/supply' => 'Supply Dashboard',
      '/app/inventory' => 'Inventory Command',
      '/app/machines' => 'Machine Control',
      '/app/orders' => 'Orders Control',
      '/app/suppliers' => 'Supplier Intelligence',
      '/app/reports' => 'Mission Reports',
      '/app/shipments' => 'Shipment Tracking',
      '/app/simulation' => context.l10n.t('app_menu_simulation'),
      '/app/team' => 'Team & Permissions',
      '/app/settings' => 'Settings',
      '/app/billing' => 'Billing',
      _ => 'Mission Control',
    };

    return LayoutBuilder(
      builder: (context, c) {
        final stackHeader = c.maxWidth < 1080;
        final titleBlock = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _HeaderTag(text: context.l10n.t('topbar_chip_roi'), icon: Icons.rocket_launch_outlined),
                _HeaderTag(text: context.l10n.t('topbar_chip_alerts'), icon: Icons.notifications_active_outlined),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: const Color(0xFFEAF2FF),
                fontSize: c.maxWidth < 1200 ? 22 : 28,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              context.l10n.t('topbar_tagline'),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF8EA3C2), fontSize: 13, height: 1.35),
            ),
          ],
        );

        final alertsChip = Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFF1A2436)),
            color: const Color(0xF208111F),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded, size: 16, color: Color(0xFFEAF2FF)),
              SizedBox(width: 8),
              Text('4 alerts', style: TextStyle(color: Color(0xFFEAF2FF), fontSize: 13)),
            ],
          ),
        );

        final userChip = Container(
          constraints: const BoxConstraints(maxWidth: 220),
          padding: const EdgeInsets.fromLTRB(6, 6, 10, 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFF1A2436)),
            color: const Color(0xF208111F),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFF0D1B30),
                child: Icon(Icons.person_outline, color: Color(0xFF8EA3C2), size: 16),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userCtx?.fullName.isNotEmpty == true
                          ? userCtx!.fullName
                          : (userCtx?.email ?? 'Operator'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFEAF2FF),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      userCtx?.role ?? 'operator',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Color(0xFF8EA3C2), fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

        return Container(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
          decoration: BoxDecoration(
            color: const Color(0xD1050914),
            border: Border(
              bottom: BorderSide(color: const Color(0xFF1A2436).withValues(alpha: 0.8)),
            ),
          ),
          child: stackHeader
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    titleBlock,
                    const SizedBox(height: 14),
                    Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 10,
                      runSpacing: 10,
                      children: [alertsChip, userChip],
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: titleBlock),
                    const SizedBox(width: 12),
                    alertsChip,
                    const SizedBox(width: 10),
                    userChip,
                  ],
                ),
        );
      },
    );
  }
}

class _HeaderTag extends StatelessWidget {
  const _HeaderTag({required this.text, required this.icon});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: const Color(0x147DD3FC),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: const Color(0xFF7DD3FC)),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF7DD3FC),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
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
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
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
