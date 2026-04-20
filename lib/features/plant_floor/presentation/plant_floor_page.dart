import 'package:fabricos/features/app_shell/providers/fabricos_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlantFloorPage extends ConsumerStatefulWidget {
  const PlantFloorPage({super.key});

  @override
  ConsumerState<PlantFloorPage> createState() => _PlantFloorPageState();
}

class _PlantFloorPageState extends ConsumerState<PlantFloorPage> {
  final _quantityController = TextEditingController(text: '10');
  final _notesController = TextEditingController();
  String _eventType = 'production';
  bool _saving = false;

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitQuickLog() async {
    final companyId = await ref.read(currentCompanyIdProvider.future);
    final machines = ref.read(machinesProvider).valueOrNull;
    final machineId = (machines != null && machines.isNotEmpty)
        ? machines.first['id']?.toString()
        : null;
    setState(() => _saving = true);
    try {
      await ref.read(fabricosRepositoryProvider).submitQuickLog(
            companyId: companyId,
            eventType: _eventType,
            quantity: double.tryParse(_quantityController.text.trim()) ?? 0,
            notes: _notesController.text.trim(),
            machineId: machineId,
          );
      _notesController.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quick log salvato')),
      );
      ref.invalidate(productionQuickLogsProvider);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _signShift() async {
    final companyId = await ref.read(currentCompanyIdProvider.future);
    setState(() => _saving = true);
    try {
      await ref.read(fabricosRepositoryProvider).signShift(
            companyId: companyId,
            shiftCode: 'SHIFT-${DateTime.now().hour < 14 ? 'A' : 'B'}',
            signerName: 'Operator',
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Firma turno registrata')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final logs = ref.watch(productionQuickLogsProvider);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Plant Floor Mode',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final type in const [
                    'production',
                    'scrap',
                    'downtime',
                    'quality_check',
                  ])
                    ChoiceChip(
                      label: Text(type),
                      selected: _eventType == type,
                      onSelected: (_) => setState(() => _eventType = type),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Quick notes / QR',
                  hintText: 'Es. QR:MCH-1002 downtime valve',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: _saving ? null : _submitQuickLog,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text('Quick log'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saving ? null : _signShift,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text('Firma turno'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: Card(
                  child: logs.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Errore: $e')),
                    data: (rows) => ListView.separated(
                      itemCount: rows.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final row = rows[index];
                        return ListTile(
                          leading: const Icon(Icons.bolt_outlined),
                          title: Text('${row['event_type']} · qty ${row['quantity']}'),
                          subtitle: Text(row['notes']?.toString() ?? '-'),
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
