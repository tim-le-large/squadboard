import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/firebase_config.dart';
import 'screens/auth_gate.dart';
import 'services/push_notification_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (FirebaseConfig.isConfigured) {
    await Firebase.initializeApp(options: FirebaseConfig.options);
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  runApp(const ProviderScope(child: SquadBoardApp()));
}

class SquadBoardApp extends StatelessWidget {
  const SquadBoardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SquadBoard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const AuthGate(),
    );
  }
}
