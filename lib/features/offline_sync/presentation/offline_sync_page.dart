import 'package:fabricos/features/app_shell/providers/fabricos_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OfflineSyncPage extends ConsumerStatefulWidget {
  const OfflineSyncPage({super.key});

  @override
  ConsumerState<OfflineSyncPage> createState() => _OfflineSyncPageState();
}

class _OfflineSyncPageState extends ConsumerState<OfflineSyncPage> {
  bool _syncing = false;

  Future<void> _queueDemoOperation() async {
    final companyId = await ref.read(currentCompanyIdProvider.future);
    final machines = ref.read(machinesProvider).valueOrNull;
    final machineId = (machines != null && machines.isNotEmpty)
        ? machines.first['id']?.toString()
        : null;
    await ref.read(fabricosRepositoryProvider).enqueueOfflineOperation(
          companyId: companyId,
          entityType: 'production_quick_logs',
          operationType: 'insert',
          payload: {
            'eventType': 'production',
            'quantity': 5,
            'notes': 'Queued from Offline Sync UI',
            'machineId': machineId,
            'happenedAt': DateTime.now().toIso8601String(),
          },
        );
    ref.invalidate(offlineSyncQueueProvider);
  }

  Future<void> _runSync() async {
    final companyId = await ref.read(currentCompanyIdProvider.future);
    setState(() => _syncing = true);
    try {
      await ref.read(fabricosRepositoryProvider).applyOfflineSyncBatch(
            companyId: companyId,
          );
      ref.invalidate(offlineSyncQueueProvider);
      ref.invalidate(productionQuickLogsProvider);
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final queue = ref.watch(offlineSyncQueueProvider);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Offline Sync',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _queueDemoOperation,
                      child: const Text('Queue demo op'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: _syncing ? null : _runSync,
                      child: Text(_syncing ? 'Syncing...' : 'Sync now'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: Card(
                  child: queue.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Errore: $e')),
                    data: (rows) => ListView.separated(
                      itemCount: rows.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final row = rows[index];
                        return ListTile(
                          leading: Icon(
                            row['status'] == 'applied'
                                ? Icons.check_circle_outline
                                : row['status'] == 'conflict'
                                    ? Icons.error_outline
                                    : Icons.sync_outlined,
                          ),
                          title: Text(
                            '${row['entity_type']} · ${row['operation_type']}',
                          ),
                          subtitle: Text(
                            'status: ${row['status']} · op: ${row['client_operation_id']}',
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
