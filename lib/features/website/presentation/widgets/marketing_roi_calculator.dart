import 'package:fabricos/core/marketing/roi_calculator_logic.dart';
import 'package:fabricos/features/website/presentation/widgets/public_site_theme.dart';
import 'package:fabricos/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

String _formatEuroAmount(double v) {
  final s = v.round().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    final fromEnd = s.length - i;
    if (i > 0 && fromEnd % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return buf.toString();
}

/// Shared ROI calculator for marketing pages (aligned with [PublicSiteTheme]).
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

  static List<BoxShadow> get _cardShadow => [
        BoxShadow(
          color: PublicSiteTheme.primary.withValues(alpha: 0.07),
          blurRadius: 48,
          offset: const Offset(0, 20),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

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
      avgDelayCostPerEvent:
          double.tryParse(_delayCost.text.replaceAll(',', '')) ?? 0,
      inventoryValue:
          double.tryParse(_inventory.text.replaceAll(',', '')) ?? 0,
    );
    setState(() => _result = r);
  }

  Widget _field(
    BuildContext context, {
    required String label,
    required TextEditingController ctrl,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: ctrl,
        onSubmitted: (_) => _run(),
        keyboardType: TextInputType.number,
        style: GoogleFonts.ibmPlexSans(
          color: PublicSiteTheme.foreground,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.ibmPlexSans(
            color: PublicSiteTheme.mutedForeground,
            fontSize: 14,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Icon(icon, color: PublicSiteTheme.primary, size: 22),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 44),
          filled: true,
          fillColor: PublicSiteTheme.muted,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: PublicSiteTheme.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: PublicSiteTheme.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: PublicSiteTheme.primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _inputsColumn(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.t('pub_calc_title'),
          style: GoogleFonts.spaceGrotesk(
            color: PublicSiteTheme.foreground,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.t('pub_calc_subtitle'),
          style: GoogleFonts.ibmPlexSans(
            color: PublicSiteTheme.mutedForeground,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 22),
        _field(
          context,
          label: l10n.t('pub_calc_monthly_revenue'),
          ctrl: _revenue,
          icon: Icons.euro_rounded,
        ),
        _field(
          context,
          label: l10n.t('pub_calc_downtime_hours'),
          ctrl: _downtime,
          icon: Icons.timer_outlined,
        ),
        _field(
          context,
          label: l10n.t('pub_calc_delay_cost'),
          ctrl: _delayCost,
          icon: Icons.warning_amber_rounded,
        ),
        _field(
          context,
          label: l10n.t('pub_calc_inventory_value'),
          ctrl: _inventory,
          icon: Icons.inventory_2_outlined,
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _run,
            style: FilledButton.styleFrom(
              backgroundColor: PublicSiteTheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.calculate_outlined, size: 22),
            label: Text(
              l10n.t('pub_calc_cta'),
              style: GoogleFonts.ibmPlexSans(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _resultPanel(AppLocalizations l10n) {
    final r = _result;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PublicSiteTheme.primary.withValues(alpha: 0.06),
            PublicSiteTheme.accent.withValues(alpha: 0.08),
          ],
        ),
        border: Border.all(
          color: PublicSiteTheme.primary.withValues(alpha: 0.18),
        ),
      ),
      child: r == null
          ? _ResultPlaceholder(l10n: l10n)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.insights_rounded,
                      color: PublicSiteTheme.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.t('pub_calc_result_label'),
                        style: GoogleFonts.ibmPlexSans(
                          color: PublicSiteTheme.mutedForeground,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '€${_formatEuroAmount(r.estimatedMonthlySavings)}${l10n.t('per_month')}',
                  style: GoogleFonts.spaceGrotesk(
                    color: PublicSiteTheme.foreground,
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    height: 1.05,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: PublicSiteTheme.border),
                  ),
                  child: Column(
                    children: [
                      _BreakdownRow(
                        label: l10n.t('pub_calc_breakdown_downtime'),
                        value: r.downtimeCost,
                      ),
                      const Divider(height: 18),
                      _BreakdownRow(
                        label: l10n.t('pub_calc_breakdown_delays'),
                        value: r.delayCost,
                      ),
                      const Divider(height: 18),
                      _BreakdownRow(
                        label: l10n.t('pub_calc_breakdown_inventory'),
                        value: r.inventoryCarryingCost,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  l10n.t('pub_calc_result_hint'),
                  style: GoogleFonts.ibmPlexSans(
                    color: PublicSiteTheme.mutedForeground,
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ],
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return LayoutBuilder(
      builder: (context, c) {
        final split = c.maxWidth >= 880;
        return Container(
          padding: EdgeInsets.all(split ? 32 : 22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: PublicSiteTheme.border),
            boxShadow: _cardShadow,
          ),
          child: split
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 11, child: _inputsColumn(l10n)),
                    const SizedBox(width: 28),
                    Expanded(flex: 9, child: _resultPanel(l10n)),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _inputsColumn(l10n),
                    const SizedBox(height: 24),
                    _resultPanel(l10n),
                  ],
                ),
        );
      },
    );
  }
}

class _ResultPlaceholder extends StatelessWidget {
  const _ResultPlaceholder({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.trending_up_rounded,
          size: 40,
          color: PublicSiteTheme.primary.withValues(alpha: 0.35),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.t('pub_calc_result_label'),
          textAlign: TextAlign.center,
          style: GoogleFonts.ibmPlexSans(
            color: PublicSiteTheme.mutedForeground,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.t('pub_calc_subtitle'),
          textAlign: TextAlign.center,
          style: GoogleFonts.ibmPlexSans(
            color: PublicSiteTheme.mutedForeground,
            fontSize: 12,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.label,
    required this.value,
  });

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.ibmPlexSans(
            color: PublicSiteTheme.mutedForeground,
            fontSize: 13,
          ),
        ),
        Text(
          '€${_formatEuroAmount(value)}',
          style: GoogleFonts.ibmPlexSans(
            color: PublicSiteTheme.foreground,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
