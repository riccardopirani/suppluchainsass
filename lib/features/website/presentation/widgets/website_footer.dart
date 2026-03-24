import 'package:fabricos/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class WebsiteFooter extends StatelessWidget {
  const WebsiteFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? scheme.surface.withValues(alpha: 0.95) : scheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(color: scheme.primary.withValues(alpha: 0.2), width: 1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: LayoutBuilder(
              builder: (context, c) {
                final stack = c.maxWidth < 640;
                final brand = Column(
                  crossAxisAlignment:
                      stack ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.t('app_name'),
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.t('pub_footer_tagline'),
                      textAlign: stack ? TextAlign.center : TextAlign.start,
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 13,
                        height: 1.45,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                );

                final links = Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  alignment: stack ? WrapAlignment.center : WrapAlignment.end,
                  children: [
                    _FooterLink(label: l10n.t('footer_privacy'), onTap: () => context.go('/privacy')),
                    _FooterLink(label: l10n.t('footer_terms'), onTap: () => context.go('/terms')),
                    _FooterLink(label: l10n.t('footer_cookies'), onTap: () => context.go('/cookies')),
                    _FooterLink(label: l10n.t('footer_contact'), onTap: () => context.go('/contact')),
                  ],
                );

                if (stack) {
                  return Column(
                    children: [
                      brand,
                      const SizedBox(height: 24),
                      links,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: brand),
                    links,
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      onPressed: onTap,
      child: Text(
        label,
        style: GoogleFonts.ibmPlexSans(
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}
