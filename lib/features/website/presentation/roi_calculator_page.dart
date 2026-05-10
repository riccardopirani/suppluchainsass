import 'package:fabricos/features/website/presentation/widgets/marketing_roi_calculator.dart';
import 'package:fabricos/features/website/presentation/widgets/public_site_theme.dart';
import 'package:fabricos/features/website/presentation/widgets/website_footer.dart';
import 'package:fabricos/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class RoiCalculatorPage extends StatelessWidget {
  const RoiCalculatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final w = MediaQuery.sizeOf(context).width;
    final compact = w < 720;
    return ColoredBox(
      color: PublicSiteTheme.background,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(24, compact ? 40 : 56, 24, compact ? 28 : 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    PublicSiteTheme.secondary.withValues(alpha: 0.55),
                    PublicSiteTheme.background,
                  ],
                ),
                border: const Border(
                  bottom: BorderSide(color: PublicSiteTheme.border),
                ),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    children: [
                      Text(
                        l10n.t('pub_calc_eyebrow').toUpperCase(),
                        style: GoogleFonts.ibmPlexSans(
                          color: PublicSiteTheme.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.35,
                        ),
                      ),
                      SizedBox(height: compact ? 10 : 14),
                      Text(
                        l10n.t('pub_roi_page_title'),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.spaceGrotesk(
                          color: PublicSiteTheme.foreground,
                          fontSize: compact ? 34 : 44,
                          fontWeight: FontWeight.w800,
                          height: 1.08,
                          letterSpacing: -0.8,
                        ),
                      ),
                      SizedBox(height: compact ? 12 : 16),
                      Text(
                        l10n.t('pub_roi_page_sub'),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.ibmPlexSans(
                          color: PublicSiteTheme.mutedForeground,
                          fontSize: compact ? 16 : 18,
                          height: 1.55,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24, compact ? 8 : 12, 24, 56),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1040),
                  child: Column(
                    children: [
                      const MarketingRoiCalculator(),
                      const SizedBox(height: 28),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: PublicSiteTheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 22,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            onPressed: () => context.go('/register'),
                            icon: const Icon(Icons.rocket_launch_rounded, size: 20),
                            label: Text(l10n.t('pub_mfg_cta_trial')),
                          ),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: PublicSiteTheme.foreground,
                              side: const BorderSide(color: PublicSiteTheme.border),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 22,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            onPressed: () => context.go('/book-demo'),
                            child: Text(l10n.t('cta_book_demo')),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const WebsiteFooter(),
          ],
        ),
      ),
    );
  }
}
