/// Public demo account credentials via `--dart-define` or `dart_defines.json`.
/// Create the user once in Firebase Auth — not a secret for portfolio demos.
abstract final class DemoConfig {
  static String get email => const String.fromEnvironment('DEMO_EMAIL');

  static String get password => const String.fromEnvironment('DEMO_PASSWORD');

  static bool get isConfigured => email.isNotEmpty && password.isNotEmpty;
}
