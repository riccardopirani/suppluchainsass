import 'package:fabricos/features/website/presentation/widgets/website_footer.dart';
import 'package:fabricos/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class FactoryAuditPage extends StatefulWidget {
  const FactoryAuditPage({super.key});

  @override
  State<FactoryAuditPage> createState() => _FactoryAuditPageState();
}

class _FactoryAuditPageState extends State<FactoryAuditPage> {
  int _step = 0;
  int _score = 50;

  static const _questions = [
    _AuditQ('How do you track downtime today?', ['Spreadsheets', 'MES only', 'Realtime OS']),
    _AuditQ('Supplier visibility?', ['Email', 'Portal', 'Scorecards + alerts']),
    _AuditQ('Inventory policy?', ['Ad hoc', 'ROP in ERP', 'Automated + ABC']),
  ];

  void _next(int delta) {
    setState(() {
      _score = (_score + delta).clamp(35, 92);
      if (_step < _questions.length - 1) {
        _step++;
      } else {
        _step = _questions.length;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      color: const Color(0xFF030712),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 80),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    children: [
                      Text(
                        l10n.t('pub_audit_hero'),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.spaceGrotesk(
                          color: const Color(0xFFF9FAFB),
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.t('pub_audit_sub'),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.ibmPlexSans(color: const Color(0xFF9CA3AF), fontSize: 16, height: 1.5),
                      ),
                      const SizedBox(height: 36),
                      if (_step < _questions.length) ...[
                        Text(
                          _questions[_step].prompt,
                          style: GoogleFonts.spaceGrotesk(color: const Color(0xFFF9FAFB), fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 20),
                        ...List.generate(_questions[_step].options.length, (i) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () => _next(6 + i * 4),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFFEAF2FF),
                                  side: const BorderSide(color: Color(0xFF1F2937)),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: Text(_questions[_step].options[i]),
                              ),
                            ),
                          );
                        }),
                      ] else ...[
                        Text(
                          'Your FactoryOps maturity score',
                          style: GoogleFonts.ibmPlexSans(color: const Color(0xFF9CA3AF)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$_score / 100',
                          style: GoogleFonts.spaceGrotesk(
                            color: const Color(0xFF34D399),
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'FabricOS typically lifts this score in 30 days by centralizing telemetry, suppliers and inventory signals.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.ibmPlexSans(color: const Color(0xFF9CA3AF), height: 1.5),
                        ),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: () => context.go('/contact'),
                          child: Text(l10n.t('pub_mfg_cta_demo')),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const WebsiteFooter(),
          ],
        ),
      ),
    );
  }
}

class _AuditQ {
  const _AuditQ(this.prompt, this.options);
  final String prompt;
  final List<String> options;
}
