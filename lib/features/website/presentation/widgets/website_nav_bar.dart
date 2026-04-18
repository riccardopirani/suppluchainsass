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
    const navBg = Color(0xEE030712);
    const navBorder = Color(0xFF1F2937);
    const textPrimary = Color(0xFFF9FAFB);
    return Material(
      elevation: 0,
      color: navBg,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            bottom: const BorderSide(color: navBorder),
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.asset(
                            'assets/image.png',
                            width: 32,
                            height: 32,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'FabricOS',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                if (isWide) ...[
                  _NavLink(label: l10n.t('nav_features'), onTap: () => context.go('/features')),
                  _NavLink(label: l10n.t('nav_pricing'), onTap: () => context.go('/pricing')),
                  _NavLink(label: l10n.t('nav_roi'), onTap: () => context.go('/roi-calculator')),
                  _NavLink(label: l10n.t('nav_factory_audit'), onTap: () => context.go('/factory-score')),
                  _NavLink(label: l10n.t('nav_book_demo'), onTap: () => context.go('/book-demo')),
                  _NavLink(label: l10n.t('nav_case_studies'), onTap: () => context.go('/case-studies')),
                  _NavLink(label: l10n.t('nav_contact'), onTap: () => context.go('/contact')),
                  _NavLink(label: l10n.t('nav_faq'), onTap: () => context.go('/faq')),
                  const SizedBox(width: 8),
                ],
                const LanguageSelector(),
                const SizedBox(width: 6),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: const BorderSide(color: navBorder),
                    foregroundColor: textPrimary,
                  ),
                  onPressed: () => context.go('/contact'),
                  child: Text(
                    l10n.t('pub_mfg_cta_demo'),
                    style: GoogleFonts.ibmPlexSans(
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: const BorderSide(color: navBorder),
                    foregroundColor: textPrimary,
                  ),
                  onPressed: () => context.go('/login'),
                  child: Text(
                    l10n.t('nav_login'),
                    style: GoogleFonts.ibmPlexSans(
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => context.go('/register'),
                  child: Text(
                    l10n.t('pub_mfg_cta_trial'),
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
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF9CA3AF),
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
