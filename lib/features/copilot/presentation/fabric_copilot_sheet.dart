import 'package:fabricos/features/app_shell/providers/fabricos_provider.dart';
import 'package:fabricos/features/copilot/data/copilot_service.dart';
import 'package:fabricos/core/theme/intelligence_theme.dart';
import 'package:fabricos/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void openFabricCopilotSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: IntelligenceTheme.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => const _CopilotSheet(),
  );
}

class FabricCopilotFab extends ConsumerWidget {
  const FabricCopilotFab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ent = ref.watch(subscriptionEntitlementsProvider);
    if (!ent.canUseAiCopilot) {
      return FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.t('copilot_upgrade_hint'))),
          );
        },
        icon: const Icon(Icons.lock_outline),
        label: Text(context.l10n.t('copilot_locked')),
        backgroundColor: IntelligenceTheme.panelStrong,
      );
    }
    return FloatingActionButton.extended(
      onPressed: () => openFabricCopilotSheet(context),
      icon: const Icon(Icons.smart_toy_outlined),
      label: Text(context.l10n.t('copilot_title')),
      backgroundColor: IntelligenceTheme.accentStrong,
    );
  }
}

class _CopilotSheet extends ConsumerStatefulWidget {
  const _CopilotSheet();

  @override
  ConsumerState<_CopilotSheet> createState() => _CopilotSheetState();
}

class _CopilotSheetState extends ConsumerState<_CopilotSheet> {
  final _ctrl = TextEditingController();
  String _reply = '';
  bool _busy = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final q = _ctrl.text.trim();
    if (q.isEmpty) return;
    setState(() {
      _busy = true;
      _reply = '';
    });
    final snap = ref.read(dashboardSnapshotProvider).valueOrNull;
    final ctxMap = <String, String>{
      if (snap != null) 'active_orders': '${snap.activeOrders}',
      if (snap != null) 'open_alerts': '${snap.openAlerts}',
      if (snap != null) 'delayed_suppliers': '${snap.delayedSuppliers}',
    };
    final text = await ref.read(copilotServiceProvider).ask(q, context: ctxMap);
    if (mounted) {
      setState(() {
        _busy = false;
        _reply = text;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pad = MediaQuery.paddingOf(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: pad.bottom + 20,
      ),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.55,
        minChildSize: 0.35,
        maxChildSize: 0.92,
        builder: (context, scrollController) {
          return ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F2937),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.t('copilot_title'),
                style: const TextStyle(
                  color: IntelligenceTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.t('copilot_subtitle'),
                style: const TextStyle(
                  color: IntelligenceTheme.textSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _chip(
                    l10n.t('copilot_q1'),
                    () => _ctrl.text = l10n.t('copilot_q1'),
                  ),
                  _chip(
                    l10n.t('copilot_q2'),
                    () => _ctrl.text = l10n.t('copilot_q2'),
                  ),
                  _chip(
                    l10n.t('copilot_q3'),
                    () => _ctrl.text = l10n.t('copilot_q3'),
                  ),
                  _chip(
                    l10n.t('copilot_q4'),
                    () => _ctrl.text = l10n.t('copilot_q4'),
                  ),
                  _chip(
                    l10n.t('copilot_q5'),
                    () => _ctrl.text = l10n.t('copilot_q5'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _ctrl,
                maxLines: 3,
                style: const TextStyle(color: IntelligenceTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: l10n.t('copilot_hint'),
                  hintStyle: const TextStyle(color: IntelligenceTheme.textDim),
                  filled: true,
                  fillColor: IntelligenceTheme.panelStrong,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: IntelligenceTheme.border,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _busy ? null : _send,
                icon: _busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded),
                label: Text(l10n.t('copilot_ask')),
              ),
              if (_reply.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  _reply,
                  style: const TextStyle(
                    color: IntelligenceTheme.textSecondary,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _chip(String label, VoidCallback onTap) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      onPressed: onTap,
      backgroundColor: IntelligenceTheme.panelStrong,
      side: const BorderSide(color: IntelligenceTheme.borderStrong),
    );
  }
}
