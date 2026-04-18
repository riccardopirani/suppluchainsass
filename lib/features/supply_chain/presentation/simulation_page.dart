import 'package:fabricos/core/operations/what_if_estimator.dart';
import 'package:fabricos/features/app_shell/providers/fabricos_provider.dart';
import 'package:fabricos/features/supply_chain/data/supply_chain_ai_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SimulationPage extends ConsumerStatefulWidget {
  const SimulationPage({super.key});

  @override
  ConsumerState<SimulationPage> createState() => _SimulationPageState();
}

class _SimulationPageState extends ConsumerState<SimulationPage> {
  String _scenario = 'supplier_delay';
  final _valueController = TextEditingController(text: '5');
  final _delayDays = TextEditingController(text: '3');
  final _demandSpike = TextEditingController(text: '8');
  final _outageHours = TextEditingController(text: '12');
  final _materialPricePct = TextEditingController(text: '0');
  bool _busy = false;
  Map<String, dynamic>? _lastResult;
  Map<String, dynamic>? _localWhatIf;

  @override
  void dispose() {
    _valueController.dispose();
    _delayDays.dispose();
    _demandSpike.dispose();
    _outageHours.dispose();
    _materialPricePct.dispose();
    super.dispose();
  }

  void _runLocalWhatIf() {
    final r = WhatIfEstimator.combined(
      supplierDelayDays: double.tryParse(_delayDays.text) ?? 0,
      demandSpikePercent: double.tryParse(_demandSpike.text) ?? 0,
      machineOutageHours: double.tryParse(_outageHours.text) ?? 0,
      materialPriceIncreasePercent: double.tryParse(_materialPricePct.text) ?? 0,
    );
    setState(() => _localWhatIf = r);
  }

  @override
  Widget build(BuildContext context) {
    final companyIdAsync = ref.watch(currentCompanyIdProvider);
    final historyAsync = ref.watch(simulationsProvider);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: companyIdAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
            data: (companyId) => ListView(
              children: [
                Text('What-if simulator', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  'Model supplier delay, demand shock and machine outage — see directional revenue, stockout and delay risk.',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Combined scenario (fast)', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 12),
                        LayoutBuilder(
                          builder: (context, c) {
                            final narrow = c.maxWidth < 720;
                            Widget field(TextEditingController ctrl, String label) {
                              return TextField(
                                controller: ctrl,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: label,
                                  border: const OutlineInputBorder(),
                                ),
                              );
                            }

                            final children = [
                              field(_delayDays, 'Supplier delay (days)'),
                              field(_demandSpike, 'Demand spike (%)'),
                              field(_outageHours, 'Machine outage (hours)'),
                              field(_materialPricePct, 'Material price increase (%)'),
                            ];
                            if (narrow) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  for (var i = 0; i < children.length; i++) ...[
                                    if (i > 0) const SizedBox(height: 12),
                                    children[i],
                                  ],
                                ],
                              );
                            }
                            return Row(
                              children: [
                                for (var i = 0; i < children.length; i++) ...[
                                  if (i > 0) const SizedBox(width: 12),
                                  Expanded(child: children[i]),
                                ],
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: _runLocalWhatIf,
                          icon: const Icon(Icons.calculate_outlined),
                          label: const Text('Estimate impact'),
                        ),
                        if (_localWhatIf != null) ...[
                          const SizedBox(height: 16),
                          _metricTiles(_localWhatIf!),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Backend simulation', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _scenario,
                                items: const [
                                  DropdownMenuItem(value: 'supplier_delay', child: Text('Supplier delay')),
                                  DropdownMenuItem(value: 'demand_spike', child: Text('Demand spike')),
                                  DropdownMenuItem(
                                    value: 'transport_disruption',
                                    child: Text('Transport disruption'),
                                  ),
                                ],
                                onChanged: (v) => setState(() => _scenario = v ?? 'supplier_delay'),
                                decoration: const InputDecoration(labelText: 'Scenario type'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 200,
                              child: TextField(
                                controller: _valueController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'Input value'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            FilledButton.icon(
                              onPressed: _busy
                                  ? null
                                  : () async {
                                      setState(() => _busy = true);
                                      try {
                                        final key = _scenario == 'supplier_delay'
                                            ? 'days'
                                            : _scenario == 'demand_spike'
                                                ? 'spikePercent'
                                                : 'disruptionHours';
                                        final result = await ref.read(supplyChainAiServiceProvider).runSimulation(
                                              companyId: companyId,
                                              scenarioType: _scenario,
                                              inputData: {
                                                key: double.tryParse(_valueController.text) ?? 0,
                                              },
                                            );
                                        ref.invalidate(simulationsProvider);
                                        setState(() => _lastResult = result);
                                      } finally {
                                        if (mounted) setState(() => _busy = false);
                                      }
                                    },
                              icon: const Icon(Icons.science_outlined),
                              label: const Text('Run simulation'),
                            ),
                          ],
                        ),
                        if (_lastResult != null && _lastResult!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          SelectableText(
                            _prettyMap(_lastResult!),
                            style: const TextStyle(fontSize: 13, height: 1.4),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('History', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                historyAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Error: $e'),
                  data: (rows) => Column(
                    children: rows
                        .map(
                          (row) => ListTile(
                            title: Text(row['scenario_type']?.toString() ?? '-'),
                            subtitle: Text('Input: ${row['input_data']}'),
                            trailing: Text(row['created_at']?.toString().split('T').first ?? ''),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _metricTiles(Map<String, dynamic> m) {
    final rev = (m['revenue_impact_eur'] as num?)?.toDouble() ?? 0;
    final stock = (m['stockout_risk_pct'] as num?)?.toDouble() ?? 0;
    final delay = (m['production_delay_days'] as num?)?.toDouble() ?? 0;
    final margin = (m['margin_impact_eur'] as num?)?.toDouble() ?? 0;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _tile('Revenue impact (€)', rev.round().toString(), rev <= 0 ? Colors.orange : Colors.green),
        _tile('Margin impact (€)', margin.round().toString(), margin <= 0 ? Colors.deepOrange : Colors.teal),
        _tile('Delay impact (d)', delay.toStringAsFixed(1), Colors.blueGrey),
        _tile('Stockout probability', '${stock.toStringAsFixed(0)}%', Colors.redAccent),
      ],
    );
  }

  Widget _tile(String label, String value, Color c) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.withValues(alpha: 0.35)),
        color: c.withValues(alpha: 0.08),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(color: c, fontSize: 20, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  String _prettyMap(Map<String, dynamic> map) {
    final b = StringBuffer();
    for (final e in map.entries) {
      b.writeln('${e.key}: ${e.value}');
    }
    return b.toString();
  }
}
