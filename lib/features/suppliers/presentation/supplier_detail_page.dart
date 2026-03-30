import 'package:fabricos/features/app_shell/providers/fabricos_provider.dart';
import 'package:fabricos/features/supply_chain/data/supply_chain_ai_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SupplierDetailPage extends ConsumerWidget {
  const SupplierDetailPage({super.key, required this.supplierId});
  final String supplierId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suppliersAsync = ref.watch(suppliersProvider);
    final companyIdAsync = ref.watch(currentCompanyIdProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: suppliersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (suppliers) {
              final supplier = suppliers.firstWhere(
                (s) => s['id']?.toString() == supplierId,
                orElse: () => <String, dynamic>{},
              );
              if (supplier.isEmpty) return const Center(child: Text('Supplier not found'));
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          supplier['name']?.toString() ?? 'Supplier',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      companyIdAsync.when(
                        data: (companyId) => FilledButton.icon(
                          onPressed: () async {
                            await ref.read(supplyChainAiServiceProvider).analyzeSupplierRisk(companyId);
                            ref.invalidate(suppliersProvider);
                          },
                          icon: const Icon(Icons.auto_graph_outlined),
                          label: const Text('Recalculate AI risk'),
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _riskBar(context, 'Total risk score', (supplier['risk_score'] as num?)?.toDouble() ?? 0),
                  _riskBar(context, 'Financial risk', (supplier['financial_risk'] as num?)?.toDouble() ?? 0),
                  _riskBar(context, 'Delivery risk', (supplier['delivery_risk'] as num?)?.toDouble() ?? 0),
                  _riskBar(context, 'Compliance risk', (supplier['compliance_risk'] as num?)?.toDouble() ?? 0),
                  const SizedBox(height: 16),
                  Text('Last evaluation: ${supplier['last_evaluation'] ?? '-'}'),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  static Widget _riskBar(BuildContext context, String label, double value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label · ${value.toStringAsFixed(1)}'),
          const SizedBox(height: 6),
          LinearProgressIndicator(value: (value / 100).clamp(0, 1)),
        ],
      ),
    );
  }
}
