import 'package:fabricos/core/theme/intelligence_theme.dart';
import 'package:fabricos/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

/// Logistics command center — links to supply, shipments, inventory (enterprise hub).
class LogisticsHubPage extends StatelessWidget {
  const LogisticsHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final w = MediaQuery.sizeOf(context).width;
    final pad = w < 560 ? 12.0 : 20.0;

    final cards = [
      (
        l10n.t('logistics_card_supply_title'),
        l10n.t('logistics_card_supply_desc'),
        Icons.hub_outlined,
        '/app/supply',
      ),
      (
        l10n.t('logistics_card_shipments_title'),
        l10n.t('logistics_card_shipments_desc'),
        Icons.route_outlined,
        '/app/shipments',
      ),
      (
        l10n.t('logistics_card_inventory_title'),
        l10n.t('logistics_card_inventory_desc'),
        Icons.inventory_2_outlined,
        '/app/inventory',
      ),
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(pad, pad, pad, pad + 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.t('logistics_hub_title'),
            style: GoogleFonts.spaceGrotesk(
              fontSize: w < 600 ? 22 : 26,
              fontWeight: FontWeight.w800,
              color: IntelligenceTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.t('logistics_hub_subtitle'),
            style: GoogleFonts.ibmPlexSans(
              fontSize: 14,
              height: 1.5,
              color: IntelligenceTheme.textMuted,
            ),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, c) {
              final cols = c.maxWidth >= 900 ? 3 : 1;
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: cols,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: cols == 3 ? 1.15 : 1.55,
                children: cards
                    .map(
                      (e) => _HubCard(
                        title: e.$1,
                        description: e.$2,
                        icon: e.$3,
                        onTap: () => context.go(e.$4),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 28),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: IntelligenceTheme.panel,
              border: Border.all(color: IntelligenceTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.t('logistics_ops_title'),
                  style: GoogleFonts.ibmPlexSans(
                    fontWeight: FontWeight.w700,
                    color: IntelligenceTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.t('logistics_ops_body'),
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 13,
                    height: 1.45,
                    color: IntelligenceTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    OutlinedButton(
                      onPressed: () => context.go('/app/vendor-portal'),
                      child: Text(l10n.t('app_nav_vendor_portal')),
                    ),
                    OutlinedButton(
                      onPressed: () => context.go('/app/plant-floor'),
                      child: Text(l10n.t('app_nav_plant_floor')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HubCard extends StatelessWidget {
  const _HubCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: IntelligenceTheme.panelAlt,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: IntelligenceTheme.accent, size: 28),
              const SizedBox(height: 12),
              Text(
                title,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: IntelligenceTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 13,
                  height: 1.45,
                  color: IntelligenceTheme.textMuted,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    context.l10n.t('logistics_open_module'),
                    style: GoogleFonts.ibmPlexSans(
                      color: IntelligenceTheme.accentStrong,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: IntelligenceTheme.accentStrong,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
