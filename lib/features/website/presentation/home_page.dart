import 'package:flutter/material.dart';
import 'package:fabricos/features/website/presentation/widgets/website_footer.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _users = 50;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF030712),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _HeroSection(onStartTrial: () => context.go('/register')),
            const _PainSection(),
            const _SolutionSection(),
            const _RoiSection(),
            const _FeaturesSection(),
            _PricingSection(
              users: _users,
              onUsersChanged: (v) => setState(() => _users = v),
              onStartTrial: () => context.go('/register?seats=${_users.round()}'),
            ),
            const _ContactSection(),
            const _FaqSection(),
            const _LegalSection(),
            _FinalCtaSection(
              onStartTrial: () => context.go('/register'),
              onContact: () => context.go('/contact'),
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
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.spaceGrotesk(
            color: const Color(0xFFF9FAFB),
            fontSize: 44,
            fontWeight: FontWeight.w700,
            height: 1.1,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 14),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.ibmPlexSans(
              color: const Color(0xFF9CA3AF),
              fontSize: 18,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.onStartTrial});
  final VoidCallback onStartTrial;

  @override
  Widget build(BuildContext context) {
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
                const _Eyebrow(
                  icon: Icons.memory_rounded,
                  text: 'Manufacturing OS · AI-native',
                ),
                const SizedBox(height: 18),
                Text(
                  'AI che previene i ritardi e ottimizza automaticamente la supply chain.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spaceGrotesk(
                    color: const Color(0xFFF9FAFB),
                    fontSize: isCompact ? 40 : 62,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                    letterSpacing: -1.0,
                  ),
                ),
                const SizedBox(height: 20),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Text(
                    'Progettato per operations e supply chain leader. Sfrutta l\'intelligenza artificiale per visibilita end-to-end e automazione dei flussi decisionali.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.ibmPlexSans(
                      color: const Color(0xFF9CA3AF),
                      fontSize: isCompact ? 18 : 20,
                      height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    FilledButton(
                      onPressed: onStartTrial,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Inizia trial gratuito ->'),
                    ),
                    OutlinedButton(
                      onPressed: () => context.go('/contact'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFF9FAFB),
                        side: const BorderSide(color: Color(0xFF1F2937)),
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Prenota demo'),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: const [
                    _Chip(icon: Icons.dashboard_customize_outlined, text: 'Go-live < 1 settimana'),
                    _Chip(icon: Icons.notifications_active_outlined, text: 'Alert in tempo reale'),
                    _Chip(icon: Icons.description_outlined, text: 'Export ESG PDF'),
                    _Chip(icon: Icons.shield_outlined, text: 'RBAC enterprise'),
                  ],
                ),
                const SizedBox(height: 48),
                Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF1F2937)),
                    boxShadow: const [BoxShadow(color: Color(0x80000000), blurRadius: 40, offset: Offset(0, 18))],
                  ),
                  child: Image.network(
                    'https://storage.googleapis.com/banani-generated-images/generated-images/7b81f20e-7931-454e-ba1f-d868ca2e5775.jpg',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: isCompact ? 240 : 520,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFF0F172A),
                      height: isCompact ? 240 : 520,
                      alignment: Alignment.center,
                      child: const Text('Dashboard preview', style: TextStyle(color: Color(0xFF9CA3AF))),
                    ),
                  ),
                ),
                const SizedBox(height: 52),
                Container(
                  padding: const EdgeInsets.only(top: 28),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Color(0xFF1F2937))),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'SCELTO DAI LEADER DELLA PRODUZIONE',
                        style: GoogleFonts.ibmPlexSans(
                          color: const Color(0xFF9CA3AF),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.6,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 36,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: const [
                          _LogoText('Stellantis'),
                          _LogoText('Pirelli'),
                          _LogoText('Leonardo'),
                          _LogoText('Brembo'),
                          _LogoText('Prysmian'),
                        ],
                      ),
                    ],
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

class _LogoText extends StatelessWidget {
  const _LogoText(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.spaceGrotesk(
        color: const Color(0x809CA3AF),
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _PainSection extends StatelessWidget {
  const _PainSection();

  @override
  Widget build(BuildContext context) {
    final cards = const [
      (Icons.build_outlined, 'Guasti non previsti', 'Downtime che bloccano intere linee, con costi orari esorbitanti e ritardi a cascata.'),
      (Icons.schedule_outlined, 'Ritardi fornitori', 'Mancanza di materiali critici per la produzione a causa di scarsa visibilita sui tier 2 e 3.'),
      (Icons.storage_outlined, 'Dati sparsi', 'Silos informativi tra ERP, Excel e MES che impediscono decisioni rapide e informate.'),
      (Icons.report_problem_outlined, 'Reporting ESG lento', 'Mesi persi per aggregare dati sulle emissioni della catena di fornitura per compliance.'),
    ];
    return _SectionWrap(
      alt: true,
      child: _PageContainer(
        child: Column(
          children: [
            const _Eyebrow(icon: Icons.factory_outlined, text: 'Progettato per fabbriche e supply chain nel 2026'),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: const [
                _Tag('Industrial IoT'),
                _Tag('MES ready'),
                _Tag('ERP connectors'),
                _Tag('ISO audit trail'),
                _Tag('EU data residency'),
              ],
            ),
            const SizedBox(height: 34),
            const _SectionTitle(
              title: 'Problemi reali, impatto diretto sul P&L',
              subtitle: 'FabricOS elimina i colli di bottiglia che rallentano la produzione e riducono i margini operativi.',
            ),
            const SizedBox(height: 46),
            LayoutBuilder(
              builder: (context, c) {
                final col = c.maxWidth >= 980 ? 4 : c.maxWidth >= 700 ? 2 : 1;
                return GridView.count(
                  crossAxisCount: col,
                  shrinkWrap: true,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 18,
                  childAspectRatio: col == 1 ? 1.6 : 1.2,
                  physics: const NeverScrollableScrollPhysics(),
                  children: cards
                      .map((it) => _PainCard(icon: it.$1, title: it.$2, text: it.$3))
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
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF1F2937)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: const Color(0x1AEF4444),
            ),
            child: const Icon(Icons.warning_amber_outlined, color: Color(0xFFEF4444), size: 20),
          ),
          const SizedBox(height: 16),
          Text(title, style: GoogleFonts.spaceGrotesk(color: const Color(0xFFF9FAFB), fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(text, style: GoogleFonts.ibmPlexSans(color: const Color(0xFF9CA3AF), fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }
}

class _SolutionSection extends StatelessWidget {
  const _SolutionSection();

  @override
  Widget build(BuildContext context) {
    final items = const [
      'Dashboard decisionale globale',
      'Predictive maintenance integrata',
      'Automazione Orders & Supply Chain',
      'Supplier intelligence e risk scoring',
      'Tracciamento ESG & compliance live',
    ];
    return _SectionWrap(
      child: _PageContainer(
        child: Column(
          children: [
            const _SectionTitle(
              title: 'Un OS operativo per la fabbrica',
              subtitle: 'Cinque moduli integrati che trasformano i dati grezzi in azioni operative immediate.',
            ),
            const SizedBox(height: 48),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 660),
              child: Column(
                children: List.generate(
                  items.length,
                  (i) => Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF1F2937)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0x1A2563EB),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${(i + 1).toString().padLeft(2, '0')}',
                            style: GoogleFonts.ibmPlexSans(
                              color: const Color(0xFF2563EB),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            items[i],
                            style: GoogleFonts.spaceGrotesk(
                              color: const Color(0xFFF9FAFB),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
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

class _RoiSection extends StatelessWidget {
  const _RoiSection();

  @override
  Widget build(BuildContext context) {
    final metrics = const [
      ('-28%', 'Downtime non pianificato'),
      ('+22%', 'Affidabilita consegne'),
      ('-40%', 'Tempo report ESG'),
      ('+19%', 'Visibilita rischio fornitore'),
    ];
    return _SectionWrap(
      alt: true,
      child: _PageContainer(
        child: Column(
          children: [
            const _SectionTitle(
              title: 'Valore misurabile nelle prime settimane',
              subtitle: 'Risultati aggregati dai nostri clienti enterprise nel primo trimestre di utilizzo.',
            ),
            const SizedBox(height: 50),
            LayoutBuilder(
              builder: (context, c) {
                final cols = c.maxWidth >= 980 ? 4 : c.maxWidth >= 700 ? 2 : 1;
                return GridView.count(
                  crossAxisCount: cols,
                  shrinkWrap: true,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 18,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: cols == 1 ? 2.0 : 1.2,
                  children: metrics
                      .map(
                        (m) => Container(
                          padding: const EdgeInsets.all(24),
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
                                  fontSize: 46,
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
                                  fontSize: 15,
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
            const SizedBox(height: 44),
            Container(
              constraints: const BoxConstraints(maxWidth: 820),
              padding: const EdgeInsets.all(36),
              decoration: BoxDecoration(
                color: const Color(0xFF030712),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1F2937)),
              ),
              child: Column(
                children: [
                  Text(
                    '"Da quando abbiamo implementato FabricOS, non lavoriamo piu in emergenza. L\'AI previene i problemi sui fornitori critici prima che impattino le linee di assemblaggio."',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.ibmPlexSans(
                      color: const Color(0xFFF9FAFB),
                      fontSize: 23,
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '— Marco Bianchi, Operations Manager',
                    style: GoogleFonts.ibmPlexSans(color: const Color(0xFF9CA3AF), fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturesSection extends StatelessWidget {
  const _FeaturesSection();

  @override
  Widget build(BuildContext context) {
    const cards = [
      (3, Icons.speed_outlined, 'Predictive Maintenance', 'Connetti i sensori IoT delle macchine per prevedere guasti con settimane di anticipo, riducendo i costi di manutenzione e fermo linea.'),
      (3, Icons.shopping_cart_outlined, 'Orders & Supply Chain', 'Visibilita end-to-end sugli ordini in transito. L\'AI ricalcola automaticamente i tempi di consegna in base al traffico globale.'),
      (2, Icons.groups_2_outlined, 'Supplier Monitoring', 'Analizza in tempo reale la salute finanziaria e operativa dei tuoi fornitori.'),
      (2, Icons.eco_outlined, 'ESG / Compliance', 'Raccogli in automatico i dati sulle emissioni Scope 3 per la direttiva CSRD.'),
      (2, Icons.bolt_outlined, 'Realtime Operations', 'Sincronizzazione millisecondo per millisecondo tra stabilimenti multipli in tutto il mondo.'),
    ];
    return _SectionWrap(
      child: _PageContainer(
        child: Column(
          children: [
            const _Eyebrow(icon: Icons.layers_outlined, text: 'Platform'),
            const SizedBox(height: 14),
            const _SectionTitle(
              title: 'Moduli FabricOS',
              subtitle: 'Una piattaforma modulare progettata per crescere con le esigenze della tua supply chain.',
            ),
            const SizedBox(height: 44),
            LayoutBuilder(
              builder: (context, c) {
                final isDesktop = c.maxWidth >= 980;
                if (!isDesktop) {
                  return Column(
                    children: cards
                        .map((card) => Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: _FeatureCard(
                                icon: card.$2,
                                title: card.$3,
                                text: card.$4,
                              ),
                            ))
                        .toList(),
                  );
                }
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _FeatureCard(
                            icon: cards[0].$2,
                            title: cards[0].$3,
                            text: cards[0].$4,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _FeatureCard(
                            icon: cards[1].$2,
                            title: cards[1].$3,
                            text: cards[1].$4,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _FeatureCard(
                            icon: cards[2].$2,
                            title: cards[2].$3,
                            text: cards[2].$4,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _FeatureCard(
                            icon: cards[3].$2,
                            title: cards[3].$3,
                            text: cards[3].$4,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _FeatureCard(
                            icon: cards[4].$2,
                            title: cards[4].$3,
                            text: cards[4].$4,
                          ),
                        ),
                      ],
                    ),
                  ],
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
      padding: const EdgeInsets.all(24),
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
              borderRadius: BorderRadius.circular(8),
              color: const Color(0x1A2563EB),
            ),
            child: Icon(icon, color: const Color(0xFF2563EB), size: 24),
          ),
          const SizedBox(height: 16),
          Text(title, style: GoogleFonts.spaceGrotesk(color: const Color(0xFFF9FAFB), fontSize: 19, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(text, style: GoogleFonts.ibmPlexSans(color: const Color(0xFF9CA3AF), fontSize: 15, height: 1.6)),
        ],
      ),
    );
  }
}

class _PricingSection extends StatelessWidget {
  const _PricingSection({
    required this.users,
    required this.onUsersChanged,
    required this.onStartTrial,
  });

  final double users;
  final ValueChanged<double> onUsersChanged;
  final VoidCallback onStartTrial;

  @override
  Widget build(BuildContext context) {
    final qty = users.round().clamp(1, 9999);
    final unit = qty <= 10
        ? 9
        : qty <= 50
            ? 8
            : qty <= 200
                ? 7
                : qty <= 500
                    ? 6
                    : 5;
    final total = unit * qty;
    return _SectionWrap(
      alt: true,
      child: _PageContainer(
        child: Column(
          children: [
            const _Eyebrow(icon: Icons.credit_card_outlined, text: 'Pricing'),
            const SizedBox(height: 14),
            const _SectionTitle(
              title: 'Prezzo semplice per utente',
              subtitle: 'Tutte le funzionalita incluse senza costi nascosti, con sconti volume automatici.',
            ),
            const SizedBox(height: 42),
            LayoutBuilder(
              builder: (context, c) {
                final compact = c.maxWidth < 980;
                final left = _PricingCalculator(
                  qty: qty,
                  unit: unit,
                  total: total,
                  onUsersChanged: onUsersChanged,
                  onStartTrial: onStartTrial,
                );
                final right = const _PricingTable();
                if (compact) {
                  return Column(children: [left, const SizedBox(height: 16), right]);
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Expanded(child: left), const SizedBox(width: 18), Expanded(child: right)],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PricingCalculator extends StatelessWidget {
  const _PricingCalculator({
    required this.qty,
    required this.unit,
    required this.total,
    required this.onUsersChanged,
    required this.onStartTrial,
  });
  final int qty;
  final int unit;
  final int total;
  final ValueChanged<double> onUsersChanged;
  final VoidCallback onStartTrial;

  @override
  Widget build(BuildContext context) {
    return _PricingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pricingTitle('Calcola il tuo piano'),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _smallText('Utenti stimati'),
              Text('$qty', style: GoogleFonts.ibmPlexSans(color: const Color(0xFFF9FAFB), fontSize: 15, fontWeight: FontWeight.w500)),
            ],
          ),
          Slider(
            value: qty.toDouble(),
            min: 1,
            max: 500,
            divisions: 499,
            activeColor: const Color(0xFF2563EB),
            inactiveColor: const Color(0xFF1F2937),
            onChanged: onUsersChanged,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('€$total', style: GoogleFonts.spaceGrotesk(color: const Color(0xFFF9FAFB), fontSize: 46, fontWeight: FontWeight.w700)),
              const SizedBox(width: 8),
              _smallText('/mese'),
            ],
          ),
          const SizedBox(height: 6),
          _smallText('€$unit per utente / mese'),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onStartTrial,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Inizia prova gratuita ->'),
            ),
          ),
          const SizedBox(height: 22),
          ...const [
            _IncludedLine('Dashboard & Reporting'),
            _IncludedLine('Machine Monitoring'),
            _IncludedLine('Orders & Suppliers'),
            _IncludedLine('AI Risk & Demand Forecasting'),
            _IncludedLine('Inventory & ESG Tracking'),
          ],
        ],
      ),
    );
  }

  Widget _pricingTitle(String text) => Text(
        text,
        style: GoogleFonts.spaceGrotesk(color: const Color(0xFFF9FAFB), fontSize: 20, fontWeight: FontWeight.w600),
      );

  Widget _smallText(String text) => Text(
        text,
        style: GoogleFonts.ibmPlexSans(color: const Color(0xFF9CA3AF), fontSize: 14),
      );
}

class _PricingTable extends StatelessWidget {
  const _PricingTable();

  @override
  Widget build(BuildContext context) {
    const rows = [
      ('1-10 utenti', '€9 / utente'),
      ('11-50 utenti', '€8 / utente'),
      ('51-200 utenti', '€7 / utente'),
      ('201-500 utenti', '€6 / utente'),
      ('501+ utenti', '€5 / utente'),
    ];
    return _PricingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sconti volume',
            style: GoogleFonts.spaceGrotesk(color: const Color(0xFFF9FAFB), fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Il costo per utente diminuisce all\'aumentare dei team coinvolti.',
            style: GoogleFonts.ibmPlexSans(color: const Color(0xFF9CA3AF), fontSize: 14),
          ),
          const SizedBox(height: 20),
          Table(
            border: const TableBorder(horizontalInside: BorderSide(color: Color(0xFF1F2937))),
            children: [
              TableRow(
                children: [
                  _tableCell('Fascia utenti', isHeader: true),
                  _tableCell('Prezzo mensile', isHeader: true),
                ],
              ),
              ...rows.map((r) => TableRow(children: [_tableCell(r.$1), _tableCell(r.$2)])),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'IVA esclusa. Nessuna carta di credito richiesta per attivare il trial di 30 giorni.',
            style: GoogleFonts.ibmPlexSans(color: const Color(0xFF9CA3AF), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _tableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Text(
        text,
        style: GoogleFonts.ibmPlexSans(
          color: isHeader ? const Color(0xFF9CA3AF) : const Color(0xFFF9FAFB),
          fontSize: 14,
          fontWeight: isHeader ? FontWeight.w500 : FontWeight.w400,
        ),
      ),
    );
  }
}

class _PricingCard extends StatelessWidget {
  const _PricingCard({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1F2937)),
      ),
      child: child,
    );
  }
}

class _IncludedLine extends StatelessWidget {
  const _IncludedLine(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline_rounded, size: 16, color: Color(0xFF2563EB)),
          const SizedBox(width: 10),
          Text(text, style: GoogleFonts.ibmPlexSans(color: const Color(0xFF9CA3AF), fontSize: 14)),
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
    return _SectionWrap(
      child: _PageContainer(
        child: LayoutBuilder(
          builder: (context, c) {
            final compact = c.maxWidth < 940;
            final left = const _ContactCopy();
            final right = _ContactForm(
              formKey: _formKey,
              sent: _sent,
              onSend: () {
                if (_formKey.currentState?.validate() ?? false) {
                  setState(() => _sent = true);
                }
              },
            );
            if (compact) {
              return Column(children: [left, const SizedBox(height: 20), right]);
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Expanded(child: left), const SizedBox(width: 42), Expanded(child: right)],
            );
          },
        ),
      ),
    );
  }
}

class _ContactCopy extends StatelessWidget {
  const _ContactCopy();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Eyebrow(icon: Icons.mail_outline, text: 'Contact', center: false),
        const SizedBox(height: 10),
        Text(
          'Parliamo delle tue operations',
          style: GoogleFonts.spaceGrotesk(
            color: const Color(0xFFF9FAFB),
            fontSize: 40,
            fontWeight: FontWeight.w700,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Raccontaci il tuo contesto produttivo. Scopri come FabricOS puo integrarsi nel tuo ecosistema software esistente (ERP, MES) e migliorare le performance in meno di 30 giorni.',
          style: GoogleFonts.ibmPlexSans(color: const Color(0xFF9CA3AF), fontSize: 18, height: 1.6),
        ),
      ],
    );
  }
}

class _ContactForm extends StatelessWidget {
  const _ContactForm({
    required this.formKey,
    required this.sent,
    required this.onSend,
  });

  final GlobalKey<FormState> formKey;
  final bool sent;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
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
              children: [
                _field('Nome e cognome *', validator: _required),
                const SizedBox(height: 16),
                _field('Email di lavoro *', validator: _email),
                const SizedBox(height: 16),
                _field('Azienda'),
                const SizedBox(height: 16),
                _field('Di cosa hai bisogno?', maxLines: 4),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onSend,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Invia richiesta'),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (sent)
          Positioned(
            right: -14,
            bottom: -16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF1F2937)),
                boxShadow: const [BoxShadow(color: Color(0x80000000), blurRadius: 22, offset: Offset(0, 10))],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Grazie — in produzione collegheremo l\'invio a CRM o email.',
                    style: GoogleFonts.ibmPlexSans(color: const Color(0xFFF9FAFB), fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _field(String label, {String? Function(String?)? validator, int maxLines = 1}) {
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

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Campo obbligatorio';
    return null;
  }

  String? _email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Campo obbligatorio';
    if (!value.contains('@')) return 'Email non valida';
    return null;
  }
}

class _FaqSection extends StatelessWidget {
  const _FaqSection();

  @override
  Widget build(BuildContext context) {
    const faq = [
      (
        'Come funziona la manutenzione predittiva nell\'MVP?',
        'Nell\'MVP, utilizziamo i dati storici esportati dal tuo MES (Machine Execution System) e li incrociamo con logiche preimpostate di usura. Nelle versioni avanzate ci colleghiamo via API ai sensori IoT per elaborazione in tempo reale.'
      ),
      (
        'Supportate configurazioni multi-stabilimento e ruoli utente?',
        'Assolutamente si. L\'architettura multi-tenant di FabricOS permette di creare divisioni logiche per ogni stabilimento con granularita sui permessi tramite RBAC.'
      ),
      (
        'I report per la compliance ESG sono esportabili?',
        'Si, tutti i dati raccolti nel modulo ESG possono essere esportati in un formato PDF standardizzato e pronto per gli audit ISO e i framework europei (CSRD).'
      ),
      (
        'L\'aggiornamento dati e veramente in tempo reale?',
        'Si, grazie all\'integrazione realtime, ogni modifica a un ordine o alert macchina viene propagata istantaneamente agli utenti connessi.'
      ),
    ];
    return _SectionWrap(
      alt: true,
      child: _PageContainer(
        child: Column(
          children: [
            const _Eyebrow(icon: Icons.help_outline, text: 'FAQ'),
            const SizedBox(height: 14),
            const _SectionTitle(
              title: 'Domande frequenti',
              subtitle: 'Tutto quello che c\'e da sapere dal punto di vista tecnico e operativo prima del deploy.',
            ),
            const SizedBox(height: 34),
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
                      childrenPadding: const EdgeInsets.only(bottom: 18),
                      iconColor: const Color(0xFF9CA3AF),
                      collapsedIconColor: const Color(0xFF9CA3AF),
                      title: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          faq[i].$1,
                          style: GoogleFonts.ibmPlexSans(color: const Color(0xFFF9FAFB), fontSize: 18, fontWeight: FontWeight.w500),
                        ),
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

class _LegalSection extends StatelessWidget {
  const _LegalSection();

  @override
  Widget build(BuildContext context) {
    return _SectionWrap(
      child: _PageContainer(
        child: Column(
          children: [
            const _Eyebrow(icon: Icons.balance_outlined, text: 'Legal'),
            const SizedBox(height: 14),
            const _SectionTitle(
              title: 'Privacy / Termini / Cookie',
              subtitle: 'Documentazione legale e trasparenza sul trattamento dei dati.',
            ),
            const SizedBox(height: 34),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 840),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF1F2937)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: const [
                        _LegalTab(text: 'Privacy Policy', active: true),
                        _LegalTab(text: 'Termini di servizio'),
                        _LegalTab(text: 'Cookie Policy'),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Ultimo aggiornamento: 2026-01-01',
                      style: GoogleFonts.ibmPlexSans(color: const Color(0xFF9CA3AF), fontSize: 13),
                    ),
                    const SizedBox(height: 18),
                    ...const [
                      _LegalBlock(
                        title: '1. Raccolta e utilizzo dei dati',
                        text:
                            'Questo e un documento di esempio per illustrare l\'impaginazione. In produzione conterra i dettagli completi sul trattamento dei dati secondo il GDPR.',
                      ),
                      _LegalBlock(
                        title: '2. Sicurezza delle informazioni',
                        text:
                            'FabricOS adotta misure di sicurezza industry-standard (crittografia AES-256 at rest, TLS 1.3 in transit) per proteggere i dati sensibili.',
                      ),
                      _LegalBlock(
                        title: '3. Diritti dell\'utente',
                        text:
                            'Gli amministratori possono richiedere esportazione completa o eliminazione definitiva dei dati del tenant secondo policy contrattuali.',
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegalTab extends StatelessWidget {
  const _LegalTab({required this.text, this.active = false});
  final String text;
  final bool active;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF111827) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF1F2937)),
      ),
      child: Text(
        text,
        style: GoogleFonts.ibmPlexSans(
          color: active ? const Color(0xFFF9FAFB) : const Color(0xFF9CA3AF),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _LegalBlock extends StatelessWidget {
  const _LegalBlock({required this.title, required this.text});
  final String title;
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.spaceGrotesk(color: const Color(0xFFF9FAFB), fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: GoogleFonts.ibmPlexSans(color: const Color(0xFF9CA3AF), fontSize: 15, height: 1.6),
          ),
        ],
      ),
    );
  }
}

class _FinalCtaSection extends StatelessWidget {
  const _FinalCtaSection({required this.onStartTrial, required this.onContact});
  final VoidCallback onStartTrial;
  final VoidCallback onContact;

  @override
  Widget build(BuildContext context) {
    return _SectionWrap(
      alt: true,
      padding: const EdgeInsets.fromLTRB(0, 90, 0, 130),
      child: _PageContainer(
        child: Column(
          children: [
            const _SectionTitle(
              title: 'Modernizza le tue operations nel 2026',
              subtitle: '',
            ),
            const SizedBox(height: 30),
            Wrap(
              spacing: 14,
              runSpacing: 14,
              alignment: WrapAlignment.center,
              children: [
                FilledButton(
                  onPressed: onStartTrial,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Attiva trial ->'),
                ),
                OutlinedButton(
                  onPressed: onContact,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFF9FAFB),
                    side: const BorderSide(color: Color(0xFF1F2937)),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Parla con un esperto'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
