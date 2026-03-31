// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Web: redirects the current tab to the given URL.
Future<void> redirectToUrl(String url) async {
  html.window.location.href = url;
}
