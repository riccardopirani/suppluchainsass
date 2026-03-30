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
  bool _busy = false;
  Map<String, dynamic>? _lastResult;

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
            data: (companyId) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Scenario Simulation', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 10),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _scenario,
                            items: const [
                              DropdownMenuItem(value: 'supplier_delay', child: Text('Supplier delay')),
                              DropdownMenuItem(value: 'demand_spike', child: Text('Demand spike')),
                              DropdownMenuItem(value: 'transport_disruption', child: Text('Transport disruption')),
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
                                      inputData: {key: double.tryParse(_valueController.text) ?? 0},
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
                  ),
                ),
                const SizedBox(height: 12),
                if (_lastResult != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(_lastResult.toString()),
                    ),
                  ),
                const SizedBox(height: 12),
                Expanded(
                  child: Card(
                    child: historyAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text('Error: $e')),
                      data: (rows) => ListView.builder(
                        itemCount: rows.length,
                        itemBuilder: (context, i) {
                          final row = rows[i];
                          return ListTile(
                            title: Text(row['scenario_type']?.toString() ?? '-'),
                            subtitle: Text('Input: ${row['input_data']}'),
                            trailing: Text(row['created_at']?.toString().split('T').first ?? ''),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
