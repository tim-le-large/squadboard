import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.workspaceId,
    required this.createdAt,
  });

  final String id;
  final String email;
  final String displayName;
  final String? workspaceId;
  final DateTime createdAt;

  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return AppUser(
      id: doc.id,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? 'User',
      workspaceId: data['workspaceId'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'email': email,
        'displayName': displayName,
        if (workspaceId != null) 'workspaceId': workspaceId,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
