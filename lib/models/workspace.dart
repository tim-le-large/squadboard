import 'package:cloud_firestore/cloud_firestore.dart';

class Workspace {
  const Workspace({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.memberIds,
    required this.inviteCode,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String ownerId;
  final List<String> memberIds;
  final String inviteCode;
  final DateTime createdAt;

  factory Workspace.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Workspace(
      id: doc.id,
      name: data['name'] as String? ?? 'Workspace',
      ownerId: data['ownerId'] as String? ?? '',
      memberIds: List<String>.from(data['memberIds'] as List? ?? []),
      inviteCode: data['inviteCode'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'ownerId': ownerId,
        'memberIds': memberIds,
        'inviteCode': inviteCode,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
