import 'package:fabricos/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: String.fromEnvironment(
      'NEXT_PUBLIC_SUPABASE_URL',
      defaultValue: 'https://ouieulumtrnnjsjtlyxe.supabase.co',
    ),
  );
  const anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: String.fromEnvironment(
      'SUPABASE_PUBLISHABLE_DEFAULT_KEY',
      defaultValue: String.fromEnvironment(
        'NEXT_PUBLIC_SUPABASE_PUBLISHABLE_DEFAULT_KEY',
        defaultValue: 'sb_publishable_JNTjWqrSduUw_ZQtLF22Ug_tBl-QyMG',
      ),
    ),
  );

  await Supabase.initialize(url: url, anonKey: anonKey);
  runApp(const ProviderScope(child: FabricOSApp()));
}
