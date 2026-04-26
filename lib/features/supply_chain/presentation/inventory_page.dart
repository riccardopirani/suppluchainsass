import 'package:fabricos/features/app_shell/providers/fabricos_provider.dart';
import 'package:fabricos/features/supply_chain/data/supply_chain_ai_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InventoryPage extends ConsumerStatefulWidget {
  const InventoryPage({super.key});

  @override
  ConsumerState<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends ConsumerState<InventoryPage> {
  bool _busy = false;

  Future<void> _runOptimization(String companyId) async {
    setState(() => _busy = true);
    try {
      final data = await ref.read(supplyChainAiServiceProvider).optimizeInventory(companyId);
      ref.invalidate(inventoryProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Optimization complete: ${(data['recommendations'] as List?)?.length ?? 0} items.')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _toggleAutomation(String companyId, bool enabled) async {
    try {
      await ref
          .read(supplyChainAiServiceProvider)
          .setAutomationEnabled(companyId: companyId, enabled: enabled);
      ref.invalidate(automationEnabledProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not update automation: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final companyIdAsync = ref.watch(currentCompanyIdProvider);
    final inventoryAsync = ref.watch(inventoryProvider);
    final autoAsync = ref.watch(autoOrdersProvider);
    final automationAsync = ref.watch(automationEnabledProvider);
    final ent = ref.watch(subscriptionEntitlementsProvider);

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
                Row(
                  children: [
                    Expanded(child: Text('Inventory Optimization', style: Theme.of(context).textTheme.headlineMedium)),
                    FilledButton.icon(
                      onPressed: (!ent.canUseAiSupplyFeatures || _busy)
                          ? null
                          : () => _runOptimization(companyId),
                      icon: const Icon(Icons.auto_graph_outlined),
                      label: const Text('Optimize inventory'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                automationAsync.when(
                  data: (enabled) => SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Auto-replenishment'),
                    subtitle: Text(
                      ent.canUseFullAutoReplenishment
                          ? 'Automatically create orders when stock falls below reorder point.'
                          : 'Full automatic execution is included in Industriale. Upgrade to enable this switch.',
                    ),
                    value: enabled && ent.canUseFullAutoReplenishment,
                    onChanged: ent.canUseFullAutoReplenishment
                        ? (v) => _toggleAutomation(companyId, v)
                        : null,
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => Text('$e'),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Card(
                          child: inventoryAsync.when(
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (e, _) => Center(child: Text('Error: $e')),
                            data: (items) => ListView.builder(
                              itemCount: items.length,
                              itemBuilder: (context, i) {
                                final item = items[i];
                                final stock = (item['stock_quantity'] as num?)?.toDouble() ?? 0;
                                final reorder = (item['reorder_point'] as num?)?.toDouble() ?? 0;
                                final safety = (item['safety_stock'] as num?)?.toDouble() ?? 0;
                                final status = stock < safety
                                    ? 'CRITICAL'
                                    : stock < reorder
                                        ? 'LOW'
                                        : 'OK';
                                final color = status == 'CRITICAL'
                                    ? const Color(0xFFDC2626)
                                    : status == 'LOW'
                                        ? const Color(0xFFD97706)
                                        : const Color(0xFF15803D);
                                return ListTile(
                                  title: Text(item['item_name']?.toString() ?? ''),
                                  subtitle: Text('Stock: ${stock.toStringAsFixed(1)} · Safety: ${safety.toStringAsFixed(1)} · Reorder: ${reorder.toStringAsFixed(1)}'),
                                  trailing: Chip(
                                    label: Text(status),
                                    backgroundColor: color.withValues(alpha: 0.15),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        flex: 2,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: autoAsync.when(
                              loading: () => const Center(child: CircularProgressIndicator()),
                              error: (e, _) => Text('Error: $e'),
                              data: (rows) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Auto Orders Log', style: Theme.of(context).textTheme.titleMedium),
                                  const SizedBox(height: 10),
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: rows.length,
                                      itemBuilder: (context, i) {
                                        final row = rows[i];
                                        return ListTile(
                                          dense: true,
                                          title: Text('${row['item_id']} · qty ${(row['quantity'] as num?)?.toStringAsFixed(1) ?? '-'}'),
                                          subtitle: Text('${row['status']} · ${row['created_at'] ?? ''}'),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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
