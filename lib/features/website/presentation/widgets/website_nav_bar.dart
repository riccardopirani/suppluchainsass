import 'package:fabricos/features/website/presentation/widgets/language_selector.dart';
import 'package:fabricos/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class WebsiteNavBar extends StatelessWidget implements PreferredSizeWidget {
  const WebsiteNavBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isWide = MediaQuery.sizeOf(context).width > 950;
    final scheme = Theme.of(context).colorScheme;

    return Material(
      elevation: 0,
      color: scheme.surface.withValues(alpha: 0.92),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: scheme.outline.withValues(alpha: 0.2)),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.go('/'),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text(
                      'FabricOS',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.6,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                if (isWide) ...[
                  _NavLink(label: l10n.t('nav_features'), onTap: () => context.go('/features')),
                  _NavLink(label: l10n.t('nav_pricing'), onTap: () => context.go('/pricing')),
                  _NavLink(label: l10n.t('nav_contact'), onTap: () => context.go('/contact')),
                  _NavLink(label: l10n.t('nav_faq'), onTap: () => context.go('/faq')),
                  const SizedBox(width: 8),
                ],
                const LanguageSelector(),
                const SizedBox(width: 6),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: scheme.outline.withValues(alpha: 0.45)),
                  ),
                  onPressed: () => context.go('/login'),
                  child: Text(
                    l10n.t('nav_login'),
                    style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => context.go('/register'),
                  child: Text(
                    l10n.t('cta_try_free'),
                    style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  const _NavLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: scheme.onSurface.withValues(alpha: 0.85),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onTap,
      child: Text(
        label,
        style: GoogleFonts.ibmPlexSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
