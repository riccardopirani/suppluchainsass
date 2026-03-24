import 'package:flutter/material.dart';

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        'How does predictive maintenance work in the MVP?',
        'FabricOS combines telemetry snapshots and maintenance history to generate a failure-risk score with placeholder AI logic.',
      ),
      (
        'Can we manage multiple plants or teams?',
        'Yes. FabricOS uses a multi-tenant company workspace model and role-based access (Admin, Manager, Operator).',
      ),
      (
        'Do you support compliance exports?',
        'Yes. ESG reports can be generated and exported as PDF in the reports module.',
      ),
      (
        'Is realtime included?',
        'Yes. Alerts and machine status updates are delivered in realtime through Supabase.',
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Frequently Asked Questions',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 20),
              ...items.map(
                (item) => ExpansionTile(
                  title: Text(item.$1),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Text(item.$2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
