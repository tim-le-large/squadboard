import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/ticket_status.dart';
import '../repositories/auth_repository.dart';
import '../repositories/chat_repository.dart';
import '../repositories/ticket_repository.dart';

/// Ensures the shared demo account has a workspace with sample tickets and chat.
class DemoSeedRepository {
  DemoSeedRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Future<void> ensureDemoReady({
    required String userId,
    required String displayName,
    required WorkspaceRepository workspaceRepo,
    required TicketRepository ticketRepo,
    required ChatRepository chatRepo,
  }) async {
    final userRef = _firestore.collection('users').doc(userId);
    final userDoc = await userRef.get();
    final workspaceId = userDoc.data()?['workspaceId'] as String?;

    String activeWorkspaceId;
    if (workspaceId == null) {
      final workspace = await workspaceRepo.createWorkspace(
        userId: userId,
        name: 'Demo Team',
      );
      activeWorkspaceId = workspace.id;
    } else {
      activeWorkspaceId = workspaceId;
    }

    final tickets = await ticketRepo
        .watchTickets(activeWorkspaceId)
        .first
        .timeout(const Duration(seconds: 10));

    if (tickets.isNotEmpty) return;

    final now = DateTime.now();
    final demoTickets = [
      (
        title: 'Welcome to SquadBoard',
        description: 'Drag tickets between columns. Open one to add comments.',
        status: TicketStatus.todo,
        priority: TicketPriority.high,
        position: 0,
      ),
      (
        title: 'Design landing page',
        description: 'Hero section + project cards for lelarge.dev',
        status: TicketStatus.inProgress,
        priority: TicketPriority.medium,
        position: 0,
      ),
      (
        title: 'Ship v1 to GitHub Pages',
        description: 'CI build with dart-define secrets',
        status: TicketStatus.done,
        priority: TicketPriority.low,
        position: 0,
      ),
    ];

    for (final demo in demoTickets) {
      await _firestore
          .collection('workspaces')
          .doc(activeWorkspaceId)
          .collection('tickets')
          .add({
        'title': demo.title,
        'description': demo.description,
        'status': demo.status.value,
        'priority': demo.priority.value,
        'position': demo.position,
        'createdBy': userId,
        'assigneeId': userId,
        'assigneeName': displayName,
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      });
    }

    final messages = [
      'Welcome to the shared demo workspace 👋',
      'Try the Board tab — drag cards between columns.',
      'This chat updates in real time for all demo visitors.',
    ];

    for (final body in messages) {
      await chatRepo.sendMessage(
        workspaceId: activeWorkspaceId,
        userId: userId,
        userName: displayName,
        body: body,
      );
    }
  }
}
