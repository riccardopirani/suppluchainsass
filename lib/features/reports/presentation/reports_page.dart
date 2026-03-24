import 'package:fabricos/features/app_shell/providers/fabricos_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  @override
  Widget build(BuildContext context) {
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
                                trailing: FilledButton.tonalIcon(
                                  onPressed: () => _exportPdf(report),
                                  icon: const Icon(
                                    Icons.picture_as_pdf_outlined,
                                  ),
                                  label: const Text('Export PDF'),
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
