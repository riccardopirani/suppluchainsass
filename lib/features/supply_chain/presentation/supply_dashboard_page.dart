import 'package:fabricos/core/theme/intelligence_theme.dart';
import 'package:fabricos/features/app_shell/providers/fabricos_provider.dart';
import 'package:fabricos/features/supply_chain/data/supply_chain_ai_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SupplyDashboardPage extends ConsumerStatefulWidget {
  const SupplyDashboardPage({super.key});

  @override
  ConsumerState<SupplyDashboardPage> createState() =>
      _SupplyDashboardPageState();
}

class _SupplyDashboardPageState extends ConsumerState<SupplyDashboardPage> {
  bool _busy = false;
  List<Map<String, dynamic>> _costSuggestions = const [];

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(ordersProvider);
    final suppliersAsync = ref.watch(suppliersProvider);
    final inventoryAsync = ref.watch(inventoryProvider);
    final disruptionsAsync = ref.watch(disruptionsProvider);
    final forecastAsync = ref.watch(demandForecastProvider);
    final companyIdAsync = ref.watch(currentCompanyIdProvider);
    final ent = ref.watch(subscriptionEntitlementsProvider);

    return Scaffold(
      backgroundColor: IntelligenceTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Supply Chain Visibility',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: IntelligenceTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'AI-first command center for demand, inventory, risk and disruptions.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: IntelligenceTheme.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 12),
              companyIdAsync.when(
                data: (companyId) => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      onPressed: (!ent.canUseForecasting || _busy)
                          ? null
                          : () => _runAction(() async {
                              await ref
                                  .read(supplyChainAiServiceProvider)
                                  .predictDemand(companyId);
                              ref.invalidate(demandForecastProvider);
                            }),
                      icon: const Icon(Icons.trending_up_outlined),
                      label: const Text('Predict demand'),
                    ),
                    OutlinedButton.icon(
                      onPressed: (!ent.canUseAiSupplyFeatures || _busy)
                          ? null
                          : () => _runAction(() async {
                              await ref
                                  .read(supplyChainAiServiceProvider)
                                  .detectDisruptions(companyId);
                              ref.invalidate(disruptionsProvider);
                            }),
                      icon: const Icon(Icons.warning_amber_outlined),
                      label: const Text('Detect disruptions'),
                    ),
                    OutlinedButton.icon(
                      onPressed:
                          (!ent.canUseCostInventoryOptimizationAi || _busy)
                          ? null
                          : () => _runAction(() async {
                              final data = await ref
                                  .read(supplyChainAiServiceProvider)
                                  .optimizeCosts(companyId);
                              final suggestions =
                                  (data['suggestions'] as List? ?? const [])
                                      .whereType<Map>()
                                      .map((e) => e.cast<String, dynamic>())
                                      .toList();
                              setState(() => _costSuggestions = suggestions);
                            }),
                      icon: const Icon(Icons.euro_outlined),
                      label: const Text('Optimize costs'),
                    ),
                  ],
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _kpiCard(
                    context,
                    'Total orders',
                    ordersAsync.valueOrNull?.length.toString() ?? '-',
                    Icons.fact_check_outlined,
                  ),
                  _kpiCard(
                    context,
                    'Delayed shipments',
                    ((ordersAsync.valueOrNull ?? const [])
                            .where(
                              (o) =>
                                  ((o['delay_days'] as num?)?.toInt() ?? 0) > 0,
                            )
                            .length)
                        .toString(),
                    Icons.local_shipping_outlined,
                  ),
                  _kpiCard(
                    context,
                    'Supplier risk avg',
                    _supplierRiskAvg(
                      suppliersAsync.valueOrNull,
                    ).toStringAsFixed(1),
                    Icons.insights_outlined,
                  ),
                  _kpiCard(
                    context,
                    'Inventory health',
                    '${_inventoryHealth(inventoryAsync.valueOrNull).toStringAsFixed(0)}%',
                    Icons.inventory_2_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                color: IntelligenceTheme.panel,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: IntelligenceTheme.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    height: 220,
                    child: !ent.canUseForecasting
                        ? _forecastLockedPlaceholder(context)
                        : forecastAsync.when(
                            data: (rows) => _forecastChart(context, rows),
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            error: (e, _) => Text('Forecast unavailable: $e'),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (_costSuggestions.isNotEmpty)
                Card(
                  color: IntelligenceTheme.panel,
                  surfaceTintColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: IntelligenceTheme.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cost Optimization Insights',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: IntelligenceTheme.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 8),
                        ..._costSuggestions.map(
                          (s) => ListTile(
                            dense: true,
                            title: Text(
                              s['message']?.toString() ?? '',
                              style: const TextStyle(
                                color: IntelligenceTheme.textSecondary,
                              ),
                            ),
                            trailing: Text(
                              '€${(s['estimated_saving'] as num?)?.toStringAsFixed(0) ?? '-'}',
                              style: const TextStyle(
                                color: IntelligenceTheme.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Card(
                color: IntelligenceTheme.panel,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: IntelligenceTheme.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: disruptionsAsync.when(
                    data: (rows) {
                      if (rows.isEmpty) {
                        return const Text(
                          'No disruptions detected.',
                          style: TextStyle(
                            color: IntelligenceTheme.textSecondary,
                          ),
                        );
                      }
                      return Column(
                        children: rows.take(8).map((d) {
                          final severity = (d['severity'] ?? 'info').toString();
                          final color = severity == 'critical'
                              ? const Color(0xFFDC2626)
                              : severity == 'warning'
                              ? const Color(0xFFD97706)
                              : const Color(0xFF0E7490);
                          return ListTile(
                            dense: true,
                            leading: Icon(
                              Icons.warning_amber_rounded,
                              color: color,
                            ),
                            title: Text(
                              d['message']?.toString() ?? '',
                              style: const TextStyle(
                                color: IntelligenceTheme.textPrimary,
                              ),
                            ),
                            subtitle: Text(
                              '${d['type']} · ${d['created_at'] ?? ''}',
                              style: const TextStyle(
                                color: IntelligenceTheme.textSecondary,
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text(
                      'Disruptions unavailable: $e',
                      style: const TextStyle(
                        color: IntelligenceTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _forecastLockedPlaceholder(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Demand forecasting is available from Professionale upward.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: IntelligenceTheme.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => context.push('/app/billing'),
              child: const Text('View plans'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _runAction(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  static Widget _forecastChart(
    BuildContext context,
    List<Map<String, dynamic>> rows,
  ) {
    final grouped = <String, double>{};
    for (final row in rows.take(30)) {
      final day = row['forecast_date']?.toString() ?? '';
      grouped[day] =
          (grouped[day] ?? 0) +
          ((row['predicted_quantity'] as num?)?.toDouble() ?? 0);
    }
    final entries = grouped.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final spots = <FlSpot>[
      for (int i = 0; i < entries.length; i++)
        FlSpot(i.toDouble(), entries[i].value),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Demand Forecast (next 30 days)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: IntelligenceTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: const FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  barWidth: 3,
                  color: IntelligenceTheme.accentStrong,
                  dotData: const FlDotData(show: false),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static Widget _kpiCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
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
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(icon, color: IntelligenceTheme.accent),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: IntelligenceTheme.textSecondary,
                    ),
                  ),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: IntelligenceTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static double _supplierRiskAvg(List<Map<String, dynamic>>? suppliers) {
    if (suppliers == null || suppliers.isEmpty) return 0;
    final total = suppliers.fold<double>(
      0,
      (sum, s) => sum + ((s['risk_score'] as num?)?.toDouble() ?? 50),
    );
    return total / suppliers.length;
  }

  static double _inventoryHealth(List<Map<String, dynamic>>? inventory) {
    if (inventory == null || inventory.isEmpty) return 100;
    final healthy = inventory.where((i) {
      final stock = (i['stock_quantity'] as num?)?.toDouble() ?? 0;
      final reorder = (i['reorder_point'] as num?)?.toDouble() ?? 0;
      return stock >= reorder;
    }).length;
    return (healthy / inventory.length) * 100;
  }
}
