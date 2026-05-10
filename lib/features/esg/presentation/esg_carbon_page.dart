import 'package:fabricos/core/theme/intelligence_theme.dart';
import 'package:fabricos/localization/app_localizations.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Scope 1–3 & CSRD-oriented sustainability cockpit (demo data).
class EsgCarbonPage extends StatelessWidget {
  const EsgCarbonPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final w = MediaQuery.sizeOf(context).width;
    final pad = w < 560 ? 12.0 : 20.0;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(pad, pad, pad, pad + 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.t('esg_page_title'),
            style: GoogleFonts.spaceGrotesk(
              fontSize: w < 600 ? 22 : 28,
              fontWeight: FontWeight.w800,
              color: IntelligenceTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.t('esg_page_subtitle'),
            style: GoogleFonts.ibmPlexSans(
              fontSize: 14,
              height: 1.5,
              color: IntelligenceTheme.textMuted,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: IntelligenceTheme.accentStrong,
                  foregroundColor: const Color(0xFF03111E),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.t('esg_snack_csrd'))),
                  );
                },
                icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                label: Text(l10n.t('esg_btn_csrd')),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: IntelligenceTheme.textPrimary,
                  side: const BorderSide(color: IntelligenceTheme.border),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.t('esg_snack_xlsx'))),
                  );
                },
                icon: const Icon(Icons.table_chart_outlined, size: 18),
                label: Text(l10n.t('esg_btn_xlsx')),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: IntelligenceTheme.textPrimary,
                  side: const BorderSide(color: IntelligenceTheme.border),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.t('esg_snack_audit'))),
                  );
                },
                icon: const Icon(Icons.verified_outlined, size: 18),
                label: Text(l10n.t('esg_btn_audit')),
              ),
            ],
          ),
          const SizedBox(height: 22),
          LayoutBuilder(
            builder: (context, c) {
              final kpis = [
                (
                  l10n.t('esg_kpi_total_co2'),
                  '12.4k t',
                  Icons.cloud_outlined,
                ),
                (
                  l10n.t('esg_kpi_scope3_pct'),
                  '76%',
                  Icons.hub_outlined,
                ),
                (
                  l10n.t('esg_kpi_suppliers'),
                  '14',
                  Icons.warning_amber_rounded,
                ),
                (
                  l10n.t('esg_kpi_complete'),
                  '82%',
                  Icons.fact_check_outlined,
                ),
                (
                  l10n.t('esg_kpi_csrd'),
                  '71%',
                  Icons.shield_outlined,
                ),
              ];
              final n = c.maxWidth > 1100
                  ? 5
                  : c.maxWidth > 720
                  ? 3
                  : 1;
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: n,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: n == 1 ? 3.5 : 2.2,
                children: kpis
                    .map(
                      (k) => _KpiMini(
                        label: k.$1,
                        value: k.$2,
                        icon: k.$3,
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 22),
          _AiInsightsCard(l10n: l10n),
          const SizedBox(height: 18),
          Text(
            l10n.t('esg_map_title'),
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: IntelligenceTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          _MapPlaceholder(l10n: l10n),
          const SizedBox(height: 22),
          Text(
            l10n.t('esg_table_title'),
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: IntelligenceTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStatePropertyAll(IntelligenceTheme.panelAlt),
              border: TableBorder.all(
                color: IntelligenceTheme.border.withValues(alpha: 0.6),
              ),
              columns: [
                _dh(l10n.t('esg_col_supplier')),
                _dh(l10n.t('esg_col_country')),
                _dh(l10n.t('esg_col_mode')),
                _dh(l10n.t('esg_col_distance')),
                _dh(l10n.t('esg_col_co2')),
                _dh(l10n.t('esg_col_report')),
                _dh(l10n.t('esg_col_risk')),
              ],
              rows: [
                _dr(
                  'Acme Steel PL',
                  'PL',
                  'Road',
                  '1 240 km',
                  '182 t',
                  l10n.t('esg_status_ok'),
                  l10n.t('esg_risk_med'),
                  IntelligenceTheme.warning,
                ),
                _dr(
                  'Nordic Logistics',
                  'SE',
                  'Sea',
                  '3 900 km',
                  '96 t',
                  l10n.t('esg_status_pending'),
                  l10n.t('esg_risk_high'),
                  IntelligenceTheme.danger,
                ),
                _dr(
                  'EuroChem GmbH',
                  'DE',
                  'Rail',
                  '820 km',
                  '41 t',
                  l10n.t('esg_status_ok'),
                  l10n.t('esg_risk_low'),
                  IntelligenceTheme.success,
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text(
            l10n.t('esg_supplier_portal_title'),
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: IntelligenceTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, c) {
              final cards = [
                (
                  l10n.t('esg_portal_invite'),
                  Icons.mail_outline,
                  l10n.t('esg_portal_invite_desc'),
                ),
                (
                  l10n.t('esg_portal_upload'),
                  Icons.upload_file_outlined,
                  l10n.t('esg_portal_upload_desc'),
                ),
                (
                  l10n.t('esg_portal_pending'),
                  Icons.hourglass_empty_rounded,
                  l10n.t('esg_portal_pending_desc'),
                ),
                (
                  l10n.t('esg_portal_completion'),
                  Icons.pie_chart_outline_rounded,
                  l10n.t('esg_portal_completion_desc'),
                ),
              ];
              final cols = c.maxWidth > 900 ? 2 : 1;
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: cols,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: cols == 2 ? 2.8 : 2.2,
                children: cards
                    .map(
                      (e) => _PortalTile(
                        title: e.$1,
                        icon: e.$2,
                        subtitle: e.$3,
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 22),
          Text(
            l10n.t('esg_charts_title'),
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: IntelligenceTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, c) {
              if (c.maxWidth < 900) {
                return Column(
                  children: [
                    _ScopePie(l10n: l10n),
                    const SizedBox(height: 12),
                    _SupplierBar(l10n: l10n),
                    const SizedBox(height: 12),
                    _ModeHorizBar(l10n: l10n),
                    const SizedBox(height: 12),
                    _MonthlyLine(l10n: l10n),
                  ],
                );
              }
              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _ScopePie(l10n: l10n)),
                      const SizedBox(width: 12),
                      Expanded(child: _SupplierBar(l10n: l10n)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _ModeHorizBar(l10n: l10n)),
                      const SizedBox(width: 12),
                      Expanded(child: _MonthlyLine(l10n: l10n)),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  DataColumn _dh(String label) => DataColumn(
        label: Text(
          label,
          style: const TextStyle(color: IntelligenceTheme.textSecondary),
        ),
      );

  DataRow _dr(
    String a,
    String b,
    String c,
    String d,
    String e,
    String status,
    String risk,
    Color riskColor,
  ) {
    return DataRow(
      cells: [
        DataCell(Text(a)),
        DataCell(Text(b)),
        DataCell(Text(c)),
        DataCell(Text(d)),
        DataCell(Text(e)),
        DataCell(Text(status)),
        DataCell(
          Text(
            risk,
            style: TextStyle(
              color: riskColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _KpiMini extends StatelessWidget {
  const _KpiMini({
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
          Icon(icon, color: IntelligenceTheme.accent, size: 22),
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

class _AiInsightsCard extends StatelessWidget {
  const _AiInsightsCard({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: [
            IntelligenceTheme.accent.withValues(alpha: 0.12),
            IntelligenceTheme.panelAlt,
          ],
        ),
        border: Border.all(color: IntelligenceTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: IntelligenceTheme.accent, size: 20),
              const SizedBox(width: 8),
              Text(
                l10n.t('esg_ai_title'),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: IntelligenceTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            l10n.t('esg_ai_body'),
            style: GoogleFonts.ibmPlexSans(
              fontSize: 13,
              height: 1.5,
              color: IntelligenceTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: IntelligenceTheme.panelAlt,
        border: Border.all(color: IntelligenceTheme.border),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _MapGridPainter(),
            ),
          ),
          Positioned(
            left: 24,
            top: 24,
            child: _HotDot(label: 'DE', color: IntelligenceTheme.danger),
          ),
          Positioned(
            right: 60,
            top: 50,
            child: _HotDot(label: 'SE', color: IntelligenceTheme.warning),
          ),
          Positioned(
            left: 90,
            bottom: 40,
            child: _HotDot(label: 'IT', color: IntelligenceTheme.success),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                l10n.t('esg_map_hint'),
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 12,
                  color: IntelligenceTheme.textMuted,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HotDot extends StatelessWidget {
  const _HotDot({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.6),
                blurRadius: 12,
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.ibmPlexSans(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: IntelligenceTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final g = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1;
    const step = 40.0;
    for (var x = 0.0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), g);
    }
    for (var y = 0.0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), g);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PortalTile extends StatelessWidget {
  const _PortalTile({
    required this.title,
    required this.icon,
    required this.subtitle,
  });

  final String title;
  final IconData icon;
  final String subtitle;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: IntelligenceTheme.accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.ibmPlexSans(
                    fontWeight: FontWeight.w700,
                    color: IntelligenceTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 12,
                    height: 1.35,
                    color: IntelligenceTheme.textMuted,
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

class _ScopePie extends StatelessWidget {
  const _ScopePie({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return _ChartCard(
      title: l10n.t('esg_chart_scope'),
      height: 180,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: [
            PieChartSectionData(
              color: IntelligenceTheme.accent,
              value: 12,
              title: 'S1',
              radius: 32,
              titleStyle: const TextStyle(
                fontSize: 10,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            PieChartSectionData(
              color: IntelligenceTheme.accentStrong,
              value: 28,
              title: 'S2',
              radius: 32,
              titleStyle: const TextStyle(
                fontSize: 10,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            PieChartSectionData(
              color: IntelligenceTheme.warning,
              value: 60,
              title: 'S3',
              radius: 32,
              titleStyle: const TextStyle(
                fontSize: 10,
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

class _SupplierBar extends StatelessWidget {
  const _SupplierBar({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return _ChartCard(
      title: l10n.t('esg_chart_suppliers'),
      height: 180,
      child: BarChart(
        BarChartData(
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  const l = ['A', 'B', 'C', 'D'];
                  final i = v.toInt();
                  if (i < 0 || i >= l.length) return const SizedBox();
                  return Text(
                    l[i],
                    style: const TextStyle(
                      fontSize: 10,
                      color: IntelligenceTheme.textMuted,
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                getTitlesWidget: (v, _) => Text(
                  '${v.toInt()}',
                  style: const TextStyle(
                    fontSize: 9,
                    color: IntelligenceTheme.textMuted,
                  ),
                ),
              ),
            ),
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
          ),
          barGroups: List.generate(
            4,
            (i) => BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: [420, 310, 280, 190][i].toDouble(),
                  width: 16,
                  color: IntelligenceTheme.accent,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeHorizBar extends StatelessWidget {
  const _ModeHorizBar({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return _ChartCard(
      title: l10n.t('esg_chart_mode'),
      height: 180,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          groupsSpace: 8,
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                getTitlesWidget: (v, _) {
                  const labels = ['Road', 'Sea', 'Rail', 'Air'];
                  final i = v.toInt();
                  if (i < 0 || i >= 4) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
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
            bottomTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
          ),
          barGroups: List.generate(
            4,
            (i) => BarChartGroupData(
              x: i,
              groupVertically: true,
              barRods: [
                BarChartRodData(
                  toY: [52, 38, 24, 8][i].toDouble(),
                  width: 14,
                  color: [IntelligenceTheme.warning, IntelligenceTheme.accent,
                      IntelligenceTheme.success, IntelligenceTheme.danger][i],
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MonthlyLine extends StatelessWidget {
  const _MonthlyLine({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return _ChartCard(
      title: l10n.t('esg_chart_monthly'),
      height: 180,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) => Text(
                  'M${v.toInt() + 1}',
                  style: const TextStyle(
                    fontSize: 9,
                    color: IntelligenceTheme.textMuted,
                  ),
                ),
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (v, _) => Text(
                  '${v.toInt()}',
                  style: const TextStyle(
                    fontSize: 9,
                    color: IntelligenceTheme.textMuted,
                  ),
                ),
              ),
            ),
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 980),
                FlSpot(1, 1020),
                FlSpot(2, 990),
                FlSpot(3, 1100),
                FlSpot(4, 1050),
                FlSpot(5, 1080),
              ],
              isCurved: true,
              color: IntelligenceTheme.success,
              barWidth: 2.5,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
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
      padding: const EdgeInsets.all(12),
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
              fontSize: 13,
              color: IntelligenceTheme.textPrimary,
            ),
          ),
          SizedBox(height: height, child: child),
        ],
      ),
    );
  }
}
