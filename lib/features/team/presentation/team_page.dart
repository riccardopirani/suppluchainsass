import 'package:fabricos/features/app_shell/providers/fabricos_provider.dart';
import 'package:fabricos/features/team/data/team_provider.dart';
import 'package:fabricos/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TeamPage extends ConsumerStatefulWidget {
  const TeamPage({super.key});

  @override
  ConsumerState<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends ConsumerState<TeamPage> {
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  String _selectedRole = 'operator';
  bool _busy = false;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _invite(String companyId) async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;
    setState(() => _busy = true);
    try {
      await ref.read(teamServiceProvider).inviteUser(
            companyId: companyId,
            email: email,
            role: _selectedRole,
            fullName: _nameController.text.trim(),
          );
      _emailController.clear();
      _nameController.clear();
      ref.invalidate(teamMembersProvider(companyId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.t('team_invite_success'))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final userCtxAsync = ref.watch(fabricUserContextProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: userCtxAsync.when(
            data: (userCtx) {
              final companyId = userCtx.companyId;
              if (companyId == null) {
                return Center(child: Text(l10n.t('error_generic')));
              }
              final membersAsync = ref.watch(teamMembersProvider(companyId));
              final isAdmin = userCtx.role == 'admin';
              final isManager = userCtx.role == 'manager';
              final canInvite = isAdmin || isManager;

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.t('team_title'), style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 4),
                    Text(l10n.t('team_subtitle'), style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 24),
                    if (canInvite) ...[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l10n.t('team_invite_title'), style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: TextField(
                                      controller: _emailController,
                                      decoration: InputDecoration(
                                        labelText: l10n.t('login_email'),
                                        border: const OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                      keyboardType: TextInputType.emailAddress,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: _nameController,
                                      decoration: InputDecoration(
                                        labelText: l10n.t('register_name'),
                                        border: const OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  DropdownButton<String>(
                                    value: _selectedRole,
                                    items: const [
                                      DropdownMenuItem(value: 'admin', child: Text('Admin')),
                                      DropdownMenuItem(value: 'manager', child: Text('Manager')),
                                      DropdownMenuItem(value: 'operator', child: Text('Operator')),
                                      DropdownMenuItem(value: 'viewer', child: Text('Viewer')),
                                    ],
                                    onChanged: (v) {
                                      if (v != null) setState(() => _selectedRole = v);
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  FilledButton(
                                    onPressed: _busy ? null : () => _invite(companyId),
                                    child: _busy
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          )
                                        : Text(l10n.t('team_invite_btn')),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Text(l10n.t('team_members_title'), style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    membersAsync.when(
                      data: (members) {
                        if (members.isEmpty) {
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(l10n.t('team_no_members')),
                            ),
                          );
                        }
                        return Card(
                          child: DataTable(
                            columns: [
                              DataColumn(label: Text(l10n.t('login_email'))),
                              DataColumn(label: Text(l10n.t('team_role'))),
                              DataColumn(label: Text(l10n.t('status'))),
                              if (isAdmin) const DataColumn(label: Text('')),
                            ],
                            rows: members.map((m) {
                              return DataRow(cells: [
                                DataCell(Text(m['email']?.toString() ?? '')),
                                DataCell(
                                  isAdmin
                                      ? DropdownButton<String>(
                                          value: m['role']?.toString() ?? 'operator',
                                          items: const [
                                            DropdownMenuItem(value: 'admin', child: Text('Admin')),
                                            DropdownMenuItem(value: 'manager', child: Text('Manager')),
                                            DropdownMenuItem(value: 'operator', child: Text('Operator')),
                                            DropdownMenuItem(value: 'viewer', child: Text('Viewer')),
                                          ],
                                          onChanged: (v) async {
                                            if (v == null) return;
                                            await ref.read(teamServiceProvider).updateMemberRole(m['id'], v);
                                            ref.invalidate(teamMembersProvider(companyId));
                                          },
                                          underline: const SizedBox(),
                                          isDense: true,
                                        )
                                      : Text(m['role']?.toString() ?? ''),
                                ),
                                DataCell(_statusChip(m['status']?.toString() ?? 'pending')),
                                if (isAdmin)
                                  DataCell(
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, size: 20),
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            title: Text(l10n.t('team_remove_confirm')),
                                            actions: [
                                              TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.t('cancel'))),
                                              FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.t('delete'))),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          await ref.read(teamServiceProvider).removeMember(m['id']);
                                          ref.invalidate(teamMembersProvider(companyId));
                                        }
                                      },
                                    ),
                                  ),
                              ]);
                            }).toList(),
                          ),
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Text('$e'),
                    ),
                    if (isAdmin) ...[
                      const SizedBox(height: 24),
                      _PermissionsSection(companyId: companyId),
                    ],
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
          ),
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    final color = switch (status) {
      'active' => Colors.green,
      'pending' => Colors.orange,
      'disabled' => Colors.grey,
      _ => Colors.grey,
    };
    return Chip(
      label: Text(status, style: const TextStyle(fontSize: 12)),
      backgroundColor: color.withValues(alpha: 0.15),
      side: BorderSide.none,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _PermissionsSection extends ConsumerStatefulWidget {
  const _PermissionsSection({required this.companyId});
  final String companyId;

  @override
  ConsumerState<_PermissionsSection> createState() => _PermissionsSectionState();
}

class _PermissionsSectionState extends ConsumerState<_PermissionsSection> {
  static const _allRoutes = [
    'dashboard', 'supply', 'inventory', 'machines', 'orders',
    'suppliers', 'reports', 'billing', 'shipments', 'simulation',
    'settings', 'team',
  ];

  String _editingRole = 'operator';
  Set<String> _selected = {};
  bool _loaded = false;

  Future<void> _loadPermissions() async {
    final perms = await ref.read(
      menuPermissionsProvider((companyId: widget.companyId, role: _editingRole)).future,
    );
    setState(() {
      _selected = perms != null ? Set<String>.from(perms) : Set<String>.from(_allRoutes);
      _loaded = true;
    });
  }

  Future<void> _save() async {
    await ref.read(teamServiceProvider).updateMenuPermissions(
          companyId: widget.companyId,
          role: _editingRole,
          allowedRoutes: _selected.toList(),
        );
    ref.invalidate(menuPermissionsProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.t('save'))),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadPermissions);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.t('team_permissions_title'), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(l10n.t('team_role')),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _editingRole,
                  items: const [
                    DropdownMenuItem(value: 'manager', child: Text('Manager')),
                    DropdownMenuItem(value: 'operator', child: Text('Operator')),
                    DropdownMenuItem(value: 'viewer', child: Text('Viewer')),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() {
                      _editingRole = v;
                      _loaded = false;
                    });
                    _loadPermissions();
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (!_loaded)
              const LinearProgressIndicator()
            else
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _allRoutes.map((route) {
                  return FilterChip(
                    label: Text(route),
                    selected: _selected.contains(route),
                    onSelected: (val) {
                      setState(() {
                        if (val) {
                          _selected.add(route);
                        } else {
                          _selected.remove(route);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _save,
              child: Text(l10n.t('save')),
            ),
          ],
        ),
      ),
    );
  }
}
