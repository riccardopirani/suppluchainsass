import 'package:fabricos/core/marketing/roi_calculator_logic.dart';
import 'package:fabricos/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shared ROI calculator for marketing pages (dark theme).
class MarketingRoiCalculator extends StatefulWidget {
  const MarketingRoiCalculator({super.key});

  @override
  State<MarketingRoiCalculator> createState() => _MarketingRoiCalculatorState();
}

class _MarketingRoiCalculatorState extends State<MarketingRoiCalculator> {
  final _revenue = TextEditingController(text: '2500000');
  final _downtime = TextEditingController(text: '36');
  final _delayCost = TextEditingController(text: '42000');
  final _inventory = TextEditingController(text: '1800000');

  RoiCalculatorResult? _result;

  @override
  void dispose() {
    _revenue.dispose();
    _downtime.dispose();
    _delayCost.dispose();
    _inventory.dispose();
    super.dispose();
  }

  void _run() {
    final r = RoiCalculatorLogic.estimate(
      monthlyRevenue: double.tryParse(_revenue.text.replaceAll(',', '')) ?? 0,
      downtimeHours: double.tryParse(_downtime.text) ?? 0,
      avgDelayCostPerEvent: double.tryParse(_delayCost.text.replaceAll(',', '')) ?? 0,
      inventoryValue: double.tryParse(_inventory.text.replaceAll(',', '')) ?? 0,
    );
    setState(() => _result = r);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1F2937)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.t('pub_calc_title'),
            style: GoogleFonts.spaceGrotesk(
              color: const Color(0xFFF9FAFB),
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.t('pub_calc_subtitle'),
            style: GoogleFonts.ibmPlexSans(color: const Color(0xFF9CA3AF), fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, c) {
              final row = c.maxWidth > 720;
              Widget field(String label, TextEditingController ctrl) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextField(
                    controller: ctrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Color(0xFFF9FAFB)),
                    decoration: InputDecoration(
                      labelText: label,
                      labelStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                      filled: true,
                      fillColor: const Color(0x08FFFFFF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF1F2937)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF1F2937)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF2563EB)),
                      ),
                    ),
                  ),
                );
              }

              final children = [
                field(l10n.t('pub_calc_monthly_revenue'), _revenue),
                field(l10n.t('pub_calc_downtime_hours'), _downtime),
                field(l10n.t('pub_calc_delay_cost'), _delayCost),
                field(l10n.t('pub_calc_inventory_value'), _inventory),
              ];
              if (row) {
                return Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: children[0]),
                        const SizedBox(width: 12),
                        Expanded(child: children[1]),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: children[2]),
                        const SizedBox(width: 12),
                        Expanded(child: children[3]),
                      ],
                    ),
                  ],
                );
              }
              return Column(children: children);
            },
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: _run,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(l10n.t('pub_calc_cta')),
          ),
          if (_result != null) ...[
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color(0xFF030712),
                border: Border.all(color: const Color(0xFF2563EB).withValues(alpha: 0.35)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.t('pub_calc_result_label'),
                    style: GoogleFonts.ibmPlexSans(color: const Color(0xFF9CA3AF), fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '€${_result!.estimatedMonthlySavings.toStringAsFixed(0)}${l10n.t('per_month')}',
                    style: GoogleFonts.spaceGrotesk(
                      color: const Color(0xFF34D399),
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.t('pub_calc_result_hint'),
                    style: GoogleFonts.ibmPlexSans(color: const Color(0xFF9CA3AF), fontSize: 12, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
