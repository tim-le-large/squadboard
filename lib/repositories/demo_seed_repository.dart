import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../config/demo_config.dart';
import '../data/demo_data.dart';
import 'auth_repository.dart';
import 'ticket_repository.dart';

/// Ensures the shared demo account has a workspace with rich sample data.
class DemoSeedRepository {
  DemoSeedRepository(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static const _richDemoMinTickets = 14;
  static const _demoSeedVersion = 2;

  bool get _isDemoUser {
    if (!DemoConfig.isConfigured) return false;
    return _auth.currentUser?.email == DemoConfig.email;
  }

  Future<void> ensureDemoReady({
    required String userId,
    required String displayName,
    required WorkspaceRepository workspaceRepo,
    required TicketRepository ticketRepo,
  }) async {
    if (!_isDemoUser) return;

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

    final workspaceDoc =
        await _firestore.collection('workspaces').doc(activeWorkspaceId).get();
    final seedVersion = workspaceDoc.data()?['demoSeedVersion'] as int? ?? 0;

    final tickets = await ticketRepo
        .watchTickets(activeWorkspaceId)
        .first
        .timeout(const Duration(seconds: 10));

    final needsReseed = seedVersion < _demoSeedVersion ||
        tickets.length < _richDemoMinTickets;

    if (!needsReseed) return;

    if (tickets.isNotEmpty) {
      await _clearWorkspaceContent(activeWorkspaceId);
    }

    await _seedRichWorkspace(
      workspaceId: activeWorkspaceId,
      userId: userId,
      displayName: displayName,
    );
  }

  Future<void> _clearWorkspaceContent(String workspaceId) async {
    final workspaceRef = _firestore.collection('workspaces').doc(workspaceId);

    final tickets = await workspaceRef.collection('tickets').get();
    for (final doc in tickets.docs) {
      final comments = await doc.reference.collection('comments').get();
      for (final comment in comments.docs) {
        await comment.reference.delete();
      }
      await doc.reference.delete();
    }

    final messages = await workspaceRef.collection('messages').get();
    for (final doc in messages.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> _seedRichWorkspace({
    required String workspaceId,
    required String userId,
    required String displayName,
  }) async {
    final now = DateTime.now();
    final workspaceRef = _firestore.collection('workspaces').doc(workspaceId);
    final ticketsRef = workspaceRef.collection('tickets');
    final messagesRef = workspaceRef.collection('messages');

    await workspaceRef.update({
      'memberIds': FieldValue.arrayUnion(
        demoTeamMembers.map((member) => member.seedId).toList(),
      ),
      'demoSeedVersion': _demoSeedVersion,
    });

    for (final demo in richDemoTickets) {
      final creator = resolveDemoMember(
        demo.createdByIndex,
        currentUserId: userId,
        currentUserName: displayName,
      );
      final assignee = resolveDemoMember(
        demo.assigneeIndex,
        currentUserId: userId,
        currentUserName: displayName,
      );

      final ticketRef = await ticketsRef.add({
        'title': demo.title,
        'description': demo.description,
        'status': demo.status.value,
        'priority': demo.priority.value,
        'position': demo.position,
        'createdBy': creator.id,
        'assigneeId': assignee.id,
        'assigneeName': assignee.name,
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      });

      for (final comment in demo.comments) {
        final author = resolveDemoMember(
          comment.authorIndex,
          currentUserId: userId,
          currentUserName: displayName,
        );
        await ticketRef.collection('comments').add({
          'userId': author.id,
          'userName': author.name,
          'body': comment.body,
          'createdAt': Timestamp.fromDate(now),
        });
      }
    }

    for (final message in demoChatMessages) {
      final author = resolveDemoMember(
        message.authorIndex,
        currentUserId: userId,
        currentUserName: displayName,
      );
      await messagesRef.add({
        'userId': author.id,
        'userName': author.name,
        'body': message.body,
        'createdAt': Timestamp.fromDate(
          now.subtract(Duration(minutes: message.minutesAgo)),
        ),
      });
    }
  }
}
