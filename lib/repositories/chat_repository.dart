import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/chat_message.dart';

class ChatRepository {
  ChatRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _messages(String workspaceId) =>
      _firestore
          .collection('workspaces')
          .doc(workspaceId)
          .collection('messages');

  Stream<List<ChatMessage>> watchMessages(String workspaceId) {
    return _messages(workspaceId)
        .orderBy('createdAt')
        .limitToLast(100)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromFirestore(doc, workspaceId))
            .toList());
  }

  Future<void> sendMessage({
    required String workspaceId,
    required String userId,
    required String userName,
    required String body,
  }) async {
    await _messages(workspaceId).add({
      'userId': userId,
      'userName': userName,
      'body': body,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
