import 'package:fabricos/features/website/presentation/widgets/marketing_page_widgets.dart';
import 'package:fabricos/features/website/presentation/widgets/website_footer.dart';
import 'package:fabricos/localization/app_localizations.dart';
import 'package:flutter/material.dart';

class FeaturesPage extends StatelessWidget {
  const FeaturesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final features = <({IconData icon, String title, String description})>[
      (
        icon: Icons.memory_rounded,
        title: l10n.t('pub_feat_pm_title'),
        description: l10n.t('pub_feat_pm_desc'),
      ),
      (
        icon: Icons.inventory_2_rounded,
        title: l10n.t('pub_feat_ord_title'),
        description: l10n.t('pub_feat_ord_desc'),
      ),
      (
        icon: Icons.groups_rounded,
        title: l10n.t('pub_feat_sup_title'),
        description: l10n.t('pub_feat_sup_desc'),
      ),
      (
        icon: Icons.eco_rounded,
        title: l10n.t('pub_feat_esg_title'),
        description: l10n.t('pub_feat_esg_desc'),
      ),
      (
        icon: Icons.bolt_rounded,
        title: l10n.t('pub_feat_rt_title'),
        description: l10n.t('pub_feat_rt_desc'),
      ),
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MarketingPageIntro(
            eyebrow: l10n.t('pub_feat_eyebrow'),
            title: l10n.t('pub_feat_title'),
            subtitle: l10n.t('pub_feat_subtitle'),
          ),
          MarketingBody(
            maxWidth: 900,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < features.length; i++) ...[
                  MarketingBentoTile(
                    icon: features[i].icon,
                    title: features[i].title,
                    description: features[i].description,
                  ),
                  if (i < features.length - 1) const SizedBox(height: 16),
                ],
              ],
            ),
          ),
          const WebsiteFooter(),
        ],
      ),
    );
  }
}
