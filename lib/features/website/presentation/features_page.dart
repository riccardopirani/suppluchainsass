import 'package:flutter/material.dart';

class FeaturesPage extends StatelessWidget {
  const FeaturesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final features = <({String title, String description})>[
      (
        title: 'Predictive Maintenance',
        description:
            'Machine registry, maintenance logs, IoT telemetry simulation and AI risk scoring.',
      ),
      (
        title: 'Orders & Supply Chain',
        description:
            'CRUD orders with lifecycle states, delay detection and proactive risk alerts.',
      ),
      (
        title: 'Supplier Monitoring',
        description:
            'Reliability and compliance dashboards with supplier-level risk indicators.',
      ),
      (
        title: 'ESG / Compliance',
        description:
            'Monthly report generation for emissions and supplier compliance with PDF export.',
      ),
      (
        title: 'Realtime Operations',
        description:
            'Live updates for machine status and AI alerts with Supabase Realtime.',
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FabricOS Features',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 12),
              Text(
                'A modular operations platform for manufacturing teams, designed to scale from first rollout to full production.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 28),
              ...features.map(
                (feature) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(feature.title),
                    subtitle: Text(feature.description),
                    leading: const Icon(Icons.check_circle_outline),
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
