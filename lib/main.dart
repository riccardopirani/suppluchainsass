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
        'Local web: copy .env.example to .env, set SUPABASE_URL and SUPABASE_ANON_KEY, '
        'then run ./scripts/run_web.sh (or pass --dart-define=SUPABASE_URL=... '
        '--dart-define=SUPABASE_ANON_KEY=... with flutter run). '
        'See .env.example.',
      ),
    ]);
  }

  await Supabase.initialize(url: url, anonKey: anonKey);
  runApp(const ProviderScope(child: FabricOSApp()));
}
