import 'package:supabase_flutter/supabase_flutter.dart';

const List<String> _companyTables = <String>['cg_companies', 'companies'];

Future<Map<String, dynamic>?> fetchCompanyRow(
  SupabaseClient client,
  String companyId, {
  String columns = 'id, name',
}) async {
  for (final table in _companyTables) {
    try {
      final row = await client
          .from(table)
          .select(columns)
          .eq('id', companyId)
          .maybeSingle();
      if (row != null) {
        return Map<String, dynamic>.from(row);
      }
    } catch (_) {
      // Try the next table name. Live and local schema names differ in this repo.
    }
  }
  return null;
}

Future<String?> fetchCompanyName(
  SupabaseClient client,
  String? companyId,
) async {
  if (companyId == null || companyId.isEmpty) return null;
  final row = await fetchCompanyRow(client, companyId);
  return row?['name']?.toString();
}
