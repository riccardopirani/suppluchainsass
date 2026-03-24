import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Get current user's workspace ID
final currentWorkspaceProvider = FutureProvider<String>((ref) async {
  final supabase = Supabase.instance.client;
  final userId = supabase.auth.currentUser?.id;

  if (userId == null) throw Exception('User not authenticated');

  final result = await supabase
      .from('workspace_members')
      .select('workspace_id')
      .eq('user_id', userId)
      .limit(1)
      .single();

  return result['workspace_id'];
});

// Get all products for current workspace
final productsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final supabase = Supabase.instance.client;
  final workspaceId = await ref.watch(currentWorkspaceProvider.future);

  return await supabase
      .from('products')
      .select()
      .eq('workspace_id', workspaceId)
      .order('created_at', ascending: false);
});

// Get all suppliers for current workspace
final suppliersProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final supabase = Supabase.instance.client;
  final workspaceId = await ref.watch(currentWorkspaceProvider.future);

  return await supabase
      .from('suppliers')
      .select()
      .eq('workspace_id', workspaceId)
      .order('created_at', ascending: false);
});

// Get all reorder recommendations for current workspace
final reorderRecommendationsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
      final supabase = Supabase.instance.client;
      final workspaceId = await ref.watch(currentWorkspaceProvider.future);

      return await supabase
          .from('reorder_recommendations')
          .select()
          .eq('workspace_id', workspaceId)
          .order('created_at', ascending: false);
    });

// Get all forecasts for current workspace
final forecastsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final supabase = Supabase.instance.client;
  final workspaceId = await ref.watch(currentWorkspaceProvider.future);

  return await supabase
      .from('forecasts')
      .select()
      .eq('workspace_id', workspaceId)
      .order('created_at', ascending: false);
});

// Get all alerts for current workspace
final alertsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final supabase = Supabase.instance.client;
  final workspaceId = await ref.watch(currentWorkspaceProvider.future);

  return await supabase
      .from('alerts')
      .select()
      .eq('workspace_id', workspaceId)
      .order('created_at', ascending: false);
});

// Get all purchase orders for current workspace
final purchaseOrdersProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final supabase = Supabase.instance.client;
  final workspaceId = await ref.watch(currentWorkspaceProvider.future);

  return await supabase
      .from('purchase_orders')
      .select()
      .eq('workspace_id', workspaceId)
      .order('created_at', ascending: false);
});

// Get sales history for current workspace
final salesHistoryProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final supabase = Supabase.instance.client;
  final workspaceId = await ref.watch(currentWorkspaceProvider.future);

  return await supabase
      .from('sales_history')
      .select()
      .eq('workspace_id', workspaceId)
      .order('sale_date', ascending: false);
});

// Get all warehouses for current workspace
final warehousesProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final supabase = Supabase.instance.client;
  final workspaceId = await ref.watch(currentWorkspaceProvider.future);

  return await supabase
      .from('warehouses')
      .select()
      .eq('workspace_id', workspaceId)
      .order('name', ascending: true);
});

// Selected warehouse ID (state provider)
final selectedWarehouseProvider = StateProvider<String?>((ref) {
  return null;
});

// Get current selected warehouse
final currentWarehouseProvider = FutureProvider<Map<String, dynamic>?>((
  ref,
) async {
  final selectedId = ref.watch(selectedWarehouseProvider);
  if (selectedId == null) {
    // Try to get default warehouse
    final supabase = Supabase.instance.client;
    final workspaceId = await ref.watch(currentWorkspaceProvider.future);

    final defaultWarehouse = await supabase
        .from('warehouses')
        .select()
        .eq('workspace_id', workspaceId)
        .eq('is_default', true)
        .limit(1)
        .maybeSingle();

    return defaultWarehouse;
  }

  final supabase = Supabase.instance.client;
  return await supabase
      .from('warehouses')
      .select()
      .eq('id', selectedId)
      .limit(1)
      .maybeSingle();
});

// Get product inventory for selected warehouse
final productInventoryProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final supabase = Supabase.instance.client;
  final warehouse = await ref.watch(currentWarehouseProvider.future);

  if (warehouse == null) {
    return [];
  }

  return await supabase
      .from('product_inventory')
      .select()
      .eq('warehouse_id', warehouse['id'])
      .order('created_at', ascending: false);
});
