import 'package:fabricos/core/theme/app_dimensions.dart';
import 'package:fabricos/core/theme/intelligence_theme.dart';
import 'package:fabricos/features/app_shell/providers/fabricos_provider.dart';
import 'package:fabricos/features/app_shell/providers/shell_ui_provider.dart';
import 'package:fabricos/features/team/data/team_provider.dart';
import 'package:fabricos/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Stripe / Linear inspired collapsible rail — routes match `/features` marketing IA.
class WorkspaceSidebar extends ConsumerWidget {
  const WorkspaceSidebar({super.key, required this.companyName});

  final String companyName;

  /// (permissionKey, icon, fallbackEnglishLabel, path)
  static const List<(String, IconData, String, String)> _primaryNav = [
    ('dashboard', Icons.dashboard_rounded, 'Dashboard', '/app'),
    ('orders', Icons.fact_check_outlined, 'Orders', '/app/orders'),
    ('logistics', Icons.route_rounded, 'Logistics', '/app/logistics'),
    ('suppliers', Icons.groups_outlined, 'Suppliers', '/app/suppliers'),
    (
      'freight_audit',
      Icons.compare_arrows_rounded,
      'Freight Audit AI',
      '/app/freight-audit',
    ),
    ('esg_carbon', Icons.eco_outlined, 'ESG / Carbon', '/app/esg-carbon'),
    ('reports', Icons.description_outlined, 'Reports', '/app/reports'),
    ('billing', Icons.credit_card_outlined, 'Billing', '/app/billing'),
  ];

  static String _label(BuildContext context, String key, String fallback) {
    final l10n = context.l10n;
    final k = switch (key) {
      'dashboard' => 'app_nav_dashboard',
      'orders' => 'app_nav_orders',
      'logistics' => 'app_nav_logistics',
      'suppliers' => 'app_nav_suppliers',
      'freight_audit' => 'app_nav_freight_audit',
      'esg_carbon' => 'app_nav_esg_carbon',
      'reports' => 'app_nav_reports',
      'billing' => 'app_nav_billing',
      _ => '',
    };
    if (k.isEmpty) return fallback;
    return l10n.t(k);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collapsed = ref.watch(sidebarCollapsedProvider);
    final width =
        collapsed ? AppDimensions.sidebarCollapsedWidth : AppDimensions.sidebarWidth;

    final userCtx = ref.watch(fabricUserContextProvider).valueOrNull;
    final companyId = userCtx?.companyId;
    final role = userCtx?.role ?? 'operator';
    final isAdmin = role == 'admin';

    final permsAsync = companyId != null && !isAdmin
        ? ref.watch(menuPermissionsProvider((companyId: companyId, role: role)))
        : null;

    final allowedRoutes = isAdmin ? null : permsAsync?.valueOrNull;
    final currentPath = GoRouterState.of(context).uri.path;

    const sidebarForeground = IntelligenceTheme.textPrimary;
    const mutedForeground = IntelligenceTheme.textDim;
    const sidebarPrimary = IntelligenceTheme.panelStrong;
    const border = IntelligenceTheme.border;

    Widget? tileFor((String, IconData, String, String) item) {
      if (allowedRoutes != null && !allowedRoutes.contains(item.$1)) {
        return null;
      }
      final selected = currentPath == item.$4;
      final label = _label(context, item.$1, item.$3);

      if (collapsed) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Tooltip(
            message: label,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => context.go(item.$4),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: selected
                        ? sidebarPrimary.withValues(alpha: 0.85)
                        : Colors.transparent,
                    border: Border.all(
                      color: selected
                          ? const Color(0x447DD3FC)
                          : Colors.transparent,
                    ),
                  ),
                  child: Icon(item.$2, size: 22, color: sidebarForeground),
                ),
              ),
            ),
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: ListTile(
          dense: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: selected
                ? const BorderSide(color: Color(0x227DD3FC))
                : BorderSide.none,
          ),
          tileColor: selected
              ? sidebarPrimary.withValues(alpha: 0.8)
              : Colors.transparent,
          textColor: sidebarForeground,
          iconColor: sidebarForeground,
          leading: Icon(item.$2, size: 20),
          title: Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          onTap: () => context.go(item.$4),
        ),
      );
    }

    final navTiles = <Widget>[
      for (final item in _primaryNav)
        if (tileFor(item) != null) tileFor(item)!,
    ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      width: width,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [IntelligenceTheme.background, Color(0xEE040A14)],
        ),
        border: Border(right: BorderSide(color: border.withValues(alpha: 0.9))),
      ),
      child: ListView(
        padding: EdgeInsets.fromLTRB(collapsed ? 10 : 14, 18, collapsed ? 10 : 14, 14),
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [IntelligenceTheme.accent, Color(0x337DD3FC)],
                  ),
                ),
                child: const Icon(Icons.radar_rounded, color: Color(0xFF03111E)),
              ),
              if (!collapsed) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'FabricOS',
                        style: TextStyle(
                          color: IntelligenceTheme.textPrimary,
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
              ],
              IconButton(
                tooltip: collapsed
                    ? context.l10n.t('sidebar_expand')
                    : context.l10n.t('sidebar_collapse'),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                onPressed: () =>
                    ref.read(sidebarCollapsedProvider.notifier).state = !collapsed,
                icon: Icon(
                  collapsed ? Icons.chevron_right_rounded : Icons.chevron_left_rounded,
                  color: sidebarForeground,
                  size: 22,
                ),
              ),
            ],
          ),
          if (!collapsed) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: const Color(0x1F34D399),
              ),
              child: Text(
                context.l10n.t('app_shell_live_badge'),
                style: TextStyle(
                  color: IntelligenceTheme.success,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          if (!collapsed)
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
              child: Text(
                context.l10n.t('nav_section_workspace').toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF8EA3C2),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ...navTiles,
          collapsed
              ? Tooltip(
                  message: context.l10n.t('settings'),
                  child: IconButton(
                    icon: const Icon(Icons.settings_outlined, size: 22),
                    color: sidebarForeground,
                    onPressed: () => context.go('/app/settings'),
                  ),
                )
              : ListTile(
                  leading: const Icon(Icons.settings_outlined, size: 20),
                  iconColor: sidebarForeground,
                  textColor: sidebarForeground,
                  title: Text(
                    context.l10n.t('settings'),
                    style: const TextStyle(fontSize: 14),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  onTap: () => context.go('/app/settings'),
                ),
          const SizedBox(height: 14),
          if (!collapsed)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: IntelligenceTheme.panel,
                border: Border.all(color: border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.t('app_shell_access_title'),
                    style: const TextStyle(
                      color: IntelligenceTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.t('app_shell_access_body'),
                    style: const TextStyle(
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
          collapsed
              ? Tooltip(
                  message: context.l10n.t('sign_out'),
                  child: IconButton(
                    icon: const Icon(Icons.logout_rounded, size: 22),
                    color: sidebarForeground,
                    onPressed: () async {
                      await Supabase.instance.client.auth.signOut();
                      if (context.mounted) context.go('/');
                    },
                  ),
                )
              : ListTile(
                  leading: const Icon(Icons.logout_rounded, size: 20),
                  iconColor: sidebarForeground,
                  textColor: sidebarForeground,
                  title: Text(
                    context.l10n.t('sign_out'),
                    style: const TextStyle(fontSize: 14),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
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
