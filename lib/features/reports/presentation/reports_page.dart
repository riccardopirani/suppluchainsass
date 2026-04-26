import 'package:fabricos/features/app_shell/providers/fabricos_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  bool _busy = false;

  Future<void> _generate(String companyId) async {
    setState(() => _busy = true);
    try {
      await ref
          .read(fabricosRepositoryProvider)
          .generateEsgReport(
            companyId: companyId,
            month: DateTime(DateTime.now().year, DateTime.now().month, 1),
          );
      ref.invalidate(esgReportsProvider);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('ESG report generated.')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _exportPdf(Map<String, dynamic> report) async {
    final month = DateTime.tryParse(report['report_month']?.toString() ?? '');
    final emissions = ((report['emissions_tco2'] as num?)?.toDouble() ?? 0)
        .toStringAsFixed(2);
    final supplierCompliance =
        ((report['supplier_compliance_score'] as num?)?.toDouble() ?? 0)
            .toStringAsFixed(1);
    final summary = report['summary']?.toString() ?? '-';
    final metadata = report['metadata'] is Map<String, dynamic>
        ? report['metadata'] as Map<String, dynamic>
        : <String, dynamic>{};

    final document = pw.Document();

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Text(
            'FabricOS ESG / Compliance Report',
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Text('Reporting month: ${month != null ? _fmtMonth(month) : '-'}'),
          pw.SizedBox(height: 16),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey500),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Core KPIs',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 8),
                pw.Text('Emissions (tCO2): $emissions'),
                pw.Text('Supplier compliance score: $supplierCompliance / 100'),
              ],
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            'Summary',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(summary),
          pw.SizedBox(height: 16),
          if (metadata.isNotEmpty) ...[
            pw.Text(
              'Additional metrics',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            ...metadata.entries.map(
              (entry) => pw.Text('${entry.key}: ${entry.value}'),
            ),
          ],
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (_) async => document.save());
  }

  Future<void> _deleteReport(
    String companyId,
    Map<String, dynamic> report,
  ) async {
    final month = DateTime.tryParse(report['report_month']?.toString() ?? '');
    final label =
        month != null ? _fmtMonth(month) : (report['id']?.toString() ?? '');
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete report'),
        content: Text(
          'Remove the ESG report for $label? This cannot be undone.',
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
      await ref.read(fabricosRepositoryProvider).deleteEsgReport(
            companyId: companyId,
            reportId: report['id'].toString(),
          );
      ref.invalidate(esgReportsProvider);
      ref.invalidate(dashboardSnapshotProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report removed.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not delete report: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ent = ref.watch(subscriptionEntitlementsProvider);
    if (!ent.canUseEsgReportsModule) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'ESG & compliance reports are included from Professionale upward.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => context.push('/app/billing'),
                      child: const Text('View plans'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    final companyIdAsync = ref.watch(currentCompanyIdProvider);
    final reportsAsync = ref.watch(esgReportsProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: companyIdAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) =>
                Center(child: Text('Unable to load company context: $err')),
            data: (companyId) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'ESG & Compliance Reports',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: _busy ? null : () => _generate(companyId),
                      icon: const Icon(Icons.auto_awesome_outlined),
                      label: const Text('Generate monthly report'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Create ESG snapshots with emissions and supplier compliance indicators, then export as PDF.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: reportsAsync.when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (err, _) => Text('Failed to load reports: $err'),
                        data: (reports) {
                          if (reports.isEmpty) {
                            return const Center(
                              child: Text('No reports generated yet.'),
                            );
                          }

                          return ListView.separated(
                            itemCount: reports.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final report = reports[index];
                              final month = DateTime.tryParse(
                                report['report_month']?.toString() ?? '',
                              );
                              final emissions =
                                  (report['emissions_tco2'] as num?)
                                      ?.toDouble() ??
                                  0;
                              final compliance =
                                  (report['supplier_compliance_score'] as num?)
                                      ?.toDouble() ??
                                  0;

                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 10,
                                ),
                                leading: CircleAvatar(
                                  backgroundColor: const Color(
                                    0xFF0E7490,
                                  ).withValues(alpha: 0.16),
                                  child: const Icon(
                                    Icons.description_outlined,
                                    color: Color(0xFF0E7490),
                                  ),
                                ),
                                title: Text(
                                  month != null
                                      ? _fmtMonth(month)
                                      : 'Monthly report',
                                ),
                                subtitle: Text(
                                  'Emissions: ${emissions.toStringAsFixed(2)} tCO2 · Supplier compliance: ${compliance.toStringAsFixed(1)}',
                                ),
                                trailing: Wrap(
                                  spacing: 4,
                                  crossAxisAlignment:
                                      WrapCrossAlignment.center,
                                  children: [
                                    FilledButton.tonalIcon(
                                      onPressed: () => _exportPdf(report),
                                      icon: const Icon(
                                        Icons.picture_as_pdf_outlined,
                                      ),
                                      label: const Text('Export PDF'),
                                    ),
                                    IconButton(
                                      tooltip: 'Delete report',
                                      onPressed: _busy
                                          ? null
                                          : () =>
                                              _deleteReport(companyId, report),
                                      icon: Icon(
                                        Icons.delete_outline,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.error,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
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
      ),
    );
  }

  static String _fmtMonth(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}';
  }
}
