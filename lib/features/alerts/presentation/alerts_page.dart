import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fabricos/localization/app_localizations.dart';
import 'package:fabricos/features/app_shell/providers/workspace_provider.dart';

class AlertsPage extends ConsumerWidget {
  const AlertsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsyncValue = ref.watch(alertsProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.t('alerts'),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: alertsAsyncValue.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                  data: (alerts) {
                    if (alerts.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_outlined,
                              size: 64,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No alerts',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: alerts.length,
                      itemBuilder: (context, i) {
                        final alert = alerts[i];
                        final severity = (alert['severity'] ?? 'info')
                            .toString();

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: Icon(
                              severity == 'critical'
                                  ? Icons.warning_amber
                                  : Icons.info_outline,
                              color: severity == 'critical'
                                  ? Colors.red
                                  : severity == 'warning'
                                  ? Colors.orange
                                  : Theme.of(context).colorScheme.primary,
                            ),
                            title: Text(alert['title'] ?? 'Alert'),
                            subtitle: Text(alert['message'] ?? ''),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
