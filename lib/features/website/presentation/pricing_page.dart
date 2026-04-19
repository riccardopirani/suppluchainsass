import 'package:fabricos/config/stripe_plans.dart';
import 'package:fabricos/core/theme/app_colors.dart';
import 'package:fabricos/features/website/presentation/widgets/marketing_page_widgets.dart';
import 'package:fabricos/features/website/presentation/widgets/website_footer.dart';
import 'package:fabricos/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class PricingPage extends StatefulWidget {
  const PricingPage({super.key});

  @override
  State<PricingPage> createState() => _PricingPageState();
}

class _PricingPageState extends State<PricingPage> {
  final _seatsController = TextEditingController(text: '10');
  double _sliderVal = 10;

  int get _qty {
    final v = int.tryParse(_seatsController.text) ?? 1;
    return v < 1 ? 1 : v;
  }

  @override
  void dispose() {
    _seatsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final qty = _qty;
    final unitPrice = SeatPricing.unitPrice(qty);
    final total = SeatPricing.monthlyTotal(qty);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MarketingPageIntro(
            eyebrow: l10n.t('pub_price_eyebrow'),
            title: l10n.t('pub_price_title'),
            subtitle: l10n.t('pub_price_subtitle'),
          ),
          MarketingBody(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 980;
                final selectorCard = _selectorCard(
                  context,
                  l10n,
                  scheme,
                  qty: qty,
                  unitPrice: unitPrice,
                  total: total,
                );

                final supportingContent = Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _tierTable(context, l10n, scheme),
                    const SizedBox(height: 28),
                    _featuresList(context, l10n, scheme),
                  ],
                );

                if (wide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 5, child: selectorCard),
                      const SizedBox(width: 24),
                      Expanded(flex: 4, child: supportingContent),
                    ],
                  );
                }

                return Column(
                  children: [
                    selectorCard,
                    const SizedBox(height: 28),
                    supportingContent,
                  ],
                );
              },
            ),
          ),
          const WebsiteFooter(),
        ],
      ),
    );
  }

  Widget _selectorCard(
    BuildContext context,
    AppLocalizations l10n,
    ColorScheme scheme, {
    required int qty,
    required double unitPrice,
    required double total,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          width: 1.4,
          color: scheme.primary.withValues(alpha: 0.38),
        ),
        color: scheme.surfaceContainerHighest.withValues(
          alpha: isDark ? 0.48 : 0.9,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.08),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.t('pricing_how_many_users'),
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: scheme.outline.withValues(alpha: 0.22)),
              color: scheme.surface.withValues(alpha: isDark ? 0.35 : 0.95),
            ),
            child: TextField(
              controller: _seatsController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 42,
                fontWeight: FontWeight.w800,
                color: scheme.primary,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                suffixText: l10n.t('pricing_users'),
                suffixStyle: GoogleFonts.ibmPlexSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              onChanged: (v) {
                final n = int.tryParse(v);
                setState(() {
                  if (n != null && n >= 1 && n <= 500) {
                    _sliderVal = n.toDouble();
                  }
                });
              },
            ),
          ),
          const SizedBox(height: 12),
          Slider(
            min: 1,
            max: 500,
            divisions: 499,
            value: _sliderVal.clamp(1, 500),
            label: '${_sliderVal.round()}',
            onChanged: (v) {
              setState(() {
                _sliderVal = v;
                _seatsController.text = '${v.round()}';
              });
            },
          ),
          Text(
            l10n.t('pricing_slider_hint'),
            textAlign: TextAlign.center,
            style: GoogleFonts.ibmPlexSans(
              fontSize: 13,
              height: 1.45,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: scheme.primary.withValues(alpha: 0.08),
              border: Border.all(color: scheme.primary.withValues(alpha: 0.16)),
            ),
            child: Column(
              children: [
                Text(
                  '€${total.toStringAsFixed(0)}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 52,
                    fontWeight: FontWeight.w800,
                    height: 1,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.t('pub_price_period'),
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '€${unitPrice.toStringAsFixed(2)} ${l10n.t('pricing_per_user_month')}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 14,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                backgroundColor: scheme.primary,
                foregroundColor: Theme.of(context).brightness == Brightness.dark
                    ? scheme.onPrimary
                    : AppColorsLight.onPrimary,
              ),
              onPressed: () => context.go('/register?seats=$qty'),
              child: Text(
                l10n.t('cta_start_trial'),
                style: GoogleFonts.ibmPlexSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.t('pub_price_footnote'),
            textAlign: TextAlign.center,
            style: GoogleFonts.ibmPlexSans(
              fontSize: 12,
              height: 1.45,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tierTable(
    BuildContext context,
    AppLocalizations l10n,
    ColorScheme scheme,
  ) {
    final rows = [
      ['1 – 10', '€9.00'],
      ['11 – 50', '€8.00'],
      ['51 – 200', '€7.00'],
      ['201 – 500', '€6.00'],
      ['501+', '€5.00'],
    ];
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.3)),
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Text(
              l10n.t('pricing_volume_discounts'),
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          for (var i = 0; i < rows.length; i++)
            _discountRow(
              context,
              scheme,
              range: rows[i][0],
              price: rows[i][1],
              isLast: i == rows.length - 1,
              usersLabel: l10n.t('pricing_users'),
              periodLabel: l10n.t('pricing_per_user_month'),
            ),
        ],
      ),
    );
  }

  Widget _discountRow(
    BuildContext context,
    ColorScheme scheme, {
    required String range,
    required String price,
    required bool isLast,
    required String usersLabel,
    required String periodLabel,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 420;
        final rowContent = narrow
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$range $usersLabel',
                    style: GoogleFonts.ibmPlexSans(fontSize: 14, height: 1.4),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$price / $periodLabel',
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: scheme.primary,
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: Text(
                      '$range $usersLabel',
                      style: GoogleFonts.ibmPlexSans(fontSize: 14, height: 1.4),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '$price / $periodLabel',
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: scheme.primary,
                    ),
                  ),
                ],
              );

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            border: isLast
                ? null
                : Border(
                    bottom: BorderSide(
                      color: scheme.outline.withValues(alpha: 0.15),
                    ),
                  ),
          ),
          child: rowContent,
        );
      },
    );
  }

  Widget _featuresList(
    BuildContext context,
    AppLocalizations l10n,
    ColorScheme scheme,
  ) {
    final features = [
      l10n.t('pricing_feat_dashboard'),
      l10n.t('pricing_feat_machines'),
      l10n.t('pricing_feat_orders'),
      l10n.t('pricing_feat_suppliers'),
      l10n.t('pricing_feat_ai_risk'),
      l10n.t('pricing_feat_demand'),
      l10n.t('pricing_feat_inventory'),
      l10n.t('pricing_feat_esg'),
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.3)),
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.t('pricing_all_included'),
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 18,
            runSpacing: 12,
            children: features
                .map(
                  (f) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 18,
                        color: scheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(f, style: GoogleFonts.ibmPlexSans(fontSize: 14)),
                    ],
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
