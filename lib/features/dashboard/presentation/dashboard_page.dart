import 'package:fabricos/features/app_shell/providers/fabricos_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshotAsync = ref.watch(dashboardSnapshotProvider);
    final alertsAsync = ref.watch(alertsProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Operations Dashboard',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 6),
              Text(
                'Live overview for maintenance, orders, suppliers and compliance.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              snapshotAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Text('Failed to load KPIs: $err'),
                data: (snapshot) {
                  return Column(
                    children: [
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          _KpiCard(
                            label: 'Active orders',
                            value: snapshot.activeOrders.toString(),
                            icon: Icons.fact_check_outlined,
                            color: const Color(0xFF0E7490),
                          ),
                          _KpiCard(
                            label: 'Machines running',
                            value: snapshot.runningMachines.toString(),
                            icon: Icons.precision_manufacturing_outlined,
                            color: const Color(0xFF15803D),
                          ),
                          _KpiCard(
                            label: 'Supplier delays',
                            value: snapshot.delayedSuppliers.toString(),
                            icon: Icons.local_shipping_outlined,
                            color: const Color(0xFFB45309),
                          ),
                          _KpiCard(
                            label: 'Open alerts',
                            value: snapshot.openAlerts.toString(),
                            icon: Icons.warning_amber_rounded,
                            color: const Color(0xFFB91C1C),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: SizedBox(
                            height: 220,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Machine status breakdown',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 12),
                                Expanded(
                                  child: BarChart(
                                    BarChartData(
                                      maxY:
                                          [
                                                snapshot.runningMachines,
                                                snapshot.warningMachines,
                                                snapshot.stoppedMachines,
                                              ]
                                              .reduce((a, b) => a > b ? a : b)
                                              .toDouble() +
                                          2,
                                      borderData: FlBorderData(show: false),
                                      gridData: const FlGridData(show: false),
                                      titlesData: FlTitlesData(
                                        leftTitles: const AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: false,
                                          ),
                                        ),
                                        rightTitles: const AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: false,
                                          ),
                                        ),
                                        topTitles: const AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: false,
                                          ),
                                        ),
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            getTitlesWidget: (value, _) {
                                              final labels = [
                                                'Running',
                                                'Warning',
                                                'Stopped',
                                              ];
                                              final index = value.toInt();
                                              if (index < 0 ||
                                                  index >= labels.length) {
                                                return const SizedBox.shrink();
                                              }
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 8,
                                                ),
                                                child: Text(
                                                  labels[index],
                                                  style: Theme.of(
                                                    context,
                                                  ).textTheme.bodySmall,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      barGroups: [
                                        _barGroup(
                                          0,
                                          snapshot.runningMachines,
                                          const Color(0xFF15803D),
                                        ),
                                        _barGroup(
                                          1,
                                          snapshot.warningMachines,
                                          const Color(0xFFF59E0B),
                                        ),
                                        _barGroup(
                                          2,
                                          snapshot.stoppedMachines,
                                          const Color(0xFFDC2626),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'AI alerts',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          IconButton(
                            tooltip: 'Refresh alerts',
                            onPressed: () => ref.invalidate(alertsProvider),
                            icon: const Icon(Icons.refresh),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      alertsAsync.when(
                        loading: () => const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (err, _) => Text('Failed to load alerts: $err'),
                        data: (alerts) {
                          if (alerts.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Text('No alerts right now.'),
                            );
                          }

                          final visible = alerts.take(6).toList();
                          return Column(
                            children: visible.map((alert) {
                              final severity = (alert['severity'] ?? 'info')
                                  .toString();
                              final color = _severityColor(severity);

                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(
                                  Icons.notifications_active_outlined,
                                  color: color,
                                ),
                                title: Text(
                                  alert['title']?.toString() ?? 'Alert',
                                ),
                                subtitle: Text(
                                  alert['message']?.toString() ?? '',
                                ),
                                trailing: Chip(
                                  label: Text(severity.toUpperCase()),
                                  backgroundColor: color.withValues(
                                    alpha: 0.12,
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static BarChartGroupData _barGroup(int x, int value, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: value.toDouble(),
          width: 24,
          borderRadius: BorderRadius.circular(6),
          color: color,
        ),
      ],
    );
  }

  static Color _severityColor(String severity) {
    switch (severity) {
      case 'critical':
        return const Color(0xFFDC2626);
      case 'warning':
        return const Color(0xFFD97706);
      default:
        return const Color(0xFF0E7490);
    }
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final cardWidth = width > 1200
        ? 250.0
        : (width > 850 ? (width - 120) / 2 : width - 64);

    return SizedBox(
      width: cardWidth,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 2),
                  Text(value, style: Theme.of(context).textTheme.headlineSmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
