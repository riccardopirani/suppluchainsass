import 'package:fabricos/features/website/presentation/widgets/website_footer.dart';
import 'package:fabricos/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class CaseStudiesPage extends StatelessWidget {
  const CaseStudiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final studies = [
      (
        'Aerospace supplier · 240 FTE',
        'Cut unplanned downtime 27% by aligning maintenance tickets with supplier delay alerts.',
        '€180k estimated annual savings',
      ),
      (
        'Food packaging · multi-plant',
        'Unified inventory signals across 3 sites — reduced slow movers 14% in one quarter.',
        'Inventory carrying cost −11%',
      ),
      (
        'Industrial electronics',
        'Executive dashboard replaced 6 weekly decks; OTIF improved 6 pts in 60 days.',
        'On-time delivery +6 pts',
      ),
    ];
    return Container(
      color: const Color(0xFF030712),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 48),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    children: [
                      Text(
                        l10n.t('pub_cases_title'),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.spaceGrotesk(
                          color: const Color(0xFFF9FAFB),
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.t('pub_cases_sub'),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.ibmPlexSans(color: const Color(0xFF9CA3AF), fontSize: 17, height: 1.5),
                      ),
                      const SizedBox(height: 40),
                      for (final s in studies)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF1F2937)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.$1,
                                style: GoogleFonts.spaceGrotesk(
                                  color: const Color(0xFFF9FAFB),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                s.$2,
                                style: GoogleFonts.ibmPlexSans(color: const Color(0xFF9CA3AF), height: 1.55),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                s.$3,
                                style: GoogleFonts.ibmPlexSans(
                                  color: const Color(0xFF34D399),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      FilledButton(
                        onPressed: () => context.go('/contact'),
                        child: Text(l10n.t('pub_mfg_cta_demo')),
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
