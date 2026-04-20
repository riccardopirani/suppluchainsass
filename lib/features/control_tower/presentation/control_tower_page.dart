import 'package:fabricos/core/marketing/roi_calculator_logic.dart';
import 'package:fabricos/core/theme/intelligence_theme.dart';
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
      child: DecoratedBox(
        decoration: const BoxDecoration(color: IntelligenceTheme.background),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: snapAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text(
              '$e',
              style: const TextStyle(color: IntelligenceTheme.textSecondary),
            ),
            data: (snap) {
              final alerts = alertsAsync.valueOrNull ?? const [];
              final critical = alerts
                  .where((a) => a['severity'] == 'critical')
                  .length;
              final estLeak = RoiCalculatorLogic.estimate(
                monthlyRevenue: 2000000,
                downtimeHours:
                    (snap.stoppedMachines + snap.warningMachines) * 5.0,
                avgDelayCostPerEvent: snap.delayedSuppliers * 4800.0,
                inventoryValue: 1500000,
              );
              final health = (100 - critical * 12 - snap.openAlerts * 2).clamp(
                20,
                100,
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.t('control_tower_title'),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: IntelligenceTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.t('control_tower_subtitle'),
                    style: const TextStyle(
                      color: IntelligenceTheme.textSecondary,
                      height: 1.45,
                    ),
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
                        color: IntelligenceTheme.success,
                        icon: Icons.health_and_safety_outlined,
                      ),
                      _TowerCard(
                        title: l10n.t('control_tower_leak'),
                        value:
                            '€${(estLeak.downtimeCost + estLeak.delayCost * 0.4).round()}',
                        suffix: l10n.t('control_tower_leak_suffix'),
                        color: IntelligenceTheme.warning,
                        icon: Icons.trending_down_rounded,
                      ),
                      _TowerCard(
                        title: l10n.t('control_tower_delays'),
                        value: '${snap.delayedSuppliers}',
                        suffix: l10n.t('control_tower_delays_suffix'),
                        color: IntelligenceTheme.accent,
                        icon: Icons.schedule_rounded,
                      ),
                      _TowerCard(
                        title: l10n.t('control_tower_alerts'),
                        value: '$critical',
                        suffix: l10n.t('control_tower_critical_suffix'),
                        color: IntelligenceTheme.danger,
                        icon: Icons.warning_amber_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text(
                    l10n.t('control_tower_risks'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: IntelligenceTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (alerts.isEmpty)
                    Text(
                      l10n.t('exec_no_alerts'),
                      style: const TextStyle(
                        color: IntelligenceTheme.textSecondary,
                      ),
                    )
                  else
                    ...alerts
                        .take(6)
                        .map(
                          (a) => Card(
                            color: IntelligenceTheme.panel,
                            surfaceTintColor: Colors.transparent,
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(
                                color: IntelligenceTheme.border,
                              ),
                            ),
                            child: ListTile(
                              leading: const Icon(
                                Icons.chevron_right,
                                color: IntelligenceTheme.accent,
                              ),
                              title: Text(
                                a['title']?.toString() ?? 'Alert',
                                style: const TextStyle(
                                  color: IntelligenceTheme.textPrimary,
                                ),
                              ),
                              subtitle: Text(
                                a['message']?.toString() ?? '',
                                style: const TextStyle(
                                  color: IntelligenceTheme.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.t('control_tower_actions'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: IntelligenceTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (actions.isEmpty)
                    Text(
                      l10n.t('control_tower_no_actions'),
                      style: const TextStyle(
                        color: IntelligenceTheme.textSecondary,
                      ),
                    )
                  else
                    ...actions
                        .take(5)
                        .map(
                          (a) => ListTile(
                            leading: const Icon(
                              Icons.bolt_outlined,
                              color: IntelligenceTheme.accent,
                            ),
                            title: Text(
                              a.title,
                              style: const TextStyle(
                                color: IntelligenceTheme.textPrimary,
                              ),
                            ),
                            subtitle: Text(
                              a.body,
                              style: const TextStyle(
                                color: IntelligenceTheme.textSecondary,
                              ),
                            ),
                          ),
                        ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FilledButton.icon(
                        onPressed: () => openFabricCopilotSheet(context),
                        icon: const Icon(Icons.smart_toy_outlined),
                        label: Text(l10n.t('copilot_title')),
                      ),
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
        ),
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
        color: IntelligenceTheme.panel,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: IntelligenceTheme.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  color: IntelligenceTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
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
                      style: const TextStyle(
                        color: IntelligenceTheme.textMuted,
                        fontSize: 14,
                      ),
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
