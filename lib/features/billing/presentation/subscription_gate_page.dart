import 'package:fabricos/config/env.dart';
import 'package:fabricos/config/plan_catalog.dart';
import 'package:fabricos/config/stripe_plans.dart';
import 'package:fabricos/features/app_shell/providers/fabricos_provider.dart';
import 'package:fabricos/localization/app_localizations.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class SubscriptionGatePage extends ConsumerStatefulWidget {
  const SubscriptionGatePage({super.key});

  @override
  ConsumerState<SubscriptionGatePage> createState() =>
      _SubscriptionGatePageState();
}

class _SubscriptionGatePageState extends ConsumerState<SubscriptionGatePage> {
  bool _busy = false;

  String _appOrigin() {
    if (kIsWeb) {
      final uri = Uri.base;
      if (uri.hasScheme && uri.host.isNotEmpty) {
        final port = uri.hasPort ? ':${uri.port}' : '';
        return '${uri.scheme}://${uri.host}$port';
      }
    }

    return ref.read(envProvider).appBaseUrl.replaceAll(RegExp(r'/$'), '');
  }

  Future<void> _openRenewal(BuildContext context, BillingStatus billing) async {
    setState(() => _busy = true);
    try {
      final router = GoRouter.of(context);
      final companyId = await ref.read(currentCompanyIdProvider.future);
      final repo = ref.read(fabricosRepositoryProvider);
      final origin = _appOrigin();

      if (billing.resolvedTier == SubscriptionPlanTier.enterprise) {
        if (mounted) {
          router.go('/contact');
        }
        return;
      }

      try {
        final portalUrl = await repo.createPortalSession(
          companyId: companyId,
          returnUrl: '$origin/app/billing?renewed=true',
        );
        if (portalUrl != null) {
          await launchUrl(
            Uri.parse(portalUrl),
            mode: LaunchMode.externalApplication,
          );
          return;
        }
      } catch (_) {
        // Fall back to Checkout if the customer portal is not available yet.
      }

      final checkoutUrl = await repo.createCheckoutSession(
        companyId: companyId,
        quantity: 1,
        unitAmountCents: PlanCheckoutPricing.unitAmountCents(
          billing.resolvedTier,
          annual: false,
        ),
        trialDays: 0,
        successUrl: '$origin/app/billing?renewed=true',
        cancelUrl: '$origin/app/billing?renewed=false',
      );
      if (checkoutUrl != null) {
        await launchUrl(
          Uri.parse(checkoutUrl),
          mode: LaunchMode.externalApplication,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final billingAsync = ref.watch(billingStatusProvider);
    final userAsync = ref.watch(fabricUserContextProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF050914),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: billingAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Card(
                  color: const Color(0xFF0F172A),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      '$error',
                      style: const TextStyle(color: Color(0xFFF9FAFB)),
                    ),
                  ),
                ),
                data: (billing) {
                  final expired = billing.isExpiredTrial;
                  final trialEnds =
                      billing.trialEndsAt
                          ?.toLocal()
                          .toString()
                          .split(' ')
                          .first ??
                      '';

                  return DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFF1F2937)),
                      gradient: const LinearGradient(
                        colors: [Color(0xF20F172A), Color(0xEE030712)],
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x66000000),
                          blurRadius: 32,
                          offset: Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              color: const Color(0x142563EB),
                            ),
                            child: Text(
                              'FabricOS',
                              style: GoogleFonts.ibmPlexSans(
                                color: const Color(0xFF2563EB),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            expired
                                ? l10n.t('billing_trial_expired_title')
                                : l10n.t('billing_required_title'),
                            style: GoogleFonts.spaceGrotesk(
                              color: const Color(0xFFF9FAFB),
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            expired
                                ? '${l10n.t('billing_trial_expired_subtitle')}${trialEnds.isEmpty ? '' : ' $trialEnds.'}'
                                : l10n.t('billing_required_subtitle'),
                            style: GoogleFonts.ibmPlexSans(
                              color: const Color(0xFF9CA3AF),
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                          if (expired) ...[
                            const SizedBox(height: 12),
                            userAsync.when(
                              data: (userCtx) => Text(
                                '${l10n.t('billing_renewal_email_notice')} ${userCtx.email}',
                                style: GoogleFonts.ibmPlexSans(
                                  color: const Color(0xFFCBD5E1),
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                              loading: () => const SizedBox.shrink(),
                              error: (_, __) => const SizedBox.shrink(),
                            ),
                          ],
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: _busy
                                  ? null
                                  : () => _openRenewal(context, billing),
                              child: _busy
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      billing.resolvedTier ==
                                              SubscriptionPlanTier.enterprise
                                          ? l10n.t('contact_sales')
                                          : l10n.t('billing_renew_with_stripe'),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => context.go('/pricing'),
                              child: Text(l10n.t('view_plans')),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: () => context.go('/app/billing'),
                            child: Text(
                              l10n.t('billing_open_page'),
                              style: const TextStyle(color: Color(0xFF93C5FD)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
