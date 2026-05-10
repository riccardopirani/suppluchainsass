import 'package:fabricos/core/theme/intelligence_theme.dart';
import 'package:fabricos/features/app_shell/providers/fabricos_provider.dart';
import 'package:fabricos/features/app_shell/widgets/workspace_sidebar.dart';
import 'package:fabricos/features/billing/presentation/subscription_gate_page.dart';
import 'package:fabricos/features/app_shell/providers/shell_ui_provider.dart';
import 'package:fabricos/features/copilot/presentation/fabric_copilot_sheet.dart';
import 'package:fabricos/features/website/presentation/widgets/language_selector.dart';
import 'package:fabricos/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
            loading: () => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => Scaffold(
              body: Center(
                child: Text('Unable to load billing status: $error'),
              ),
            ),
            data: (b) => b.canAccessApp
                ? _buildShell(
                    context,
                    child,
                    ctx.companyName ?? 'FabricOS Workspace',
                  )
                : const SubscriptionGatePage(),
          );
        }

        return _buildShell(
          context,
          child,
          ctx.companyName ?? 'FabricOS Workspace',
        );
      },
    );
  }

  Widget _buildShell(BuildContext context, Widget child, String companyName) {
    final isWide = MediaQuery.sizeOf(context).width >= 1024;
    const shellBackground = IntelligenceTheme.background;
    const shellBorder = IntelligenceTheme.border;
    const panelBackground = IntelligenceTheme.panel;

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
                  WorkspaceSidebar(companyName: companyName),
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
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                20,
                                20,
                                20,
                              ),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: panelBackground.withValues(
                                    alpha: 0.88,
                                  ),
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
          const Positioned(right: 32, bottom: 32, child: FabricCopilotFab()),
        ],
      );
    }
    return Scaffold(
      backgroundColor: shellBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8, left: 8, bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  LanguageSelector(),
                ],
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
      bottomNavigationBar: const _BottomNav(),
      floatingActionButton: const FabricCopilotFab(),
    );
  }
}


class _TopBar extends ConsumerWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userCtx = ref.watch(fabricUserContextProvider).valueOrNull;
    final path = GoRouterState.of(context).uri.path;
    final l10n = context.l10n;
    final title = switch (path) {
      '/app' => l10n.t('topbar_route_home'),
      '/app/control-tower' => l10n.t('control_tower_title'),
      '/app/executive-report' => l10n.t('exec_report_title'),
      '/app/forecasting' => l10n.t('app_menu_forecasting'),
      '/app/supply' => l10n.t('topbar_route_supply'),
      '/app/inventory' => l10n.t('topbar_route_inventory'),
      '/app/machines' => l10n.t('topbar_route_machines'),
      '/app/orders' => l10n.t('topbar_route_orders'),
      '/app/logistics' => l10n.t('topbar_route_logistics'),
      '/app/freight-audit' => l10n.t('topbar_route_freight_audit'),
      '/app/esg-carbon' => l10n.t('topbar_route_esg_carbon'),
      '/app/plant-floor' => l10n.t('topbar_route_plant_floor'),
      '/app/suppliers' => l10n.t('topbar_route_suppliers'),
      '/app/vendor-portal' => l10n.t('topbar_route_vendor_portal'),
      '/app/reports' => l10n.t('topbar_route_reports'),
      '/app/shipments' => l10n.t('topbar_route_shipments'),
      '/app/offline-sync' => l10n.t('topbar_route_offline_sync'),
      '/app/simulation' => l10n.t('app_menu_simulation'),
      '/app/team' => l10n.t('topbar_route_team'),
      '/app/settings' => l10n.t('topbar_route_settings'),
      '/app/billing' => l10n.t('topbar_route_billing'),
      _ => l10n.t('topbar_route_default'),
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
                _HeaderTag(
                  text: context.l10n.t('topbar_chip_roi'),
                  icon: Icons.rocket_launch_outlined,
                ),
                _HeaderTag(
                  text: context.l10n.t('topbar_chip_alerts'),
                  icon: Icons.notifications_active_outlined,
                ),
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
              style: const TextStyle(
                color: Color(0xFF8EA3C2),
                fontSize: 13,
                height: 1.35,
              ),
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 16,
                color: Color(0xFFEAF2FF),
              ),
              SizedBox(width: 8),
              Text(
                context.l10n.t('topbar_alerts_count'),
                style: TextStyle(color: Color(0xFFEAF2FF), fontSize: 13),
              ),
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
                child: Icon(
                  Icons.person_outline,
                  color: Color(0xFF8EA3C2),
                  size: 16,
                ),
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
                      style: const TextStyle(
                        color: Color(0xFF8EA3C2),
                        fontSize: 11,
                      ),
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
            color: IntelligenceTheme.background.withValues(alpha: 0.82),
            border: Border(
              bottom: BorderSide(
                color: const Color(0xFF1A2436).withValues(alpha: 0.8),
              ),
            ),
          ),
          child: stackHeader
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    titleBlock,
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.end,
                        children: [
                          const _ThemeToggleButton(),
                          const LanguageSelector(),
                          alertsChip,
                          userChip,
                        ],
                      ),
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: titleBlock),
                    const SizedBox(width: 8),
                    const _ThemeToggleButton(),
                    const LanguageSelector(),
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

class _ThemeToggleButton extends ConsumerWidget {
  const _ThemeToggleButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(appThemeModeProvider);
    final dark = mode == ThemeMode.dark ||
        (mode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);
    return IconButton(
      tooltip: context.l10n.t('theme_tooltip_toggle'),
      style: IconButton.styleFrom(
        foregroundColor: const Color(0xFFEAF2FF),
      ),
      onPressed: () {
        ref.read(appThemeModeProvider.notifier).state =
            dark ? ThemeMode.light : ThemeMode.dark;
      },
      icon: Icon(
        dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
        size: 22,
      ),
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
          Icon(icon, size: 13, color: IntelligenceTheme.accent),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: IntelligenceTheme.accent,
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
    final l10n = context.l10n;
    final path = GoRouterState.of(context).uri.path;

    var currentIndex = 0;
    if (path.contains('/logistics')) {
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
            context.go('/app/logistics');
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
      destinations: [
        NavigationDestination(
          icon: Icon(Icons.dashboard_rounded),
          label: l10n.t('app_bottom_nav_dashboard'),
        ),
        NavigationDestination(
          icon: Icon(Icons.route_rounded),
          label: l10n.t('app_bottom_nav_logistics'),
        ),
        NavigationDestination(
          icon: Icon(Icons.fact_check_outlined),
          label: l10n.t('app_bottom_nav_orders'),
        ),
        NavigationDestination(
          icon: Icon(Icons.local_shipping_outlined),
          label: l10n.t('app_bottom_nav_suppliers'),
        ),
        NavigationDestination(
          icon: Icon(Icons.description_outlined),
          label: l10n.t('app_bottom_nav_reports'),
        ),
      ],
    );
  }
}
