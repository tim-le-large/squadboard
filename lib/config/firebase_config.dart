import 'package:firebase_core/firebase_core.dart';

/// Firebase credentials via `--dart-define` or `dart_defines.json`.
/// Never commit real keys — use `dart_defines.example.json` as template.
class FirebaseConfig {
  static const apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const authDomain = String.fromEnvironment('FIREBASE_AUTH_DOMAIN');
  static const projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const storageBucket = String.fromEnvironment('FIREBASE_STORAGE_BUCKET');
  static const messagingSenderId =
      String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
  static const appId = String.fromEnvironment('FIREBASE_APP_ID');

  static bool get isConfigured =>
      apiKey.isNotEmpty &&
      authDomain.isNotEmpty &&
      projectId.isNotEmpty &&
      appId.isNotEmpty;

  static FirebaseOptions get options => FirebaseOptions(
        apiKey: apiKey,
        authDomain: authDomain,
        projectId: projectId,
        storageBucket: storageBucket.isNotEmpty ? storageBucket : '$projectId.appspot.com',
        messagingSenderId:
            messagingSenderId.isNotEmpty ? messagingSenderId : '0',
        appId: appId,
      );
}
