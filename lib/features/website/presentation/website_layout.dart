import 'package:fabricos/features/website/presentation/widgets/exit_intent/exit_intent.dart';
import 'package:fabricos/features/website/presentation/widgets/website_nav_bar.dart';
import 'package:flutter/material.dart';

class WebsiteLayout extends StatelessWidget {
  const WebsiteLayout({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030712),
      body: wrapWebsiteExitIntent(
        child: Column(
          children: [
            const WebsiteNavBar(),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
