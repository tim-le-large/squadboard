import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/ticket_comment.dart';

class CommentRepository {
  CommentRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _comments(
    String workspaceId,
    String ticketId,
  ) =>
      _firestore
          .collection('workspaces')
          .doc(workspaceId)
          .collection('tickets')
          .doc(ticketId)
          .collection('comments');

  Stream<List<TicketComment>> watchComments({
    required String workspaceId,
    required String ticketId,
  }) {
    return _comments(workspaceId, ticketId)
        .orderBy('createdAt')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TicketComment.fromFirestore(doc, ticketId))
            .toList());
  }

  Future<void> addComment({
    required String workspaceId,
    required String ticketId,
    required String userId,
    required String userName,
    required String body,
  }) async {
    await _comments(workspaceId, ticketId).add({
      'userId': userId,
      'userName': userName,
      'body': body,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
