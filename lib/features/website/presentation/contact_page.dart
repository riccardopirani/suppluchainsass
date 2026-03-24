import 'package:fabricos/features/website/presentation/widgets/marketing_page_widgets.dart';
import 'package:fabricos/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MarketingPageIntro(
            eyebrow: l10n.t('pub_contact_eyebrow'),
            title: l10n.t('pub_contact_title'),
            subtitle: l10n.t('pub_contact_subtitle'),
          ),
          MarketingBody(
            maxWidth: 620,
            child: MarketingGlassPanel(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.t('pub_contact_form_title'),
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.t('pub_contact_form_lead'),
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 14,
                        color: scheme.onSurfaceVariant,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      decoration: InputDecoration(labelText: l10n.t('pub_contact_name')),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? l10n.t('pub_contact_err_required') : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      decoration: InputDecoration(labelText: l10n.t('pub_contact_email')),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return l10n.t('pub_contact_err_required');
                        if (!v.contains('@')) return l10n.t('pub_contact_err_email');
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      decoration: InputDecoration(labelText: l10n.t('pub_contact_company')),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: l10n.t('pub_contact_message'),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.t('pub_contact_snackbar')),
                              ),
                            );
                          }
                        },
                        child: Text(
                          l10n.t('pub_contact_send'),
                          style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
