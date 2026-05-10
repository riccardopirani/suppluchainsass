import 'package:fabricos/features/website/presentation/widgets/public_site_theme.dart';
import 'package:fabricos/features/website/presentation/widgets/website_footer.dart';
import 'package:fabricos/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HeroSection(
            onDemo: () => context.go('/book-demo'),
            onTrial: () => context.go('/register'),
          ),
          const _AiPersuasionStrip(),
          const _PainSection(),
          const _KpiSection(),
          _PricingSection(onPlan: (p) => context.go('/register?plan=$p')),
          const _FaqSection(),
          _FinalCta(
            onTrial: () => context.go('/register'),
            onContact: () => context.go('/contact'),
          ),
          const WebsiteFooter(),
        ],
      ),
    );
  }
}

class _Wrap extends StatelessWidget {
  const _Wrap({required this.child});
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

class _Section extends StatelessWidget {
  const _Section({
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
        color: alt
            ? PublicSiteTheme.secondary.withValues(alpha: 0.5)
            : PublicSiteTheme.background,
        border: alt
            ? const Border(
                top: BorderSide(color: PublicSiteTheme.border),
                bottom: BorderSide(color: PublicSiteTheme.border),
              )
            : null,
      ),
      child: child,
    );
  }
}

const _kHeroVideoAsset = 'assets/15561210_1920_1080_25fps.mp4';

/// Ombre scure per testo bianco leggibile su video chiari/scuri.
const _kHeroTitleShadows = [
  Shadow(color: Color(0x99000000), blurRadius: 16, offset: Offset(0, 2)),
  Shadow(color: Color(0x66000000), blurRadius: 28, offset: Offset(0, 1)),
];

const _kHeroSubtitleShadows = [
  Shadow(color: Color(0x88000000), blurRadius: 12, offset: Offset(0, 1)),
  Shadow(color: Color(0x55000000), blurRadius: 22, offset: Offset(0, 0)),
];

class _HeroSection extends StatefulWidget {
  const _HeroSection({required this.onDemo, required this.onTrial});
  final VoidCallback onDemo;
  final VoidCallback onTrial;

  @override
  State<_HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<_HeroSection> {
  VideoPlayerController? _video;
  bool _videoReady = false;

  @override
  void initState() {
    super.initState();
    _video = VideoPlayerController.asset(_kHeroVideoAsset)
      ..setLooping(true)
      ..setVolume(0)
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() => _videoReady = true);
        _video?.play();
      }).catchError((_) {
        if (!mounted) return;
        setState(() => _videoReady = false);
      });
  }

  @override
  void dispose() {
    _video?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 900;
    return ClipRect(
      child: Stack(
        clipBehavior: Clip.hardEdge,
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: _videoReady &&
                    _video != null &&
                    _video!.value.isInitialized
                ? ClipRect(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _video!.value.size.width,
                        height: _video!.value.size.height,
                        child: VideoPlayer(_video!),
                      ),
                    ),
                  )
                : ColoredBox(color: PublicSiteTheme.background),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 96, 0, 92),
            child: _Wrap(
              child: LayoutBuilder(
                builder: (context, c) {
                  final stack = c.maxWidth < 980;
                  return Column(
                    crossAxisAlignment: stack
                        ? CrossAxisAlignment.center
                        : CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.42),
                          ),
                        ),
                        child: Text(
                          context.l10n.t('pub_home_eyebrow'),
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.9,
                            shadows: _kHeroSubtitleShadows,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        context.l10n.t('pub_home_hero_title'),
                        textAlign: stack ? TextAlign.center : TextAlign.start,
                        style: GoogleFonts.spaceGrotesk(
                          color: Colors.white,
                          fontSize: compact ? 38 : 56,
                          fontWeight: FontWeight.w800,
                          height: 1.08,
                          letterSpacing: -1,
                          shadows: _kHeroTitleShadows,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        context.l10n.t('pub_home_hero_subtitle'),
                        textAlign: stack ? TextAlign.center : TextAlign.start,
                        style: GoogleFonts.ibmPlexSans(
                          color: Colors.white.withValues(alpha: 0.92),
                          fontSize: 18,
                          height: 1.6,
                          shadows: _kHeroSubtitleShadows,
                        ),
                      ),
                      const SizedBox(height: 26),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: stack
                            ? WrapAlignment.center
                            : WrapAlignment.start,
                        children: [
                          FilledButton(
                            onPressed: widget.onDemo,
                            style: FilledButton.styleFrom(
                              backgroundColor: PublicSiteTheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 18,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            child:
                                Text(context.l10n.t('pub_home_cta_demo')),
                          ),
                          OutlinedButton(
                            onPressed: widget.onTrial,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.65),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 18,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            child:
                                Text(context.l10n.t('pub_home_cta_trial')),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: stack
                            ? WrapAlignment.center
                            : WrapAlignment.start,
                        children: [
                          _MiniPill(context.l10n.t('pub_home_pill_1'), heroOnVideo: true),
                          _MiniPill(context.l10n.t('pub_home_pill_2'), heroOnVideo: true),
                          _MiniPill(context.l10n.t('pub_home_pill_3'), heroOnVideo: true),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  const _MiniPill(this.text, {this.heroOnVideo = false});

  final String text;
  final bool heroOnVideo;

  @override
  Widget build(BuildContext context) {
    if (heroOnVideo) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withValues(alpha: 0.38)),
        ),
        child: Text(
          text,
          style: GoogleFonts.ibmPlexSans(
            color: Colors.white.withValues(alpha: 0.95),
            fontSize: 13,
            fontWeight: FontWeight.w500,
            shadows: _kHeroSubtitleShadows,
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: PublicSiteTheme.secondary.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: PublicSiteTheme.border),
      ),
      child: Text(
        text,
        style: GoogleFonts.ibmPlexSans(
          color: PublicSiteTheme.mutedForeground,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _AiPersuasionStrip extends StatelessWidget {
  const _AiPersuasionStrip();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: PublicSiteTheme.secondary.withValues(alpha: 0.42),
        border: const Border(
          top: BorderSide(color: PublicSiteTheme.border),
          bottom: BorderSide(color: PublicSiteTheme.border),
        ),
      ),
      child: _Wrap(
        child: Column(
          children: [
            Text(
              l10n.t('pub_home_ai_strip_eyebrow'),
              textAlign: TextAlign.center,
              style: GoogleFonts.ibmPlexSans(
                color: PublicSiteTheme.primary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.t('pub_home_ai_strip_title'),
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                color: PublicSiteTheme.foreground,
                fontSize: 26,
                fontWeight: FontWeight.w700,
                height: 1.25,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.t('pub_home_ai_strip_subtitle'),
              textAlign: TextAlign.center,
              style: GoogleFonts.ibmPlexSans(
                color: PublicSiteTheme.mutedForeground,
                fontSize: 17,
                height: 1.55,
              ),
            ),
          ],
        ),
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
      (l10n.t('pub_home_pain_1_title'), l10n.t('pub_home_pain_1_body')),
      (l10n.t('pub_home_pain_2_title'), l10n.t('pub_home_pain_2_body')),
      (l10n.t('pub_home_pain_3_title'), l10n.t('pub_home_pain_3_body')),
    ];
    return _Section(
      child: _Wrap(
        child: Column(
          children: [
            Text(
              context.l10n.t('pub_home_pain_title'),
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                color: PublicSiteTheme.foreground,
                fontSize: 44,
                fontWeight: FontWeight.w700,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n.t('pub_home_pain_subtitle'),
              textAlign: TextAlign.center,
              style: GoogleFonts.ibmPlexSans(
                color: PublicSiteTheme.mutedForeground,
                fontSize: 18,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 36),
            LayoutBuilder(
              builder: (context, c) {
                final cols = c.maxWidth > 980 ? 3 : (c.maxWidth > 640 ? 2 : 1);
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: cols,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: cols == 1 ? 1.55 : 1.15,
                  children: cards
                      .map(
                        (c) => Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: PublicSiteTheme.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.$1,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: PublicSiteTheme.foreground,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                c.$2,
                                style: GoogleFonts.ibmPlexSans(
                                  fontSize: 15,
                                  color: PublicSiteTheme.mutedForeground,
                                  height: 1.55,
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

class _KpiSection extends StatelessWidget {
  const _KpiSection();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = [
      (l10n.t('pub_home_kpi_1_val'), l10n.t('pub_home_kpi_1_label')),
      (l10n.t('pub_home_kpi_2_val'), l10n.t('pub_home_kpi_2_label')),
      (l10n.t('pub_home_kpi_3_val'), l10n.t('pub_home_kpi_3_label')),
    ];
    return _Section(
      alt: true,
      child: _Wrap(
        child: LayoutBuilder(
          builder: (context, c) {
            final cols = c.maxWidth > 900 ? 3 : 1;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: cols,
              childAspectRatio: cols == 1 ? 3.1 : 1.9,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: items
                  .map(
                    (i) => Container(
                      decoration: BoxDecoration(
                        color: PublicSiteTheme.foreground,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            i.$1,
                            style: GoogleFonts.spaceGrotesk(
                              color: PublicSiteTheme.accent,
                              fontSize: 48,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            i.$2,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.ibmPlexSans(
                              color: Colors.white70,
                              fontSize: 16,
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
      ),
    );
  }
}

class _PricingSection extends StatelessWidget {
  const _PricingSection({required this.onPlan});
  final void Function(String) onPlan;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final plans = [
      (
        l10n.t('pub_home_plan_ess_name'),
        l10n.t('pub_home_plan_ess_price'),
        l10n.t('pub_home_plan_ess_period'),
        [
          l10n.t('pub_home_plan_ess_f1'),
          l10n.t('pub_home_plan_ess_f2'),
          l10n.t('pub_home_plan_ess_f3'),
        ],
        false,
        'essenziale',
      ),
      (
        l10n.t('pub_home_plan_pro_name'),
        l10n.t('pub_home_plan_pro_price'),
        l10n.t('pub_home_plan_pro_period'),
        [
          l10n.t('pub_home_plan_pro_f1'),
          l10n.t('pub_home_plan_pro_f2'),
          l10n.t('pub_home_plan_pro_f3'),
        ],
        true,
        'professionale',
      ),
      (
        l10n.t('pub_home_plan_ind_name'),
        l10n.t('pub_home_plan_ind_price'),
        l10n.t('pub_home_plan_ind_period'),
        [
          l10n.t('pub_home_plan_ind_f1'),
          l10n.t('pub_home_plan_ind_f2'),
          l10n.t('pub_home_plan_ind_f3'),
        ],
        false,
        'industriale',
      ),
    ];
    return _Section(
      alt: true,
      child: _Wrap(
        child: Column(
          children: [
            Text(
              context.l10n.t('pub_home_pricing_title'),
              style: GoogleFonts.spaceGrotesk(
                fontSize: 42,
                fontWeight: FontWeight.w700,
                color: PublicSiteTheme.foreground,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              context.l10n.t('pub_home_pricing_subtitle'),
              textAlign: TextAlign.center,
              style: GoogleFonts.ibmPlexSans(
                fontSize: 18,
                color: PublicSiteTheme.mutedForeground,
              ),
            ),
            const SizedBox(height: 32),
            LayoutBuilder(
              builder: (context, c) {
                final cols = c.maxWidth > 980 ? 3 : 1;
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: cols,
                  childAspectRatio: cols == 1 ? 1.4 : 0.72,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: plans.map((p) {
                    return Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: p.$5 ? PublicSiteTheme.primary : PublicSiteTheme.border,
                          width: p.$5 ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (p.$5)
                            Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: PublicSiteTheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                context.l10n.t('pub_home_plan_badge_popular'),
                                style: GoogleFonts.ibmPlexSans(
                                  color: PublicSiteTheme.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.7,
                                ),
                              ),
                            ),
                          Text(
                            p.$1,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: PublicSiteTheme.foreground,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                p.$2,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 42,
                                  fontWeight: FontWeight.w800,
                                  color: PublicSiteTheme.foreground,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8, left: 4),
                                child: Text(
                                  p.$3,
                                  style: GoogleFonts.ibmPlexSans(
                                    color: PublicSiteTheme.mutedForeground,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ...p.$4.map(
                            (f) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle_outline_rounded,
                                    size: 18,
                                    color: PublicSiteTheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      f,
                                      style: GoogleFonts.ibmPlexSans(
                                        fontSize: 14,
                                        color: PublicSiteTheme.mutedForeground,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () => onPlan(p.$6),
                              style: FilledButton.styleFrom(
                                backgroundColor: p.$5
                                    ? PublicSiteTheme.primary
                                    : PublicSiteTheme.secondary,
                                foregroundColor: p.$5
                                    ? Colors.white
                                    : PublicSiteTheme.foreground,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: Text(
                                p.$5
                                    ? context.l10n.t('pub_home_cta_start_trial')
                                    : (p.$6 == 'industriale'
                                          ? context.l10n.t(
                                              'pub_home_cta_contact_sales',
                                            )
                                          : context.l10n.t(
                                              'pub_home_cta_start_trial',
                                            )),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqSection extends StatelessWidget {
  const _FaqSection();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final faq = [
      (l10n.t('pub_home_faq_1_q'), l10n.t('pub_home_faq_1_a')),
      (l10n.t('pub_home_faq_2_q'), l10n.t('pub_home_faq_2_a')),
      (l10n.t('pub_home_faq_3_q'), l10n.t('pub_home_faq_3_a')),
    ];
    return _Section(
      child: _Wrap(
        child: Column(
          children: [
            Text(
              context.l10n.t('pub_home_faq_title'),
              style: GoogleFonts.spaceGrotesk(
                fontSize: 40,
                fontWeight: FontWeight.w700,
                color: PublicSiteTheme.foreground,
              ),
            ),
            const SizedBox(height: 26),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: Column(
                children: faq
                    .map(
                      (f) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: PublicSiteTheme.border),
                        ),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 6,
                          ),
                          childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                          iconColor: PublicSiteTheme.primary,
                          collapsedIconColor: PublicSiteTheme.primary,
                          title: Text(
                            f.$1,
                            style: GoogleFonts.ibmPlexSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: PublicSiteTheme.foreground,
                            ),
                          ),
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                f.$2,
                                style: GoogleFonts.ibmPlexSans(
                                  fontSize: 15,
                                  height: 1.55,
                                  color: PublicSiteTheme.mutedForeground,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FinalCta extends StatelessWidget {
  const _FinalCta({required this.onTrial, required this.onContact});
  final VoidCallback onTrial;
  final VoidCallback onContact;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: PublicSiteTheme.primary,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: _Wrap(
        child: Column(
          children: [
            Text(
              context.l10n.t('pub_home_final_title'),
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                color: Colors.white,
                fontSize: 44,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n.t('pub_home_final_subtitle'),
              textAlign: TextAlign.center,
              style: GoogleFonts.ibmPlexSans(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 26),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                FilledButton(
                  onPressed: onTrial,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: PublicSiteTheme.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: Text(context.l10n.t('pub_home_final_cta_trial')),
                ),
                OutlinedButton(
                  onPressed: onContact,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.45)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: Text(context.l10n.t('pub_home_final_cta_contact')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
