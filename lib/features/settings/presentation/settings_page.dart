import 'package:fabricos/features/app_shell/providers/fabricos_provider.dart';
import 'package:fabricos/features/website/presentation/widgets/language_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(fabricUserContextProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: userAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) =>
                Center(child: Text('Unable to load profile: $err')),
            data: (user) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 24),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.person_outline),
                        title: const Text('User'),
                        subtitle: Text(
                          '${user.fullName.isEmpty ? user.email : user.fullName} · ${user.role}',
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.business_outlined),
                        title: const Text('Company'),
                        subtitle: Text(user.companyName ?? 'Not configured'),
                        trailing: TextButton(
                          onPressed: () => context.go('/onboarding'),
                          child: const Text('Edit'),
                        ),
                      ),
                      const Divider(height: 1),
                      const ListTile(
                        leading: Icon(Icons.dark_mode_outlined),
                        title: Text('Theme mode'),
                        subtitle: Text(
                          'FabricOS follows your system light/dark mode.',
                        ),
                      ),
                      const Divider(height: 1),
                      const ListTile(
                        leading: Icon(Icons.language_outlined),
                        title: Text('Language'),
                        trailing: LanguageSelector(),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.logout),
                        title: const Text('Sign out'),
                        onTap: () async {
                          await Supabase.instance.client.auth.signOut();
                          if (context.mounted) context.go('/');
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
