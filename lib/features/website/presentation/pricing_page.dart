import 'package:fabricos/config/plan_catalog.dart';
import 'package:fabricos/core/theme/app_colors.dart';
import 'package:fabricos/features/website/presentation/widgets/marketing_page_widgets.dart';
import 'package:fabricos/features/website/presentation/widgets/website_footer.dart';
import 'package:fabricos/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class PricingPage extends StatelessWidget {
  const PricingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

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
                final wide = constraints.maxWidth >= 1000;
                final cards = _planCards(context, l10n, scheme);

                if (wide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < cards.length; i++) ...[
                        if (i > 0) const SizedBox(width: 16),
                        Expanded(child: cards[i]),
                      ],
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < cards.length; i++) ...[
                      if (i > 0) const SizedBox(height: 16),
                      cards[i],
                    ],
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text(
              l10n.t('pub_price_annual_note'),
              textAlign: TextAlign.center,
              style: GoogleFonts.ibmPlexSans(
                fontSize: 14,
                height: 1.45,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: Text(
              l10n.t('pub_price_footnote'),
              textAlign: TextAlign.center,
              style: GoogleFonts.ibmPlexSans(
                fontSize: 12,
                height: 1.45,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          const WebsiteFooter(),
        ],
      ),
    );
  }

  List<Widget> _planCards(
    BuildContext context,
    AppLocalizations l10n,
    ColorScheme scheme,
  ) {
    Widget card({
      required String planKey,
      required String nameKey,
      required String priceKey,
      required List<String> featureKeys,
      required bool highlight,
    }) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final features = featureKeys.map((k) => l10n.t(k)).toList();
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            width: highlight ? 1.6 : 1.1,
            color: highlight
                ? scheme.primary.withValues(alpha: 0.55)
                : scheme.outline.withValues(alpha: 0.28),
          ),
          color: scheme.surfaceContainerHighest.withValues(
            alpha: isDark ? 0.48 : 0.92,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (highlight)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: scheme.primary.withValues(alpha: 0.12),
                ),
                child: Text(
                  l10n.t('pub_price_badge'),
                  style: GoogleFonts.ibmPlexSans(
                    color: scheme.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            if (highlight) const SizedBox(height: 12),
            Text(
              l10n.t(nameKey),
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  l10n.t(priceKey),
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    height: 1,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    l10n.t('pub_price_period'),
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            for (final f in features) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: scheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      f,
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 8),
            FilledButton(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: scheme.primary,
                foregroundColor: Theme.of(context).brightness == Brightness.dark
                    ? scheme.onPrimary
                    : AppColorsLight.onPrimary,
              ),
              onPressed: () => context.go('/register?plan=$planKey'),
              child: Text(
                l10n.t('pub_price_cta_start'),
                style: GoogleFonts.ibmPlexSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return [
      card(
        planKey: PlanCatalog.essenziale.planKey,
        nameKey: 'pub_price_essenziale_name',
        priceKey: 'pub_price_essenziale_price',
        featureKeys: const [
          'pub_price_essenziale_f1',
          'pub_price_essenziale_f2',
          'pub_price_essenziale_f3',
          'pub_price_essenziale_f4',
        ],
        highlight: false,
      ),
      card(
        planKey: PlanCatalog.professionale.planKey,
        nameKey: 'pub_price_professionale_name',
        priceKey: 'pub_price_professionale_price',
        featureKeys: const [
          'pub_price_professionale_f1',
          'pub_price_professionale_f2',
          'pub_price_professionale_f3',
          'pub_price_professionale_f4',
        ],
        highlight: true,
      ),
      card(
        planKey: PlanCatalog.industriale.planKey,
        nameKey: 'pub_price_industriale_name',
        priceKey: 'pub_price_industriale_price',
        featureKeys: const [
          'pub_price_industriale_f1',
          'pub_price_industriale_f2',
          'pub_price_industriale_f3',
          'pub_price_industriale_f4',
        ],
        highlight: false,
      ),
    ];
  }
}
