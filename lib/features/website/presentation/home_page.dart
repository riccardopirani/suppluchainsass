import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stockguard_ai/localization/app_localizations.dart';
import 'package:stockguard_ai/core/theme/app_colors.dart';
import 'package:stockguard_ai/core/theme/app_dimensions.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradient = isDark ? AppColorsDark.heroGradient : AppColorsLight.heroGradient;

    return SingleChildScrollView(
      child: Column(
        children: [
          _HeroSection(gradient: gradient),
          const SizedBox(height: 72),
          _SocialProofSection(),
          const SizedBox(height: 72),
          _ProblemSection(),
          const SizedBox(height: 72),
          _SolutionSection(),
          const SizedBox(height: 72),
          _FeatureSection(l10n: l10n),
          const SizedBox(height: 72),
          _PricingPreview(l10n: l10n),
          const SizedBox(height: 72),
          _FinalCta(l10n: l10n),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

/// 1. Hero: headline forte, subheadline, CTA primaria + secondaria, visual prodotto
class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.gradient});

  final LinearGradient gradient;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(gradient: gradient),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 56),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        l10n.t('tagline'),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.95),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ).animate().fadeIn().slideY(begin: 0.2, end: 0, curve: Curves.easeOut),
                    const SizedBox(height: 28),
                    Text(
                      l10n.t('hero_headline_benefit'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        letterSpacing: -0.5,
                      ),
                    ).animate().fadeIn(delay: 80.ms).slideY(begin: 0.12, end: 0, curve: Curves.easeOut),
                    const SizedBox(height: 20),
                    Text(
                      l10n.t('hero_subheadline_one_line'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontSize: 19,
                        height: 1.5,
                      ),
                    ).animate().fadeIn(delay: 160.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOut),
                    const SizedBox(height: 40),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 14,
                      runSpacing: 14,
                      children: [
                        FilledButton(
                          onPressed: () => context.go('/register'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF0F172A),
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                            textStyle: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          child: Text(l10n.t('cta_try_free')),
                        ).animate().fadeIn(delay: 240.ms).scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),
                        FilledButton(
                          onPressed: () => context.go('/contact'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                            side: const BorderSide(color: Colors.white70),
                          ),
                          child: Text(l10n.t('cta_book_demo')),
                        ).animate().fadeIn(delay: 280.ms).scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),
                        OutlinedButton(
                          onPressed: () => context.go('/register'),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white54),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          ),
                          child: Text(l10n.t('cta_start_now')),
                        ).animate().fadeIn(delay: 320.ms).scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 20,
                      runSpacing: 12,
                      children: [
                        TextButton.icon(
                          onPressed: () => context.go('/contact'),
                          icon: Icon(Icons.play_circle_outline, size: 20, color: Colors.white.withValues(alpha: 0.9)),
                          label: Text(l10n.t('cta_watch_demo'), style: TextStyle(color: Colors.white.withValues(alpha: 0.9))),
                        ),
                        TextButton.icon(
                          onPressed: () => context.go('/features'),
                          icon: Icon(Icons.help_outline_rounded, size: 20, color: Colors.white.withValues(alpha: 0.9)),
                          label: Text(l10n.t('cta_see_how'), style: TextStyle(color: Colors.white.withValues(alpha: 0.9))),
                        ),
                      ],
                    ).animate().fadeIn(delay: 360.ms),
                    const SizedBox(height: 56),
                    _ProductVisual(context: context),
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

/// Visual del prodotto: mockup dashboard
class _ProductVisual extends StatelessWidget {
  const _ProductVisual({required this.context});

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Container(
      height: 380,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 48,
            offset: const Offset(0, 24),
          ),
        ],
        border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        child: Container(
          color: theme.colorScheme.surface,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: Colors.orange.shade300, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: Colors.green.shade400, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 24),
                  Text(
                    '${l10n.t('app_name')} — ${l10n.t('dashboard_title')}',
                    style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: List.generate(
                  4,
                  (i) => Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      height: 72,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              [l10n.t('products_at_risk'), l10n.t('overstocked'), l10n.t('reorder_today'), l10n.t('inventory_value')][i],
                              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              ['12', '5', '8', '€124k'][i],
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Table(
                    columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(1), 2: FlexColumnWidth(1), 3: FlexColumnWidth(1)},
                    children: [
                      TableRow(
                        children: [
                          _tableCell(context, l10n.t('sku'), true),
                          _tableCell(context, l10n.t('current_stock'), true),
                          _tableCell(context, l10n.t('recommended'), true),
                          _tableCell(context, l10n.t('status'), true),
                        ],
                      ),
                      ...List.generate(4, (i) => TableRow(
                        children: [
                          _tableCell(context, 'SKU-${1001 + i}'),
                          _tableCell(context, '${45 - i * 10}'),
                          _tableCell(context, '${80 + i * 15}'),
                          _tableCell(context, i == 0 ? l10n.t('status_critical') : (i == 1 ? l10n.t('status_attention') : l10n.t('status_safe'))),
                        ],
                      )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.15, end: 0, curve: Curves.easeOut);
  }

  Widget _tableCell(BuildContext context, String text, [bool isHeader = false]) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: isHeader ? FontWeight.w600 : FontWeight.normal,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// 2. Social proof: loghi, metriche, testimonial
class _SocialProofSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            l10n.t('social_proof_title'),
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (i) => Container(
                width: 100,
                height: 44,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    ['Acme', 'Retail+', 'SupplyCo', 'Logix', 'Trade'][i],
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 16,
            children: [
              _MetricPill(label: l10n.t('social_proof_metric_stockout'), icon: Icons.trending_down_rounded),
              _MetricPill(label: l10n.t('social_proof_metric_forecast'), icon: Icons.trending_up_rounded),
              _MetricPill(label: l10n.t('social_proof_metric_cash'), icon: Icons.savings_outlined),
              _MetricPill(label: l10n.t('social_proof_companies'), icon: Icons.business_rounded),
            ],
          ),
          const SizedBox(height: 40),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 700;
              return isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _TestimonialCard(quote: l10n.t('testimonial_1'), author: l10n.t('testimonial_1_author'))),
                        const SizedBox(width: 24),
                        Expanded(child: _TestimonialCard(quote: l10n.t('testimonial_2'), author: l10n.t('testimonial_2_author'))),
                      ],
                    )
                  : Column(
                      children: [
                        _TestimonialCard(quote: l10n.t('testimonial_1'), author: l10n.t('testimonial_1_author')),
                        const SizedBox(height: 20),
                        _TestimonialCard(quote: l10n.t('testimonial_2'), author: l10n.t('testimonial_2_author')),
                      ],
                    );
            },
          ),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Text(label, style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  const _TestimonialCard({required this.quote, required this.author});

  final String quote;
  final String author;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.format_quote_rounded, size: 32, color: theme.colorScheme.primary.withValues(alpha: 0.6)),
          const SizedBox(height: 12),
          Text(
            quote,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.55),
          ),
          const SizedBox(height: 16),
          Text(
            author,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

/// 3. Problema: "Ti riconosci?" — 4 problemi reali del target
class _ProblemSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            l10n.t('problem_title'),
            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.t('problem_subtitle'),
            style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          LayoutBuilder(
            builder: (context, constraints) {
              return Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: [
                  _ProblemCard(
                    icon: Icons.remove_shopping_cart,
                    title: l10n.t('problem_1_title'),
                    desc: l10n.t('problem_1_desc'),
                  ),
                  _ProblemCard(
                    icon: Icons.lock_clock_rounded,
                    title: l10n.t('problem_2_title'),
                    desc: l10n.t('problem_2_desc'),
                  ),
                  _ProblemCard(
                    icon: Icons.table_chart_outlined,
                    title: l10n.t('problem_3_title'),
                    desc: l10n.t('problem_3_desc'),
                  ),
                  _ProblemCard(
                    icon: Icons.schedule_rounded,
                    title: l10n.t('problem_4_title'),
                    desc: l10n.t('problem_4_desc'),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ProblemCard extends StatelessWidget {
  const _ProblemCard({
    required this.icon,
    required this.title,
    required this.desc,
  });

  final IconData icon;
  final String title;
  final String desc;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 320,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 28, color: theme.colorScheme.error),
              ),
              const SizedBox(height: 18),
              Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Text(
                desc,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 4. Soluzione: 3 blocchi semplici
class _SolutionSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      ),
      child: Column(
        children: [
          Text(
            l10n.t('solution_title'),
            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.t('solution_subtitle'),
            style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 700;
              final children = [
                _SolutionBlock(
                  step: 1,
                  icon: Icons.visibility_rounded,
                  title: l10n.t('solution_1_title'),
                  desc: l10n.t('solution_1_desc'),
                ),
                _SolutionBlock(
                  step: 2,
                  icon: Icons.auto_awesome_rounded,
                  title: l10n.t('solution_2_title'),
                  desc: l10n.t('solution_2_desc'),
                ),
                _SolutionBlock(
                  step: 3,
                  icon: Icons.savings_rounded,
                  title: l10n.t('solution_3_title'),
                  desc: l10n.t('solution_3_desc'),
                ),
              ];
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: children
                      .map((e) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: e,
                            ),
                          ))
                      .toList(),
                );
              }
              return Column(children: children);
            },
          ),
        ],
      ),
    );
  }
}

class _SolutionBlock extends StatelessWidget {
  const _SolutionBlock({
    required this.step,
    required this.icon,
    required this.title,
    required this.desc,
  });

  final int step;
  final IconData icon;
  final String title;
  final String desc;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(icon, size: 28, color: theme.colorScheme.primary),
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$step',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            desc,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _FeatureSection extends StatelessWidget {
  const _FeatureSection({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final features = [
      (l10n.t('forecasting'), Icons.trending_up_rounded),
      ('Reorder intelligence', Icons.auto_awesome),
      ('Supplier visibility', Icons.local_shipping_rounded),
      (l10n.t('alerts'), Icons.notifications_active_rounded),
      (l10n.t('analytics'), Icons.analytics_rounded),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(l10n.t('features_section_title'), style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 32),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: features
                .map(
                  (e) => Chip(
                    avatar: Icon(e.$2, size: 20, color: Theme.of(context).colorScheme.primary),
                    label: Text(e.$1),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _PricingPreview extends StatelessWidget {
  const _PricingPreview({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(context.l10n.t('nav_pricing'), style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () => context.go('/pricing'),
          child: Text(l10n.t('view_plans')),
        ),
      ],
    );
  }
}

class _FinalCta extends StatelessWidget {
  const _FinalCta({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        children: [
          Text(
            l10n.t('final_cta_title'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => context.go('/register'),
            child: Text(l10n.t('cta_start_trial')),
          ),
        ],
      ),
    );
  }
}
