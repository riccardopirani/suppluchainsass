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
final productsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final supabase = Supabase.instance.client;
  final workspaceId = await ref.watch(currentWorkspaceProvider.future);
  
  return await supabase
      .from('products')
      .select()
      .eq('workspace_id', workspaceId)
      .order('created_at', ascending: false);
});

// Get all suppliers for current workspace
final suppliersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final supabase = Supabase.instance.client;
  final workspaceId = await ref.watch(currentWorkspaceProvider.future);
  
  return await supabase
      .from('suppliers')
      .select()
      .eq('workspace_id', workspaceId)
      .order('created_at', ascending: false);
});

// Get all reorder recommendations for current workspace
final reorderRecommendationsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final supabase = Supabase.instance.client;
  final workspaceId = await ref.watch(currentWorkspaceProvider.future);
  
  return await supabase
      .from('reorder_recommendations')
      .select()
      .eq('workspace_id', workspaceId)
      .order('created_at', ascending: false);
});

// Get all forecasts for current workspace
final forecastsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
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
final purchaseOrdersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final supabase = Supabase.instance.client;
  final workspaceId = await ref.watch(currentWorkspaceProvider.future);
  
  return await supabase
      .from('purchase_orders')
      .select()
      .eq('workspace_id', workspaceId)
      .order('created_at', ascending: false);
});

// Get sales history for current workspace
final salesHistoryProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final supabase = Supabase.instance.client;
  final workspaceId = await ref.watch(currentWorkspaceProvider.future);
  
  return await supabase
      .from('sales_history')
      .select()
      .eq('workspace_id', workspaceId)
      .order('sale_date', ascending: false);
});
