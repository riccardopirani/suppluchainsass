import 'package:url_launcher/url_launcher.dart';

/// Non-web fallback: opens in external browser.
Future<void> redirectToUrl(String url) async {
  await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
}
