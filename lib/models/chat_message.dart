import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.workspaceId,
    required this.userId,
    required this.userName,
    required this.body,
    required this.createdAt,
  });

  final String id;
  final String workspaceId;
  final String userId;
  final String userName;
  final String body;
  final DateTime createdAt;

  factory ChatMessage.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String workspaceId,
  ) {
    final data = doc.data()!;
    return ChatMessage(
      id: doc.id,
      workspaceId: workspaceId,
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? 'User',
      body: data['body'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'userName': userName,
        'body': body,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
