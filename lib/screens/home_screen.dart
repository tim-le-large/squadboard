import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/core_providers.dart';
import 'board_screen.dart';
import 'chat_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
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
