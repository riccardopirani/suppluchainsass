import 'package:fabricos/features/app_shell/providers/fabricos_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MachinesPage extends ConsumerStatefulWidget {
  const MachinesPage({super.key});

  @override
  ConsumerState<MachinesPage> createState() => _MachinesPageState();
}

class _MachinesPageState extends ConsumerState<MachinesPage> {
  bool _busy = false;

  Future<void> _createMachine(String companyId) async {
    final nameController = TextEditingController();
    final typeController = TextEditingController(text: 'CNC');
    final countryController = TextEditingController();
    final cityController = TextEditingController();
    final addressController = TextEditingController();
    final latitudeController = TextEditingController();
    final longitudeController = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New machine'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: typeController,
                  decoration: const InputDecoration(labelText: 'Type'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: countryController,
                  decoration: const InputDecoration(labelText: 'Country'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: cityController,
                  decoration: const InputDecoration(labelText: 'City'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
                const SizedBox(height: 8),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final stack = constraints.maxWidth < 360;
                    if (stack) {
                      return Column(
                        children: [
                          TextField(
                            controller: latitudeController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Latitude',
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: longitudeController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Longitude',
                            ),
                          ),
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: latitudeController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Latitude',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: longitudeController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Longitude',
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (ok != true || !mounted) return;
    if (nameController.text.trim().isEmpty) return;

    setState(() => _busy = true);
    try {
      final repo = ref.read(fabricosRepositoryProvider);
      await repo.createMachine(
        companyId: companyId,
        name: nameController.text.trim(),
        type: typeController.text.trim().isEmpty
            ? 'General'
            : typeController.text.trim(),
        country: countryController.text.trim().isEmpty
            ? null
            : countryController.text.trim(),
        city: cityController.text.trim().isEmpty
            ? null
            : cityController.text.trim(),
        address: addressController.text.trim().isEmpty
            ? null
            : addressController.text.trim(),
        latitude: double.tryParse(latitudeController.text.trim()),
        longitude: double.tryParse(longitudeController.text.trim()),
      );
      ref.invalidate(machinesProvider);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _simulate(String companyId, String machineId) async {
    setState(() => _busy = true);
    try {
      final repo = ref.read(fabricosRepositoryProvider);
      final risk = await repo.simulateTelemetryAndPredictRisk(
        companyId: companyId,
        machineId: machineId,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Simulated telemetry. Failure risk: ${(risk * 100).toStringAsFixed(1)}%',
            ),
          ),
        );
      }
      ref.invalidate(alertsProvider);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _deleteMachine(
    String companyId,
    String machineId,
    String displayName,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete machine'),
        content: Text(
          'Remove "$displayName" and related telemetry and maintenance logs? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(fabricosRepositoryProvider)
          .deleteMachine(companyId: companyId, machineId: machineId);
      ref.invalidate(machinesProvider);
      ref.invalidate(maintenanceLogsProvider);
      ref.invalidate(alertsProvider);
      ref.invalidate(dashboardSnapshotProvider);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Machine removed.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not delete machine: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _logMaintenance(String companyId, String machineId) async {
    final notesController = TextEditingController();
    final technicianController = TextEditingController(
      text: 'Maintenance Team',
    );
    final costController = TextEditingController(text: '250');

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add maintenance log'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'Notes'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: technicianController,
                  decoration: const InputDecoration(labelText: 'Technician'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: costController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Cost'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (ok != true || !mounted) return;

    setState(() => _busy = true);
    try {
      final repo = ref.read(fabricosRepositoryProvider);
      await repo.addMaintenanceLog(
        companyId: companyId,
        machineId: machineId,
        notes: notesController.text.trim().isEmpty
            ? 'Scheduled maintenance'
            : notesController.text.trim(),
        technician: technicianController.text.trim().isEmpty
            ? 'Ops team'
            : technicianController.text.trim(),
        cost: double.tryParse(costController.text) ?? 0,
      );
      ref.invalidate(maintenanceLogsProvider);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final companyIdAsync = ref.watch(currentCompanyIdProvider);
    final machinesAsync = ref.watch(machinesProvider);
    final logsAsync = ref.watch(maintenanceLogsProvider);
    final ent = ref.watch(subscriptionEntitlementsProvider);
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 700;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(compact ? 16 : 24),
          child: companyIdAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) =>
                Center(child: Text('Unable to load company context: $err')),
            data: (companyId) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final stackHeader = constraints.maxWidth < 520;
                    final title = Text(
                      'Predictive Maintenance',
                      style: Theme.of(context).textTheme.headlineMedium,
                    );
                    final action = SizedBox(
                      width: stackHeader ? double.infinity : null,
                      child: FilledButton.icon(
                        onPressed: _busy
                            ? null
                            : () => _createMachine(companyId),
                        icon: const Icon(Icons.add),
                        label: const Text('New machine'),
                      ),
                    );
                    if (stackHeader) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [title, const SizedBox(height: 12), action],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(child: title),
                        const SizedBox(width: 12),
                        action,
                      ],
                    );
                  },
                ),
                const SizedBox(height: 6),
                Text(
                  'Monitor machine health, simulate IoT telemetry, and generate AI risk warnings.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 18),
                const SizedBox(height: 18),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final stackPanels = constraints.maxWidth < 980;
                      final machinesCard = Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: machinesAsync.when(
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            error: (err, _) =>
                                Text('Failed to load machines: $err'),
                            data: (machines) {
                              if (machines.isEmpty) {
                                return const Center(
                                  child: Text(
                                    'No machines yet. Add one to start monitoring.',
                                  ),
                                );
                              }

                              return ListView.separated(
                                itemCount: machines.length,
                                separatorBuilder: (_, __) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final machine = machines[index];
                                  return _MachineListItem(
                                    machine: machine,
                                    busy: _busy,
                                    compact: compact,
                                    onSimulate: ent.canUsePredictiveAi
                                        ? () => _simulate(
                                            companyId,
                                            machine['id'].toString(),
                                          )
                                        : null,
                                    onLogMaintenance: () => _logMaintenance(
                                      companyId,
                                      machine['id'].toString(),
                                    ),
                                    onDelete: () => _deleteMachine(
                                      companyId,
                                      machine['id'].toString(),
                                      machine['name']?.toString() ?? 'Machine',
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      );

                      final logsCard = Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Recent maintenance logs',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: logsAsync.when(
                                  loading: () => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  error: (err, _) =>
                                      Text('Failed to load logs: $err'),
                                  data: (logs) {
                                    if (logs.isEmpty) {
                                      return const Text('No logs available.');
                                    }
                                    return ListView.builder(
                                      itemCount: logs.length,
                                      itemBuilder: (context, index) {
                                        final log = logs[index];
                                        final machine =
                                            log['machines']
                                                as Map<String, dynamic>?;
                                        return ListTile(
                                          dense: true,
                                          title: Text(
                                            machine?['name']?.toString() ??
                                                'Machine',
                                          ),
                                          subtitle: Text(
                                            '${formatMachineDate(log['performed_at'])} · ${log['technician'] ?? 'Technician'}',
                                          ),
                                          trailing: Text(
                                            '€${((log['cost'] as num?)?.toDouble() ?? 0).toStringAsFixed(0)}',
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
                      );

                      if (stackPanels) {
                        return Column(
                          children: [
                            SizedBox(height: 380, child: machinesCard),
                            const SizedBox(height: 16),
                            SizedBox(height: 300, child: logsCard),
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(flex: 3, child: machinesCard),
                          const SizedBox(width: 16),
                          Expanded(flex: 2, child: logsCard),
                        ],
                      );
                    },
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

class _MachineListItem extends StatelessWidget {
  const _MachineListItem({
    required this.machine,
    required this.busy,
    required this.compact,
    required this.onSimulate,
    required this.onLogMaintenance,
    required this.onDelete,
  });

  final Map<String, dynamic> machine;
  final bool busy;
  final bool compact;
  final VoidCallback? onSimulate;
  final VoidCallback onLogMaintenance;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final risk = ((machine['failure_risk'] as num?)?.toDouble() ?? 0) * 100;
    final status = machine['status']?.toString() ?? 'running';
    final city = machine['city']?.toString();
    final country = machine['country']?.toString();
    final location = [
      if (city != null && city.isNotEmpty) city,
      if (country != null && country.isNotEmpty) country,
    ].join(', ');
    final statusChip = Chip(
      label: Text(status.toUpperCase()),
      backgroundColor: machineStatusColor(status).withValues(alpha: 0.15),
    );
    final actions = Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: compact ? WrapAlignment.start : WrapAlignment.end,
      children: [
        statusChip,
        IconButton(
          tooltip: 'Simulate IoT data',
          onPressed: (busy || onSimulate == null) ? null : onSimulate,
          icon: const Icon(Icons.bolt_outlined),
        ),
        IconButton(
          tooltip: 'Log maintenance',
          onPressed: busy ? null : onLogMaintenance,
          icon: const Icon(Icons.build_outlined),
        ),
        IconButton(
          tooltip: 'Delete machine',
          onPressed: busy ? null : onDelete,
          icon: Icon(
            Icons.delete_outline,
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      ],
    );

    if (compact) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: machineStatusColor(
                    status,
                  ).withValues(alpha: 0.15),
                  child: Icon(
                    Icons.memory_rounded,
                    color: machineStatusColor(status),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${machine['name']} · ${machine['type']}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Last maintenance: ${formatMachineDate(machine['last_maintenance_at'])} | Risk ${risk.toStringAsFixed(1)}%${location.isNotEmpty ? ' | $location' : ''}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            actions,
          ],
        ),
      );
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      leading: CircleAvatar(
        backgroundColor: machineStatusColor(status).withValues(alpha: 0.15),
        child: Icon(Icons.memory_rounded, color: machineStatusColor(status)),
      ),
      title: Text('${machine['name']} · ${machine['type']}'),
      subtitle: Text(
        'Last maintenance: ${formatMachineDate(machine['last_maintenance_at'])} | Risk ${risk.toStringAsFixed(1)}%${location.isNotEmpty ? ' | $location' : ''}',
      ),
      trailing: actions,
    );
  }
}

String formatMachineDate(dynamic value) {
  final date = DateTime.tryParse(value?.toString() ?? '');
  if (date == null) return '-';
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

Color machineStatusColor(String status) {
  switch (status) {
    case 'warning':
      return const Color(0xFFD97706);
    case 'stopped':
      return const Color(0xFFDC2626);
    default:
      return const Color(0xFF15803D);
  }
}
