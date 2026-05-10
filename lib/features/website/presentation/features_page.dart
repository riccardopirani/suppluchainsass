import 'package:fabricos/features/website/presentation/widgets/marketing_page_widgets.dart';
import 'package:fabricos/features/website/presentation/widgets/website_footer.dart';
import 'package:fabricos/localization/app_localizations.dart';
import 'package:flutter/material.dart';

/// FabricOS capabilities — detailed copy for COO / plant / SC buyers.
class FeaturesPage extends StatelessWidget {
  const FeaturesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final features = <({
      IconData icon,
      String title,
      String description,
      String points,
    })>[
      (
        icon: Icons.hub_outlined,
        title: l10n.t('pub_feat_control_tower_title'),
        description: l10n.t('pub_feat_control_tower_desc'),
        points: l10n.t('pub_feat_control_tower_points'),
      ),
      (
        icon: Icons.bolt_rounded,
        title: l10n.t('pub_feat_rt_title'),
        description: l10n.t('pub_feat_rt_desc'),
        points: l10n.t('pub_feat_rt_points'),
      ),
      (
        icon: Icons.receipt_long_outlined,
        title: l10n.t('pub_feat_ord_title'),
        description: l10n.t('pub_feat_ord_desc'),
        points: l10n.t('pub_feat_ord_points'),
      ),
      (
        icon: Icons.groups_rounded,
        title: l10n.t('pub_feat_sup_intel_title'),
        description: l10n.t('pub_feat_sup_intel_desc'),
        points: l10n.t('pub_feat_sup_intel_points'),
      ),
      (
        icon: Icons.inventory_2_rounded,
        title: l10n.t('pub_feat_inv_title'),
        description: l10n.t('pub_feat_inv_desc'),
        points: l10n.t('pub_feat_inv_points'),
      ),
      (
        icon: Icons.precision_manufacturing_outlined,
        title: l10n.t('pub_feat_pm_title'),
        description: l10n.t('pub_feat_pm_desc'),
        points: l10n.t('pub_feat_pm_points'),
      ),
      (
        icon: Icons.science_rounded,
        title: l10n.t('pub_feat_sim_title'),
        description: l10n.t('pub_feat_sim_desc'),
        points: l10n.t('pub_feat_sim_points'),
      ),
      (
        icon: Icons.assessment_rounded,
        title: l10n.t('pub_feat_exec_title'),
        description: l10n.t('pub_feat_exec_desc'),
        points: l10n.t('pub_feat_exec_points'),
      ),
      (
        icon: Icons.public_rounded,
        title: l10n.t('pub_feat_esg_title'),
        description: l10n.t('pub_feat_esg_desc'),
        points: l10n.t('pub_feat_esg_points'),
      ),
      (
        icon: Icons.balance_rounded,
        title: l10n.t('pub_feat_freight_audit_title'),
        description: l10n.t('pub_feat_freight_audit_desc'),
        points: l10n.t('pub_feat_freight_audit_points'),
      ),
      (
        icon: Icons.eco_rounded,
        title: l10n.t('pub_feat_carbon_tracking_title'),
        description: l10n.t('pub_feat_carbon_tracking_desc'),
        points: l10n.t('pub_feat_carbon_tracking_points'),
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
            maxWidth: 960,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < features.length; i++) ...[
                  MarketingBentoTile(
                    icon: features[i].icon,
                    title: features[i].title,
                    description: features[i].description,
                    bulletPoints: features[i].points,
                  ),
                  if (i < features.length - 1) const SizedBox(height: 20),
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
