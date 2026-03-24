import 'package:fabricos/features/website/presentation/widgets/marketing_page_widgets.dart';
import 'package:fabricos/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = <(String, String)>[
      (l10n.t('pub_faq_q1'), l10n.t('pub_faq_a1')),
      (l10n.t('pub_faq_q2'), l10n.t('pub_faq_a2')),
      (l10n.t('pub_faq_q3'), l10n.t('pub_faq_a3')),
      (l10n.t('pub_faq_q4'), l10n.t('pub_faq_a4')),
    ];

    final scheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MarketingPageIntro(
            eyebrow: l10n.t('pub_faq_eyebrow'),
            title: l10n.t('pub_faq_title'),
            subtitle: l10n.t('pub_faq_subtitle'),
          ),
          MarketingBody(
            maxWidth: 800,
            child: Column(
              children: [
                for (var i = 0; i < items.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Material(
                      color: scheme.surface,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: BorderSide(color: scheme.outline.withValues(alpha: 0.28)),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          dividerColor: Colors.transparent,
                          expansionTileTheme: ExpansionTileThemeData(
                            shape: const RoundedRectangleBorder(),
                            collapsedShape: const RoundedRectangleBorder(),
                            iconColor: scheme.primary,
                            collapsedIconColor: scheme.primary,
                          ),
                        ),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 4,
                          ),
                          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          title: Text(
                            items[i].$1,
                            style: GoogleFonts.ibmPlexSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              height: 1.35,
                            ),
                          ),
                          children: [
                            Text(
                              items[i].$2,
                              style: GoogleFonts.ibmPlexSans(
                                fontSize: 14,
                                height: 1.55,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
