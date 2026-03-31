import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final teamMembersProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, companyId) async {
  final client = Supabase.instance.client;
  final rows = await client
      .from('team_members')
      .select()
      .eq('company_id', companyId)
      .order('created_at', ascending: false);
  return List<Map<String, dynamic>>.from(rows);
});

final menuPermissionsProvider = FutureProvider.family<List<String>?, ({String companyId, String role})>((ref, params) async {
  final client = Supabase.instance.client;
  final row = await client
      .from('menu_permissions')
      .select('allowed_routes')
      .eq('company_id', params.companyId)
      .eq('role', params.role)
      .maybeSingle();
  if (row == null) return null;
  final routes = row['allowed_routes'];
  if (routes is List) return routes.cast<String>();
  return null;
});

final userCompaniesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final client = Supabase.instance.client;
  final userId = client.auth.currentUser?.id;
  if (userId == null) return [];
  final rows = await client
      .from('team_members')
      .select('company_id, role, companies:company_id(name)')
      .eq('user_id', userId)
      .eq('status', 'active');
  final ownProfile = await client
      .from('users')
      .select('company_id, role, companies:company_id(name)')
      .eq('id', userId)
      .maybeSingle();
  final result = <String, Map<String, dynamic>>{};
  if (ownProfile != null && ownProfile['company_id'] != null) {
    result[ownProfile['company_id'] as String] = {
      'company_id': ownProfile['company_id'],
      'role': ownProfile['role'],
      'company_name': (ownProfile['companies'] as Map?)?['name'] ?? '',
    };
  }
  for (final r in List<Map<String, dynamic>>.from(rows)) {
    final cId = r['company_id'] as String;
    if (!result.containsKey(cId)) {
      result[cId] = {
        'company_id': cId,
        'role': r['role'],
        'company_name': (r['companies'] as Map?)?['name'] ?? '',
      };
    }
  }
  return result.values.toList();
});

class TeamService {
  TeamService(this._client);
  final SupabaseClient _client;

  Future<Map<String, dynamic>> inviteUser({
    required String companyId,
    required String email,
    String role = 'operator',
    String? fullName,
  }) async {
    final response = await _client.functions.invoke(
      'invite-user',
      body: {
        'companyId': companyId,
        'email': email,
        'role': role,
        'fullName': fullName ?? '',
      },
    );
    final data = response.data;
    if (response.status >= 400) {
      throw Exception(data is Map ? data['error'] ?? 'Invite failed' : 'Invite failed');
    }
    return data is Map<String, dynamic> ? data : {};
  }

  Future<void> removeMember(String memberId) async {
    await _client.from('team_members').delete().eq('id', memberId);
  }

  Future<void> updateMemberRole(String memberId, String newRole) async {
    await _client.from('team_members').update({'role': newRole}).eq('id', memberId);
  }

  Future<void> updateMenuPermissions({
    required String companyId,
    required String role,
    required List<String> allowedRoutes,
  }) async {
    await _client.from('menu_permissions').upsert({
      'company_id': companyId,
      'role': role,
      'allowed_routes': allowedRoutes,
    }, onConflict: 'company_id,role');
  }

  Future<void> switchCompany(String userId, String companyId) async {
    await _client.from('users').update({'company_id': companyId}).eq('id', userId);
  }
}

final teamServiceProvider = Provider<TeamService>((ref) {
  return TeamService(Supabase.instance.client);
});
