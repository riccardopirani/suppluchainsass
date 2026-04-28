import 'package:fabricos/features/website/presentation/widgets/public_site_theme.dart';
import 'package:fabricos/features/website/presentation/widgets/website_footer.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

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
          const _TrustBand(),
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

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.onDemo, required this.onTrial});
  final VoidCallback onDemo;
  final VoidCallback onTrial;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 900;
    return _Section(
      padding: const EdgeInsets.fromLTRB(0, 96, 0, 92),
      child: _Wrap(
        child: LayoutBuilder(
          builder: (context, c) {
            final stack = c.maxWidth < 980;
            final content = Column(
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
                    color: PublicSiteTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: PublicSiteTheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    'CONTROL TOWER PER MANIFATTURA',
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 11,
                      color: PublicSiteTheme.primary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.9,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Dal caos operativo al controllo predittivo della supply chain',
                  textAlign: stack ? TextAlign.center : TextAlign.start,
                  style: GoogleFonts.spaceGrotesk(
                    color: PublicSiteTheme.foreground,
                    fontSize: compact ? 38 : 56,
                    fontWeight: FontWeight.w800,
                    height: 1.08,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'FabricOS unisce operations, AI e compliance in una vista unica: previsione domanda, rischi fornitori, simulazioni what-if e report ESG. Setup in 30 giorni.',
                  textAlign: stack ? TextAlign.center : TextAlign.start,
                  style: GoogleFonts.ibmPlexSans(
                    color: PublicSiteTheme.mutedForeground,
                    fontSize: 18,
                    height: 1.6,
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
                      onPressed: onDemo,
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
                      child: const Text('Prenota demo'),
                    ),
                    OutlinedButton(
                      onPressed: onTrial,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: PublicSiteTheme.foreground,
                        side: const BorderSide(color: PublicSiteTheme.border),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 18,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: const Text('Inizia prova 30 giorni'),
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
                  children: const [
                    _MiniPill('Setup rapido'),
                    _MiniPill('Alert critici in tempo reale'),
                    _MiniPill('Sicurezza enterprise'),
                  ],
                ),
              ],
            );
            final visual = _HeroVisual(compact: compact);

            if (stack) {
              return Column(
                children: [
                  content,
                  const SizedBox(height: 28),
                  visual,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 11, child: content),
                const SizedBox(width: 36),
                Expanded(flex: 10, child: visual),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HeroVisual extends StatelessWidget {
  const _HeroVisual({required this.compact});
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: PublicSiteTheme.secondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PublicSiteTheme.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x190F172A),
            blurRadius: 38,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: AspectRatio(
        aspectRatio: compact ? 4 / 3 : 1.1,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: PublicSiteTheme.border.withValues(alpha: 0.7),
            ),
          ),
          child: Column(
            children: [
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: PublicSiteTheme.border)),
                ),
                child: const Row(
                  children: [
                    _Dot(),
                    SizedBox(width: 6),
                    _Dot(),
                    SizedBox(width: 6),
                    _Dot(),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color:
                                      PublicSiteTheme.secondary.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Expanded(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: PublicSiteTheme.muted,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: PublicSiteTheme.muted,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: PublicSiteTheme.primary.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: PublicSiteTheme.primary.withValues(alpha: 0.2),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: PublicSiteTheme.border,
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  const _MiniPill(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
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

class _TrustBand extends StatelessWidget {
  const _TrustBand();

  @override
  Widget build(BuildContext context) {
    const brands = [
      'AeroDynamics',
      'GlobalSteel',
      'PackTech',
      'MediEquip',
      'VentoAuto',
    ];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: PublicSiteTheme.border),
          bottom: BorderSide(color: PublicSiteTheme.border),
        ),
      ),
      child: _Wrap(
        child: Column(
          children: [
            Text(
              'SCELTO DALLE MIGLIORI AZIENDE MANIFATTURIERE',
              style: GoogleFonts.ibmPlexSans(
                color: PublicSiteTheme.mutedForeground,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 24,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: brands
                  .map(
                    (b) => Text(
                      b,
                      style: GoogleFonts.spaceGrotesk(
                        color: PublicSiteTheme.mutedForeground.withValues(alpha: 0.75),
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                      ),
                    ),
                  )
                  .toList(),
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
    final cards = const [
      (
        'Rischio ordini',
        'Identifichi ritardi prima dell\'impatto su OTIF e margini.'
      ),
      (
        'Inventario ottimizzato',
        'Riduci stock eccessivo senza aumentare rotture di stock.'
      ),
      (
        'Compliance ESG',
        'Generi snapshot ESG mensili e tracciabilità audit-ready.'
      ),
    ];
    return _Section(
      child: _Wrap(
        child: Column(
          children: [
            Text(
              'Punti critici che risolvi subito',
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
              'Ritardi ordini, stockout, fornitori instabili, decisioni tardive, reportistica frammentata.',
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
                  childAspectRatio: cols == 1 ? 2.2 : 1.15,
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
    const items = [
      ('-22%', 'Downtime medio impianto'),
      ('+18%', 'Accuratezza decisioni'),
      ('+31%', 'Velocità risposta'),
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
    const plans = [
      (
        'Essenziale',
        '€790',
        '/mese',
        ['1 stabilimento', 'Funzioni operative core', 'No AI predittiva avanzata'],
        false,
        'essenziale',
      ),
      (
        'Professionale',
        '€1690',
        '/mese',
        ['Forecast e what-if', 'Supplier risk AI', 'Modulo ESG completo'],
        true,
        'professionale',
      ),
      (
        'Industriale',
        '€3490',
        '/mese',
        ['Integrazione API/ERP', 'Auto-replenishment full', 'Ottimizzazione costi AI'],
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
              'Piani e Prezzi',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 42,
                fontWeight: FontWeight.w700,
                color: PublicSiteTheme.foreground,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Scegli il piano adatto alle dimensioni della tua operations.',
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
                                'PIU SCELTO',
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
                                    ? 'Inizia Prova'
                                    : (p.$6 == 'industriale'
                                          ? 'Contatta Vendite'
                                          : 'Inizia Prova'),
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
    const faq = [
      (
        'La prova gratuita è per tutti i piani?',
        'Sì, 30 giorni sul piano selezionato. Alla scadenza è necessario un abbonamento attivo.',
      ),
      (
        'Posso cambiare piano dopo l\'attivazione?',
        'Sì, puoi fare upgrade o downgrade dalla sezione Billing.',
      ),
      (
        'Le feature sono sicure e protette?',
        'Sì: edge functions e trigger DB validano billing e tier per operazioni critiche.',
      ),
    ];
    return _Section(
      child: _Wrap(
        child: Column(
          children: [
            Text(
              'Domande frequenti',
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
              'Pronto a prendere il controllo?',
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                color: Colors.white,
                fontSize: 44,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Trasforma la tua supply chain da reattiva a predittiva.',
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
                  child: const Text('Attiva Trial'),
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
                  child: const Text('Parla con noi'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
