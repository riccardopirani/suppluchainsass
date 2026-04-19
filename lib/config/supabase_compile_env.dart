/// Compile-time Supabase settings via `--dart-define` / IDE launch configs.
/// Do not commit real keys or URLs here — use `.env` only locally (gitignored).
abstract final class SupabaseCompileEnv {
  SupabaseCompileEnv._();

  /// Prefer `SUPABASE_URL`, then `NEXT_PUBLIC_SUPABASE_URL`.
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: String.fromEnvironment(
      'NEXT_PUBLIC_SUPABASE_URL',
      defaultValue: '',
    ),
  );

  /// Prefer service-role-style anon key env names used across tooling.
  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: String.fromEnvironment(
      'SUPABASE_PUBLISHABLE_DEFAULT_KEY',
      defaultValue: String.fromEnvironment(
        'NEXT_PUBLIC_SUPABASE_PUBLISHABLE_DEFAULT_KEY',
        defaultValue: String.fromEnvironment(
          'NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY',
          defaultValue: '',
        ),
      ),
    ),
  );

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
