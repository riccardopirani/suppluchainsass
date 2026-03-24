import 'dart:ui';

import 'package:fabricos/core/theme/app_colors.dart';
import 'package:fabricos/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

/// Marketing home: manufacturing SaaS 2026 — bento, glass, industrial palette.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const _HeroSection(),
          const SizedBox(height: 96),
          const _LogoStrip(),
          const SizedBox(height: 88),
          const _PainSection(),
          const SizedBox(height: 88),
          const _SolutionSection(),
          const SizedBox(height: 88),
          const _RoiSection(),
          const SizedBox(height: 88),
          const _FinalCtaSection(),
          const SizedBox(height: 96),
        ],
      ),
    );
  }
}

// ——— Hero —————————————————————————————————————————————————————————

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgGradient = isDark
        ? AppColorsDark.heroGradient
        : const LinearGradient(
            colors: [
              Color(0xFF0C1222),
              Color(0xFF111A2E),
              Color(0xFF0D1F24),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
    final accent = isDark ? AppColorsDark.primary : AppColorsLight.primary;
    final onHero = const Color(0xFFE2E8F0);
    final muted = onHero.withValues(alpha: 0.72);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(gradient: bgGradient),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _MeshGridPainter(accent: accent)),
          ),
          Positioned(
            right: -80,
            top: -100,
            child: _GlowOrb(color: accent.withValues(alpha: 0.35), size: 420),
          ),
          Positioned(
            left: -120,
            bottom: -80,
            child: _GlowOrb(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.22),
              size: 360,
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              24,
              56,
              24,
              MediaQuery.sizeOf(context).width >= 960 ? 72 : 48,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: LayoutBuilder(
                  builder: (context, c) {
                    final wide = c.maxWidth >= 960;
                    final copy = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Eyebrow(
                          label: l10n.t('pub_mfg_eyebrow'),
                          color: accent,
                          onSurface: onHero,
                        ),
                        const SizedBox(height: 22),
                        Text(
                          l10n.t('pub_mfg_hero_title'),
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: wide ? 44 : 30,
                            fontWeight: FontWeight.w600,
                            height: 1.08,
                            letterSpacing: -1.2,
                            color: onHero,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          l10n.t('pub_mfg_hero_subtitle'),
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: wide ? 17 : 15,
                            height: 1.55,
                            color: muted,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          alignment: WrapAlignment.start,
                          children: [
                            FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: accent,
                                foregroundColor: isDark
                                    ? AppColorsDark.onPrimary
                                    : AppColorsLight.onPrimary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 22,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () => context.go('/register'),
                              icon: const Icon(Icons.bolt_rounded, size: 20),
                              label: Text(
                                l10n.t('pub_mfg_cta_trial'),
                                style: GoogleFonts.ibmPlexSans(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: onHero,
                                side: BorderSide(color: onHero.withValues(alpha: 0.35)),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 22,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () => context.go('/contact'),
                              icon: const Icon(Icons.calendar_month_outlined, size: 20),
                              label: Text(
                                l10n.t('pub_mfg_cta_demo'),
                                style: GoogleFonts.ibmPlexSans(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.go('/features'),
                              child: Text(
                                l10n.t('pub_mfg_cta_modules'),
                                style: GoogleFonts.ibmPlexSans(
                                  color: accent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _TrustChip(label: l10n.t('pub_mfg_trust_1'), accent: accent),
                            _TrustChip(label: l10n.t('pub_mfg_trust_2'), accent: accent),
                            _TrustChip(label: l10n.t('pub_mfg_trust_3'), accent: accent),
                            _TrustChip(label: l10n.t('pub_mfg_trust_4'), accent: accent),
                          ],
                        ),
                      ],
                    );

                    final bento = _HeroBento(accent: accent, onHero: onHero);

                    if (wide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 12, child: copy),
                          const SizedBox(width: 48),
                          Expanded(flex: 10, child: bento),
                        ],
                      )
                          .animate()
                          .fadeIn(duration: 420.ms)
                          .slideY(begin: 0.06, end: 0);
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        copy,
                        const SizedBox(height: 40),
                        bento,
                      ],
                    )
                        .animate()
                        .fadeIn(duration: 420.ms)
                        .slideY(begin: 0.06, end: 0);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow({
    required this.label,
    required this.color,
    required this.onSurface,
  });

  final String label;
  final Color color;
  final Color onSurface;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.45)),
        color: onSurface.withValues(alpha: 0.06),
      ),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.ibmPlexSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.4,
          color: color,
        ),
      ),
    );
  }
}

class _TrustChip extends StatelessWidget {
  const _TrustChip({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent.withValues(alpha: 0.28)),
        color: Colors.white.withValues(alpha: 0.04),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline_rounded, size: 16, color: accent),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.ibmPlexSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFE2E8F0).withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
            stops: const [0.2, 1],
          ),
        ),
      ),
    );
  }
}

class _MeshGridPainter extends CustomPainter {
  _MeshGridPainter({required this.accent});

  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1;
    const step = 48.0;
    for (var x = 0.0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), line);
    }
    for (var y = 0.0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
    }
    final node = Paint()..color = accent.withValues(alpha: 0.08);
    for (var x = 0.0; x < size.width; x += step * 3) {
      for (var y = 0.0; y < size.height; y += step * 3) {
        canvas.drawCircle(Offset(x, y), 2, node);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MeshGridPainter oldDelegate) =>
      oldDelegate.accent != accent;
}

class _HeroBento extends StatelessWidget {
  const _HeroBento({required this.accent, required this.onHero});

  final Color accent;
  final Color onHero;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.1),
                Colors.white.withValues(alpha: 0.03),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent,
                        boxShadow: [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.6),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      l10n.t('pub_mfg_bento_title'),
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                        color: onHero.withValues(alpha: 0.85),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      l10n.t('pub_mfg_bento_updated'),
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 11,
                        color: accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                LayoutBuilder(
                  builder: (context, c) {
                    final twoCol = c.maxWidth > 420;
                    final stats = [
                      _BentoStat(
                        label: l10n.t('pub_mfg_kpi_machines'),
                        value: '58',
                        sub: l10n.t('pub_mfg_kpi_machines_sub'),
                        accent: accent,
                        onHero: onHero,
                      ),
                      _BentoStat(
                        label: l10n.t('pub_mfg_kpi_risk'),
                        value: '4',
                        sub: l10n.t('pub_mfg_kpi_risk_sub'),
                        accent: const Color(0xFFF59E0B),
                        onHero: onHero,
                      ),
                      _BentoStat(
                        label: l10n.t('pub_mfg_kpi_orders'),
                        value: '31',
                        sub: l10n.t('pub_mfg_kpi_orders_sub'),
                        accent: const Color(0xFF3B82F6),
                        onHero: onHero,
                      ),
                      _BentoStat(
                        label: l10n.t('pub_mfg_kpi_suppliers'),
                        value: '3',
                        sub: l10n.t('pub_mfg_kpi_suppliers_sub'),
                        accent: const Color(0xFFEF4444),
                        onHero: onHero,
                      ),
                    ];
                    if (twoCol) {
                      return GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.15,
                        children: stats,
                      );
                    }
                    return Column(
                      children: stats
                          .map(
                            (w) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: w,
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _SparklineBar(accent: accent),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BentoStat extends StatelessWidget {
  const _BentoStat({
    required this.label,
    required this.value,
    required this.sub,
    required this.accent,
    required this.onHero,
  });

  final String label;
  final String value;
  final String sub;
  final Color accent;
  final Color onHero;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.black.withValues(alpha: 0.25),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              height: 1,
              color: onHero,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.ibmPlexSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: accent,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            style: GoogleFonts.ibmPlexSans(
              fontSize: 11,
              color: onHero.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}

class _SparklineBar extends StatelessWidget {
  const _SparklineBar({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.t('pub_mfg_sparkline'),
          style: GoogleFonts.ibmPlexSans(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.45),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: List.generate(14, (i) {
            final h = 12.0 + (i % 4) * 6.0 + (i % 3) * 4.0;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200 + i * 40),
                  height: h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        accent.withValues(alpha: 0.25),
                        accent.withValues(alpha: 0.85),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ——— Trust strip ——————————————————————————————————————————————————

class _LogoStrip extends StatelessWidget {
  const _LogoStrip();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = Theme.of(context).colorScheme.onSurfaceVariant;
    final names = [
      l10n.t('pub_mfg_strip_1'),
      l10n.t('pub_mfg_strip_2'),
      l10n.t('pub_mfg_strip_3'),
      l10n.t('pub_mfg_strip_4'),
      l10n.t('pub_mfg_strip_5'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Text(
                l10n.t('pub_mfg_strip_intro'),
                textAlign: TextAlign.center,
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.3,
                  color: fg.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 28,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: names
                    .map(
                      (n) => Text(
                        n.toUpperCase(),
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.35)
                              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                          letterSpacing: 1.1,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ——— Pain ————————————————————————————————————————————————————————

class _PainSection extends StatelessWidget {
  const _PainSection();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pains = <({String title, String desc, IconData icon})>[
      (
        title: l10n.t('pub_mfg_pain1_title'),
        desc: l10n.t('pub_mfg_pain1_desc'),
        icon: Icons.warning_amber_rounded,
      ),
      (
        title: l10n.t('pub_mfg_pain2_title'),
        desc: l10n.t('pub_mfg_pain2_desc'),
        icon: Icons.local_shipping_rounded,
      ),
      (
        title: l10n.t('pub_mfg_pain3_title'),
        desc: l10n.t('pub_mfg_pain3_desc'),
        icon: Icons.hub_rounded,
      ),
      (
        title: l10n.t('pub_mfg_pain4_title'),
        desc: l10n.t('pub_mfg_pain4_desc'),
        icon: Icons.description_rounded,
      ),
    ];

    return _SectionShell(
      eyebrow: l10n.t('pub_mfg_pain_eyebrow'),
      title: l10n.t('pub_mfg_pain_title'),
      subtitle: l10n.t('pub_mfg_pain_subtitle'),
      child: LayoutBuilder(
        builder: (context, c) {
          final w = (c.maxWidth - 36) / 2;
          final cardWidth = c.maxWidth >= 900 ? w.clamp(260.0, 520.0) : c.maxWidth;
          return Wrap(
            spacing: 18,
            runSpacing: 18,
            children: pains
                .map(
                  (pain) => SizedBox(
                    width: cardWidth,
                    child: _BentoCard(
                      icon: pain.icon,
                      title: pain.title,
                      desc: pain.desc,
                    ),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}

class _BentoCard extends StatelessWidget {
  const _BentoCard({
    required this.icon,
    required this.title,
    required this.desc,
  });

  final IconData icon;
  final String title;
  final String desc;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.go('/features'),
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: scheme.outline.withValues(alpha: 0.35)),
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: scheme.primary.withValues(alpha: 0.12),
                  ),
                  child: Icon(icon, color: scheme.primary, size: 26),
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  desc,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 14,
                    height: 1.5,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ——— Solution ——————————————————————————————————————————————————————

class _SolutionSection extends StatelessWidget {
  const _SolutionSection();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = [
      ('01', l10n.t('pub_mfg_sol1_title'), l10n.t('pub_mfg_sol1_desc')),
      ('02', l10n.t('pub_mfg_sol2_title'), l10n.t('pub_mfg_sol2_desc')),
      ('03', l10n.t('pub_mfg_sol3_title'), l10n.t('pub_mfg_sol3_desc')),
      ('04', l10n.t('pub_mfg_sol4_title'), l10n.t('pub_mfg_sol4_desc')),
      ('05', l10n.t('pub_mfg_sol5_title'), l10n.t('pub_mfg_sol5_desc')),
    ];

    return _SectionShell(
      eyebrow: l10n.t('pub_mfg_sol_eyebrow'),
      title: l10n.t('pub_mfg_sol_title'),
      subtitle: l10n.t('pub_mfg_sol_subtitle'),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _SolutionTile(
                step: items[i].$1,
                title: items[i].$2,
                desc: items[i].$3,
                isLast: i == items.length - 1,
              ),
            ),
        ],
      ),
    );
  }
}

class _SolutionTile extends StatelessWidget {
  const _SolutionTile({
    required this.step,
    required this.title,
    required this.desc,
    required this.isLast,
  });

  final String step;
  final String title;
  final String desc;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 52,
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      colors: [
                        scheme.primary.withValues(alpha: 0.85),
                        scheme.secondary.withValues(alpha: 0.75),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: scheme.primary.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Text(
                    step,
                    style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.w700,
                      color: scheme.onPrimary,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Container(
                        width: 2,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(99),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              scheme.primary.withValues(alpha: 0.5),
                              scheme.outline.withValues(alpha: 0.15),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    desc,
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 14,
                      height: 1.5,
                      color: scheme.onSurfaceVariant,
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

// ——— ROI ——————————————————————————————————————————————————————————

class _RoiSection extends StatelessWidget {
  const _RoiSection();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return _SectionShell(
      eyebrow: l10n.t('pub_mfg_roi_eyebrow'),
      title: l10n.t('pub_mfg_roi_title'),
      subtitle: l10n.t('pub_mfg_roi_subtitle'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, c) {
              final run = c.maxWidth < 640;
              final metrics = [
                ('-28%', l10n.t('pub_mfg_roi_m1')),
                ('+22%', l10n.t('pub_mfg_roi_m2')),
                ('-40%', l10n.t('pub_mfg_roi_m3')),
                ('+19%', l10n.t('pub_mfg_roi_m4')),
              ];
              if (run) {
                return Column(
                  children: metrics
                      .map(
                        (m) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _RoiTile(value: m.$1, label: m.$2),
                        ),
                      )
                      .toList(),
                );
              }
              return Row(
                children: [
                  for (var i = 0; i < metrics.length; i++) ...[
                    Expanded(child: _RoiTile(value: metrics[i].$1, label: metrics[i].$2)),
                    if (i < metrics.length - 1) const SizedBox(width: 14),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: scheme.primary.withValues(alpha: 0.25)),
              gradient: LinearGradient(
                colors: [
                  scheme.primary.withValues(alpha: 0.08),
                  scheme.surfaceContainerHighest.withValues(alpha: 0.4),
                ],
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.format_quote_rounded, size: 36, color: scheme.primary.withValues(alpha: 0.5)),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    l10n.t('pub_mfg_roi_quote'),
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 16,
                      height: 1.55,
                      fontStyle: FontStyle.italic,
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

class _RoiTile extends StatelessWidget {
  const _RoiTile({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.25)),
        color: scheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              height: 1,
              color: scheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: GoogleFonts.ibmPlexSans(
              fontSize: 13,
              height: 1.35,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ——— Final CTA —————————————————————————————————————————————————————

class _FinalCtaSection extends StatelessWidget {
  const _FinalCtaSection();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: isDark
                          ? LinearGradient(
                              colors: [
                                scheme.primary.withValues(alpha: 0.2),
                                const Color(0xFF0F172A),
                              ],
                            )
                          : AppColorsLight.primaryGradient,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(36),
                  child: LayoutBuilder(
                    builder: (context, c) {
                      final stack = c.maxWidth < 720;
                      final copy = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.t('pub_mfg_final_title'),
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: stack ? 26 : 32,
                              fontWeight: FontWeight.w700,
                              height: 1.15,
                              color: isDark ? scheme.onSurface : AppColorsLight.onPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.t('pub_mfg_final_subtitle'),
                            style: GoogleFonts.ibmPlexSans(
                              fontSize: 16,
                              height: 1.5,
                              color: isDark
                                  ? scheme.onSurface.withValues(alpha: 0.85)
                                  : AppColorsLight.onPrimary.withValues(alpha: 0.92),
                            ),
                          ),
                        ],
                      );
                      final actions = Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: isDark ? scheme.primary : AppColorsLight.onPrimary,
                              foregroundColor: isDark ? scheme.onPrimary : AppColorsLight.primary,
                              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () => context.go('/register'),
                            child: Text(
                              l10n.t('pub_mfg_final_cta1'),
                              style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w700),
                            ),
                          ),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: isDark ? scheme.onSurface : AppColorsLight.onPrimary,
                              side: BorderSide(
                                color: (isDark ? scheme.onSurface : AppColorsLight.onPrimary)
                                    .withValues(alpha: 0.5),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () => context.go('/contact'),
                            child: Text(
                              l10n.t('pub_mfg_final_cta2'),
                              style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      );

                      if (stack) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [copy, const SizedBox(height: 24), actions],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(child: copy),
                          actions,
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.04, end: 0);
  }
}

class _SectionShell extends StatelessWidget {
  const _SectionShell({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow.toUpperCase(),
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                subtitle,
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 16,
                  height: 1.55,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 28),
              child,
            ],
          ).animate().fadeIn(duration: 380.ms).slideY(begin: 0.05, end: 0),
        ),
      ),
    );
  }
}
