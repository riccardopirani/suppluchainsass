import 'package:flutter_riverpod/flutter_riverpod.dart';

final envProvider = Provider<Env>((ref) => Env());

class Env {
  Env();

  String get supabaseUrl => const String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: String.fromEnvironment(
      'NEXT_PUBLIC_SUPABASE_URL',
      defaultValue: 'https://ouieulumtrnnjsjtlyxe.supabase.co',
    ),
  );
  String get supabaseAnonKey => const String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: String.fromEnvironment(
      'SUPABASE_PUBLISHABLE_DEFAULT_KEY',
      defaultValue: String.fromEnvironment(
        'NEXT_PUBLIC_SUPABASE_PUBLISHABLE_DEFAULT_KEY',
        defaultValue: 'sb_publishable_JNTjWqrSduUw_ZQtLF22Ug_tBl-QyMG',
      ),
    ),
  );
  String get appBaseUrl => const String.fromEnvironment(
    'APP_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );
  String get stripePublishableKey =>
      const String.fromEnvironment('STRIPE_PUBLISHABLE_KEY', defaultValue: '');

  bool get isDevelopment =>
      const String.fromEnvironment('APP_ENV', defaultValue: 'development') ==
      'development';
}
