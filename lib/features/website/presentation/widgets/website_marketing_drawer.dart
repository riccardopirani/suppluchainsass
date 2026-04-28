import 'package:fabricos/features/website/presentation/widgets/language_selector.dart';
import 'package:fabricos/features/website/presentation/widgets/public_site_theme.dart';
import 'package:fabricos/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

/// Full navigation + CTAs for narrow viewports (mobile / small tablet).
class WebsiteMarketingDrawer extends StatelessWidget {
  const WebsiteMarketingDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    const bg = PublicSiteTheme.background;
    const border = PublicSiteTheme.border;
    const textPrimary = PublicSiteTheme.foreground;
    const textMuted = PublicSiteTheme.mutedForeground;

    void go(String path) {
      Navigator.pop(context);
      context.go(path);
    }

    Widget link(String label, String path) {
      return ListTile(
        title: Text(
          label,
          style: GoogleFonts.ibmPlexSans(
            color: textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        onTap: () => go(path),
      );
    }

    return Drawer(
      backgroundColor: bg,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 24),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset('assets/image.png', width: 40, height: 40),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'FabricOS',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: border),
            link(l10n.t('nav_features'), '/features'),
            link(l10n.t('nav_pricing'), '/pricing'),
            link(l10n.t('nav_roi'), '/roi-calculator'),
            link(l10n.t('nav_factory_audit'), '/factory-score'),
            link(l10n.t('nav_book_demo'), '/book-demo'),
            link(l10n.t('nav_case_studies'), '/case-studies'),
            link(l10n.t('nav_contact'), '/contact'),
            link(l10n.t('nav_faq'), '/faq'),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: LanguageSelector(),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: textPrimary,
                      side: const BorderSide(color: border),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => go('/contact'),
                    child: Text(l10n.t('pub_mfg_cta_demo')),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: textPrimary,
                      side: const BorderSide(color: border),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => go('/login'),
                    child: Text(l10n.t('nav_login')),
                  ),
                  const SizedBox(height: 10),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: PublicSiteTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => go('/register'),
                    child: Text(l10n.t('pub_mfg_cta_trial')),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                l10n.t('pub_footer_tagline'),
                style: GoogleFonts.ibmPlexSans(fontSize: 12, height: 1.4, color: textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
