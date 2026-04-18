import 'package:fabricos/features/website/presentation/widgets/marketing_roi_calculator.dart';
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
    return Container(
      color: const Color(0xFF030712),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    children: [
                      Text(
                        l10n.t('pub_roi_page_title'),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.spaceGrotesk(
                          color: const Color(0xFFF9FAFB),
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.t('pub_roi_page_sub'),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.ibmPlexSans(
                          color: const Color(0xFF9CA3AF),
                          fontSize: 18,
                          height: 1.55,
                        ),
                      ),
                      const SizedBox(height: 32),
                      const MarketingRoiCalculator(),
                      const SizedBox(height: 24),
                      OutlinedButton(
                        onPressed: () => context.go('/register'),
                        child: Text(l10n.t('pub_mfg_cta_trial')),
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
