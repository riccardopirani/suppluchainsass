import 'dart:ui';

import 'package:fabricos/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shared visuals for public marketing pages (2026 manufacturing SaaS).
class MarketingMeshPainter extends CustomPainter {
  MarketingMeshPainter({required this.accent});

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
  bool shouldRepaint(covariant MarketingMeshPainter oldDelegate) =>
      oldDelegate.accent != accent;
}

class MarketingGlowOrb extends StatelessWidget {
  const MarketingGlowOrb({super.key, required this.color, required this.size});

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

/// Compact hero band for inner marketing routes (features, pricing, etc.).
class MarketingPageIntro extends StatelessWidget {
  const MarketingPageIntro({
    super.key,
    required this.eyebrow,
    required this.title,
    this.subtitle,
  });

  final String eyebrow;
  final String title;
  final String? subtitle;

  static const Color _onHero = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColorsDark.primary : AppColorsLight.primary;
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

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(gradient: bgGradient),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: CustomPaint(painter: MarketingMeshPainter(accent: accent)),
          ),
          Positioned(
            right: -40,
            top: -50,
            child: MarketingGlowOrb(
              color: accent.withValues(alpha: 0.3),
              size: 220,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 44, 24, 48),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: LayoutBuilder(
                  builder: (context, bc) {
                    final narrow = bc.maxWidth < 520;
                    final titleSize = narrow ? 28.0 : 36.0;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          eyebrow.toUpperCase(),
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            color: accent,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          title,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: titleSize,
                            fontWeight: FontWeight.w700,
                            height: 1.12,
                            letterSpacing: -0.8,
                            color: _onHero,
                          ),
                        ),
                        if (subtitle != null && subtitle!.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Text(
                            subtitle!,
                            style: GoogleFonts.ibmPlexSans(
                              fontSize: narrow ? 15 : 16,
                              height: 1.5,
                              color: _onHero.withValues(alpha: 0.72),
                            ),
                          ),
                        ],
                      ],
                    );
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

/// Standard max width wrapper for marketing body content.
class MarketingBody extends StatelessWidget {
  const MarketingBody({
    super.key,
    required this.child,
    this.maxWidth = 1200,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 56),
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
  }
}

/// Bento-style tile for feature lists.
class MarketingBentoTile extends StatelessWidget {
  const MarketingBentoTile({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: scheme.outline.withValues(alpha: 0.35)),
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Row(
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
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                        description,
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 14,
                          height: 1.5,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
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

/// Glass-style panel for forms (contact, etc.).
class MarketingGlassPanel extends StatelessWidget {
  const MarketingGlassPanel({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: scheme.outline.withValues(alpha: 0.35)),
            color: scheme.surface.withValues(alpha: 0.85),
          ),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: child,
          ),
        ),
      ),
    );
  }
}
