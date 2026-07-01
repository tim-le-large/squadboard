import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/ticket.dart';
import '../models/ticket_status.dart';

class TicketRepository {
  TicketRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _tickets(String workspaceId) =>
      _firestore.collection('workspaces').doc(workspaceId).collection('tickets');

  Stream<List<Ticket>> watchTickets(String workspaceId) {
    return _tickets(workspaceId)
        .orderBy('status')
        .orderBy('position')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Ticket.fromFirestore(doc, workspaceId))
            .toList());
  }

  Future<void> createTicket({
    required String workspaceId,
    required String title,
    required String description,
    required TicketPriority priority,
    required String createdBy,
    String? assigneeId,
    String? assigneeName,
  }) async {
    final status = TicketStatus.todo;
    final position = await _nextPosition(workspaceId, status);

    await _tickets(workspaceId).add({
      'title': title,
      'description': description,
      'status': status.value,
      'priority': priority.value,
      'position': position,
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      if (assigneeId != null) 'assigneeId': assigneeId,
      if (assigneeName != null) 'assigneeName': assigneeName,
    });
  }

  Future<void> updateTicket(Ticket ticket) async {
    await _tickets(ticket.workspaceId).doc(ticket.id).update({
      ...ticket.toFirestore(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> moveTicket({
    required Ticket ticket,
    required TicketStatus newStatus,
    required int newPosition,
  }) async {
    await _tickets(ticket.workspaceId).doc(ticket.id).update({
      'status': newStatus.value,
      'position': newPosition,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteTicket(Ticket ticket) async {
    await _tickets(ticket.workspaceId).doc(ticket.id).delete();
  }

  Future<int> _nextPosition(String workspaceId, TicketStatus status) async {
    final snapshot = await _tickets(workspaceId)
        .where('status', isEqualTo: status.value)
        .orderBy('position', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return 0;
    return (snapshot.docs.first.data()['position'] as int? ?? 0) + 1;
  }
}
