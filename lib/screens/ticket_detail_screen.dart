import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/ticket.dart';
import '../models/ticket_status.dart';
import '../models/ticket_comment.dart';
import '../models/workspace.dart';
import '../providers/core_providers.dart';
import '../providers/tickets_provider.dart';
import '../widgets/priority_badge.dart';

final ticketCommentsProvider = StreamProvider.family<
    List<TicketComment>,
    ({String workspaceId, String ticketId})>((ref, params) {
  return ref.watch(commentRepositoryProvider).watchComments(
        workspaceId: params.workspaceId,
        ticketId: params.ticketId,
      );
});

class TicketDetailScreen extends ConsumerStatefulWidget {
  const TicketDetailScreen({
    super.key,
    required this.workspace,
    required this.ticket,
  });

  final Workspace workspace;
  final Ticket ticket;

  @override
  ConsumerState<TicketDetailScreen> createState() =>
      _TicketDetailScreenState();
}

class _TicketDetailScreenState extends ConsumerState<TicketDetailScreen> {
  late Ticket _ticket;
  final _commentController = TextEditingController();
  final _dateFormat = DateFormat('dd.MM.yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    _ticket = widget.ticket;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _updateStatus(TicketStatus? status) async {
    if (status == null || status == _ticket.status) return;
    final updated = _ticket.copyWith(status: status, updatedAt: DateTime.now());
    await ref.read(ticketActionsProvider).update(updated);
    setState(() => _ticket = updated);
  }

  Future<void> _updatePriority(TicketPriority? priority) async {
    if (priority == null || priority == _ticket.priority) return;
    final updated =
        _ticket.copyWith(priority: priority, updatedAt: DateTime.now());
    await ref.read(ticketActionsProvider).update(updated);
    setState(() => _ticket = updated);
  }

  Future<void> _addComment() async {
    final body = _commentController.text.trim();
    if (body.isEmpty) return;

    final user = ref.read(authRepositoryProvider).currentUser;
    final appUser = ref.read(appUserProvider).valueOrNull;
    if (user == null) return;

    await ref.read(commentRepositoryProvider).addComment(
          workspaceId: widget.workspace.id,
          ticketId: _ticket.id,
          userId: user.uid,
          userName: appUser?.displayName ?? 'User',
          body: body,
        );
    _commentController.clear();
  }

  Future<void> _deleteTicket() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete ticket?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(ticketActionsProvider).delete(_ticket);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(
      ticketCommentsProvider((
        workspaceId: widget.workspace.id,
        ticketId: _ticket.id,
      )),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticket'),
        actions: [
          IconButton(
            onPressed: _deleteTicket,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  _ticket.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                if (_ticket.description.isNotEmpty)
                  Text(
                    _ticket.description,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    PriorityBadge(priority: _ticket.priority),
                    const SizedBox(width: 12),
                    if (_ticket.assigneeName != null)
                      Chip(
                        avatar: const Icon(Icons.person, size: 16),
                        label: Text(_ticket.assigneeName!),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<TicketStatus>(
                        value: _ticket.status,
                        decoration: const InputDecoration(labelText: 'Status'),
                        items: TicketStatus.values
                            .map(
                              (s) => DropdownMenuItem(
                                value: s,
                                child: Text(s.label),
                              ),
                            )
                            .toList(),
                        onChanged: _updateStatus,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<TicketPriority>(
                        value: _ticket.priority,
                        decoration:
                            const InputDecoration(labelText: 'Priority'),
                        items: TicketPriority.values
                            .map(
                              (p) => DropdownMenuItem(
                                value: p,
                                child: Text(p.label),
                              ),
                            )
                            .toList(),
                        onChanged: _updatePriority,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Comments',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                commentsAsync.when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (error, _) => Text('Comments error: $error'),
                  data: (comments) {
                    if (comments.isEmpty) {
                      return Text(
                        'No comments yet.',
                        style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      );
                    }
                    return Column(
                      children: comments.map((comment) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            child: Text(
                              comment.userName.substring(0, 1).toUpperCase(),
                            ),
                          ),
                          title: Text(comment.userName),
                          subtitle: Text(comment.body),
                          trailing: Text(
                            _dateFormat.format(comment.createdAt),
                            style: const TextStyle(fontSize: 11),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: 'Add a comment…',
                      ),
                      onSubmitted: (_) => _addComment(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _addComment,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
