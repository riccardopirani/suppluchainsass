import 'package:fabricos/app/app.dart';
import 'package:fabricos/config/supabase_compile_env.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final url = SupabaseCompileEnv.url;
  final anonKey = SupabaseCompileEnv.anonKey;

  if (!SupabaseCompileEnv.isConfigured) {
    throw FlutterError.fromParts(<DiagnosticsNode>[
      ErrorSummary('Supabase is not configured.'),
      ErrorDescription(
        'Pass dart-defines, e.g. '
        '--dart-define=NEXT_PUBLIC_SUPABASE_URL=https://xxx.supabase.co '
        '--dart-define=NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY=sb_publishable_... '
        'or use SUPABASE_URL / SUPABASE_ANON_KEY. See .env.example.',
      ),
    ]);
  }

  await Supabase.initialize(url: url, anonKey: anonKey);
  runApp(const ProviderScope(child: FabricOSApp()));
}
