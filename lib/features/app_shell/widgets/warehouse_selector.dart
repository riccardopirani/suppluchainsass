import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/app_shell/providers/workspace_provider.dart';

class WarehouseSelector extends ConsumerWidget {
  const WarehouseSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final warehousesAsync = ref.watch(warehousesProvider);
    final selectedId = ref.watch(selectedWarehouseProvider);

    return warehousesAsync.when(
      loading: () => const SizedBox(
        height: 40,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Text('Error loading warehouses: $err'),
      data: (warehouses) {
        if (warehouses.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('No warehouses available'),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: DropdownButton<String>(
            value: selectedId,
            hint: const Text('Select Warehouse'),
            onChanged: (String? warehouseId) {
              if (warehouseId != null) {
                ref.read(selectedWarehouseProvider.notifier).state = warehouseId;
              }
            },
            items: warehouses
                .map(
                  (w) => DropdownMenuItem<String>(
                    value: w['id'] as String,
                    child: Text(w['name'] as String),
                  ),
                )
                .toList(),
            isExpanded: true,
          ),
        );
      },
    );
  }
}
