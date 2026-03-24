import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 72),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? const [Color(0xFF0F172A), Color(0xFF1F2937)]
                    : const [Color(0xFFE2E8F0), Color(0xFFBAE6FD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1080),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surface.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'FabricOS for Manufacturing (10-500 employees)',
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Run operations with AI copilots for maintenance, orders, suppliers, and ESG.',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'FabricOS helps plant and operations teams anticipate failures, reduce supplier risk, and ship compliance reports faster.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        FilledButton(
                          onPressed: () => context.go('/register'),
                          child: const Text('Start free trial'),
                        ),
                        OutlinedButton(
                          onPressed: () => context.go('/features'),
                          child: const Text('Explore platform'),
                        ),
                        TextButton(
                          onPressed: () => context.go('/contact'),
                          child: const Text('Book demo'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 36),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: const [
                            _HeroKpi(
                              label: 'Downtime risk reduction',
                              value: '-31%',
                            ),
                            _HeroKpi(
                              label: 'Delay prediction coverage',
                              value: '89%',
                            ),
                            _HeroKpi(
                              label: 'Reporting preparation time',
                              value: '-45%',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(duration: 450.ms).slideY(begin: 0.05),
          const SizedBox(height: 56),
          const _FeatureGrid(),
          const SizedBox(height: 56),
          const _UseCases(),
          const SizedBox(height: 56),
          Padding(
            padding: const EdgeInsets.only(bottom: 72),
            child: FilledButton.tonal(
              onPressed: () => context.go('/pricing'),
              child: const Text('View pricing'),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroKpi extends StatelessWidget {
  const _HeroKpi({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 210,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid();

  @override
  Widget build(BuildContext context) {
    final cards = <({IconData icon, String title, String desc, Color color})>[
      (
        icon: Icons.precision_manufacturing_outlined,
        title: 'Predictive Maintenance',
        desc:
            'AI failure-risk scoring from machine telemetry and maintenance logs.',
        color: const Color(0xFF0E7490),
      ),
      (
        icon: Icons.fact_check_outlined,
        title: 'Orders & Supply Chain',
        desc: 'Order lifecycle tracking with delay detection and risk alerts.',
        color: const Color(0xFF15803D),
      ),
      (
        icon: Icons.local_shipping_outlined,
        title: 'Supplier Monitoring',
        desc: 'Performance and reliability scorecards with risk indicators.',
        color: const Color(0xFFD97706),
      ),
      (
        icon: Icons.description_outlined,
        title: 'ESG Reporting',
        desc:
            'Generate emissions and compliance snapshots and export PDF reports.',
        color: const Color(0xFF7C3AED),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080),
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            children: cards
                .map(
                  (card) => SizedBox(
                    width: 255,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(card.icon, color: card.color),
                            const SizedBox(height: 10),
                            Text(
                              card.title,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              card.desc,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _UseCases extends StatelessWidget {
  const _UseCases();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Built for industrial operators',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'From production teams to operations managers, FabricOS centralizes execution and decisions.',
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: const [
                      Chip(label: Text('Plant Operations')),
                      Chip(label: Text('Maintenance Teams')),
                      Chip(label: Text('Supply Chain Managers')),
                      Chip(label: Text('Compliance & ESG Leads')),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
