import 'package:cloud_firestore/cloud_firestore.dart';

class TicketComment {
  const TicketComment({
    required this.id,
    required this.ticketId,
    required this.userId,
    required this.userName,
    required this.body,
    required this.createdAt,
  });

  final String id;
  final String ticketId;
  final String userId;
  final String userName;
  final String body;
  final DateTime createdAt;

  factory TicketComment.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String ticketId,
  ) {
    final data = doc.data()!;
    return TicketComment(
      id: doc.id,
      ticketId: ticketId,
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
