import 'package:fabricos/core/marketing/roi_calculator_logic.dart';
import 'package:fabricos/core/operations/auto_actions_engine.dart';
import 'package:fabricos/features/app_shell/providers/fabricos_provider.dart';
import 'package:fabricos/features/dashboard/data/auto_actions_provider.dart';
import 'package:fabricos/features/dashboard/presentation/widgets/world_globe_view_stub.dart'
    if (dart.library.html)
    'package:fabricos/features/dashboard/presentation/widgets/world_globe_view_web.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshotAsync = ref.watch(dashboardSnapshotProvider);
    final alertsAsync = ref.watch(alertsProvider);
    final machinesAsync = ref.watch(machinesProvider);
    final ordersAsync = ref.watch(ordersProvider);
    final suppliersAsync = ref.watch(suppliersProvider);

    final w = MediaQuery.sizeOf(context).width;
    final hPad = w < 480 ? 12.0 : w < 900 ? 16.0 : 24.0;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 1120;
              if (!isWide) {
                return Column(
                  children: [
                    _HeroPanel(
                      snapshotAsync: snapshotAsync,
                      machinesAsync: machinesAsync,
                    ),
                    const SizedBox(height: 20),
                    _TelemetryPanel(snapshotAsync: snapshotAsync),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 7,
                    child: _HeroPanel(
                      snapshotAsync: snapshotAsync,
                      machinesAsync: machinesAsync,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 3,
                    child: _TelemetryPanel(snapshotAsync: snapshotAsync),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          snapshotAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text('Failed to load KPIs: $err'),
            data: (snapshot) => _ExecutiveKpiRow(
              snapshot: snapshot,
              machinesAsync: machinesAsync,
              suppliersAsync: suppliersAsync,
              alertsAsync: alertsAsync,
            ),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 1120;
              final fulfillment = _Panel(
                child: _FulfillmentChart(ordersAsync: ordersAsync),
              );
              final savings = _Panel(
                child: _SavingsTrendChart(snapshotAsync: snapshotAsync),
              );
              final insights = _Panel(
                child: _AlertPanel(alertsAsync: alertsAsync),
              );
              if (!isWide) {
                return Column(
                  children: [
                    SizedBox(height: 300, child: fulfillment),
                    const SizedBox(height: 20),
                    SizedBox(height: 260, child: savings),
                    const SizedBox(height: 20),
                    SizedBox(height: 400, child: insights),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 5, child: SizedBox(height: 340, child: fulfillment)),
                      const SizedBox(width: 20),
                      Expanded(flex: 4, child: SizedBox(height: 340, child: savings)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(height: 420, child: insights),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          snapshotAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (snapshot) => _OpsTrendsRow(snapshot: snapshot),
          ),
          const SizedBox(height: 20),
          Consumer(
            builder: (context, ref, _) {
              final actions = ref.watch(autoActionsProvider);
              return _Panel(
                child: _DailyActionsPanel(actions: actions),
              );
            },
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 1120;
              final ordersPanel = _Panel(
                child: _RecentOrdersTable(ordersAsync: ordersAsync),
              );
              final queuesPanel = _Panel(
                child: _PriorityQueues(
                  suppliersAsync: suppliersAsync,
                  machinesAsync: machinesAsync,
                ),
              );
              if (!isWide) {
                return Column(
                  children: [
                    SizedBox(height: 380, child: ordersPanel),
                    const SizedBox(height: 20),
                    queuesPanel,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 6, child: SizedBox(height: 400, child: ordersPanel)),
                  const SizedBox(width: 20),
                  Expanded(flex: 4, child: queuesPanel),
                ],
              );
            },
          ),
        ],
      ),
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

  static List<Map<String, dynamic>> _globePointsFromMachines(
    List<Map<String, dynamic>> machines,
  ) {
    return machines
        .map((machine) {
          final latitude = _toDouble(machine['latitude']);
          final longitude = _toDouble(machine['longitude']);
          if (latitude == null || longitude == null) return null;

          return {
            'name': machine['name']?.toString() ?? 'Machine',
            'city': machine['city']?.toString() ?? '',
            'country': machine['country']?.toString() ?? '',
            'address': machine['address']?.toString() ?? '',
            'status': machine['status']?.toString() ?? 'running',
            'latitude': latitude,
            'longitude': longitude,
          };
        })
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}

class _OpsTrendsRow extends StatelessWidget {
  const _OpsTrendsRow({required this.snapshot});

  final DashboardSnapshot snapshot;

  static List<FlSpot> _series(double start, double drift) {
    return List.generate(
      14,
      (i) => FlSpot(i.toDouble(), (start + drift * i + (i % 4) * 0.25).clamp(0, 500)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final downIdx = (snapshot.stoppedMachines * 2.8 + snapshot.warningMachines * 1.2).clamp(3.0, 56.0);
    final supScore = (92 - snapshot.delayedSuppliers * 5.0).clamp(38.0, 96.0);
    final turns = (6.8 - snapshot.openAlerts * 0.07).clamp(2.2, 9.4);

    Widget chartCard(String title, String subtitle, List<FlSpot> spots, Color color) {
      return _Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(color: Color(0xFFEAF2FF), fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Color(0xFF8EA3C2), fontSize: 12)),
            const SizedBox(height: 10),
            SizedBox(
              height: 130,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) => const FlLine(
                      color: Color(0x148EA3C2),
                      dashArray: [4, 4],
                    ),
                  ),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: color,
                      barWidth: 2.5,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [color.withValues(alpha: 0.35), color.withValues(alpha: 0)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, c) {
        final downtimeSpots = _series(downIdx * 0.35, -0.07);
        final supplierSpots = _series(supScore * 0.92, 0.035);
        final inventorySpots = _series(turns, 0.018);

        if (c.maxWidth < 900) {
          return Column(
            children: [
              chartCard(
                'Downtime trend',
                'Directional hours index — last 14 days',
                downtimeSpots,
                const Color(0xFFF97316),
              ),
              const SizedBox(height: 16),
              chartCard(
                'Supplier performance',
                'Composite reliability score',
                supplierSpots,
                const Color(0xFF38BDF8),
              ),
              const SizedBox(height: 16),
              chartCard(
                'Inventory turnover',
                'Turns per month (proxy)',
                inventorySpots,
                const Color(0xFF34D399),
              ),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: chartCard(
                'Downtime trend',
                'Directional hours index — last 14 days',
                downtimeSpots,
                const Color(0xFFF97316),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: chartCard(
                'Supplier performance',
                'Composite reliability score',
                supplierSpots,
                const Color(0xFF38BDF8),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: chartCard(
                'Inventory turnover',
                'Turns per month (proxy)',
                inventorySpots,
                const Color(0xFF34D399),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ExecutiveKpiRow extends ConsumerWidget {
  const _ExecutiveKpiRow({
    required this.snapshot,
    required this.machinesAsync,
    required this.suppliersAsync,
    required this.alertsAsync,
  });

  final DashboardSnapshot snapshot;
  final AsyncValue<List<Map<String, dynamic>>> machinesAsync;
  final AsyncValue<List<Map<String, dynamic>>> suppliersAsync;
  final AsyncValue<List<Map<String, dynamic>>> alertsAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final machines = machinesAsync.valueOrNull ?? const [];
    final suppliers = suppliersAsync.valueOrNull ?? const [];
    final totalM = machines.isEmpty ? 1 : machines.length;
    final running = machines.where((m) => m['status'] == 'running').length;
    final machineHealth = (running * 100 / totalM).round().clamp(0, 100);
    final supTotal = suppliers.length;
    final reliabilityPct = supTotal == 0
        ? 94
        : (((supTotal - snapshot.delayedSuppliers) / supTotal) * 100).round().clamp(0, 100);
    final invEff = (100 - snapshot.openAlerts * 3).clamp(45, 99);
    final savings = RoiCalculatorLogic.estimate(
      monthlyRevenue: 1800000,
      downtimeHours: (snapshot.stoppedMachines + snapshot.warningMachines) * 4.0,
      avgDelayCostPerEvent: snapshot.delayedSuppliers * 3500.0,
      inventoryValue: 1200000,
    ).estimatedMonthlySavings;
    final criticalOpen = alertsAsync.maybeWhen(
      data: (alerts) => alerts
          .where((a) => a['resolved'] != true && (a['severity'] ?? '').toString() == 'critical')
          .length,
      orElse: () => 0,
    );

    final tiles = [
      _ExecTile('Active orders', '${snapshot.activeOrders}', Icons.fact_check_outlined, const Color(0xFF7DD3FC)),
      _ExecTile('Machine health', '$machineHealth%', Icons.precision_manufacturing_outlined, const Color(0xFF34D399)),
      _ExecTile('Supplier reliability', '$reliabilityPct%', Icons.local_shipping_outlined, const Color(0xFFFBBF24)),
      _ExecTile('Inventory efficiency', '$invEff%', Icons.inventory_2_outlined, const Color(0xFFA78BFA)),
      _ExecTile('Monthly savings (est.)', '€${savings.round()}', Icons.savings_outlined, const Color(0xFF2DD4BF)),
      _ExecTile('Open critical alerts', '$criticalOpen', Icons.crisis_alert_outlined, const Color(0xFFF472B6)),
    ];

    return LayoutBuilder(
      builder: (context, c) {
        final cols = c.maxWidth >= 1300 ? 6 : c.maxWidth >= 800 ? 3 : c.maxWidth >= 520 ? 2 : 1;
        return GridView.count(
          crossAxisCount: cols,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: cols == 1 ? 3.25 : cols == 6 ? 1.95 : 1.75,
          children: tiles,
        );
      },
    );
  }
}

class _ExecTile extends StatelessWidget {
  const _ExecTile(this.label, this.value, this.icon, this.color);
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1A2436)),
        gradient: const LinearGradient(
          colors: [Color(0xF508111F), Color(0xEB09101D)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label, style: const TextStyle(color: Color(0xFF8EA3C2), fontSize: 12)),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Color(0xFFEAF2FF),
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavingsTrendChart extends StatelessWidget {
  const _SavingsTrendChart({required this.snapshotAsync});

  final AsyncValue<DashboardSnapshot> snapshotAsync;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cost savings trend',
          style: TextStyle(color: Color(0xFFEAF2FF), fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        const Text(
          'Illustrative 14-day trajectory from alert and delay reduction.',
          style: TextStyle(color: Color(0xFF8EA3C2), fontSize: 13),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: snapshotAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('$e'),
            data: (snap) {
              final base = RoiCalculatorLogic.estimate(
                monthlyRevenue: 1800000,
                downtimeHours: (snap.stoppedMachines + snap.warningMachines) * 4.0,
                avgDelayCostPerEvent: snap.delayedSuppliers * 3500.0,
                inventoryValue: 1200000,
              ).estimatedMonthlySavings;
              final spots = List.generate(
                14,
                (i) => FlSpot(i.toDouble(), (base * (0.65 + i * 0.025)).clamp(0, base * 1.4)),
              );
              return LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: const Color(0x228EA3C2),
                      dashArray: [4, 4],
                    ),
                  ),
                  titlesData: const FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: const Color(0xFF34D399),
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0x4434D399),
                            const Color(0x0034D399),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DailyActionsPanel extends StatelessWidget {
  const _DailyActionsPanel({required this.actions});

  final List<AutoActionSuggestion> actions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Daily actions (auto rules)',
          style: TextStyle(color: Color(0xFFEAF2FF), fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        const Text(
          'Reorder, maintenance, and vendor flags generated from live thresholds.',
          style: TextStyle(color: Color(0xFF8EA3C2), fontSize: 13),
        ),
        const SizedBox(height: 14),
        if (actions.isEmpty)
          const Text('No rule-based actions right now.', style: TextStyle(color: Color(0xFF8EA3C2)))
        else
          ...actions.take(6).map((a) {
            final color = switch (a.severity) {
              AutoActionSeverity.critical => const Color(0xFFDC2626),
              AutoActionSeverity.warning => const Color(0xFFFBBF24),
              AutoActionSeverity.info => const Color(0xFF7DD3FC),
            };
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color(0x0FFFFFFF),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.bolt_outlined, color: color, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a.title,
                          style: const TextStyle(
                            color: Color(0xFFEAF2FF),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          a.body,
                          style: const TextStyle(color: Color(0xFF8EA3C2), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1A2436)),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xF508111F), Color(0xEB09101D)],
        ),
      ),
      child: Padding(padding: const EdgeInsets.all(20), child: child),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({required this.snapshotAsync, required this.machinesAsync});

  final AsyncValue<dynamic> snapshotAsync;
  final AsyncValue<List<Map<String, dynamic>>> machinesAsync;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const RadialGradient(
                    center: Alignment.topRight,
                    radius: 1.0,
                    colors: [Color(0x147DD3FC), Color(0x00000000)],
                  ),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: const Color(0x1434D399),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.rocket_launch_outlined, size: 13, color: Color(0xFF34D399)),
                    SizedBox(width: 6),
                    Text(
                      'Mission status nominal',
                      style: TextStyle(
                        color: Color(0xFF34D399),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Executive control for a high-velocity supply network.',
                style: TextStyle(
                  color: Color(0xFFEAF2FF),
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -1.0,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Critical signals are surfaced first so teams align on throughput, risk and resilience in seconds.',
                style: TextStyle(color: Color(0xFF8EA3C2), fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 16),
              snapshotAsync.when(
                loading: () => const CircularProgressIndicator(),
                error: (err, _) => Text('Error: $err'),
                data: (snapshot) => Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _HeroStat(
                      label: 'Network uptime',
                      value: '99.72%',
                      foot: '+0.4 vs last cycle',
                    ),
                    _HeroStat(
                      label: 'Orders in motion',
                      value: snapshot.activeOrders.toString(),
                      foot: '${snapshot.openAlerts} priority class',
                    ),
                    _HeroStat(
                      label: 'Factories online',
                      value: '${snapshot.runningMachines}/${snapshot.runningMachines + snapshot.warningMachines + snapshot.stoppedMachines}',
                      foot: '${snapshot.warningMachines + snapshot.stoppedMachines} diagnostics',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 260,
                child: machinesAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(child: Text('Failed to load map: $err')),
                  data: (machines) => WorldGlobeView(
                    points: DashboardPage._globePointsFromMachines(machines),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.label, required this.value, required this.foot});

  final String label;
  final String value;
  final String foot;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0x8C040A14),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x267DD3FC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF8EA3C2), fontSize: 12)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFFEAF2FF),
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(foot, style: const TextStyle(color: Color(0xFF7DD3FC), fontSize: 11)),
        ],
      ),
    );
  }
}

class _TelemetryPanel extends StatelessWidget {
  const _TelemetryPanel({required this.snapshotAsync});

  final AsyncValue<dynamic> snapshotAsync;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Live telemetry',
            style: TextStyle(color: Color(0xFFEAF2FF), fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          const Text(
            'Key operational signals across the chain.',
            style: TextStyle(color: Color(0xFF8EA3C2), fontSize: 13),
          ),
          const SizedBox(height: 14),
          snapshotAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text('Error: $err'),
            data: (snapshot) => Column(
              children: [
                _telemetryRow('Machine cluster health', 'Stable ${snapshot.runningMachines}', ok: true),
                _telemetryRow('Inventory risk index', '${snapshot.openAlerts} flagged', warn: true),
                _telemetryRow('Supplier latency', '${snapshot.delayedSuppliers} delayed'),
                _telemetryRow('Subscription access', 'Enterprise tier'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _telemetryRow(String label, String value, {bool ok = false, bool warn = false}) {
    final color = ok
        ? const Color(0xFF34D399)
        : warn
            ? const Color(0xFFFBBF24)
            : const Color(0xFFEAF2FF);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0x0FFFFFFF),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: Color(0xFF8EA3C2), fontSize: 13))),
          Text(value, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _FulfillmentChart extends StatelessWidget {
  const _FulfillmentChart({required this.ordersAsync});

  final AsyncValue<List<Map<String, dynamic>>> ordersAsync;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fulfillment velocity',
          style: TextStyle(color: Color(0xFFEAF2FF), fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        const Text(
          'Daily shipped units with reduced visual noise.',
          style: TextStyle(color: Color(0xFF8EA3C2), fontSize: 13),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ordersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text('Error: $err'),
            data: (orders) {
              final bars = _buildVelocityBars(orders);
              return BarChart(
                BarChartData(
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 2,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: const Color(0x228EA3C2),
                      dashArray: [4, 4],
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                          final index = value.toInt();
                          if (index < 0 || index >= labels.length) return const SizedBox.shrink();
                          return Text(labels[index], style: const TextStyle(color: Color(0xFF8EA3C2), fontSize: 11));
                        },
                      ),
                    ),
                  ),
                  barGroups: bars,
                  maxY: 10,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  List<BarChartGroupData> _buildVelocityBars(List<Map<String, dynamic>> orders) {
    final bucket = List<int>.filled(7, 0);
    for (final order in orders) {
      final date = DateTime.tryParse(order['created_at']?.toString() ?? '');
      if (date == null) continue;
      final weekday = date.weekday - 1;
      bucket[weekday] = bucket[weekday] + 1;
    }
    return List.generate(7, (i) {
      final value = bucket[i] == 0 ? (i + 2) : bucket[i].clamp(1, 10);
      return BarChartGroupData(
        x: i,
        barsSpace: 4,
        barRods: [
          BarChartRodData(toY: (value * 0.35).toDouble(), color: const Color(0x22EAF2FF), width: 14),
          BarChartRodData(
            toY: value.toDouble(),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF7DD3FC), Color(0x5538BDF8)],
            ),
            width: 14,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ],
      );
    });
  }
}

class _AlertPanel extends StatelessWidget {
  const _AlertPanel({required this.alertsAsync});

  final AsyncValue<List<Map<String, dynamic>>> alertsAsync;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AI insights feed',
          style: TextStyle(color: Color(0xFFEAF2FF), fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        const Text(
          'Machine risk, supplier slippage, stock criticality and margin alerts — prioritized.',
          style: TextStyle(color: Color(0xFF8EA3C2), fontSize: 13),
        ),
        const SizedBox(height: 14),
        alertsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Text('Error: $err'),
          data: (alerts) {
            final visible = alerts.take(8).toList();
            if (visible.isEmpty) {
              return const Text('No alerts right now.', style: TextStyle(color: Color(0xFF8EA3C2)));
            }
            return Column(
              children: visible.map((alert) {
                final severity = (alert['severity'] ?? 'info').toString();
                final color = DashboardPage._severityColor(severity);
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: const Color(0x0FFFFFFF),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.notifications_active_outlined, color: color, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              alert['title']?.toString() ?? 'Alert',
                              style: const TextStyle(color: Color(0xFFEAF2FF), fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              alert['message']?.toString() ?? '',
                              style: const TextStyle(color: Color(0xFF8EA3C2), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: color.withValues(alpha: 0.15),
                        ),
                        child: Text(
                          severity.toUpperCase(),
                          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _RecentOrdersTable extends StatelessWidget {
  const _RecentOrdersTable({required this.ordersAsync});

  final AsyncValue<List<Map<String, dynamic>>> ordersAsync;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent orders',
          style: TextStyle(color: Color(0xFFEAF2FF), fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        const Text(
          'A concise operational ledger for fast executive review.',
          style: TextStyle(color: Color(0xFF8EA3C2), fontSize: 13),
        ),
        const SizedBox(height: 14),
        ordersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Text('Error: $err'),
          data: (orders) => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingTextStyle: const TextStyle(color: Color(0xFF8EA3C2), fontSize: 12, fontWeight: FontWeight.w600),
              dataTextStyle: const TextStyle(color: Color(0xFFEAF2FF), fontSize: 13),
              columns: const [
                DataColumn(label: Text('Order ID')),
                DataColumn(label: Text('Supplier')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('ETA')),
              ],
              rows: orders.take(4).map((order) {
                final status = order['status']?.toString() ?? 'pending';
                return DataRow(
                  cells: [
                    DataCell(Text(order['order_number']?.toString() ?? '-')),
                    DataCell(Text((order['suppliers'] as Map?)?['name']?.toString() ?? 'Supplier')),
                    DataCell(_statusChip(status)),
                    DataCell(
                      Text(
                        DateTime.tryParse(order['expected_delivery_date']?.toString() ?? '')?.toIso8601String().split('T').first ?? '-',
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _statusChip(String status) {
    final (color, label) = switch (status) {
      'completed' => (const Color(0xFF34D399), 'Delivered'),
      'in_progress' => (const Color(0xFF7DD3FC), 'In transit'),
      _ => (const Color(0xFFFBBF24), 'Delayed'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withValues(alpha: 0.15),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class _PriorityQueues extends StatelessWidget {
  const _PriorityQueues({required this.suppliersAsync, required this.machinesAsync});

  final AsyncValue<List<Map<String, dynamic>>> suppliersAsync;
  final AsyncValue<List<Map<String, dynamic>>> machinesAsync;

  @override
  Widget build(BuildContext context) {
    final suppliers = suppliersAsync.valueOrNull ?? const [];
    final machines = machinesAsync.valueOrNull ?? const [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Priority queues',
          style: TextStyle(color: Color(0xFFEAF2FF), fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        const Text(
          'Compact overview for teams and filtered permission states.',
          style: TextStyle(color: Color(0xFF8EA3C2), fontSize: 13),
        ),
        const SizedBox(height: 14),
        _miniRow('Billing review', 'Visible only with proper plan access', '2 items'),
        _miniRow('Supplier audits', 'Filtered for non-admin if needed', '${suppliers.length} open'),
        _miniRow('Simulation runs', 'Next scenario batch at 14:30 UTC', '18 queued'),
        _miniRow('Onboarding gate', 'Pre-dashboard flow for incomplete setup', machines.isEmpty ? 'Idle' : 'Enabled'),
      ],
    );
  }

  Widget _miniRow(String title, String subtitle, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0x0FFFFFFF),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Color(0xFFEAF2FF), fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Text(subtitle, style: const TextStyle(color: Color(0xFF8EA3C2), fontSize: 12)),
              ],
            ),
          ),
          Text(value, style: const TextStyle(color: Color(0xFFEAF2FF), fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
