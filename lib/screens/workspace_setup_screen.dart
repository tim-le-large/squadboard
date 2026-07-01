import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/core_providers.dart';

class WorkspaceSetupScreen extends ConsumerStatefulWidget {
  const WorkspaceSetupScreen({super.key});

  @override
  ConsumerState<WorkspaceSetupScreen> createState() =>
      _WorkspaceSetupScreenState();
}

class _WorkspaceSetupScreenState extends ConsumerState<WorkspaceSetupScreen> {
  final _nameController = TextEditingController();
  final _inviteController = TextEditingController();
  bool _isCreate = true;
  bool _isLoading = false;
  String? _errorMessage;
  String? _createdInviteCode;

  @override
  void dispose() {
    _nameController.dispose();
    _inviteController.dispose();
    super.dispose();
  }

  Future<void> _createWorkspace() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorMessage = 'Enter a workspace name');
      return;
    }

    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final workspace = await ref
          .read(workspaceRepositoryProvider)
          .createWorkspace(userId: user.uid, name: name);
      setState(() => _createdInviteCode = workspace.inviteCode);
    } catch (error) {
      setState(() => _errorMessage = error.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _joinWorkspace() async {
    final code = _inviteController.text.trim();
    if (code.isEmpty) {
      setState(() => _errorMessage = 'Enter invite code');
      return;
    }

    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(workspaceRepositoryProvider).joinWorkspace(
            userId: user.uid,
            inviteCode: code,
          );
    } catch (error) {
      setState(() => _errorMessage = error.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (_createdInviteCode != null) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline,
                        size: 64, color: scheme.primary),
                    const SizedBox(height: 16),
                    Text(
                      'Workspace created!',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Share this invite code with your team:',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 16),
                    SelectableText(
                      _createdInviteCode!,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            letterSpacing: 4,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(text: _createdInviteCode!));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Copied to clipboard')),
                        );
                      },
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy invite code'),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Loading workspace…',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Join your team',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create a new workspace or join with an invite code.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 24),
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: true, label: Text('Create')),
                      ButtonSegment(value: false, label: Text('Join')),
                    ],
                    selected: {_isCreate},
                    onSelectionChanged: (value) {
                      setState(() => _isCreate = value.first);
                    },
                  ),
                  const SizedBox(height: 24),
                  if (_isCreate)
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Workspace name',
                        prefixIcon: Icon(Icons.groups_outlined),
                      ),
                    )
                  else
                    TextField(
                      controller: _inviteController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'Invite code',
                        prefixIcon: Icon(Icons.vpn_key_outlined),
                      ),
                    ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(_errorMessage!, style: TextStyle(color: scheme.error)),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _isLoading
                        ? null
                        : (_isCreate ? _createWorkspace : _joinWorkspace),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_isCreate ? 'Create workspace' : 'Join workspace'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
