import 'package:fabricos/features/website/presentation/widgets/public_site_theme.dart';
import 'package:fabricos/features/website/presentation/widgets/website_footer.dart';
import 'package:fabricos/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

/// High-intent demo booking — deep-links to calendar URL or falls back to contact.
class BookDemoPage extends StatelessWidget {
  const BookDemoPage({super.key});

  static const String _defaultCalendarUrl = 'https://cal.com';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ColoredBox(
      color: PublicSiteTheme.background,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 56, 24, 72),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Column(
                    children: [
                      Text(
                        l10n.t('book_demo_title'),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.spaceGrotesk(
                          color: PublicSiteTheme.foreground,
                          fontSize: 42,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.t('book_demo_subtitle'),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.ibmPlexSans(
                          color: PublicSiteTheme.mutedForeground,
                          fontSize: 18,
                          height: 1.55,
                        ),
                      ),
                      const SizedBox(height: 36),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: PublicSiteTheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 18,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        onPressed: () async {
                          final uri = Uri.parse(_defaultCalendarUrl);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        },
                        child: Text(l10n.t('book_demo_cta_calendar')),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: PublicSiteTheme.foreground,
                          side: const BorderSide(color: PublicSiteTheme.border),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        onPressed: () => context.go('/contact'),
                        child: Text(l10n.t('book_demo_cta_form')),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        l10n.t('book_demo_footnote'),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.ibmPlexSans(
                          color: PublicSiteTheme.mutedForeground,
                          fontSize: 13,
                          height: 1.5,
                        ),
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
