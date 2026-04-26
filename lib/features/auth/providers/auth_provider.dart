import 'package:fabricos/config/supabase_placeholder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authStateProvider = StreamProvider<User?>((ref) {
  if (fabricosSupabaseIsPlaceholder) {
    return Stream<User?>.value(null);
  }
  final client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange.map((e) => e.session?.user);
});

final authUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});
