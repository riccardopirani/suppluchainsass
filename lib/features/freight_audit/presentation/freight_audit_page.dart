import 'package:fabricos/core/theme/intelligence_theme.dart';
import 'package:fabricos/localization/app_localizations.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FreightAuditPage extends StatefulWidget {
  const FreightAuditPage({super.key});

  @override
  State<FreightAuditPage> createState() => _FreightAuditPageState();
}

class _RowData {
  const _RowData({
    required this.carrier,
    required this.shipmentId,
    required this.expected,
    required this.billed,
    required this.variancePct,
    required this.status, // ok | warn | crit
    required this.aiLine,
  });

  final String carrier;
  final String shipmentId;
  final double expected;
  final double billed;
  final double variancePct;
  final String status;
  final String aiLine;
}

class _FreightAuditPageState extends State<FreightAuditPage> {
  int? _selected;
  final _fileHover = ValueNotifier<bool>(false);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const _rows = <_RowData>[
    _RowData(
      carrier: 'DHL Freight',
      shipmentId: 'SH-2026-18432',
      expected: 1840,
      billed: 2120,
      variancePct: 15.2,
      status: 'warn',
      aiLine: 'Linehaul base matches contract; accessorial "redelivery" not in rate card.',
    ),
    _RowData(
      carrier: 'Kuehne + Nagel',
      shipmentId: 'SH-2026-18002',
      expected: 9600,
      billed: 9600,
      variancePct: 0,
      status: 'ok',
      aiLine: 'Billed cost aligns with agreed lane rate and fuel index.',
    ),
    _RowData(
      carrier: 'DB Schenker',
      shipmentId: 'SH-2026-17911',
      expected: 4200,
      billed: 6890,
      variancePct: 64.0,
      status: 'crit',
      aiLine: 'Duplicate fuel surcharge; second line references same consignment id.',
    ),
  ];

  @override
  void dispose() {
    _fileHover.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final w = MediaQuery.sizeOf(context).width;
    final pad = w < 560 ? 12.0 : 20.0;
    final sel = _selected != null ? _rows[_selected!] : null;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.transparent,
      endDrawer: sel == null
          ? null
          : Drawer(
              width: w < 600 ? w * 0.92 : 420,
              backgroundColor: IntelligenceTheme.panel,
              child: SafeArea(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.t('freight_drawer_title'),
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: IntelligenceTheme.textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded),
                          color: IntelligenceTheme.textMuted,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      sel.shipmentId,
                      style: GoogleFonts.ibmPlexSans(
                        color: IntelligenceTheme.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _DrawerSection(
                      title: l10n.t('freight_drawer_ai'),
                      body: sel.aiLine,
                    ),
                    const SizedBox(height: 12),
                    _DrawerSection(
                      title: l10n.t('freight_drawer_detail'),
                      body: l10n.t('freight_drawer_detail_mock'),
                    ),
                    const SizedBox(height: 12),
                    _DrawerSection(
                      title: l10n.t('freight_drawer_invoice'),
                      body: l10n.t('freight_drawer_invoice_mock'),
                    ),
                    const SizedBox(height: 12),
                    _DrawerSection(
                      title: l10n.t('freight_drawer_action'),
                      body: l10n.t('freight_drawer_action_mock'),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: 0.86,
                      backgroundColor: IntelligenceTheme.border,
                      color: IntelligenceTheme.success,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.t('freight_drawer_confidence_label'),
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 12,
                        color: IntelligenceTheme.textMuted,
                      ),
                    ),
                    Text(
                      '86%',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: IntelligenceTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
      onEndDrawerChanged: (o) {
        if (!o) setState(() => _selected = null);
      },
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(pad, pad, pad, pad + 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.t('freight_page_title'),
              style: GoogleFonts.spaceGrotesk(
                fontSize: w < 600 ? 22 : 28,
                fontWeight: FontWeight.w800,
                color: IntelligenceTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.t('freight_page_subtitle'),
              style: GoogleFonts.ibmPlexSans(
                fontSize: 14,
                height: 1.5,
                color: IntelligenceTheme.textMuted,
              ),
            ),
            const SizedBox(height: 18),
            _AlertsStrip(l10n: l10n),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, c) {
                final kpis = [
                  (
                    l10n.t('freight_kpi_spend'),
                    '€182k',
                    Icons.payments_outlined,
                  ),
                  (
                    l10n.t('freight_kpi_recover'),
                    '€24.8k',
                    Icons.savings_outlined,
                  ),
                  (
                    l10n.t('freight_kpi_overcharge'),
                    '6.4%',
                    Icons.trending_up_rounded,
                  ),
                  (
                    l10n.t('freight_kpi_dup'),
                    '3',
                    Icons.copy_all_outlined,
                  ),
                  (
                    l10n.t('freight_kpi_trend'),
                    '+€6.1k',
                    Icons.show_chart_rounded,
                  ),
                ];
                final n = c.maxWidth > 1200
                    ? 5
                    : c.maxWidth > 800
                    ? 3
                    : 1;
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: n,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: n == 1 ? 3.6 : 2.1,
                  children: kpis
                      .map(
                        (k) => _KpiCard(
                          label: k.$1,
                          value: k.$2,
                          icon: k.$3,
                        ),
                      )
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 20),
            _UploadZone(
              l10n: l10n,
              hover: _fileHover,
            ),
            const SizedBox(height: 24),
            Text(
              l10n.t('freight_table_title'),
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: IntelligenceTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: w < 800 ? w - pad * 2 : 960,
                ),
                child: DataTable(
                  headingRowColor: WidgetStatePropertyAll(
                    IntelligenceTheme.panelAlt,
                  ),
                  border: TableBorder.all(
                    color: IntelligenceTheme.border.withValues(alpha: 0.6),
                  ),
                  columns: [
                    DataColumn(
                      label: Text(
                        l10n.t('freight_col_carrier'),
                        style: const TextStyle(
                          color: IntelligenceTheme.textSecondary,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        l10n.t('freight_col_shipment'),
                        style: const TextStyle(
                          color: IntelligenceTheme.textSecondary,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        l10n.t('freight_col_expected'),
                        style: const TextStyle(
                          color: IntelligenceTheme.textSecondary,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        l10n.t('freight_col_billed'),
                        style: const TextStyle(
                          color: IntelligenceTheme.textSecondary,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        l10n.t('freight_col_var'),
                        style: const TextStyle(
                          color: IntelligenceTheme.textSecondary,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        l10n.t('freight_col_status'),
                        style: const TextStyle(
                          color: IntelligenceTheme.textSecondary,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        l10n.t('freight_col_ai'),
                        style: const TextStyle(
                          color: IntelligenceTheme.textSecondary,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        l10n.t('freight_col_actions'),
                        style: const TextStyle(
                          color: IntelligenceTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                  rows: List.generate(_rows.length, (i) {
                    final r = _rows[i];
                    return DataRow(
                      onSelectChanged: (_) {
                        setState(() => _selected = i);
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _scaffoldKey.currentState?.openEndDrawer();
                        });
                      },
                      cells: [
                        DataCell(Text(r.carrier)),
                        DataCell(Text(r.shipmentId)),
                        DataCell(Text('€${r.expected.toStringAsFixed(0)}')),
                        DataCell(Text('€${r.billed.toStringAsFixed(0)}')),
                        DataCell(
                          Text(
                            '${r.variancePct.toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: r.variancePct > 20
                                  ? IntelligenceTheme.danger
                                  : r.variancePct > 5
                                  ? IntelligenceTheme.warning
                                  : IntelligenceTheme.success,
                            ),
                          ),
                        ),
                        DataCell(_StatusPill(status: r.status, l10n: l10n)),
                        DataCell(
                          SizedBox(
                            width: 220,
                            child: Text(
                              r.aiLine,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(
                          TextButton(
                        onPressed: () {
                          setState(() => _selected = i);
                          _scaffoldKey.currentState?.openEndDrawer();
                        },
                            child: Text(l10n.t('freight_action_review')),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              l10n.t('freight_charts_title'),
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: IntelligenceTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, c) {
                if (c.maxWidth < 800) {
                  return Column(
                    children: [
                      _BarByCarrier(l10n: l10n),
                      const SizedBox(height: 16),
                      _LineOvercharge(l10n: l10n),
                      const SizedBox(height: 16),
                      _CategoriesChart(l10n: l10n),
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _BarByCarrier(l10n: l10n)),
                    const SizedBox(width: 12),
                    Expanded(child: _LineOvercharge(l10n: l10n)),
                    const SizedBox(width: 12),
                    Expanded(child: _CategoriesChart(l10n: l10n)),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: IntelligenceTheme.panel,
        border: Border.all(color: IntelligenceTheme.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: IntelligenceTheme.accent.withValues(alpha: 0.12),
            ),
            child: Icon(icon, color: IntelligenceTheme.accent, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 11,
                    color: IntelligenceTheme.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: IntelligenceTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status, required this.l10n});

  final String status;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = switch (status) {
      'ok' => (
        IntelligenceTheme.success.withValues(alpha: 0.15),
        IntelligenceTheme.success,
        l10n.t('freight_status_ok'),
      ),
      'warn' => (
        IntelligenceTheme.warning.withValues(alpha: 0.18),
        IntelligenceTheme.warning,
        l10n.t('freight_status_warn'),
      ),
      _ => (
        IntelligenceTheme.danger.withValues(alpha: 0.18),
        IntelligenceTheme.danger,
        l10n.t('freight_status_crit'),
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.ibmPlexSans(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}

class _AlertsStrip extends StatelessWidget {
  const _AlertsStrip({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.warning_amber_rounded, IntelligenceTheme.warning,
          l10n.t('freight_alert_overcharge')),
      (Icons.copy_all_rounded, IntelligenceTheme.accentStrong,
          l10n.t('freight_alert_dup')),
      (Icons.local_gas_station_outlined, IntelligenceTheme.danger,
          l10n.t('freight_alert_fuel')),
    ];
    return Column(
      children: items
          .map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: IntelligenceTheme.panelAlt,
                  border: Border.all(color: IntelligenceTheme.border),
                ),
                child: Row(
                  children: [
                    Icon(e.$1, color: e.$2, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        e.$3,
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 13,
                          color: IntelligenceTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _UploadZone extends StatelessWidget {
  const _UploadZone({
    required this.l10n,
    required this.hover,
  });

  final AppLocalizations l10n;
  final ValueNotifier<bool> hover;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: hover,
      builder: (context, h, _) {
        return MouseRegion(
          onEnter: (_) => hover.value = true,
          onExit: (_) => hover.value = false,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: h
                    ? IntelligenceTheme.accent.withValues(alpha: 0.8)
                    : IntelligenceTheme.border,
                width: h ? 1.5 : 1,
              ),
              color: IntelligenceTheme.panel.withValues(alpha: h ? 0.95 : 0.7),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 32,
                  color: IntelligenceTheme.accent,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.t('freight_upload_title'),
                  style: GoogleFonts.ibmPlexSans(
                    fontWeight: FontWeight.w700,
                    color: IntelligenceTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.t('freight_upload_hint'),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 12,
                    color: IntelligenceTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DrawerSection extends StatelessWidget {
  const _DrawerSection({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.ibmPlexSans(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: IntelligenceTheme.textMuted,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          body,
          style: GoogleFonts.ibmPlexSans(
            fontSize: 13,
            height: 1.45,
            color: IntelligenceTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _BarByCarrier extends StatelessWidget {
  const _BarByCarrier({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return _ChartShell(
      title: l10n.t('freight_chart_carrier'),
      height: 200,
      child: BarChart(
        BarChartData(
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  const labels = ['DHL', 'KN', 'DBS'];
                  final i = v.toInt();
                  if (i < 0 || i >= labels.length) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      labels[i],
                      style: const TextStyle(
                        fontSize: 10,
                        color: IntelligenceTheme.textMuted,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (v, _) => Text(
                  '${v.toInt()}k',
                  style: const TextStyle(
                    fontSize: 10,
                    color: IntelligenceTheme.textMuted,
                  ),
                ),
              ),
            ),
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
          ),
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: 6.2,
                  width: 18,
                  color: IntelligenceTheme.accent,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: 9.1,
                  width: 18,
                  color: IntelligenceTheme.accentStrong,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(
                  toY: 11.4,
                  width: 18,
                  color: IntelligenceTheme.warning,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LineOvercharge extends StatelessWidget {
  const _LineOvercharge({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return _ChartShell(
      title: l10n.t('freight_chart_trend'),
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 3.2),
                FlSpot(1, 4.1),
                FlSpot(2, 3.8),
                FlSpot(3, 5.6),
                FlSpot(4, 6.1),
                FlSpot(5, 6.4),
              ],
              isCurved: true,
              color: IntelligenceTheme.danger,
              barWidth: 3,
              dotData: const FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoriesChart extends StatelessWidget {
  const _CategoriesChart({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return _ChartShell(
      title: l10n.t('freight_chart_categories'),
      height: 200,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 28,
          sections: [
            PieChartSectionData(
              value: 38,
              title: 'FUEL',
              radius: 36,
              color: IntelligenceTheme.warning,
              titleStyle: const TextStyle(
                fontSize: 9,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            PieChartSectionData(
              value: 27,
              title: 'ACC',
              radius: 36,
              color: IntelligenceTheme.accent,
              titleStyle: const TextStyle(
                fontSize: 9,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            PieChartSectionData(
              value: 22,
              title: 'DUP',
              radius: 36,
              color: IntelligenceTheme.danger,
              titleStyle: const TextStyle(
                fontSize: 9,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            PieChartSectionData(
              value: 13,
              title: 'OTH',
              radius: 36,
              color: IntelligenceTheme.textDim,
              titleStyle: const TextStyle(
                fontSize: 9,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartShell extends StatelessWidget {
  const _ChartShell({
    required this.title,
    required this.height,
    required this.child,
  });

  final String title;
  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: IntelligenceTheme.panel,
        border: Border.all(color: IntelligenceTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.ibmPlexSans(
              fontWeight: FontWeight.w700,
              color: IntelligenceTheme.textPrimary,
              fontSize: 13,
            ),
          ),
          SizedBox(height: height, child: child),
        ],
      ),
    );
  }
}
