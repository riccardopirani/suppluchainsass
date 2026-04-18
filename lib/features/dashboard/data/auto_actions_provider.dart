import 'package:fabricos/core/operations/auto_actions_engine.dart';
import 'package:fabricos/features/app_shell/providers/fabricos_provider.dart';
import 'package:fabricos/features/supply_chain/data/supply_chain_ai_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final autoActionsProvider = Provider<List<AutoActionSuggestion>>((ref) {
  final inv = ref.watch(inventoryProvider).valueOrNull ?? const [];
  final machines = ref.watch(machinesProvider).valueOrNull ?? const [];
  final suppliers = ref.watch(suppliersProvider).valueOrNull ?? const [];
  final snap = ref.watch(dashboardSnapshotProvider).valueOrNull;
  if (snap == null) return const [];
  return const AutoActionsEngine().evaluate(
    inventoryRows: inv,
    machines: machines,
    suppliers: suppliers,
    openAlerts: snap.openAlerts,
    delayedSuppliers: snap.delayedSuppliers,
  );
});
