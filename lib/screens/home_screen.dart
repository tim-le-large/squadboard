import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/core_providers.dart';
import '../services/push_notification_service.dart';
import 'board_screen.dart';
import 'chat_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _tabIndex = 0;
  bool _pushEnabled = false;
  bool _pushLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(pushNotificationServiceProvider).initialize(ref);
      final enabled =
          await ref.read(pushNotificationServiceProvider).areNotificationsEnabled();
      if (mounted) setState(() => _pushEnabled = enabled);
    });
  }

  Future<void> _togglePushNotifications() async {
    setState(() => _pushLoading = true);
    final push = ref.read(pushNotificationServiceProvider);

    try {
      if (_pushEnabled) {
        await push.removeTokenForCurrentUser();
        if (mounted) {
          setState(() => _pushEnabled = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Push notifications disabled')),
          );
        }
      } else {
        final granted = await push.requestPermissionAndSync();
        if (mounted) {
          setState(() => _pushEnabled = granted);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                granted
                    ? 'Push notifications enabled'
                    : 'Permission denied — enable in browser settings',
              ),
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _pushLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<PushBanner?>(pushBannerProvider, (previous, next) {
      if (next == null || !mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${next.title}: ${next.body}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      ref.read(pushBannerProvider.notifier).state = null;
    });

    final workspaceAsync = ref.watch(workspaceProvider);
    final appUser = ref.watch(appUserProvider).valueOrNull;

    return workspaceAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        body: Center(child: Text('Workspace error: $error')),
      ),
      data: (workspace) {
        if (workspace == null) {
          return const Scaffold(
            body: Center(child: Text('Workspace not found')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('SquadBoard'),
                Text(
                  workspace.name,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
            actions: [
              if (PushNotificationService.isAvailable)
                IconButton(
                  tooltip: _pushEnabled
                      ? 'Disable push notifications'
                      : 'Enable push notifications',
                  onPressed: _pushLoading ? null : _togglePushNotifications,
                  icon: Icon(
                    _pushEnabled
                        ? Icons.notifications_active
                        : Icons.notifications_none,
                  ),
                ),
              IconButton(
                tooltip: 'Copy invite code',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: workspace.inviteCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Invite code: ${workspace.inviteCode}'),
                    ),
                  );
                },
                icon: const Icon(Icons.link),
              ),
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'logout') {
                    if (PushNotificationService.isAvailable) {
                      await ref
                          .read(pushNotificationServiceProvider)
                          .removeTokenForCurrentUser();
                    }
                    await ref.read(authRepositoryProvider).signOut();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    enabled: false,
                    child: Text(appUser?.displayName ?? 'User'),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Text('Sign out'),
                  ),
                ],
              ),
            ],
          ),
          body: IndexedStack(
            index: _tabIndex,
            children: [
              BoardScreen(workspace: workspace),
              ChatScreen(workspace: workspace),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _tabIndex,
            onDestinationSelected: (index) => setState(() => _tabIndex = index),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.view_kanban_outlined),
                selectedIcon: Icon(Icons.view_kanban),
                label: 'Board',
              ),
              NavigationDestination(
                icon: Icon(Icons.chat_outlined),
                selectedIcon: Icon(Icons.chat),
                label: 'Chat',
              ),
            ],
          ),
        );
      },
    );
  }
}
