import 'package:fabricos/features/website/presentation/widgets/public_site_theme.dart';
import 'package:fabricos/features/website/presentation/widgets/website_footer.dart';
import 'package:fabricos/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

/// Evidence-led case narratives for manufacturing buyers (COO / plant / SC).
class CaseStudiesPage extends StatelessWidget {
  const CaseStudiesPage({super.key});

  static const List<int> _studyIds = [1, 2, 3];

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
              padding: EdgeInsets.fromLTRB(
                24,
                compact ? 40 : 52,
                24,
                compact ? 28 : 36,
              ),
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
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    children: [
                      Text(
                        l10n.t('pub_cases_eyebrow').toUpperCase(),
                        style: GoogleFonts.ibmPlexSans(
                          color: PublicSiteTheme.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.35,
                        ),
                      ),
                      SizedBox(height: compact ? 10 : 14),
                      Text(
                        l10n.t('pub_cases_title'),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.spaceGrotesk(
                          color: PublicSiteTheme.foreground,
                          fontSize: compact ? 32 : 42,
                          fontWeight: FontWeight.w800,
                          height: 1.08,
                          letterSpacing: -0.8,
                        ),
                      ),
                      SizedBox(height: compact ? 12 : 16),
                      Text(
                        l10n.t('pub_cases_sub'),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.ibmPlexSans(
                          color: PublicSiteTheme.mutedForeground,
                          fontSize: compact ? 16 : 17,
                          height: 1.55,
                        ),
                      ),
                      SizedBox(height: compact ? 18 : 22),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: PublicSiteTheme.border),
                        ),
                        child: Text(
                          l10n.t('pub_cases_audience_line'),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.ibmPlexSans(
                            color: PublicSiteTheme.foreground,
                            fontSize: 14,
                            height: 1.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                compact ? 8 : 12,
                24,
                28,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1040),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < _studyIds.length; i++) ...[
                        if (i > 0) const SizedBox(height: 28),
                        _CaseStudyDetailCard(studyIndex: _studyIds[i]),
                      ],
                      const SizedBox(height: 32),
                      Text(
                        l10n.t('pub_cases_disclaimer'),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.ibmPlexSans(
                          color: PublicSiteTheme.mutedForeground,
                          fontSize: 12,
                          height: 1.45,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
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
                            onPressed: () => context.go('/contact'),
                            icon: const Icon(Icons.forum_outlined, size: 20),
                            label: Text(l10n.t('pub_mfg_cta_demo')),
                          ),
                          OutlinedButton.icon(
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
                            onPressed: () => context.go('/roi-calculator'),
                            icon: const Icon(Icons.calculate_outlined, size: 20),
                            label: Text(l10n.t('pub_mfg_cta_roi')),
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

class _CaseStudyDetailCard extends StatelessWidget {
  const _CaseStudyDetailCard({required this.studyIndex});

  final int studyIndex;

  String _t(AppLocalizations l10n, String suffix) =>
      l10n.t('pub_cases_${studyIndex}_$suffix');

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final kpis = [
      (_t(l10n, 'kpi1_label'), _t(l10n, 'kpi1_value')),
      (_t(l10n, 'kpi2_label'), _t(l10n, 'kpi2_value')),
      (_t(l10n, 'kpi3_label'), _t(l10n, 'kpi3_value')),
      (_t(l10n, 'kpi4_label'), _t(l10n, 'kpi4_value')),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: PublicSiteTheme.border),
        boxShadow: [
          BoxShadow(
            color: PublicSiteTheme.primary.withValues(alpha: 0.06),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  PublicSiteTheme.muted,
                  PublicSiteTheme.background,
                ],
              ),
              border: Border(
                bottom: BorderSide(
                  color: PublicSiteTheme.border.withValues(alpha: 0.85),
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: PublicSiteTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: PublicSiteTheme.primary.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Text(
                    _t(l10n, 'chip'),
                    style: GoogleFonts.ibmPlexSans(
                      color: PublicSiteTheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  _t(l10n, 'title'),
                  style: GoogleFonts.spaceGrotesk(
                    color: PublicSiteTheme.foreground,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _t(l10n, 'meta'),
                  style: GoogleFonts.ibmPlexSans(
                    color: PublicSiteTheme.mutedForeground,
                    fontSize: 13,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: LayoutBuilder(
              builder: (context, c) {
                final split = c.maxWidth >= 720;
                final challenge = _NarrativeBlock(
                  title: l10n.t('pub_cases_hdr_challenge'),
                  body: _t(l10n, 'challenge'),
                );
                final approach = _NarrativeBlock(
                  title: l10n.t('pub_cases_hdr_approach'),
                  body: _t(l10n, 'approach'),
                );
                if (split) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: challenge),
                      const SizedBox(width: 24),
                      Expanded(child: approach),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    challenge,
                    const SizedBox(height: 22),
                    approach,
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.t('pub_cases_hdr_outcomes'),
                  style: GoogleFonts.ibmPlexSans(
                    color: PublicSiteTheme.foreground,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 14),
                LayoutBuilder(
                  builder: (context, c) {
                    final cols = c.maxWidth >= 520 ? 2 : 1;
                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: cols,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: cols == 2 ? 2.25 : 2.8,
                      children: kpis
                          .map(
                            (k) => _KpiTile(label: k.$1, value: k.$2),
                          )
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(22, 0, 22, 22),
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            decoration: BoxDecoration(
              color: PublicSiteTheme.secondary.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: PublicSiteTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.format_quote_rounded,
                      color: PublicSiteTheme.primary.withValues(alpha: 0.65),
                      size: 26,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _t(l10n, 'quote'),
                        style: GoogleFonts.ibmPlexSans(
                          color: PublicSiteTheme.foreground,
                          fontSize: 15,
                          height: 1.55,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _t(l10n, 'byline'),
                  style: GoogleFonts.ibmPlexSans(
                    color: PublicSiteTheme.mutedForeground,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
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

class _NarrativeBlock extends StatelessWidget {
  const _NarrativeBlock({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: GoogleFonts.ibmPlexSans(
            color: PublicSiteTheme.foreground,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.05,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          body,
          style: GoogleFonts.ibmPlexSans(
            color: PublicSiteTheme.mutedForeground,
            fontSize: 15,
            height: 1.55,
          ),
        ),
      ],
    );
  }
}

class _KpiTile extends StatelessWidget {
  const _KpiTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: PublicSiteTheme.muted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PublicSiteTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.ibmPlexSans(
              color: PublicSiteTheme.mutedForeground,
              fontSize: 11,
              height: 1.25,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              color: PublicSiteTheme.foreground,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}
