import 'package:flutter/material.dart';
import 'package:fabricos/features/website/presentation/widgets/website_nav_bar.dart';

class WebsiteLayout extends StatelessWidget {
  const WebsiteLayout({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030712),
      body: Column(
        children: [
          const WebsiteNavBar(),
          Expanded(child: child),
        ],
      ),
    );
  }
}
