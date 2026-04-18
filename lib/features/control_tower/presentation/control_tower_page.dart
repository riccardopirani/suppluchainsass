import 'package:fabricos/core/marketing/roi_calculator_logic.dart';
import 'package:fabricos/features/app_shell/providers/fabricos_provider.dart';
import 'package:fabricos/features/copilot/presentation/fabric_copilot_sheet.dart';
import 'package:fabricos/features/dashboard/data/auto_actions_provider.dart';
import 'package:fabricos/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Single-screen “AI Control Tower”: risks, capital leakage, delays, actions.
class ControlTowerPage extends ConsumerWidget {
  const ControlTowerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final snapAsync = ref.watch(dashboardSnapshotProvider);
    final alertsAsync = ref.watch(alertsProvider);
    final actions = ref.watch(autoActionsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: snapAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Text('$e'),
        data: (snap) {
          final alerts = alertsAsync.valueOrNull ?? const [];
          final critical = alerts.where((a) => a['severity'] == 'critical').length;
          final estLeak = RoiCalculatorLogic.estimate(
            monthlyRevenue: 2000000,
            downtimeHours: (snap.stoppedMachines + snap.warningMachines) * 5.0,
            avgDelayCostPerEvent: snap.delayedSuppliers * 4800.0,
            inventoryValue: 1500000,
          );
          final health = (100 - critical * 12 - snap.openAlerts * 2).clamp(20, 100);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.t('control_tower_title'), style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                l10n.t('control_tower_subtitle'),
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _TowerCard(
                    title: l10n.t('control_tower_health'),
                    value: '$health',
                    suffix: '/100',
                    color: const Color(0xFF34D399),
                    icon: Icons.health_and_safety_outlined,
                  ),
                  _TowerCard(
                    title: l10n.t('control_tower_leak'),
                    value: '€${(estLeak.downtimeCost + estLeak.delayCost * 0.4).round()}',
                    suffix: l10n.t('control_tower_leak_suffix'),
                    color: const Color(0xFFFBBF24),
                    icon: Icons.trending_down_rounded,
                  ),
                  _TowerCard(
                    title: l10n.t('control_tower_delays'),
                    value: '${snap.delayedSuppliers}',
                    suffix: l10n.t('control_tower_delays_suffix'),
                    color: const Color(0xFF7DD3FC),
                    icon: Icons.schedule_rounded,
                  ),
                  _TowerCard(
                    title: l10n.t('control_tower_alerts'),
                    value: '$critical',
                    suffix: l10n.t('control_tower_critical_suffix'),
                    color: const Color(0xFFDC2626),
                    icon: Icons.warning_amber_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text(l10n.t('control_tower_risks'), style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              if (alerts.isEmpty)
                Text(l10n.t('exec_no_alerts'), style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))
              else
                ...alerts.take(6).map(
                      (a) => Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: Icon(
                            Icons.chevron_right,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          title: Text(a['title']?.toString() ?? 'Alert'),
                          subtitle: Text(a['message']?.toString() ?? ''),
                        ),
                      ),
                    ),
              const SizedBox(height: 24),
              Text(l10n.t('control_tower_actions'), style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              if (actions.isEmpty)
                Text(l10n.t('control_tower_no_actions'),
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))
              else
                ...actions.take(5).map(
                      (a) => ListTile(
                        leading: const Icon(Icons.bolt_outlined),
                        title: Text(a.title),
                        subtitle: Text(a.body),
                      ),
                    ),
              const SizedBox(height: 24),
              Row(
                children: [
                  FilledButton.icon(
                    onPressed: () => openFabricCopilotSheet(context),
                    icon: const Icon(Icons.smart_toy_outlined),
                    label: Text(l10n.t('copilot_title')),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () => context.go('/app/executive-report'),
                    child: Text(l10n.t('exec_report_title')),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TowerCard extends StatelessWidget {
  const _TowerCard({
    required this.title,
    required this.value,
    required this.suffix,
    required this.color,
    required this.icon,
  });

  final String title;
  final String value;
  final String suffix;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 10),
              Text(title, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
              const SizedBox(height: 6),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: value,
                      style: TextStyle(
                        color: color,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    TextSpan(
                      text: suffix,
                      style: const TextStyle(color: Color(0xFF8EA3C2), fontSize: 14),
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
