import 'package:fabricos/features/website/presentation/widgets/marketing_roi_calculator.dart';
import 'package:fabricos/features/website/presentation/widgets/website_footer.dart';
import 'package:fabricos/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF030712),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _HeroSection(
              onStartTrial: () => context.go('/register'),
              onDemo: () => context.go('/book-demo'),
              onRoi: () => context.go('/roi-calculator'),
            ),
            const _PainSection(),
            const _SolutionSection(),
            const _RoiMetricsSection(),
            const _HomeRoiCalculatorSection(),
            const _FeaturesGridSection(),
            const _TestimonialsSection(),
            _PricingTiersSection(
              onPlan: (plan) => context.go('/register?plan=$plan'),
              onEnterprise: () => context.go('/contact'),
            ),
            const _ContactSection(),
            const _FaqSection(),
            const _LegalLinksSection(),
            _FinalCtaSection(
              onStartTrial: () => context.go('/register'),
              onDemo: () => context.go('/book-demo'),
              onRoi: () => context.go('/roi-calculator'),
            ),
            const WebsiteFooter(),
          ],
        ),
      ),
    );
  }
}

class _PageContainer extends StatelessWidget {
  const _PageContainer({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: child,
        ),
      ),
    );
  }
}

class _SectionWrap extends StatelessWidget {
  const _SectionWrap({
    required this.child,
    this.alt = false,
    this.padding = const EdgeInsets.symmetric(vertical: 96),
  });

  final Widget child;
  final bool alt;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: alt ? const Color(0xFF111827) : const Color(0xFF030712),
        border: alt
            ? Border(
                top: BorderSide(color: const Color(0xFF1F2937).withValues(alpha: 0.9)),
                bottom: BorderSide(color: const Color(0xFF1F2937).withValues(alpha: 0.9)),
              )
            : null,
      ),
      child: child,
    );
  }
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow({required this.icon, required this.text, this.center = true});
  final IconData icon;
  final String text;
  final bool center;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: center ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: const Color(0x142563EB),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: const Color(0xFF2563EB)),
              const SizedBox(width: 8),
              Text(
                text,
                style: GoogleFonts.ibmPlexSans(
                  color: const Color(0xFF2563EB),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 560;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              color: const Color(0xFFF9FAFB),
              fontSize: narrow ? 30 : 44,
              fontWeight: FontWeight.w700,
              height: 1.1,
              letterSpacing: -0.8,
            ),
          ),
        ),
        const SizedBox(height: 14),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.ibmPlexSans(
                color: const Color(0xFF9CA3AF),
                fontSize: narrow ? 16 : 18,
                height: 1.6,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.onStartTrial,
    required this.onDemo,
    required this.onRoi,
  });

  final VoidCallback onStartTrial;
  final VoidCallback onDemo;
  final VoidCallback onRoi;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isCompact = MediaQuery.sizeOf(context).width < 760;
    return _SectionWrap(
      padding: const EdgeInsets.fromLTRB(0, 108, 0, 72),
      child: Stack(
        children: [
          Positioned(
            top: -220,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Center(
                child: Container(
                  width: 820,
                  height: 820,
                  decoration: const BoxDecoration(
                    gradient: RadialGradient(
                      colors: [Color(0x332563EB), Color(0x00030712)],
                      stops: [0, 0.62],
                    ),
                  ),
                ),
              ),
            ),
          ),
          _PageContainer(
            child: Column(
              children: [
                _Eyebrow(icon: Icons.hub_outlined, text: l10n.t('pub_mfg_eyebrow')),
                const SizedBox(height: 18),
                Text(
                  l10n.t('pub_mfg_hero_title'),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spaceGrotesk(
                    color: const Color(0xFFF9FAFB),
                    fontSize: isCompact ? 38 : 58,
                    fontWeight: FontWeight.w800,
                    height: 1.08,
                    letterSpacing: -1.0,
                  ),
                ),
                const SizedBox(height: 20),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Text(
                    l10n.t('pub_mfg_hero_subtitle'),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.ibmPlexSans(
                      color: const Color(0xFF9CA3AF),
                      fontSize: isCompact ? 18 : 20,
                      height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.t('pub_mfg_trust_brand'),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.ibmPlexSans(
                    color: const Color(0xFF6B7280),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _Tag(l10n.t('pub_micro_1')),
                    _Tag(l10n.t('pub_micro_2')),
                    _Tag(l10n.t('pub_micro_3')),
                    _Tag(l10n.t('pub_micro_4')),
                    _Tag(l10n.t('pub_micro_5')),
                  ],
                ),
                const SizedBox(height: 28),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    FilledButton(
                      onPressed: onDemo,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(l10n.t('pub_mfg_cta_demo')),
                    ),
                    FilledButton.tonal(
                      onPressed: onStartTrial,
                      style: FilledButton.styleFrom(
                        foregroundColor: const Color(0xFFEAF2FF),
                        backgroundColor: const Color(0xFF1E293B),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(l10n.t('pub_mfg_cta_trial')),
                    ),
                    OutlinedButton(
                      onPressed: onRoi,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFF9FAFB),
                        side: const BorderSide(color: Color(0xFF1F2937)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(l10n.t('pub_mfg_cta_roi')),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    _Chip(icon: Icons.verified_outlined, text: l10n.t('pub_mfg_trust_1')),
                    _Chip(icon: Icons.notifications_active_outlined, text: l10n.t('pub_mfg_trust_2')),
                    _Chip(icon: Icons.description_outlined, text: l10n.t('pub_mfg_trust_3')),
                    _Chip(icon: Icons.shield_outlined, text: l10n.t('pub_mfg_trust_4')),
                  ],
                ),
                const SizedBox(height: 48),
                Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF1F2937)),
                    boxShadow: const [
                      BoxShadow(color: Color(0x80000000), blurRadius: 40, offset: Offset(0, 18)),
                    ],
                  ),
                  child: Image.network(
                    'https://storage.googleapis.com/banani-generated-images/generated-images/7b81f20e-7931-454e-ba1f-d868ca2e5775.jpg',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: isCompact ? 240 : 480,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFF0F172A),
                      height: isCompact ? 240 : 480,
                      alignment: Alignment.center,
                      child: Text(
                        l10n.t('pub_mfg_bento_title'),
                        style: const TextStyle(color: Color(0xFF9CA3AF)),
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

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        border: Border.all(color: const Color(0xFF1F2937)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF9CA3AF)),
          const SizedBox(width: 8),
          Text(text, style: GoogleFonts.ibmPlexSans(color: const Color(0xFF9CA3AF), fontSize: 13)),
        ],
      ),
    );
  }
}

class _PainSection extends StatelessWidget {
  const _PainSection();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cards = [
      (Icons.precision_manufacturing_outlined, 'pub_mfg_pain1_title', 'pub_mfg_pain1_desc'),
      (Icons.local_shipping_outlined, 'pub_mfg_pain2_title', 'pub_mfg_pain2_desc'),
      (Icons.inventory_2_outlined, 'pub_mfg_pain3_title', 'pub_mfg_pain3_desc'),
      (Icons.table_chart_outlined, 'pub_mfg_pain4_title', 'pub_mfg_pain4_desc'),
    ];
    return _SectionWrap(
      alt: true,
      child: _PageContainer(
        child: Column(
          children: [
            _Eyebrow(icon: Icons.crisis_alert_outlined, text: l10n.t('pub_mfg_pain_eyebrow')),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                _Tag(l10n.t('pub_mfg_strip_1')),
                _Tag(l10n.t('pub_mfg_strip_2')),
                _Tag(l10n.t('pub_mfg_strip_3')),
                _Tag(l10n.t('pub_mfg_strip_4')),
                _Tag(l10n.t('pub_mfg_strip_5')),
              ],
            ),
            const SizedBox(height: 34),
            _SectionTitle(title: l10n.t('pub_mfg_pain_title'), subtitle: l10n.t('pub_mfg_pain_subtitle')),
            const SizedBox(height: 46),
            LayoutBuilder(
              builder: (context, c) {
                final col = c.maxWidth >= 980 ? 4 : c.maxWidth >= 700 ? 2 : 1;
                return GridView.count(
                  crossAxisCount: col,
                  shrinkWrap: true,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 18,
                  childAspectRatio: col == 1 ? 1.55 : 1.15,
                  physics: const NeverScrollableScrollPhysics(),
                  children: cards
                      .map(
                        (it) => _PainCard(
                          icon: it.$1,
                          title: l10n.t(it.$2),
                          text: l10n.t(it.$3),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF1F2937)),
        color: const Color(0x0DFFFFFF),
      ),
      child: Text(text, style: GoogleFonts.ibmPlexSans(color: const Color(0xFFF9FAFB), fontSize: 13)),
    );
  }
}

class _PainCard extends StatelessWidget {
  const _PainCard({required this.icon, required this.title, required this.text});
  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1F2937)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color(0x1AEF4444),
            ),
            child: Icon(icon, color: const Color(0xFFEF4444), size: 22),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.spaceGrotesk(
              color: const Color(0xFFF9FAFB),
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: GoogleFonts.ibmPlexSans(color: const Color(0xFF9CA3AF), fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _SolutionSection extends StatelessWidget {
  const _SolutionSection();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final keys = [
      ('pub_mfg_sol1_title', 'pub_mfg_sol1_desc'),
      ('pub_mfg_sol2_title', 'pub_mfg_sol2_desc'),
      ('pub_mfg_sol3_title', 'pub_mfg_sol3_desc'),
      ('pub_mfg_sol4_title', 'pub_mfg_sol4_desc'),
      ('pub_mfg_sol5_title', 'pub_mfg_sol5_desc'),
    ];
    return _SectionWrap(
      child: _PageContainer(
        child: Column(
          children: [
            _Eyebrow(icon: Icons.auto_awesome_outlined, text: l10n.t('pub_mfg_sol_eyebrow')),
            const SizedBox(height: 14),
            _SectionTitle(title: l10n.t('pub_mfg_sol_title'), subtitle: l10n.t('pub_mfg_sol_subtitle')),
            const SizedBox(height: 40),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                children: List.generate(keys.length, (i) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF1F2937)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0x1A2563EB),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            (i + 1).toString().padLeft(2, '0'),
                            style: GoogleFonts.ibmPlexSans(
                              color: const Color(0xFF2563EB),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.t(keys[i].$1),
                                style: GoogleFonts.spaceGrotesk(
                                  color: const Color(0xFFF9FAFB),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                l10n.t(keys[i].$2),
                                style: GoogleFonts.ibmPlexSans(
                                  color: const Color(0xFF9CA3AF),
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoiMetricsSection extends StatelessWidget {
  const _RoiMetricsSection();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final metrics = [
      ('−31%', l10n.t('pub_mfg_roi_m1')),
      ('+18%', l10n.t('pub_mfg_roi_m2')),
      ('−42%', l10n.t('pub_mfg_roi_m3')),
      ('+12%', l10n.t('pub_mfg_roi_m4')),
    ];
    return _SectionWrap(
      alt: true,
      child: _PageContainer(
        child: Column(
          children: [
            _Eyebrow(icon: Icons.insights_outlined, text: l10n.t('pub_mfg_roi_eyebrow')),
            const SizedBox(height: 14),
            _SectionTitle(title: l10n.t('pub_mfg_roi_title'), subtitle: l10n.t('pub_mfg_roi_subtitle')),
            const SizedBox(height: 44),
            LayoutBuilder(
              builder: (context, c) {
                final cols = c.maxWidth >= 980 ? 4 : c.maxWidth >= 700 ? 2 : 1;
                return GridView.count(
                  crossAxisCount: cols,
                  shrinkWrap: true,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 18,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: cols == 1 ? 2.0 : 1.15,
                  children: metrics
                      .map(
                        (m) => Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF1F2937)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                m.$1,
                                style: GoogleFonts.spaceGrotesk(
                                  color: const Color(0xFF2563EB),
                                  fontSize: 40,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -1.0,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                m.$2,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.ibmPlexSans(
                                  color: const Color(0xFF9CA3AF),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 40),
            Container(
              constraints: const BoxConstraints(maxWidth: 820),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF030712),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1F2937)),
              ),
              child: Text(
                l10n.t('pub_mfg_roi_quote'),
                textAlign: TextAlign.center,
                style: GoogleFonts.ibmPlexSans(
                  color: const Color(0xFFF9FAFB),
                  fontSize: 20,
                  height: 1.55,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeRoiCalculatorSection extends StatelessWidget {
  const _HomeRoiCalculatorSection();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _SectionWrap(
      child: _PageContainer(
        child: Column(
          children: [
            _Eyebrow(icon: Icons.calculate_outlined, text: l10n.t('pub_calc_eyebrow')),
            const SizedBox(height: 14),
            _SectionTitle(title: l10n.t('pub_calc_title'), subtitle: l10n.t('pub_calc_subtitle')),
            const SizedBox(height: 36),
            const MarketingRoiCalculator(),
          ],
        ),
      ),
    );
  }
}

class _FeaturesGridSection extends StatelessWidget {
  const _FeaturesGridSection();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cards = [
      (Icons.hub_outlined, 'pub_feat_control_tower_title', 'pub_feat_control_tower_desc'),
      (Icons.speed_outlined, 'pub_feat_pm_title', 'pub_feat_pm_desc'),
      (Icons.groups_2_outlined, 'pub_feat_sup_intel_title', 'pub_feat_sup_intel_desc'),
      (Icons.inventory_2_outlined, 'pub_feat_inv_title', 'pub_feat_inv_desc'),
      (Icons.science_outlined, 'pub_feat_sim_title', 'pub_feat_sim_desc'),
      (Icons.assessment_outlined, 'pub_feat_exec_title', 'pub_feat_exec_desc'),
    ];
    return _SectionWrap(
      alt: true,
      child: _PageContainer(
        child: Column(
          children: [
            _Eyebrow(icon: Icons.layers_outlined, text: l10n.t('pub_feat_eyebrow')),
            const SizedBox(height: 14),
            _SectionTitle(title: l10n.t('pub_feat_title'), subtitle: l10n.t('pub_feat_subtitle')),
            const SizedBox(height: 40),
            LayoutBuilder(
              builder: (context, c) {
                final w = c.maxWidth;
                final cols = w >= 1100 ? 3 : w >= 700 ? 2 : 1;
                return GridView.count(
                  crossAxisCount: cols,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.15,
                  children: cards
                      .map(
                        (card) => _FeatureCard(
                          icon: card.$1,
                          title: l10n.t(card.$2),
                          text: l10n.t(card.$3),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.icon, required this.title, required this.text});
  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1F2937)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color(0x1A2563EB),
            ),
            child: Icon(icon, color: const Color(0xFF2563EB), size: 24),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: GoogleFonts.spaceGrotesk(
              color: const Color(0xFFF9FAFB),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.ibmPlexSans(color: const Color(0xFF9CA3AF), fontSize: 14, height: 1.55),
            ),
          ),
        ],
      ),
    );
  }
}

class _TestimonialsSection extends StatelessWidget {
  const _TestimonialsSection();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = [
      ('pub_testimonial_1_quote', 'pub_testimonial_1_attr'),
      ('pub_testimonial_2_quote', 'pub_testimonial_2_attr'),
      ('pub_testimonial_3_quote', 'pub_testimonial_3_attr'),
    ];
    return _SectionWrap(
      child: _PageContainer(
        child: Column(
          children: [
            _Eyebrow(icon: Icons.format_quote_outlined, text: l10n.t('pub_testimonial_eyebrow')),
            const SizedBox(height: 14),
            _SectionTitle(
              title: l10n.t('pub_testimonial_section_title'),
              subtitle: l10n.t('pub_testimonial_section_subtitle'),
            ),
            const SizedBox(height: 36),
            LayoutBuilder(
              builder: (context, c) {
                final col = c.maxWidth >= 1000 ? 3 : 1;
                return GridView.count(
                  crossAxisCount: col,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: col == 1 ? 1.25 : 0.95,
                  children: items
                      .map(
                        (it) => Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF1F2937)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.t(it.$1),
                                style: GoogleFonts.ibmPlexSans(
                                  color: const Color(0xFFF9FAFB),
                                  fontSize: 16,
                                  height: 1.55,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                l10n.t(it.$2),
                                style: GoogleFonts.ibmPlexSans(
                                  color: const Color(0xFF9CA3AF),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PricingTiersSection extends StatelessWidget {
  const _PricingTiersSection({required this.onPlan, required this.onEnterprise});

  final void Function(String plan) onPlan;
  final VoidCallback onEnterprise;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _SectionWrap(
      alt: true,
      child: _PageContainer(
        child: Column(
          children: [
            _Eyebrow(icon: Icons.payments_outlined, text: l10n.t('pub_price_eyebrow')),
            const SizedBox(height: 14),
            _SectionTitle(title: l10n.t('pub_price_title'), subtitle: l10n.t('pub_price_subtitle')),
            const SizedBox(height: 12),
            Text(
              l10n.t('pub_price_annual_note'),
              textAlign: TextAlign.center,
              style: GoogleFonts.ibmPlexSans(color: const Color(0xFF6B7280), fontSize: 14),
            ),
            const SizedBox(height: 36),
            LayoutBuilder(
              builder: (context, c) {
                final tiers = [
                  _TierCard(
                    name: l10n.t('pub_price_starter_name'),
                    price: l10n.t('pub_price_starter_price'),
                    period: l10n.t('pub_price_period'),
                    features: [
                      l10n.t('pub_price_starter_f1'),
                      l10n.t('pub_price_starter_f2'),
                      l10n.t('pub_price_starter_f3'),
                      l10n.t('pub_price_starter_f4'),
                    ],
                    highlight: false,
                    onCta: () => onPlan('starter'),
                    ctaLabel: l10n.t('pub_price_cta_start'),
                  ),
                  _TierCard(
                    name: l10n.t('pub_price_growth_name'),
                    price: l10n.t('pub_price_growth_price'),
                    period: l10n.t('pub_price_period'),
                    features: [
                      l10n.t('pub_price_growth_f1'),
                      l10n.t('pub_price_growth_f2'),
                      l10n.t('pub_price_growth_f3'),
                      l10n.t('pub_price_growth_f4'),
                    ],
                    highlight: true,
                    onCta: () => onPlan('growth'),
                    ctaLabel: l10n.t('pub_price_cta_start'),
                  ),
                  _TierCard(
                    name: l10n.t('pub_price_pro_name'),
                    price: l10n.t('pub_price_pro_price'),
                    period: l10n.t('pub_price_period'),
                    features: [
                      l10n.t('pub_price_pro_f1'),
                      l10n.t('pub_price_pro_f2'),
                      l10n.t('pub_price_pro_f3'),
                      l10n.t('pub_price_pro_f4'),
                    ],
                    highlight: false,
                    onCta: () => onPlan('pro'),
                    ctaLabel: l10n.t('pub_price_cta_start'),
                  ),
                  _TierCard(
                    name: l10n.t('pub_price_ent_name'),
                    price: l10n.t('pub_price_ent_from'),
                    period: '',
                    features: [
                      l10n.t('pub_price_ent_f1'),
                      l10n.t('pub_price_ent_f2'),
                      l10n.t('pub_price_ent_f3'),
                      l10n.t('pub_price_ent_f4'),
                    ],
                    highlight: false,
                    onCta: onEnterprise,
                    ctaLabel: l10n.t('pub_price_cta_talk'),
                  ),
                ];
                if (c.maxWidth < 720) {
                  return Column(
                    children: [
                      for (final t in tiers) Padding(padding: const EdgeInsets.only(bottom: 16), child: t),
                    ],
                  );
                }
                if (c.maxWidth < 1200) {
                  return GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.72,
                    children: tiers,
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < tiers.length; i++) ...[
                      if (i > 0) const SizedBox(width: 12),
                      Expanded(child: tiers[i]),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              l10n.t('pub_price_footnote'),
              textAlign: TextAlign.center,
              style: GoogleFonts.ibmPlexSans(color: const Color(0xFF6B7280), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _TierCard extends StatelessWidget {
  const _TierCard({
    required this.name,
    required this.price,
    required this.period,
    required this.features,
    required this.highlight,
    required this.onCta,
    required this.ctaLabel,
  });

  final String name;
  final String price;
  final String period;
  final List<String> features;
  final bool highlight;
  final VoidCallback onCta;
  final String ctaLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: highlight ? const Color(0xFF111827) : const Color(0xFF0F172A),
        border: Border.all(
          color: highlight ? const Color(0xFF2563EB) : const Color(0xFF1F2937),
          width: highlight ? 1.5 : 1,
        ),
        boxShadow: highlight
            ? const [BoxShadow(color: Color(0x332563EB), blurRadius: 28, offset: Offset(0, 12))]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (highlight)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: const Color(0x142563EB),
              ),
              child: Text(
                context.l10n.t('pub_price_badge'),
                style: GoogleFonts.ibmPlexSans(
                  color: const Color(0xFF2563EB),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          if (highlight) const SizedBox(height: 12),
          Text(name, style: GoogleFonts.spaceGrotesk(color: const Color(0xFFF9FAFB), fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: GoogleFonts.spaceGrotesk(
                  color: const Color(0xFFF9FAFB),
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ),
              if (period.isNotEmpty) ...[
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    period,
                    style: GoogleFonts.ibmPlexSans(color: const Color(0xFF9CA3AF), fontSize: 14),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),
          for (final f in features)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_outline_rounded, size: 18, color: Color(0xFF2563EB)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      f,
                      style: GoogleFonts.ibmPlexSans(color: const Color(0xFF9CA3AF), fontSize: 14, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onCta,
              style: FilledButton.styleFrom(
                backgroundColor: highlight ? const Color(0xFF2563EB) : const Color(0xFF1E293B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(ctaLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactSection extends StatefulWidget {
  const _ContactSection();

  @override
  State<_ContactSection> createState() => _ContactSectionState();
}

class _ContactSectionState extends State<_ContactSection> {
  final _formKey = GlobalKey<FormState>();
  bool _sent = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _SectionWrap(
      child: _PageContainer(
        child: LayoutBuilder(
          builder: (context, c) {
            final compact = c.maxWidth < 940;
            final left = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Eyebrow(icon: Icons.mail_outline, text: l10n.t('pub_contact_eyebrow'), center: false),
                const SizedBox(height: 10),
                Text(
                  l10n.t('pub_contact_title'),
                  style: GoogleFonts.spaceGrotesk(
                    color: const Color(0xFFF9FAFB),
                    fontSize: 38,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  l10n.t('pub_contact_subtitle'),
                  style: GoogleFonts.ibmPlexSans(color: const Color(0xFF9CA3AF), fontSize: 18, height: 1.6),
                ),
              ],
            );
            final right = _ContactFormCard(
              formKey: _formKey,
              sent: _sent,
              onSend: () {
                if (_formKey.currentState?.validate() ?? false) {
                  setState(() => _sent = true);
                }
              },
            );
            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [left, const SizedBox(height: 24), right],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Expanded(child: left), const SizedBox(width: 40), Expanded(child: right)],
            );
          },
        ),
      ),
    );
  }
}

class _ContactFormCard extends StatelessWidget {
  const _ContactFormCard({
    required this.formKey,
    required this.sent,
    required this.onSend,
  });

  final GlobalKey<FormState> formKey;
  final bool sent;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1F2937)),
          ),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.t('pub_contact_form_title'),
                  style: GoogleFonts.spaceGrotesk(color: const Color(0xFFF9FAFB), fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.t('pub_contact_form_lead'),
                  style: GoogleFonts.ibmPlexSans(color: const Color(0xFF9CA3AF), fontSize: 14),
                ),
                const SizedBox(height: 20),
                _formField(context, l10n.t('pub_contact_name'), validator: _req(l10n)),
                const SizedBox(height: 14),
                _formField(context, l10n.t('pub_contact_email'), validator: _email(l10n)),
                const SizedBox(height: 14),
                _formField(context, l10n.t('pub_contact_company')),
                const SizedBox(height: 14),
                _formField(context, l10n.t('pub_contact_message'), maxLines: 4),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onSend,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(l10n.t('pub_contact_send')),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (sent)
          Positioned(
            right: -8,
            bottom: -12,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xFF0F172A),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF1F2937)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      l10n.t('pub_contact_snackbar'),
                      style: GoogleFonts.ibmPlexSans(color: const Color(0xFFF9FAFB), fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _formField(
    BuildContext context,
    String label, {
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.ibmPlexSans(color: const Color(0xFFF9FAFB), fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          maxLines: maxLines,
          validator: validator,
          style: const TextStyle(color: Color(0xFFF9FAFB)),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: const Color(0x08FFFFFF),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF1F2937)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF1F2937)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF2563EB)),
            ),
          ),
        ),
      ],
    );
  }

  String? Function(String?) _req(AppLocalizations l10n) {
    return (v) => (v == null || v.trim().isEmpty) ? l10n.t('pub_contact_err_required') : null;
  }

  String? Function(String?) _email(AppLocalizations l10n) {
    return (v) {
      if (v == null || v.trim().isEmpty) return l10n.t('pub_contact_err_required');
      if (!v.contains('@')) return l10n.t('pub_contact_err_email');
      return null;
    };
  }
}

class _FaqSection extends StatelessWidget {
  const _FaqSection();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final faq = [
      (l10n.t('pub_faq_q1'), l10n.t('pub_faq_a1')),
      (l10n.t('pub_faq_q2'), l10n.t('pub_faq_a2')),
      (l10n.t('pub_faq_q3'), l10n.t('pub_faq_a3')),
      (l10n.t('pub_faq_q4'), l10n.t('pub_faq_a4')),
    ];
    return _SectionWrap(
      alt: true,
      child: _PageContainer(
        child: Column(
          children: [
            _Eyebrow(icon: Icons.help_outline, text: l10n.t('pub_faq_eyebrow')),
            const SizedBox(height: 14),
            _SectionTitle(title: l10n.t('pub_faq_title'), subtitle: l10n.t('pub_faq_subtitle')),
            const SizedBox(height: 28),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: Column(
                children: List.generate(
                  faq.length,
                  (i) => Theme(
                    data: ThemeData(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      initiallyExpanded: i == 0,
                      tilePadding: EdgeInsets.zero,
                      childrenPadding: const EdgeInsets.only(bottom: 16),
                      iconColor: const Color(0xFF9CA3AF),
                      collapsedIconColor: const Color(0xFF9CA3AF),
                      title: Text(
                        faq[i].$1,
                        style: GoogleFonts.ibmPlexSans(color: const Color(0xFFF9FAFB), fontSize: 17, fontWeight: FontWeight.w600),
                      ),
                      subtitle: const Divider(color: Color(0xFF1F2937), height: 1),
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            faq[i].$2,
                            style: GoogleFonts.ibmPlexSans(color: const Color(0xFF9CA3AF), fontSize: 15, height: 1.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegalLinksSection extends StatelessWidget {
  const _LegalLinksSection();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _SectionWrap(
      child: _PageContainer(
        child: Column(
          children: [
            _Eyebrow(icon: Icons.balance_outlined, text: l10n.t('pub_legal_eyebrow')),
            const SizedBox(height: 14),
            _SectionTitle(title: l10n.t('pub_legal_main_title'), subtitle: l10n.t('pub_legal_subtitle')),
            const SizedBox(height: 28),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () => context.go('/privacy'),
                  child: Text(l10n.t('pub_legal_privacy_tab')),
                ),
                OutlinedButton(
                  onPressed: () => context.go('/terms'),
                  child: Text(l10n.t('pub_legal_terms_tab')),
                ),
                OutlinedButton(
                  onPressed: () => context.go('/cookies'),
                  child: Text(l10n.t('pub_legal_cookie_tab')),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              l10n.t('pub_legal_updated'),
              style: GoogleFonts.ibmPlexSans(color: const Color(0xFF6B7280), fontSize: 13),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.t('pub_legal_placeholder'),
              textAlign: TextAlign.center,
              style: GoogleFonts.ibmPlexSans(color: const Color(0xFF9CA3AF), fontSize: 14, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}

class _FinalCtaSection extends StatelessWidget {
  const _FinalCtaSection({
    required this.onStartTrial,
    required this.onDemo,
    required this.onRoi,
  });

  final VoidCallback onStartTrial;
  final VoidCallback onDemo;
  final VoidCallback onRoi;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _SectionWrap(
      alt: true,
      padding: const EdgeInsets.fromLTRB(0, 80, 0, 100),
      child: _PageContainer(
        child: Column(
          children: [
            _SectionTitle(title: l10n.t('pub_mfg_final_title'), subtitle: l10n.t('pub_mfg_final_subtitle')),
            const SizedBox(height: 28),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                FilledButton(
                  onPressed: onDemo,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(l10n.t('pub_mfg_final_cta2')),
                ),
                FilledButton.tonal(
                  onPressed: onStartTrial,
                  style: FilledButton.styleFrom(
                    foregroundColor: const Color(0xFFEAF2FF),
                    backgroundColor: const Color(0xFF1E293B),
                    padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(l10n.t('pub_mfg_final_cta1')),
                ),
                OutlinedButton(
                  onPressed: onRoi,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFF9FAFB),
                    side: const BorderSide(color: Color(0xFF1F2937)),
                    padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(l10n.t('pub_mfg_final_cta3')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
