import 'package:fabricos/features/supply_chain/data/supply_chain_ai_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShipmentsPage extends ConsumerWidget {
  const ShipmentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final page = ref.watch(shipmentsPageProvider);
    final shipmentsAsync = ref.watch(shipmentsProvider);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Shipment Tracking', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'Simulated shipment visibility with status timeline.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: Card(
                  child: shipmentsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e')),
                    data: (rows) => ListView.builder(
                      itemCount: rows.length,
                      itemBuilder: (context, i) {
                        final row = rows[i];
                        final status = row['status']?.toString() ?? 'in_transit';
                        final color = status == 'delayed'
                            ? const Color(0xFFDC2626)
                            : status == 'delivered'
                                ? const Color(0xFF15803D)
                                : const Color(0xFF0E7490);
                        final order = row['orders'] as Map<String, dynamic>?;
                        return ListTile(
                          leading: Icon(Icons.local_shipping_outlined, color: color),
                          title: Text('Order ${order?['order_number'] ?? row['order_id']}'),
                          subtitle: Text('ETA: ${row['eta'] ?? '-'} · Location: ${row['location'] ?? '-'}'),
                          trailing: Chip(
                            label: Text(status.toUpperCase()),
                            backgroundColor: color.withValues(alpha: 0.14),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: page > 0 ? () => ref.read(shipmentsPageProvider.notifier).state = page - 1 : null,
                    child: const Text('Previous'),
                  ),
                  const SizedBox(width: 8),
                  Text('Page ${page + 1}'),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () => ref.read(shipmentsPageProvider.notifier).state = page + 1,
                    child: const Text('Next'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
