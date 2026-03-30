import 'package:fabricos/features/app_shell/providers/fabricos_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supplyChainAiServiceProvider = Provider<SupplyChainAiService>((ref) {
  final client = ref.watch(fabricSupabaseClientProvider);
  return SupplyChainAiService(client);
});

final demandForecastProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final client = ref.watch(fabricSupabaseClientProvider);
  final companyId = await ref.watch(currentCompanyIdProvider.future);
  return client
      .from('demand_forecasts')
      .select()
      .eq('company_id', companyId)
      .order('forecast_date', ascending: true)
      .limit(120);
});

final inventoryProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final client = ref.watch(fabricSupabaseClientProvider);
  final companyId = await ref.watch(currentCompanyIdProvider.future);
  return client.from('inventory').select().eq('company_id', companyId).order('item_name');
});

final disruptionsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) async* {
  final client = ref.watch(fabricSupabaseClientProvider);
  final companyId = await ref.watch(currentCompanyIdProvider.future);
  yield* client
      .from('supply_disruptions')
      .stream(primaryKey: ['id'])
      .eq('company_id', companyId)
      .order('created_at', ascending: false);
});

final shipmentsPageProvider = StateProvider<int>((ref) => 0);

final shipmentsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final client = ref.watch(fabricSupabaseClientProvider);
  final companyId = await ref.watch(currentCompanyIdProvider.future);
  final page = ref.watch(shipmentsPageProvider);
  const pageSize = 20;
  return client
      .from('shipments')
      .select('*, orders(order_number)')
      .eq('company_id', companyId)
      .order('created_at', ascending: false)
      .range(page * pageSize, page * pageSize + pageSize - 1);
});

final autoOrdersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final client = ref.watch(fabricSupabaseClientProvider);
  final companyId = await ref.watch(currentCompanyIdProvider.future);
  return client
      .from('auto_orders')
      .select()
      .eq('company_id', companyId)
      .order('created_at', ascending: false)
      .limit(40);
});

final warehousesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final client = ref.watch(fabricSupabaseClientProvider);
  final companyId = await ref.watch(currentCompanyIdProvider.future);
  return client.from('warehouses').select().eq('company_id', companyId).order('name');
});

final inventoryLocationsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final client = ref.watch(fabricSupabaseClientProvider);
  final companyId = await ref.watch(currentCompanyIdProvider.future);
  return client
      .from('inventory_locations')
      .select('*, warehouses!inner(company_id,name)')
      .eq('warehouses.company_id', companyId)
      .order('item_id');
});

final simulationsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final client = ref.watch(fabricSupabaseClientProvider);
  final companyId = await ref.watch(currentCompanyIdProvider.future);
  return client
      .from('simulations')
      .select()
      .eq('company_id', companyId)
      .order('created_at', ascending: false)
      .limit(30);
});

final automationEnabledProvider = FutureProvider<bool>((ref) async {
  final client = ref.watch(fabricSupabaseClientProvider);
  final companyId = await ref.watch(currentCompanyIdProvider.future);
  final row = await client
      .from('automation_settings')
      .select('auto_replenishment_enabled')
      .eq('company_id', companyId)
      .maybeSingle();
  return (row?['auto_replenishment_enabled'] as bool?) ?? false;
});

class SupplyChainAiService {
  SupplyChainAiService(this._client);
  final SupabaseClient _client;

  Future<Map<String, dynamic>> predictDemand(String companyId) async {
    final res = await _client.functions.invoke('predict-demand', body: {'companyId': companyId});
    return (res.data as Map?)?.cast<String, dynamic>() ?? {};
  }

  Future<Map<String, dynamic>> optimizeInventory(String companyId) async {
    final res = await _client.functions.invoke('optimize-inventory', body: {'companyId': companyId});
    return (res.data as Map?)?.cast<String, dynamic>() ?? {};
  }

  Future<Map<String, dynamic>> detectDisruptions(String companyId) async {
    final res = await _client.functions.invoke('detect-disruptions', body: {'companyId': companyId});
    return (res.data as Map?)?.cast<String, dynamic>() ?? {};
  }

  Future<Map<String, dynamic>> analyzeSupplierRisk(String companyId) async {
    final res = await _client.functions.invoke('analyze-supplier-risk', body: {'companyId': companyId});
    return (res.data as Map?)?.cast<String, dynamic>() ?? {};
  }

  Future<Map<String, dynamic>> autoReplenishment(String companyId) async {
    final res = await _client.functions.invoke('auto-replenishment', body: {'companyId': companyId});
    return (res.data as Map?)?.cast<String, dynamic>() ?? {};
  }

  Future<Map<String, dynamic>> optimizeCosts(String companyId) async {
    final res = await _client.functions.invoke('optimize-costs', body: {'companyId': companyId});
    return (res.data as Map?)?.cast<String, dynamic>() ?? {};
  }

  Future<Map<String, dynamic>> runSimulation({
    required String companyId,
    required String scenarioType,
    required Map<String, dynamic> inputData,
  }) async {
    final res = await _client.functions.invoke(
      'run-simulation',
      body: {'companyId': companyId, 'scenarioType': scenarioType, 'inputData': inputData},
    );
    return (res.data as Map?)?.cast<String, dynamic>() ?? {};
  }

  Future<void> setAutomationEnabled({
    required String companyId,
    required bool enabled,
  }) async {
    await _client.from('automation_settings').upsert({
      'company_id': companyId,
      'auto_replenishment_enabled': enabled,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}
