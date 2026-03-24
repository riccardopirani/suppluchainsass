import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PricingPage extends StatelessWidget {
  const PricingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080),
          child: Column(
            children: [
              Text(
                'FabricOS Pricing',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 12),
              const Text('Simple plans for SMB manufacturing operations.'),
              const SizedBox(height: 36),
              Wrap(
                spacing: 18,
                runSpacing: 18,
                children: [
                  _PlanCard(
                    title: 'Starter',
                    price: '€149',
                    period: '/month',
                    features: const [
                      'Up to 3 users',
                      'Machines + orders modules',
                      'Basic supplier tracking',
                      'Realtime alerts',
                    ],
                    cta: 'Start trial',
                    onTap: () => context.go('/register'),
                  ),
                  _PlanCard(
                    title: 'Growth',
                    price: '€399',
                    period: '/month',
                    highlighted: true,
                    features: const [
                      'Up to 15 users',
                      'Predictive maintenance AI',
                      'Advanced supplier monitoring',
                      'ESG reporting + PDF export',
                    ],
                    cta: 'Start trial',
                    onTap: () => context.go('/register'),
                  ),
                  _PlanCard(
                    title: 'Enterprise',
                    price: 'Custom',
                    period: '',
                    features: const [
                      'Unlimited users',
                      'Custom integrations',
                      'Dedicated onboarding',
                      'Priority support',
                    ],
                    cta: 'Contact sales',
                    onTap: () => context.go('/contact'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.price,
    required this.period,
    required this.features,
    required this.cta,
    required this.onTap,
    this.highlighted = false,
  });

  final String title;
  final String price;
  final String period;
  final List<String> features;
  final String cta;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Card(
        color: highlighted
            ? Theme.of(context).colorScheme.primaryContainer
            : null,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(price, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(width: 4),
                  Text(period),
                ],
              ),
              const SizedBox(height: 16),
              ...features.map(
                (f) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.check, size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text(f)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(onPressed: onTap, child: Text(cta)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
