import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthPageShell extends StatelessWidget {
  const AuthPageShell({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.bullets,
    required this.form,
    this.formMaxWidth = 460,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final List<({IconData icon, String text})> bullets;
  final Widget form;
  final double formMaxWidth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030712),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final split =
                constraints.maxWidth >= 1040 && constraints.maxHeight >= 760;
            if (split) {
              return Row(
                children: [
                  Expanded(
                    flex: 11,
                    child: _PaneScroll(
                      child: _HeroPane(
                        eyebrow: eyebrow,
                        title: title,
                        subtitle: subtitle,
                        bullets: bullets,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 9,
                    child: _PaneScroll(
                      child: _FormPane(form: form, maxWidth: formMaxWidth),
                    ),
                  ),
                ],
              );
            }
            return SingleChildScrollView(
              child: Column(
                children: [
                  _HeroPane(
                    eyebrow: eyebrow,
                    title: title,
                    subtitle: subtitle,
                    bullets: bullets,
                    compact: true,
                  ),
                  _FormPane(form: form, maxWidth: formMaxWidth, compact: true),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PaneScroll extends StatelessWidget {
  const _PaneScroll({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: child,
          ),
        );
      },
    );
  }
}

class _HeroPane extends StatelessWidget {
  const _HeroPane({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.bullets,
    this.compact = false,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final List<({IconData icon, String text})> bullets;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF030712), Color(0xFF0B1220), Color(0xFF030712)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -140,
            left: -100,
            child: _GlowOrb(
              size: compact ? 220 : 320,
              color: const Color(0x332563EB),
            ),
          ),
          Positioned(
            bottom: -180,
            right: -110,
            child: _GlowOrb(
              size: compact ? 220 : 360,
              color: const Color(0x2238BDF8),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                compact ? 20 : 56,
                compact ? 28 : 56,
                compact ? 20 : 40,
                compact ? 28 : 56,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0x142563EB),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: const Color(0x332563EB)),
                    ),
                    child: Text(
                      eyebrow,
                      style: GoogleFonts.ibmPlexSans(
                        color: const Color(0xFF93C5FD),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    title,
                    style: GoogleFonts.spaceGrotesk(
                      color: const Color(0xFFF9FAFB),
                      fontSize: compact ? 34 : 58,
                      fontWeight: FontWeight.w800,
                      height: 1.04,
                      letterSpacing: -1.0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 620),
                    child: Text(
                      subtitle,
                      style: GoogleFonts.ibmPlexSans(
                        color: const Color(0xFFCBD5E1),
                        fontSize: compact ? 17 : 19,
                        height: 1.65,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: bullets
                        .map(
                          (bullet) =>
                              _BulletChip(icon: bullet.icon, text: bullet.text),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 26),
                  _ProductIllustration(compact: compact),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormPane extends StatelessWidget {
  const _FormPane({
    required this.form,
    required this.maxWidth,
    this.compact = false,
  });

  final Widget form;
  final double maxWidth;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 16 : 24,
        vertical: compact ? 24 : 40,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: form,
        ),
      ),
    );
  }
}

class _BulletChip extends StatelessWidget {
  const _BulletChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0x1AFFFFFF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x22FFFFFF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: const Color(0xFF93C5FD)),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.ibmPlexSans(
              color: const Color(0xFFF9FAFB),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, const Color(0x00030712)],
          stops: const [0.0, 0.82],
        ),
      ),
    );
  }
}

class _ProductIllustration extends StatelessWidget {
  const _ProductIllustration({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: compact ? 270 : 360,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B1220), Color(0xFF111827), Color(0xFF0F172A)],
        ),
        border: Border.all(color: const Color(0x332563EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x550F172A),
            blurRadius: 40,
            offset: Offset(0, 24),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 12,
            right: 12,
            child: _FloatingCard(
              label: 'Live alert',
              value: '3 critical',
              color: const Color(0xFFEF4444),
              icon: Icons.notification_important_outlined,
            ),
          ),
          Positioned(
            left: 12,
            bottom: 18,
            child: _FloatingCard(
              label: 'ROI',
              value: '+32%',
              color: const Color(0xFF10B981),
              icon: Icons.trending_up_outlined,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0x142563EB),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.hub_outlined,
                      color: Color(0xFF93C5FD),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FabricOS command center',
                        style: GoogleFonts.ibmPlexSans(
                          color: const Color(0xFFF9FAFB),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Orders, teams and alerts',
                        style: GoogleFonts.ibmPlexSans(
                          color: const Color(0xFF94A3B8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: const [
                  Expanded(
                    child: _MiniMetric(value: '128', label: 'Orders today'),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _MiniMetric(value: '14', label: 'Alerts'),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _MiniMetric(value: '7', label: 'Teams'),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0x08FFFFFF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0x1FFFFFFF)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Operational pulse',
                        style: GoogleFonts.ibmPlexSans(
                          color: const Color(0xFFF9FAFB),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, chartConstraints) {
                            final barMaxHeight =
                                (chartConstraints.maxHeight * 0.72).clamp(
                                  54.0,
                                  138.0,
                                );
                            const heights = <double>[
                              0.38,
                              0.52,
                              0.68,
                              0.84,
                              0.74,
                              0.9,
                              0.58,
                              0.72,
                            ];
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: List.generate(8, (index) {
                                return Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      right: index == 7 ? 0 : 8,
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          height: barMaxHeight * heights[index],
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                            gradient: const LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Color(0xFF60A5FA),
                                                Color(0xFF2563EB),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Container(
                                          height: 2,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF334155),
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0x12FFFFFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x1FFFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              color: const Color(0xFFF9FAFB),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.ibmPlexSans(
              color: const Color(0xFF94A3B8),
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _FloatingCard extends StatelessWidget {
  const _FloatingCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xE60F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x33FFFFFF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 18,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: GoogleFonts.ibmPlexSans(
                  color: const Color(0xFF94A3B8),
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                value,
                style: GoogleFonts.ibmPlexSans(
                  color: const Color(0xFFF9FAFB),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
