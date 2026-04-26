import 'package:fabricos/config/supabase_compile_env.dart';
import 'package:fabricos/config/supabase_placeholder.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Initializes Supabase. In **release** (all platforms) and **non-web debug**,
/// real compile-time env vars are required.
///
/// **Debug web only:** if vars are missing, a placeholder project URL/key is used
/// so the marketing shell and UI load; login and Edge Functions will not work
/// until you run `./scripts/run_web.sh` or pass `--dart-define=...`.
Future<void> bootstrapSupabase() async {
  if (SupabaseCompileEnv.isConfigured) {
    fabricosSupabaseIsPlaceholder = false;
    await Supabase.initialize(
      url: SupabaseCompileEnv.url,
      anonKey: SupabaseCompileEnv.anonKey,
    );
    return;
  }

  if (kReleaseMode || !kIsWeb || !kDebugMode) {
    throw FlutterError.fromParts(<DiagnosticsNode>[
      ErrorSummary('Supabase is not configured.'),
      ErrorDescription(
        'Set SUPABASE_URL and SUPABASE_ANON_KEY (see .env.example). '
        'For Chrome: ./scripts/run_web.sh or '
        '--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...',
      ),
    ]);
  }

  fabricosSupabaseIsPlaceholder = true;
  debugPrint(
    'FABRICOS: Supabase env missing — web debug placeholder. '
    'Marketing UI works; auth/API need ./scripts/run_web.sh or dart-define.',
  );

  // Well-formed URL/key shape; not a real project — avoids init assertions.
  await Supabase.initialize(
    url: 'https://fabricos-local-preview.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYW5vbiIsImlzcyI6ImZhYnJpY29zLXByZXZpZXcifQ.'
        'fabricosPlaceholderSignatureNotForProductionUse0123456789abcdef',
  );
}
