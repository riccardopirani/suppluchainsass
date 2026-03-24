import 'package:fabricos/features/website/presentation/widgets/marketing_page_widgets.dart';
import 'package:fabricos/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum LegalType { privacy, terms, cookies }

class LegalPage extends StatelessWidget {
  const LegalPage({super.key, required this.type});

  final LegalType type;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final title = switch (type) {
      LegalType.privacy => l10n.t('footer_privacy'),
      LegalType.terms => l10n.t('footer_terms'),
      LegalType.cookies => l10n.t('footer_cookies'),
    };

    final scheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MarketingPageIntro(
            eyebrow: l10n.t('pub_legal_eyebrow'),
            title: title,
            subtitle: l10n.t('pub_legal_subtitle'),
          ),
          MarketingBody(
            maxWidth: 760,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: scheme.outline.withValues(alpha: 0.3)),
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.t('pub_legal_updated'),
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    l10n.t('pub_legal_placeholder'),
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 16,
                      height: 1.65,
                      color: scheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
