import 'dart:io';

/// Repo-root [.env] when running on a VM with `flutter run` from the project dir
/// (desktop / host). Ignored on device builds where [.env] is absent.
Future<String?> readRootDotenvIfPresent() async {
  try {
    final f = File('.env');
    if (await f.exists()) {
      return f.readAsString();
    }
  } catch (_) {}
  return null;
}
