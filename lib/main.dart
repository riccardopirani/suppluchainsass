import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stockguard_ai/app/app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final url = const String.fromEnvironment('SUPABASE_URL', defaultValue: 'https://placeholder.supabase.co');
  final anonKey = const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: 'placeholder-anon-key');
  await Supabase.initialize(url: url, anonKey: anonKey);
  runApp(
    const ProviderScope(
      child: StockGuardApp(),
    ),
  );
}
