import 'package:fabricos/config/supabase_compile_env.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final envProvider = Provider<Env>((ref) => Env());

class Env {
  Env();

  String get supabaseUrl => SupabaseCompileEnv.url;

  String get supabaseAnonKey => SupabaseCompileEnv.anonKey;
  String get appBaseUrl => const String.fromEnvironment(
    'APP_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );
  String get stripePublishableKey =>
      const String.fromEnvironment('STRIPE_PUBLISHABLE_KEY', defaultValue: '');

  bool get isDevelopment =>
      const String.fromEnvironment('APP_ENV', defaultValue: 'development') ==
      'development';

  /// Optional — when empty, FabricOS Copilot uses the mock service.
  String get openAiApiKey =>
      const String.fromEnvironment('OPENAI_API_KEY', defaultValue: '');
}
