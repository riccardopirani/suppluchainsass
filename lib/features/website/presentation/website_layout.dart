import 'package:flutter/material.dart';
import 'package:stockguard_ai/features/website/presentation/widgets/website_nav_bar.dart';
import 'package:stockguard_ai/features/website/presentation/widgets/website_footer.dart';

class WebsiteLayout extends StatelessWidget {
  const WebsiteLayout({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const WebsiteNavBar(),
          Expanded(
            child: child,
          ),
          const WebsiteFooter(),
        ],
      ),
    );
  }
}
