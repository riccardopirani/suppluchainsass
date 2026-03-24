import 'package:fabricos/core/theme/app_colors.dart';
import 'package:fabricos/features/website/presentation/widgets/marketing_page_widgets.dart';
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
              builder: (context, c) {
                final run = c.maxWidth < 640;
                final cards = [
                  _PlanCard(
                    title: l10n.t('plan_starter'),
                    price: '€149',
                    period: l10n.t('pub_price_period'),
                    features: [
                      l10n.t('pub_price_starter_f1'),
                      l10n.t('pub_price_starter_f2'),
                      l10n.t('pub_price_starter_f3'),
                      l10n.t('pub_price_starter_f4'),
                    ],
                    cta: l10n.t('cta_start_trial'),
                    onTap: () => context.go('/register'),
                    highlighted: false,
                  ),
                  _PlanCard(
                    title: l10n.t('plan_growth'),
                    price: '€399',
                    period: l10n.t('pub_price_period'),
                    features: [
                      l10n.t('pub_price_growth_f1'),
                      l10n.t('pub_price_growth_f2'),
                      l10n.t('pub_price_growth_f3'),
                      l10n.t('pub_price_growth_f4'),
                    ],
                    cta: l10n.t('cta_start_trial'),
                    onTap: () => context.go('/register'),
                    highlighted: true,
                  ),
                  _PlanCard(
                    title: l10n.t('plan_enterprise'),
                    price: l10n.t('pub_price_custom'),
                    period: '',
                    features: [
                      l10n.t('pub_price_ent_f1'),
                      l10n.t('pub_price_ent_f2'),
                      l10n.t('pub_price_ent_f3'),
                      l10n.t('pub_price_ent_f4'),
                    ],
                    cta: l10n.t('contact_sales'),
                    onTap: () => context.go('/contact'),
                    highlighted: false,
                  ),
                ];
                if (run) {
                  return Column(
                    children: cards
                        .map(
                          (w) => Padding(
                            padding: const EdgeInsets.only(bottom: 18),
                            child: w,
                          ),
                        )
                        .toList(),
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < cards.length; i++) ...[
                      Expanded(child: cards[i]),
                      if (i < cards.length - 1) const SizedBox(width: 18),
                    ],
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 56),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: scheme.outline.withValues(alpha: 0.3)),
                    color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.verified_outlined, color: scheme.primary, size: 28),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          l10n.t('pub_price_footnote'),
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 14,
                            height: 1.45,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.price,
    required this.period,
    required this.features,
    required this.cta,
    required this.onTap,
    required this.highlighted,
  });

  final String title;
  final String price;
  final String period;
  final List<String> features;
  final String cta;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          width: highlighted ? 2 : 1,
          color: highlighted
              ? scheme.primary.withValues(alpha: 0.65)
              : scheme.outline.withValues(alpha: 0.35),
        ),
        boxShadow: highlighted
            ? [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: 0.2),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ]
            : null,
        gradient: highlighted
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  scheme.primary.withValues(alpha: 0.12),
                  scheme.surface,
                ],
              )
            : null,
        color: highlighted ? null : scheme.surface,
      ),
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (highlighted)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: scheme.primary.withValues(alpha: 0.18),
                ),
                child: Text(
                  context.l10n.t('pub_price_badge'),
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: scheme.primary,
                  ),
                ),
              ),
            Text(
              title,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  price,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    height: 1,
                    color: highlighted ? scheme.primary : scheme.onSurface,
                  ),
                ),
                if (period.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Text(
                    period,
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 14,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 22),
            ...features.map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_rounded, size: 20, color: scheme.primary),
                    const SizedBox(width: 10),
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
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  backgroundColor: highlighted ? scheme.primary : scheme.primary,
                  foregroundColor: Theme.of(context).brightness == Brightness.dark
                      ? scheme.onPrimary
                      : AppColorsLight.onPrimary,
                ),
                onPressed: onTap,
                child: Text(
                  cta,
                  style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
