import 'package:fabricos/l10n/home_l10n_context.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Hero for the public home page — strings from `FabricosHomeArb` (ARB / gen-l10n).
///
/// Usage: wrap the app with [FabricosHomeArb.delegate] (see `FabricOSApp`).
class FabricosHomeHeroSection extends StatelessWidget {
  const FabricosHomeHeroSection({
    super.key,
    required this.onPrimary,
    required this.onSecondary,
  });

  final VoidCallback onPrimary;
  final VoidCallback onSecondary;

  @override
  Widget build(BuildContext context) {
    final h = context.homeL10n;
    final isCompact = MediaQuery.sizeOf(context).width < 760;

    return Column(
      children: [
        Text(
          h.home_hero_badge,
          textAlign: TextAlign.center,
          style: GoogleFonts.ibmPlexSans(
            color: const Color(0xFF2563EB),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          h.home_hero_title_line1,
          textAlign: TextAlign.center,
          style: GoogleFonts.spaceGrotesk(
            color: const Color(0xFFF9FAFB),
            fontSize: isCompact ? 32 : 48,
            fontWeight: FontWeight.w800,
            height: 1.08,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          h.home_hero_title_line2,
          textAlign: TextAlign.center,
          style: GoogleFonts.spaceGrotesk(
            color: const Color(0xFFF9FAFB),
            fontSize: isCompact ? 32 : 48,
            fontWeight: FontWeight.w800,
            height: 1.08,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          h.home_hero_title_accent,
          textAlign: TextAlign.center,
          style: GoogleFonts.spaceGrotesk(
            color: const Color(0xFF60A5FA),
            fontSize: isCompact ? 32 : 48,
            fontWeight: FontWeight.w800,
            height: 1.08,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 20),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Text(
            h.home_hero_subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.ibmPlexSans(
              color: const Color(0xFF9CA3AF),
              fontSize: isCompact ? 17 : 19,
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 28),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: [
            FilledButton(
              onPressed: onPrimary,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(h.home_hero_cta_primary),
            ),
            OutlinedButton(
              onPressed: onSecondary,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFF9FAFB),
                side: const BorderSide(color: Color(0xFF1F2937)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(h.home_hero_cta_secondary),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: [
            _ProofChip(text: h.home_hero_proof_1),
            _ProofChip(text: h.home_hero_proof_2),
            _ProofChip(text: h.home_hero_proof_3),
            _ProofChip(text: h.home_hero_proof_4),
          ],
        ),
      ],
    );
  }
}

class _ProofChip extends StatelessWidget {
  const _ProofChip({required this.text});

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
      child: Text(
        text,
        style: GoogleFonts.ibmPlexSans(
          color: const Color(0xFF9CA3AF),
          fontSize: 13,
        ),
      ),
    );
  }
}
