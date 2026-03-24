import 'package:flutter/material.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Contact FabricOS',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 12),
              const Text(
                'Tell us about your operations context and we will help you deploy FabricOS for your team.',
              ),
              const SizedBox(height: 24),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Full name'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Work email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Company'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'What do you need?',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 18),
              FilledButton(onPressed: () {}, child: const Text('Send request')),
            ],
          ),
        ),
      ),
    );
  }
}
