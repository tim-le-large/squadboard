import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ticket_status.dart';
import '../models/workspace.dart';
import '../providers/core_providers.dart';
import '../providers/tickets_provider.dart';

class AddTicketSheet extends ConsumerStatefulWidget {
  const AddTicketSheet({super.key, required this.workspace});

  final Workspace workspace;

  @override
  ConsumerState<AddTicketSheet> createState() => _AddTicketSheetState();
}

class _AddTicketSheetState extends ConsumerState<AddTicketSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  TicketPriority _priority = TicketPriority.medium;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final user = ref.read(authRepositoryProvider).currentUser;
    final appUser = ref.read(appUserProvider).valueOrNull;
    if (user == null) return;

    setState(() => _isSaving = true);

    try {
      await ref.read(ticketActionsProvider).create(
            workspaceId: widget.workspace.id,
            title: title,
            description: _descriptionController.text.trim(),
            priority: _priority,
            createdBy: user.uid,
            assigneeId: user.uid,
            assigneeName: appUser?.displayName,
          );
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'New ticket',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<TicketPriority>(
            value: _priority,
            decoration: const InputDecoration(labelText: 'Priority'),
            items: TicketPriority.values
                .map(
                  (p) => DropdownMenuItem(value: p, child: Text(p.label)),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _priority = value);
            },
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Create ticket'),
          ),
        ],
      ),
    );
  }
}
