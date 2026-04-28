import 'package:fabricos/features/website/presentation/widgets/website_marketing_drawer.dart';
import 'package:fabricos/features/website/presentation/widgets/website_nav_bar.dart';
import 'package:fabricos/features/website/presentation/widgets/public_site_theme.dart';
import 'package:flutter/material.dart';

class WebsiteLayout extends StatelessWidget {
  const WebsiteLayout({super.key, required this.child});

  final Widget child;

  static const double _drawerBreakpoint = 960;

  @override
  Widget build(BuildContext context) {
    final useDrawer = MediaQuery.sizeOf(context).width < _drawerBreakpoint;
    return Theme(
      data: PublicSiteTheme.theme,
      child: Scaffold(
        backgroundColor: PublicSiteTheme.background,
        drawer: useDrawer ? const WebsiteMarketingDrawer() : null,
        body: Builder(
          builder: (scaffoldContext) {
            return Column(
              children: [
                WebsiteNavBar(
                  onOpenMobileMenu: useDrawer
                      ? () => Scaffold.of(scaffoldContext).openDrawer()
                      : null,
                ),
                Expanded(child: child),
              ],
            );
          },
        ),
      ),
    );
  }
}
