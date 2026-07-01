import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/firebase_config.dart';
import '../providers/core_providers.dart';
import 'firebase_setup_screen.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'workspace_setup_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!FirebaseConfig.isConfigured) {
      return const FirebaseSetupScreen();
    }

    final authAsync = ref.watch(authStateProvider);

    return authAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        body: Center(child: Text('Auth error: $error')),
      ),
      data: (user) {
        if (user == null) return const LoginScreen();

        final appUserAsync = ref.watch(appUserProvider);
        return appUserAsync.when(
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => Scaffold(
            body: Center(child: Text('Profile error: $error')),
          ),
          data: (appUser) {
            if (appUser?.workspaceId == null) {
              return const WorkspaceSetupScreen();
            }
            return const HomeScreen();
          },
        );
      },
    );
  }
}
